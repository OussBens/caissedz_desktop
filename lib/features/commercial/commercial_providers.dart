import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../application/document_commercial_service.dart';
import '../../application/vente_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/print/documents_pdf.dart';
import '../../data/boutique_repository.dart';
import '../../data/client_repository.dart';
import '../../data/documents_commerciaux_repository.dart';
import '../../data/tiers_repository.dart';
import '../../domain/models/document_commercial.dart';
import '../../domain/models/facture.dart';
import '../../domain/models/parametres_vente.dart';
import '../../domain/montant_en_lettres.dart';
import '../caisse/pos_dialogs.dart';
import '../commun/apercu_document.dart';
import '../commun/statuts.dart';
import '../produits/produits_providers.dart';
import '../stock/stock_providers.dart';
import '../tiers/tiers_providers.dart';

final documentsRepositoryProvider = Provider<DocumentsCommerciauxRepository>(
  (ref) => DocumentsCommerciauxRepository(ref.watch(appDatabaseProvider).db),
);

final documentClientServiceProvider = Provider<DocumentClientService>(
  (ref) => DocumentClientService(
    ref.watch(appDatabaseProvider).db,
    utilisateurCode: ref.watch(utilisateurCourantCodeProvider),
    parametres: ref.watch(parametresVenteProvider).value ?? const ParametresVente(),
  ),
);

final commandeFournisseurServiceProvider = Provider<CommandeFournisseurService>(
  (ref) => CommandeFournisseurService(
    ref.watch(appDatabaseProvider).db,
    utilisateurCode: ref.watch(utilisateurCourantCodeProvider),
  ),
);

/// Devis, proformas ou commandes clients d'une période.
final documentsClientsProvider = FutureProvider.family<List<DocumentClient>, (String, DateTime, DateTime)>((ref, cle) {
  ref.watch(commerceVersionProvider);
  return ref.watch(documentsRepositoryProvider).documentsClients(type: cle.$1, debut: cle.$2, fin: cle.$3);
});

/// Bons de livraison d'une période.
final livraisonsProvider = FutureProvider.family<List<BonLivraison>, (DateTime, DateTime)>((ref, bornes) {
  ref.watch(commerceVersionProvider);
  return ref.watch(documentsRepositoryProvider).livraisons(debut: bornes.$1, fin: bornes.$2);
});

/// Commandes fournisseurs d'une période.
final commandesFournisseursProvider = FutureProvider.family<List<CommandeFournisseur>, (DateTime, DateTime)>((
  ref,
  bornes,
) {
  ref.watch(commerceVersionProvider);
  return ref.watch(documentsRepositoryProvider).commandesFournisseurs(debut: bornes.$1, fin: bornes.$2);
});

/// Rafraîchit les listes après une écriture (documents, ventes, stock, soldes).
void rafraichirDocuments(WidgetRef ref) {
  rafraichirCommerce(ref);
  rafraichirStock(ref);
}

String messageErreurDocument(AppLocalizations l10n, ErreurDocument e) => switch (e) {
  ErreurDocument.lignesVides => l10n.achatErreurLignes,
  ErreurDocument.quantiteInvalide => l10n.achatErreurQuantite,
  ErreurDocument.prixInvalide => l10n.achatErreurPrix,
  ErreurDocument.produitInconnu => l10n.achatErreurProduit,
  ErreurDocument.clientInconnu => l10n.docErreurClient,
  ErreurDocument.fournisseurInconnu => l10n.achatErreurFournisseur,
  ErreurDocument.documentInconnu => l10n.docErreurInconnu,
  ErreurDocument.nonModifiable => l10n.docErreurNonModifiable,
  ErreurDocument.dejaAnnule => l10n.docErreurDejaAnnule,
  ErreurDocument.motifObligatoire => l10n.entErreurMotif,
  ErreurDocument.livraisonLiee => l10n.docErreurLivraisonLiee,
  ErreurDocument.receptionLiee => l10n.cmdfErreurReceptionLiee,
  ErreurDocument.rienALivrer => l10n.docErreurRienALivrer,
  ErreurDocument.quantiteExcessive => l10n.docErreurQuantiteExcessive,
  ErreurDocument.livraisonExistante => l10n.docErreurLivraisonExistante,
  ErreurDocument.venteInconnue => l10n.docErreurVenteInconnue,
  ErreurDocument.venteAnnulee => l10n.factureVenteAnnulee,
  ErreurDocument.sessionRequise => l10n.communSessionRequise,
  ErreurDocument.dejaSoldee => l10n.cmdfErreurDejaSoldee,
};

/// Exécute une écriture de document ; affiche l'erreur métier et renvoie `false` en cas d'échec.
Future<bool> executerDocument(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
  final l10n = AppLocalizations.of(context);
  String? message;
  try {
    await action();
    rafraichirDocuments(ref);
    return true;
  } on DocumentException catch (e) {
    message = messageErreurDocument(l10n, e.erreur) + (e.detail == null ? '' : ' (${e.detail})');
  } on VenteException catch (e) {
    message = messageErreurVente(l10n, e, ref.read(deviseProvider));
  }
  if (context.mounted) {
    unawaited(afficherResultat(context, type: DsResultatType.erreur, titre: l10n.moduleDocuments, message: message));
  }
  return false;
}

