import 'package:sqflite_common/sqlite_api.dart';

import '../data/catalogue_repository.dart';
import '../data/client_repository.dart';
import '../data/documents_commerciaux_repository.dart';
import '../data/historique_repository.dart';
import '../data/parametre_repository.dart';
import '../data/tiers_repository.dart';
import '../data/vente_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/code_generator.dart';
import '../domain/fiscalite.dart';
import '../domain/models/document_commercial.dart';
import '../domain/models/panier.dart';
import '../domain/models/parametres_vente.dart';
import '../domain/models/vente.dart';
import 'vente_service.dart';

enum ErreurDocument {
  lignesVides,
  quantiteInvalide,
  prixInvalide,
  produitInconnu,
  clientInconnu,
  fournisseurInconnu,
  documentInconnu,
  nonModifiable,
  dejaAnnule,
  motifObligatoire,
  livraisonLiee,
  receptionLiee,
  rienALivrer,
  quantiteExcessive,
  livraisonExistante,
  venteInconnue,
  venteAnnulee,
  sessionRequise,
  dejaSoldee,
}

class DocumentException implements Exception {
  const DocumentException(this.erreur, [this.detail]);
  final ErreurDocument erreur;
  final String? detail;
  @override
  String toString() => 'DocumentException($erreur${detail == null ? '' : ', $detail'})';
}

/// Ligne saisie d'un document commercial (prix TTC pour un client, prix d'achat pour un fournisseur).
class DemandeLigneDocument {
  const DemandeLigneDocument({required this.produitCode, required this.quantite, required this.prix});
  final String produitCode;
  final double quantite;
  final double prix;
}

/// Devis (DEV), factures proforma (PRO), bons de commande clients (BCC) et bons de livraison (LIV).
/// Devis et proforma n'ont aucun effet sur le stock ni sur le solde ; une commande est livrée, en une ou plusieurs
/// fois, par un bon de livraison qui crée dans la MÊME transaction la vente (stock, solde, paiement éventuel).
class DocumentClientService {
  const DocumentClientService(this.db, {required this.utilisateurCode, this.parametres = const ParametresVente()});

  final Database db;
  final String utilisateurCode;
  final ParametresVente parametres;

  static String prefixe(String type) => switch (type) {
    TypesDocumentClient.devis => CodeGenerator.devis,
    TypesDocumentClient.proforma => CodeGenerator.proforma,
    _ => CodeGenerator.commandeClient,
  };

  Future<DocumentClient> creer({
    required String type,
    required String clientCode,
    required List<DemandeLigneDocument> lignes,
    DateTime? validite,
    String? observation,
    DateTime? date,
    String? origineCode,
  }) async {
    _verifier(lignes);
    return db.transaction((txn) async {
      if (await ClientRepository(txn).parCode(clientCode) == null) {
        throw const DocumentException(ErreurDocument.clientInconnu);
      }
      final code = await TiersRepository(txn).prochainCode('document_client', prefixe(type));
      await txn.insert('document_client', {
        'code': code,
        'type': type,
        'date': (date ?? DateTime.now()).toUtc().toIso8601String(),
        'client_code': clientCode,
        'validite': validite?.toUtc().toIso8601String(),
        'statut': StatutsDocumentClient.enCours,
        'origine_code': origineCode,
        'observation': _texte(observation),
        'utilisateur_code': utilisateurCode,
      });
      await _ecrireLignes(txn, code, lignes);
      await _journal(txn, 'Création', code, '$type $clientCode');
      return (await DocumentsCommerciauxRepository(txn).documentClient(code))!;
    });
  }

  /// Modifie un document en cours (pour une commande : tant que rien n'est livré).
  Future<DocumentClient> modifier(
    String code, {
    required String clientCode,
    required List<DemandeLigneDocument> lignes,
    DateTime? validite,
    String? observation,
  }) async {
    _verifier(lignes);
    return db.transaction((txn) async {
      final d = await _document(txn, code);
      if (!d.modifiable) throw const DocumentException(ErreurDocument.nonModifiable);
      if (await ClientRepository(txn).parCode(clientCode) == null) {
        throw const DocumentException(ErreurDocument.clientInconnu);
      }
      await txn.update(
        'document_client',
        {
          'client_code': clientCode,
          'validite': validite?.toUtc().toIso8601String(),
          'observation': _texte(observation),
        },
        where: 'code = ?',
        whereArgs: [code],
      );
      await txn.delete('document_client_ligne', where: 'document_code = ?', whereArgs: [code]);
      await _ecrireLignes(txn, code, lignes);
      await _journal(txn, 'Modification', code, '${d.total}');
      return (await DocumentsCommerciauxRepository(txn).documentClient(code))!;
    });
  }

