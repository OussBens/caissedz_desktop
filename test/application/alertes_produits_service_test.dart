import 'package:caissedz_desktop/application/alertes_produits_service.dart';
import 'package:caissedz_desktop/application/auth_service.dart';
import 'package:caissedz_desktop/application/catalogue_service.dart';
import 'package:caissedz_desktop/data/catalogue_rayons_repository.dart';
import 'package:caissedz_desktop/domain/alertes_produits.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common/sqlite_api.dart';

import '../helpers/bases.dart';

final _maintenant = DateTime(2026, 10, 21, 12);

/// [jours] jours avant [_maintenant], à 10 h.
DateTime _il(int jours) => DateTime(2026, 10, 21 - jours, 10);

void main() {
  late Database db;
  late Session admin;
  late String sessionCaisse;
  var numeroVente = 0, numeroAchat = 0, numeroRetour = 0;

  setUp(() async {
    final base = await ouvrirBaseDeTest();
    db = base.db;
    await ouvrirSessionDeTest(db);
    sessionCaisse = (await db.query('session_caisse')).first['code']! as String;
    admin = (await AuthService(db).reprendreSession('USR0000'))!;
    numeroVente = numeroAchat = numeroRetour = 0;
  });

  Future<String> produit(String nom, {double pa = 80, double pv = 100, int? seuil, String? cb}) async =>
      (await CatalogueService(db, utilisateurCode: 'USR0000').creerProduit(
        Produit(
          code: '',
          designation: nom,
          codeBarres: cb,
          categorieCode: 'CATE0000',
          sousCategorieCode: 'SC0000',
          prixAchat: pa,
          prixVente: pv,
          seuilStock: seuil,
        ),
      )).code;

  Future<void> mvt(
    String p,
    double q,
    int jours, {
    String magasin = 'MAG0000',
    String type = 'Entrée',
    String? motif,
  }) => db.insert('mouvement_stock', {
    'date': _il(jours).toUtc().toIso8601String(),
    'produit_code': p,
    'magasin_code': magasin,
    'type': type,
    'quantite': q,
    'motif': motif,
    'utilisateur_code': 'USR0000',
  });

  /// Ticket validé de [lignes] (produit, unités) il y a [jours] jours ; le stock sort avec lui.
  Future<String> vente(List<(String, double)> lignes, int jours) async {
    final code = 'VTE${(++numeroVente).toString().padLeft(4, '0')}';
    await db.insert('vente', {
      'code': code,
      'date': _il(jours).toUtc().toIso8601String(),
      'session_code': sessionCaisse,
      'caisse_code': 'CIS0000',
      'magasin_code': 'MAG0000',
      'client_code': 'CLN0000',
      'utilisateur_code': 'USR0000',
      'total_brut': 0,
      'total_remise': 0,
      'total_net': 0,
      'verse': 0,
      'reste': 0,
      'hash': '0' * 64,
      'hash_precedent': '0' * 64,
    });
    for (final (i, (p, q)) in lignes.indexed) {
      await db.insert('vente_ligne', {
        'vente_code': code,
        'ordre': i + 1,
        'produit_code': p,
        'designation': p,
        'quantite': q,
        'unites': q,
        'prix_unitaire': 100,
        'total': 100 * q,
      });
      await mvt(p, -q, jours, type: 'Vente');
    }
    return code;
  }

  Future<void> retour(String venteCode, String p, double q, int jours) async {
    final code = 'RET${(++numeroRetour).toString().padLeft(4, '0')}';
    await db.insert('retour', {
      'code': code,
      'date': _il(jours).toUtc().toIso8601String(),
      'type': 'Client',
      'document_code': venteCode,
      'client_code': 'CLN0000',
      'magasin_code': 'MAG0000',
      'utilisateur_code': 'USR0000',
      'total': 100 * q,
    });
    await db.insert('retour_ligne', {
      'retour_code': code,
      'ordre': 1,
      'produit_code': p,
      'designation': p,
      'quantite': q,
      'prix_unitaire': 100,
      'total': 100 * q,
    });
  }

  Future<void> achat(String p, double prix, int jours) async {
    final code = 'ENT${(++numeroAchat).toString().padLeft(4, '0')}';
    await db.insert('achat', {
      'code': code,
      'date': _il(jours).toUtc().toIso8601String(),
      'fournisseur_code': 'FOR0000',
      'magasin_code': 'MAG0000',
      'utilisateur_code': 'USR0000',
      'total': prix,
    });
    await db.insert('achat_ligne', {
      'achat_code': code,
      'ordre': 1,
      'produit_code': p,
      'designation': p,
      'quantite': 1,
      'prix_achat': prix,
      'total': prix,
    });
  }

  Future<AlertesProduits> calculer({Session? session, SeuilsAlertesProduits? seuils}) =>
      AlertesProduitsService(db).calculer(session ?? admin, maintenant: _maintenant, seuils: seuils);

  AlerteProduit? de(AlertesProduits a, TypeAlerteProduit t, String code) =>
      a.de(t).where((x) => x.produitCode == code).firstOrNull;

  test('ventes : meilleures ventes, en hausse, retours élevés, achetés ensemble, saisonniers', () async {
    final lait = await produit('Lait');
    final cafe = await produit('Café');
    final the = await produit('Thé');
    final dattes = await produit('Dattes');
    await mvt(lait, 35, 40);
    await mvt(cafe, 50, 40);
    await mvt(the, 50, 40);
    await mvt(dattes, 2, 400);
    // Lait : 30 vendus en 30 jours, 5 en stock = 5 jours de ventes (< 7) ; café sur 10 de ses tickets.
    for (var j = 0; j < 30; j++) {
      await vente([(lait, 1), if (j < 10) (cafe, 1)], j);
    }
    // Café : 3 retournés sur 10 vendus.
    await retour('VTE0001', cafe, 3, 0);
    // Thé : 4 vendus il y a 15 à 28 jours, 12 sur les 14 derniers jours (+200 %).
    for (var j = 0; j < 4; j++) {
      await vente([(the, 1)], 15 + j);
    }
    for (var j = 0; j < 12; j++) {
      await vente([(the, 1)], j);
    }
    // Dattes : 8 vendues l'an passé dans les 30 jours à venir, 2 en stock.
    await vente([(dattes, 8)], 360);
    await mvt(dattes, 8, 361);

    final a = await calculer();
    final meilleur = de(a, TypeAlerteProduit.meilleuresVentes, lait)!;
    expect((meilleur.quantite, meilleur.stock, meilleur.jours, meilleur.critique), (30.0, 5.0, 5.0, true));
    expect(a.de(TypeAlerteProduit.meilleuresVentes).first.produitCode, lait, reason: 'à réapprovisionner d’abord');
    final hausse = de(a, TypeAlerteProduit.enHausse, the)!;
    expect((hausse.quantite, hausse.quantite2, hausse.evolution), (12.0, 4.0, 200.0));
    final retours = de(a, TypeAlerteProduit.retoursEleves, cafe)!;
    expect((retours.quantite, retours.quantite2, retours.pct), (3.0, 10.0, 30.0));
    final paire = a.de(TypeAlerteProduit.achetesEnsemble).single;
    expect({paire.produitCode, paire.produit2Code}, {lait, cafe});
    expect((paire.quantite, paire.pct), (10.0, 100.0));
    final saison = de(a, TypeAlerteProduit.saisonniers, dattes)!;
    expect((saison.quantite, saison.stock, saison.suggestion), (8.0, 2.0, 6.0));
  });

  test('stock : dormant, lent, jamais vendu, ruptures fréquentes, sans commande, déséquilibré, anormal', () async {
    final riz = await produit('Riz', pa: 50, pv: 100);
    final sel = await produit('Sel', pa: 10, pv: 20);
    final huile = await produit('Huile');
    final pates = await produit('Pâtes', seuil: 5);
    final farine = await produit('Farine', seuil: 5);
    final semoule = await produit('Semoule', seuil: 5);
    final levure = await produit('Levure');
    await mvt(riz, 41, 200);
    await vente([(riz, 1)], 90);
    await mvt(sel, 230, 100);
    for (var j = 0; j < 30; j++) {
      await vente([(sel, 1)], j);
    }
    await mvt(huile, 10, 45);
    // Pâtes : 10 entrées il y a 25 jours, vendues il y a 20 jours, en rupture depuis (21 jours sur 30).
    await mvt(pates, 10, 25);
    await vente([(pates, 10)], 20);
    // Farine : rupture, une commande fournisseur livrable il y a 3 jours (retard < 7 jours) : pas d'alerte.
    await db.insert('commande_fournisseur', {
      'code': 'BCF0001',
      'date': _il(10).toIso8601String(),
      'fournisseur_code': 'FOR0000',
      'magasin_code': 'MAG0000',
      'date_livraison': _il(3).toIso8601String(),
      'utilisateur_code': 'USR0000',
    });
    await db.insert('commande_fournisseur_ligne', {
      'commande_code': 'BCF0001',
      'ordre': 1,
      'produit_code': farine,
      'designation': 'Farine',
      'quantite': 20,
    });
    // Semoule : 0 au principal, 20 dans un second magasin.
    await db.insert('magasin', {'code': 'MAG0001', 'nom': 'Dépôt'});
    await mvt(semoule, 20, 30, magasin: 'MAG0001');
    // Levure : vendue sans être entrée (stock négatif), 3 casses.
    await vente([(levure, 3)], 2);
    for (var j = 0; j < 3; j++) {
      await mvt(levure, -1, j, type: 'Sortie', motif: 'Casse');
    }

    final a = await calculer();
    final dormant = de(a, TypeAlerteProduit.stockDormant, riz)!;
    expect((dormant.stock, dormant.jours, dormant.montant), (40.0, 90.0, 2000.0));
    final candidat = de(a, TypeAlerteProduit.candidatsRemise, riz)!;
    expect((candidat.pct, candidat.suggestion), (100.0, 20.0));
    expect(candidat.motifs, ['dormant']);
    final lent = de(a, TypeAlerteProduit.stockLent, sel)!;
    expect((lent.stock, lent.jours), (200.0, 200.0));
    expect(de(a, TypeAlerteProduit.jamaisVendus, huile)!.jours, 45);
    final ruptures = de(a, TypeAlerteProduit.rupturesFrequentes, pates)!;
    expect((ruptures.jours, ruptures.critique), (21.0, true));
    expect(de(a, TypeAlerteProduit.ruptureSansCommande, pates)!.motifs, ['aucune']);
    expect(de(a, TypeAlerteProduit.ruptureSansCommande, farine), isNull, reason: 'commandée, retard de 3 jours');
    final transfert = de(a, TypeAlerteProduit.stockDesequilibre, semoule)!;
    expect((transfert.magasin, transfert.magasin2, transfert.suggestion), ('MAG0000', 'MAG0001', 10.0));
    final anormal = de(a, TypeAlerteProduit.stockAnormal, levure)!;
    expect(anormal.motifs, ['negatif', 'casse']);
    expect(anormal.critique, isTrue);
  });

  test('prix : marge faible, hausse fournisseur, remise sans effet, bonne marge peu vendue', () async {
    final sucre = await produit('Sucre', pa: 100, pv: 102);
    final riz = await produit('Riz', pa: 50, pv: 100);
    final sel = await produit('Sel', pa: 10, pv: 12);
    for (final p in [sucre, riz, sel, await produit('Eau', pa: 20, pv: 25)]) {
      await mvt(p, 100, 60);
    }
    await achat(sucre, 100, 50);
    await achat(sucre, 110, 5);
    // Sel : 1 vendu par jour avant et pendant la remise (11 jours, aujourd'hui compris) : ventes inchangées.
    for (var j = 0; j < 25; j++) {
      await vente([(sel, 1)], j);
    }
    await db.insert('remise', {
      'code': 'REM0001',
      'designation': '-10 % sel',
      'type': 'Pourcentage',
      'valeur': 10,
      'produit_code': sel,
      'date_debut': DateTime(2026, 10, 11).toIso8601String(),
      'date_fin': DateTime(2026, 10, 31).toIso8601String(),
    });

    final a = await calculer();
    final marge = de(a, TypeAlerteProduit.margeFaible, sucre)!;
    expect((marge.montant, marge.critique), (110.0, true), reason: 'vendu sous le dernier prix d’achat');
    final hausse = de(a, TypeAlerteProduit.hausseFournisseur, sucre)!;
    expect((hausse.evolution, hausse.suggestion), (10.0, 112.2));
    final remise = de(a, TypeAlerteProduit.remisesInefficaces, sel)!;
    expect((remise.remiseCode, remise.quantite, remise.quantite2, remise.jours), ('REM0001', 11.0, 11.0, 11.0));
    expect(de(a, TypeAlerteProduit.bonneMargePeuVendus, riz), isNotNull, reason: 'meilleure marge, aucune vente');

    // Sans « Voir les prix d'achat » : les alertes sur le prix d'achat disparaissent.
    final vendeur = Session(utilisateur: admin.utilisateur, permissions: const {}, modulesAutorises: const {'stock'});
    final sansCout = await calculer(session: vendeur);
    expect(sansCout.parType.keys, isNot(contains(TypeAlerteProduit.margeFaible)));
    expect(sansCout.parType.keys, contains(TypeAlerteProduit.remisesInefficaces));
    // Alerte désactivée dans les Paramètres ; sans module Produits / Stock / Besoins : rien.
    final seuils = const SeuilsAlertesProduits().avec(const {}, inactives: {TypeAlerteProduit.margeFaible});
    expect((await calculer(seuils: seuils)).parType.keys, isNot(contains(TypeAlerteProduit.margeFaible)));
    final caissier = Session(utilisateur: admin.utilisateur, permissions: const {}, modulesAutorises: const {'caisse'});
    expect((await calculer(session: caissier)).total, 0);
  });

  test('qualité et marché : fiche incomplète, nouveautés et tendances du catalogue BENS', () async {
    final complet = await produit('Lait', cb: '6130000000015');
    await db.insert('produit_photo', {'produit_code': complet, 'ordre': 1, 'chemin': 'lait.jpg'});
    await db.update('produit', {'categorie_code': 'CATE0000'}, where: 'code = ?', whereArgs: [complet]);
    final sansPrix = await produit('Yaourt');
    await db.update('produit', {'prix_vente': 0}, where: 'code = ?', whereArgs: [sansPrix]);
    await db.insert('catalogue_rayon', {
      'rayon_code': 'epicerie',
      'nom': 'Épicerie',
      'categorie_code': 'CATE0000',
      'sous_categorie_code': 'SC0000',
      'importe_le': _il(20).toUtc().toIso8601String(),
    });
    Future<void> catalogue(String code, String cb, int jours) => db.insert('produit', {
      'code': code,
      'designation': 'Catalogue $code',
      'code_barres': cb,
      'categorie_code': 'CATE0000',
      'sous_categorie_code': 'SC0000',
      'source': Produit.sourceCatalogue,
      'cree_le': _il(jours).toUtc().toIso8601String(),
    });
    await catalogue('PRD0901', '6130000000901', 20); // téléchargé avec le rayon
    await catalogue('PRD0902', '6130000000902', 2); // arrivé ensuite (tendance)
    await CatalogueRayonsRepository(db).marquerProduitsTendance(['6130000000902'], _il(2));

    final a = await calculer();
    expect(de(a, TypeAlerteProduit.ficheIncomplete, sansPrix)!.motifs, ['codeBarres', 'photo', 'categorie', 'prix']);
    expect(de(a, TypeAlerteProduit.ficheIncomplete, complet)!.motifs, ['categorie']);
    expect(a.de(TypeAlerteProduit.nouveautesMarche).map((x) => x.produitCode), ['PRD0902']);
    expect(a.de(TypeAlerteProduit.tendancesMarche).single.produitCode, 'PRD0902');
    expect(de(a, TypeAlerteProduit.ficheIncomplete, 'PRD0901'), isNull, reason: 'catalogue jamais entré en stock');
    // Entré en stock : le produit du catalogue n'est plus une alerte du marché.
    await mvt('PRD0902', 5, 1);
    expect((await calculer()).de(TypeAlerteProduit.tendancesMarche), isEmpty);
  });

  test('seuils : lus et écrits dans les paramètres, valeurs invalides ignorées', () {
    const d = SeuilsAlertesProduits();
    final s = d.avec(
      {
        SeuilsAlertesProduits.cleTopN: '20',
        SeuilsAlertesProduits.cleRetours: 'x',
        SeuilsAlertesProduits.cleBaisse: '12,5',
      },
      inactives: {TypeAlerteProduit.ficheIncomplete},
    );
    expect((s.topN, s.retoursPct, s.baisseVentesPct), (20, 10.0, 12.5));
    final relu = SeuilsAlertesProduits.depuisCles(s.versCles());
    expect(relu, s);
    expect(relu.active(TypeAlerteProduit.ficheIncomplete), isFalse);
    expect(AlertesProduits.vide.empreintes, isEmpty);
  });
}