String libelleTypeDocument(AppLocalizations l10n, String type) => switch (type) {
  TypesDocumentClient.devis => l10n.docTypeDevis,
  TypesDocumentClient.proforma => l10n.docTypeProforma,
  _ => l10n.docTypeCommande,
};

String libelleStatutDocument(AppLocalizations l10n, String statut) => switch (statut) {
  StatutsDocumentClient.accepte => l10n.docStatutAccepte,
  StatutsDocumentClient.refuse => l10n.docStatutRefuse,
  StatutsDocumentClient.transforme => l10n.docStatutTransforme,
  StatutsDocumentClient.expire => l10n.docStatutExpire,
  StatutsDocumentClient.partielle => l10n.docStatutPartielle,
  StatutsDocumentClient.livree => l10n.docStatutLivree,
  StatutsDocumentClient.annule => l10n.docStatutAnnule,
  _ => l10n.docStatutEnCours,
};

DsBadgeTon tonStatutDocument(String statut) => switch (statut) {
  StatutsDocumentClient.accepte || StatutsDocumentClient.livree => DsBadgeTon.succes,
  StatutsDocumentClient.transforme => DsBadgeTon.info,
  StatutsDocumentClient.partielle || StatutsDocumentClient.expire => DsBadgeTon.avertissement,
  StatutsDocumentClient.refuse || StatutsDocumentClient.annule => DsBadgeTon.danger,
  _ => DsBadgeTon.primaire,
};

String libelleStatutCommandeFournisseur(AppLocalizations l10n, String statut) => switch (statut) {
  StatutsCommandeFournisseur.partielle => l10n.cmdfStatutPartielle,
  StatutsCommandeFournisseur.recue => l10n.cmdfStatutRecue,
  StatutsCommandeFournisseur.soldee => l10n.cmdfStatutSoldee,
  StatutsCommandeFournisseur.annulee => l10n.docStatutAnnule,
  _ => l10n.docStatutEnCours,
};

DsBadgeTon tonStatutCommandeFournisseur(String statut) => switch (statut) {
  StatutsCommandeFournisseur.recue => DsBadgeTon.succes,
  StatutsCommandeFournisseur.partielle => DsBadgeTon.avertissement,
  StatutsCommandeFournisseur.soldee => DsBadgeTon.info,
  StatutsCommandeFournisseur.annulee => DsBadgeTon.danger,
  _ => DsBadgeTon.primaire,
};

// ———————————————————————————— Impression A4 ————————————————————————————

Future<IdentiteFiscale> _vendeur(WidgetRef ref) async {
  final b = await BoutiqueRepository(ref.read(appDatabaseProvider).db).lire();
  return IdentiteFiscale(
    nom: b?.nom ?? '',
    adresse: b?.adresse ?? '',
    telephone: b?.telephone ?? '',
    nif: b?.nif ?? '',
    nis: b?.nis ?? '',
    rc: b?.rc ?? '',
    ai: b?.article ?? '',
  );
}

Future<IdentiteFiscale> _client(WidgetRef ref, String code) async {
  final c = await ClientRepository(ref.read(appDatabaseProvider).db).parCode(code);
  if (c == null) return IdentiteFiscale(nom: code);
  return IdentiteFiscale(
    nom: c.nom,
    adresse: c.adresse,
    telephone: c.telephone,
    nif: c.fiche.nif,
    nis: c.fiche.nis,
    rc: c.fiche.nrc,
    ai: c.fiche.ai,
  );
}

Future<void> _imprimer(
  BuildContext context,
  WidgetRef ref,
  String titre,
  String nom,
  Future<Uint8List> Function(DocumentsPdf) faire,
) async {
  final arabe = Localizations.localeOf(context).languageCode == 'ar';
  final pdf = await documentsPdf(ref, arabe: arabe);
  if (!context.mounted) return;
  await afficherApercuDocument(context, ref, titre: '$titre $nom', nom: nom, pdf: () => faire(pdf));
}