  /// Devis / proforma accepté ou refusé par le client.
  Future<DocumentClient> changerStatut(String code, String statut) => db.transaction((txn) async {
    final d = await _document(txn, code);
    if (!d.actif || d.estCommande || d.statutStocke == StatutsDocumentClient.transforme) {
      throw const DocumentException(ErreurDocument.nonModifiable);
    }
    await txn.update('document_client', {'statut': statut}, where: 'code = ?', whereArgs: [code]);
    await _journal(txn, statut, code, null);
    return (await DocumentsCommerciauxRepository(txn).documentClient(code))!;
  });

  /// Devis ou proforma → bon de commande (lignes et prix repris, lien `origine_code`) ; l'origine passe
  /// « Transformé ».
  Future<DocumentClient> transformerEnCommande(String code) async {
    final d = await DocumentsCommerciauxRepository(db).documentClient(code);
    if (d == null) throw const DocumentException(ErreurDocument.documentInconnu);
    if (!d.actif ||
        d.estCommande ||
        d.statutStocke == StatutsDocumentClient.transforme ||
        d.statutStocke == StatutsDocumentClient.refuse) {
      throw const DocumentException(ErreurDocument.nonModifiable);
    }
    return db.transaction((txn) async {
      final commande = await _creerDans(
        txn,
        type: TypesDocumentClient.commande,
        clientCode: d.clientCode,
        lignes: [for (final l in d.lignes) l],
        observation: d.observation,
        origineCode: d.code,
      );
      await txn.update(
        'document_client',
        {'statut': StatutsDocumentClient.transforme},
        where: 'code = ?',
        whereArgs: [code],
      );
      await _journal(txn, 'Transformation', code, commande.code);
      return commande;
    });
  }

  Future<DocumentClient> _creerDans(
    Transaction txn, {
    required String type,
    required String clientCode,
    required List<DocumentLigne> lignes,
    String? observation,
    String? origineCode,
  }) async {
    final code = await TiersRepository(txn).prochainCode('document_client', prefixe(type));
    await txn.insert('document_client', {
      'code': code,
      'type': type,
      'date': DateTime.now().toUtc().toIso8601String(),
      'client_code': clientCode,
      'statut': StatutsDocumentClient.enCours,
      'origine_code': origineCode,
      'observation': observation,
      'utilisateur_code': utilisateurCode,
    });
    for (final (i, l) in lignes.indexed) {
      await txn.insert('document_client_ligne', {
        'document_code': code,
        'ordre': i,
        'produit_code': l.produitCode,
        'designation': l.designation,
        'quantite': l.quantite,
        'prix_unitaire': l.prixUnitaire,
        'taux_tva': l.tauxTva,
        'montant_ht': l.montantHt,
        'montant_tva': l.montantTva,
        'total': l.total,
      });
    }
    await _journal(txn, 'Création', code, '$type $clientCode');
    return (await DocumentsCommerciauxRepository(txn).documentClient(code))!;
  }

  /// Annule un document. Une commande déjà livrée (bon de livraison actif) est refusée : annuler d'abord la
  /// livraison (sa vente).
  Future<void> annuler(String code, {required String motif}) async {
    if (motif.trim().isEmpty) throw const DocumentException(ErreurDocument.motifObligatoire);
    await db.transaction((txn) async {
      final d = await _document(txn, code);
      if (!d.actif) throw const DocumentException(ErreurDocument.dejaAnnule);
      if (d.livraisons.isNotEmpty) throw const DocumentException(ErreurDocument.livraisonLiee);
      await txn.update(
        'document_client',
        {
          'actif': 0,
          'annule_par': utilisateurCode,
          'motif_annulation': motif.trim(),
          'date_annulation': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'code = ?',
        whereArgs: [code],
      );
      await _journal(txn, 'Annulation', code, motif.trim());
    });
  }

  /// Livre une commande, en tout ou en partie : [quantites] par ordre de ligne (au plus le reste à livrer).
  /// En UNE transaction : la vente (stock sorti du [magasinCode], solde du client, [paiements] éventuels, le reste
  /// à crédit) et le bon de livraison lié à la commande.
  Future<BonLivraison> livrer(
    String commandeCode, {
    required Map<int, double> quantites,
    required SessionCaisse session,
    required String magasinCode,
    List<Paiement> paiements = const [],
    bool depassementPlafond = false,
    String? observation,
  }) async {
    if (!session.estOuverte) throw const DocumentException(ErreurDocument.sessionRequise);
    return db.transaction((txn) async {
      final c = await _document(txn, commandeCode);
      if (!c.estCommande || !c.actif) throw const DocumentException(ErreurDocument.nonModifiable);
      final aLivrer = <(DocumentLigne, double)>[];
      for (final l in c.lignes) {
        final q = CalculsPrix.arrondir(quantites[l.ordre] ?? 0);
        if (q < 0) throw const DocumentException(ErreurDocument.quantiteInvalide);
        if (q > l.reste + 1e-9) throw DocumentException(ErreurDocument.quantiteExcessive, l.designation);
        if (q > 0) aLivrer.add((l, q));
      }
      if (aLivrer.isEmpty) throw const DocumentException(ErreurDocument.rienALivrer);
      final catalogue = CatalogueRepository(txn);
      final lignesPanier = <PanierLigne>[];
      for (final (l, q) in aLivrer) {
        final p = await catalogue.produitParCode(l.produitCode);
        if (p == null) throw DocumentException(ErreurDocument.produitInconnu, l.produitCode);
        lignesPanier.add(
          PanierLigne(
            produit: p,
            quantite: q,
            prixUnitaire: l.prixUnitaire,
            nombreExige: p.exigeNombre(global: parametres.nombreActif),
          ),
        );
      }
      final code = await TiersRepository(txn).prochainCode('bon_livraison', CodeGenerator.livraison);
      final vente = await VenteService(db, utilisateurCode: utilisateurCode, parametres: parametres).encaisser(
        Panier(
          id: 0,
          clientCode: c.clientCode,
          lignes: lignesPanier,
          paiements: paiements,
          commentaire: '$code · ${c.code}',
        ),
        session: session,
        magasinCode: magasinCode,
        creditAutorise: true,
        depassementPlafond: depassementPlafond,
        txn: txn,
      );
      await _ecrireLivraison(
        txn,
        code: code,
        commandeCode: c.code,
        vente: vente,
        magasinCode: magasinCode,
        observation: observation,
        lignes: [
          for (final (l, q) in aLivrer)
            BonLivraisonLigne(
              ordreCommande: l.ordre,
              produitCode: l.produitCode,
              designation: l.designation,
              quantite: q,
            ),
        ],
      );
      return (await DocumentsCommerciauxRepository(txn).livraison(code))!;
    });
  }

  /// Bon de livraison d'une vente de caisse (sans commande) : un seul par vente, reprend ses lignes.
  Future<BonLivraison> bonLivraisonPourVente(String venteCode, {String? observation}) => db.transaction((txn) async {
    final repo = DocumentsCommerciauxRepository(txn);
    final existant = await repo.livraisonDeVente(venteCode);
    if (existant != null) return existant;
    final v = await VenteRepository(txn).vente(venteCode);
    if (v == null) throw const DocumentException(ErreurDocument.venteInconnue);
    if (v.statut == StatutsVente.annulee) throw const DocumentException(ErreurDocument.venteAnnulee);
    final code = await TiersRepository(txn).prochainCode('bon_livraison', CodeGenerator.livraison);
    await _ecrireLivraison(
      txn,
      code: code,
      vente: v,
      magasinCode: v.magasinCode,
      observation: observation,
      lignes: [
        for (final l in v.lignes)
          if (l.produitCode != PanierLigne.codeMontant)
            BonLivraisonLigne(produitCode: l.produitCode, designation: l.designation, quantite: l.quantite),
      ],
    );
    return (await repo.livraison(code))!;
  });

  Future<void> _ecrireLivraison(
    Transaction txn, {
    required String code,
    String? commandeCode,
    required Vente vente,
    required String magasinCode,
    String? observation,
    required List<BonLivraisonLigne> lignes,
  }) async {
    await txn.insert('bon_livraison', {
      'code': code,
      'date': DateTime.now().toUtc().toIso8601String(),
      'commande_code': commandeCode,
      'vente_code': vente.code,
      'client_code': vente.clientCode,
      'magasin_code': magasinCode,
      'utilisateur_code': utilisateurCode,
      'observation': _texte(observation),
    });
    for (final (i, l) in lignes.indexed) {
      await txn.insert('bon_livraison_ligne', {
        'livraison_code': code,
        'ordre': i,
        'ordre_commande': l.ordreCommande,
        'produit_code': l.produitCode,
        'designation': l.designation,
        'quantite': l.quantite,
      });
    }
    await HistoriqueRepository(txn).journaliser(
      utilisateurCode: utilisateurCode,
      action: 'Livraison',
      entite: 'bon_livraison',
      entiteCode: code,
      detail: '${commandeCode ?? ''} ${vente.code}'.trim(),
    );
  }

  Future<DocumentClient> _document(Transaction txn, String code) async {
    final d = await DocumentsCommerciauxRepository(txn).documentClient(code);
    if (d == null) throw const DocumentException(ErreurDocument.documentInconnu);
    return d;
  }

  void _verifier(List<DemandeLigneDocument> lignes) {
    if (lignes.isEmpty) throw const DocumentException(ErreurDocument.lignesVides);
    for (final l in lignes) {
      if (l.quantite <= 0) throw const DocumentException(ErreurDocument.quantiteInvalide);
      if (l.prix < 0) throw const DocumentException(ErreurDocument.prixInvalide);
    }
  }

  /// Lignes au prix TTC saisi, TVA du produit selon le régime, figée et ventilée HT + TVA.
  Future<void> _ecrireLignes(Transaction txn, String code, List<DemandeLigneDocument> lignes) async {
    final regime = await ParametreRepository(txn).lire(Fiscalite.cleRegime) ?? RegimesFiscaux.reel;
    final catalogue = CatalogueRepository(txn);
    for (final (i, l) in lignes.indexed) {
      final p = await catalogue.produitParCode(l.produitCode);
      if (p == null) throw DocumentException(ErreurDocument.produitInconnu, l.produitCode);
      final total = CalculsPrix.arrondir(l.quantite * l.prix);
      final taux = Fiscalite.taux(p.tvaPct, regime);
      final v = Fiscalite.ventiler(total, taux);
      await txn.insert('document_client_ligne', {
        'document_code': code,
        'ordre': i,
        'produit_code': p.code,
        'designation': p.designation,
        'quantite': l.quantite,
        'prix_unitaire': l.prix,
        'taux_tva': taux,
        'montant_ht': v.ht,
        'montant_tva': v.tva,
        'total': total,
      });
    }
  }

  Future<void> _journal(Transaction txn, String action, String code, String? detail) => HistoriqueRepository(txn)
      .journaliser(
        utilisateurCode: utilisateurCode,
        action: action,
        entite: 'document_client',
        entiteCode: code,
        detail: detail,
      );

  static String? _texte(String? s) => (s?.trim().isEmpty ?? true) ? null : s!.trim();
}

/// Bons de commande fournisseurs (BCF) : réceptionnés en une ou plusieurs entrées (`AchatService.enregistrer`
/// avec `commandeCode`) ; quantités reçues calculées ; le reliquat peut être soldé (abandonné).
class CommandeFournisseurService {
  const CommandeFournisseurService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  Future<CommandeFournisseur> creer({
    required String fournisseurCode,
    required String magasinCode,
    required List<DemandeLigneDocument> lignes,
    DateTime? dateLivraison,
    String? besoinCode,
    String? observation,
    DateTime? date,
  }) async {
    _verifier(lignes);
    return db.transaction((txn) async {
      if (await TiersRepository(txn).fournisseur(fournisseurCode) == null) {
        throw const DocumentException(ErreurDocument.fournisseurInconnu);
      }
      final code = await TiersRepository(txn).prochainCode('commande_fournisseur', CodeGenerator.commandeFournisseur);
      await txn.insert('commande_fournisseur', {
        'code': code,
        'date': (date ?? DateTime.now()).toUtc().toIso8601String(),
        'fournisseur_code': fournisseurCode,
        'magasin_code': magasinCode,
        'date_livraison': dateLivraison?.toUtc().toIso8601String(),
        'besoin_code': besoinCode,
        'observation': DocumentClientService._texte(observation),
        'utilisateur_code': utilisateurCode,
      });
      await _ecrireLignes(txn, code, lignes);
      await _journal(txn, 'Création', code, fournisseurCode);
      return (await DocumentsCommerciauxRepository(txn).commandeFournisseur(code))!;
    });
  }