/// Devis, proforma ou bon de commande client en A4 : identités, lignes HT / TVA / TTC, montant en lettres.
Future<void> imprimerDocumentClient(BuildContext context, WidgetRef ref, DocumentClient d) async {
  final l10n = AppLocalizations.of(context);
  final vendeur = await _vendeur(ref);
  final client = await _client(ref, d.clientCode);
  if (!context.mounted) return;
  final devise = ref.read(deviseProvider);
  String m(double v) => '${f2(v)} $devise';
  final titre = switch (d.type) {
    TypesDocumentClient.devis => l10n.docPdfDevis,
    TypesDocumentClient.proforma => l10n.docPdfProforma,
    _ => l10n.docPdfCommande,
  };
  await _imprimer(
    context,
    ref,
    titre,
    d.code,
    (pdf) => pdf.documentCommercial(
      titre: titre,
      numero: d.code,
      date: d.date,
      references: [
        if (d.validite != null) (l10n.docValidite, formatDate.format(d.validite!)),
        if (d.origineCode != null) (l10n.docOrigine, d.origineCode!),
      ],
      emetteur: vendeur,
      libelleTiers: l10n.ventesClient,
      tiers: client,
      entetes: [
        l10n.produitsColCode,
        l10n.dsPosProduit,
        l10n.stockColQuantite,
        l10n.docPuTtc,
        l10n.tvaTaux,
        l10n.tvaHt,
        l10n.tvaMontant,
        l10n.tvaTtc,
      ],
      lignes: [
        for (final l in d.lignes)
          [
            l.produitCode,
            l.designation,
            formaterNombre(l.quantite),
            f2(l.prixUnitaire),
            '${formaterNombre(l.tauxTva)} %',
            f2(l.montantHt),
            f2(l.montantTva),
            f2(l.total),
          ],
      ],
      totaux: [(l10n.tvaHt, m(d.totalHt)), (l10n.tvaMontant, m(d.totalTva)), (l10n.docTotalTtc, m(d.total))],
      arretee: l10n.docArretee(titre.toLowerCase()),
      montantLettres: MontantEnLettres.fr(d.total),
      observation: d.observation,
      mention: d.type == TypesDocumentClient.proforma ? l10n.docMentionProforma : null,
      signatures: [l10n.docSignatureClient, l10n.docSignatureVendeur],
    ),
  );
}

/// Bon de livraison A4 : quantités livrées, sans prix ; signature du réceptionnaire.
Future<void> imprimerBonLivraison(BuildContext context, WidgetRef ref, BonLivraison b) async {
  final l10n = AppLocalizations.of(context);
  final vendeur = await _vendeur(ref);
  final client = await _client(ref, b.clientCode);
  if (!context.mounted) return;
  await _imprimer(
    context,
    ref,
    l10n.docPdfLivraison,
    b.code,
    (pdf) => pdf.documentCommercial(
      titre: l10n.docPdfLivraison,
      numero: b.code,
      date: b.date,
      references: [
        (l10n.factureVente, b.venteCode),
        if (b.commandeCode != null) (l10n.docTypeCommande, b.commandeCode!),
      ],
      emetteur: vendeur,
      libelleTiers: l10n.ventesClient,
      tiers: client,
      entetes: [l10n.produitsColCode, l10n.dsPosProduit, l10n.docQuantiteLivree],
      lignes: [
        for (final l in b.lignes) [l.produitCode, l.designation, formaterNombre(l.quantite)],
      ],
      observation: b.observation,
      filigrane: b.actif ? null : l10n.docStatutAnnule,
      signatures: [l10n.docSignatureLivreur, l10n.docSignatureReception],
    ),
  );
}

/// Bon de commande fournisseur A4 : la boutique commande, le fournisseur livre.
Future<void> imprimerCommandeFournisseur(BuildContext context, WidgetRef ref, CommandeFournisseur c) async {
  final l10n = AppLocalizations.of(context);
  final acheteur = await _vendeur(ref);
  final f = await TiersRepository(ref.read(appDatabaseProvider).db).fournisseur(c.fournisseurCode);
  if (!context.mounted) return;
  final devise = ref.read(deviseProvider);
  final fournisseur = f == null
      ? IdentiteFiscale(nom: c.fournisseurCode)
      : IdentiteFiscale(
          nom: f.nom,
          adresse: f.adresse,
          telephone: f.telephone,
          nif: f.fiche.nif,
          nis: f.fiche.nis,
          rc: f.fiche.nrc,
          ai: f.fiche.ai,
        );
  await _imprimer(
    context,
    ref,
    l10n.cmdfPdfTitre,
    c.code,
    (pdf) => pdf.documentCommercial(
      titre: l10n.cmdfPdfTitre,
      numero: c.code,
      date: c.date,
      references: [if (c.dateLivraison != null) (l10n.stkLivraison, formatDate.format(c.dateLivraison!))],
      emetteur: acheteur,
      libelleTiers: l10n.retoursFournisseur,
      tiers: fournisseur,
      entetes: [l10n.produitsColCode, l10n.dsPosProduit, l10n.stockColQuantite, l10n.cmdfPrix, l10n.retoursMontant],
      lignes: [
        for (final l in c.lignes) [l.produitCode, l.designation, formaterNombre(l.quantite), f2(l.prix), f2(l.montant)],
      ],
      totaux: [(l10n.communTotal, '${f2(c.total)} $devise')],
      observation: c.observation,
      signatures: [l10n.docSignatureVendeur],
    ),
  );
}

/// Bon de livraison d'une vente de caisse (créé au premier appel, réimprimé ensuite).
Future<void> imprimerBonLivraisonVente(BuildContext context, WidgetRef ref, String venteCode) async {
  BonLivraison? bl;
  final ok = await executerDocument(
    context,
    ref,
    () async => bl = await ref.read(documentClientServiceProvider).bonLivraisonPourVente(venteCode),
  );
  if (ok && context.mounted) await imprimerBonLivraison(context, ref, bl!);
}