  /// Modifie une commande tant qu'aucune entrée ne l'a réceptionnée.
  Future<CommandeFournisseur> modifier(
    String code, {
    required String fournisseurCode,
    required String magasinCode,
    required List<DemandeLigneDocument> lignes,
    DateTime? dateLivraison,
    String? observation,
  }) async {
    _verifier(lignes);
    return db.transaction((txn) async {
      final c = await _commande(txn, code);
      if (!c.actif || c.soldee) throw const DocumentException(ErreurDocument.nonModifiable);
      if (c.receptions.isNotEmpty) throw const DocumentException(ErreurDocument.receptionLiee);
      if (await TiersRepository(txn).fournisseur(fournisseurCode) == null) {
        throw const DocumentException(ErreurDocument.fournisseurInconnu);
      }
      await txn.update(
        'commande_fournisseur',
        {
          'fournisseur_code': fournisseurCode,
          'magasin_code': magasinCode,
          'date_livraison': dateLivraison?.toUtc().toIso8601String(),
          'observation': DocumentClientService._texte(observation),
        },
        where: 'code = ?',
        whereArgs: [code],
      );
      await txn.delete('commande_fournisseur_ligne', where: 'commande_code = ?', whereArgs: [code]);
      await _ecrireLignes(txn, code, lignes);
      await _journal(txn, 'Modification', code, null);
      return (await DocumentsCommerciauxRepository(txn).commandeFournisseur(code))!;
    });
  }

  /// Annule une commande sans réception active (annuler d'abord les entrées liées).
  Future<void> annuler(String code, {required String motif}) async {
    if (motif.trim().isEmpty) throw const DocumentException(ErreurDocument.motifObligatoire);
    await db.transaction((txn) async {
      final c = await _commande(txn, code);
      if (!c.actif) throw const DocumentException(ErreurDocument.dejaAnnule);
      if (c.receptions.isNotEmpty) throw const DocumentException(ErreurDocument.receptionLiee);
      await txn.update(
        'commande_fournisseur',
        {
          'actif': 0,
          'annule_par': utilisateurCode,
          'motif_annulation': motif.trim(),
          'date_annulation': DateTime.now().toUtc().toIso8601String(),
        },
        where: 'code = ?',
        whereArgs: [code],
      );
      await _journal(txn, 'Annulation', code, motif.trim());
    });
  }

  /// Solde une commande partiellement reçue : le reliquat n'est plus attendu.
  Future<CommandeFournisseur> solder(String code) => db.transaction((txn) async {
    final c = await _commande(txn, code);
    if (!c.actif) throw const DocumentException(ErreurDocument.dejaAnnule);
    if (c.soldee) throw const DocumentException(ErreurDocument.dejaSoldee);
    await txn.update('commande_fournisseur', {'soldee': 1}, where: 'code = ?', whereArgs: [code]);
    await _journal(txn, 'Solde', code, null);
    return (await DocumentsCommerciauxRepository(txn).commandeFournisseur(code))!;
  });

  Future<CommandeFournisseur> _commande(Transaction txn, String code) async {
    final c = await DocumentsCommerciauxRepository(txn).commandeFournisseur(code);
    if (c == null) throw const DocumentException(ErreurDocument.documentInconnu);
    return c;
  }

  void _verifier(List<DemandeLigneDocument> lignes) {
    if (lignes.isEmpty) throw const DocumentException(ErreurDocument.lignesVides);
    for (final l in lignes) {
      if (l.quantite <= 0) throw const DocumentException(ErreurDocument.quantiteInvalide);
      if (l.prix < 0) throw const DocumentException(ErreurDocument.prixInvalide);
    }
  }

  Future<void> _ecrireLignes(Transaction txn, String code, List<DemandeLigneDocument> lignes) async {
    final catalogue = CatalogueRepository(txn);
    for (final (i, l) in lignes.indexed) {
      final p = await catalogue.produitParCode(l.produitCode);
      if (p == null) throw DocumentException(ErreurDocument.produitInconnu, l.produitCode);
      await txn.insert('commande_fournisseur_ligne', {
        'commande_code': code,
        'ordre': i,
        'produit_code': p.code,
        'designation': p.designation,
        'quantite': l.quantite,
        'prix': l.prix,
      });
    }
  }

  Future<void> _journal(Transaction txn, String action, String code, String? detail) => HistoriqueRepository(txn)
      .journaliser(
        utilisateurCode: utilisateurCode,
        action: action,
        entite: 'commande_fournisseur',
        entiteCode: code,
        detail: detail,
      );
}
