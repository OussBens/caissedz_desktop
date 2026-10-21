import 'package:sqflite_common/sqlite_api.dart';

import '../data/catalogue_repository.dart';
import '../data/parametre_repository.dart';
import '../data/stock_repository.dart';
import '../domain/calculs_prix.dart';
import '../domain/codes_barres.dart';
import '../domain/fiscalite.dart';
import '../domain/models/panier.dart';
import '../domain/models/parametres_paiement.dart';
import '../domain/models/parametres_vente.dart';
import '../domain/models/produit.dart';
import '../domain/models/vente.dart';
import 'catalogue_service.dart';
import 'cloture_service.dart';
import 'session_caisse_service.dart';
import 'stock_service.dart';
import 'vente_service.dart';

/// Nature d'un article vendable : produit seul, colis (emballage) ou pack.
enum TypeArticle { produit, colis, pack }

/// Article résolu depuis un code (scan du téléphone), au prix de la caisse : TTC selon le régime et « caisse avec
/// TVA », remise produit en pourcentage ; [stock] : unités disponibles dans le magasin de la caisse (null : service
/// ou pack).
class ArticleCaisse {
  const ArticleCaisse({
    required this.type,
    required this.code,
    required this.produit,
    required this.designation,
    required this.prix,
    this.remisePct = 0,
    this.stock,
  });

  final TypeArticle type;

  /// Code du produit, du colis ou du pack (renvoyé tel quel à l'encaissement).
  final String code;
  final Produit produit;
  final String designation;
  final double prix;
  final double remisePct;
  final double? stock;

  Map<String, Object?> versJson() => {
    'type': type.name,
    'code': code,
    'produit': produit.code,
    'designation': designation,
    'prix': prix,
    'remisePct': remisePct,
    'unite': produit.unite,
    'image': produit.image != null && produit.image!.startsWith('http') ? produit.image : null,
    'stock': stock,
  };
}

/// Ligne demandée par le téléphone : l'article (type + code) et la quantité.
typedef LigneMobile = ({TypeArticle type, String code, double quantite});

/// Vente depuis le téléphone (CaisseDZ Scan) : même résolution des codes et mêmes prix que la Caisse du poste, puis
/// encaissement par [VenteService.encaisser] (UNE transaction) sur la session de caisse ouverte de l'utilisateur.
/// Paiement unique, sans crédit ni points ; le stock est gardé par l'encaissement.
class VenteMobileService {
  const VenteMobileService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  CatalogueRepository get _catalogue => CatalogueRepository(db);

  Future<ParametresVente> _parametres() async =>
      ParametresVente.depuisCles(await ParametreRepository(db).lirePlusieurs(ParametresVente.cles));

  /// Modes de paiement proposés sur le téléphone : ceux de la caisse, sauf les points (client identifié requis).
  Future<List<String>> modesPaiement() async => [
    for (final m in ParametresPaiement.depuisCles(
      await ParametreRepository(db).lirePlusieurs(ParametresPaiement.cles),
    ).modes)
      if (m != 'Points') m,
  ];

  /// Magasin de la caisse ouverte de l'utilisateur, sinon son magasin principal.
  Future<String> _magasinCaisse() async {
    final session = await SessionCaisseService(db, utilisateurCode: utilisateurCode).courante();
    if (session != null) {
      final r = await db.query('caisse', columns: ['magasin_code'], where: 'code = ?', whereArgs: [session.caisseCode]);
      final m = r.firstOrNull?['magasin_code'] as String?;
      if (m != null) return m;
    }
    return StockService(db, utilisateurCode: utilisateurCode).magasinPrincipal(utilisateurCode);
  }

  /// Résout un code scanné comme la Caisse : QR produit, code-barres ou code produit, puis colis, puis pack.
  Future<ArticleCaisse?> resoudre(String code) async {
    final c = code.trim();
    if (c.isEmpty) return null;
    final qr = CodesBarres.codeProduitDepuisQr(c);
    var produit = qr != null ? await _catalogue.produitParCode(qr) : await _catalogue.produitParCodeBarres(c);
    produit ??= await _catalogue.produitParCode(c.toUpperCase());
    if (produit != null) return produit.actif ? _article(TypeArticle.produit, produit.code) : null;
    final colis = await _catalogue.colisParCodeBarres(c);
    if (colis != null) return _article(TypeArticle.colis, colis.code);
    final pack = await _catalogue.packParCodeBarres(c);
    if (pack != null) return _article(TypeArticle.pack, pack.code);
    return null;
  }

  Future<ArticleCaisse?> _article(TypeArticle type, String code) async {
    final p = await _parametres();
    double ttc(Produit x, [double? ht]) =>
        Fiscalite.ttc(ht ?? x.prixVente, Fiscalite.taux(x.tvaPct, p.regimeFiscal, avecTva: p.tvaCaisse));
    switch (type) {
      case TypeArticle.produit:
        final produit = await _catalogue.produitParCode(code);
        if (produit == null || !produit.actif) return null;
        final prix = ttc(produit);
        final remise = await CatalogueService(db, utilisateurCode: utilisateurCode).remiseApplicable(produit, prix);
        return ArticleCaisse(
          type: type,
          code: produit.code,
          produit: produit,
          designation: produit.designation,
          prix: prix,
          remisePct: remise > 0 && prix > 0 ? double.parse((remise / prix * 100).toStringAsFixed(2)) : 0,
          stock: produit.service ? null : await _stock(produit.code),
        );
      case TypeArticle.colis:
        final colis = (await _catalogue.colis()).where((k) => k.code == code && k.actif).firstOrNull;
        final produit = colis == null ? null : await _catalogue.produitParCode(colis.produitCode);
        if (colis == null || produit == null) return null;
        return ArticleCaisse(
          type: type,
          code: colis.code,
          produit: produit,
          designation: colis.designation,
          prix: ttc(produit, colis.prixVente),
          stock: produit.service ? null : await _stock(produit.code),
        );
      case TypeArticle.pack:
        final pack = (await _catalogue.packs()).where((k) => k.code == code && k.actif).firstOrNull;
        if (pack == null || pack.lignes.isEmpty) return null;
        final produit = await _catalogue.produitParCode(pack.lignes.first.produitCode);
        if (produit == null) return null;
        return ArticleCaisse(
          type: type,
          code: pack.code,
          produit: produit,
          designation: pack.designation,
          prix: pack.prixVente,
        );
    }
  }

  Future<double> _stock(String produitCode) async =>
      (await StockRepository(db).niveau(produitCode, await _magasinCaisse())).quantite;

  /// Panier des [lignes] (mêmes lignes que la Caisse : un pack est éclaté en une ligne par produit).
  Future<Panier> _panier(List<LigneMobile> lignes, String clientCode, ParametresVente p) async {
    var panier = Panier(id: 0, clientCode: clientCode);
    for (final l in lignes) {
      if (l.quantite <= 0) throw const VenteException(ErreurVente.quantiteInvalide);
      final a = await _article(l.type, l.code);
      if (a == null) throw VenteException(ErreurVente.articleInconnu, l.code);
      if (l.type != TypeArticle.pack) {
        panier = panier.ajouter(
          PanierLigne(
            produit: a.produit,
            colis: l.type == TypeArticle.colis ? (await _catalogue.colis()).firstWhere((k) => k.code == l.code) : null,
            quantite: l.quantite,
            prixUnitaire: a.prix,
            remisePct: a.remisePct,
            nombreExige: a.produit.exigeNombre(global: p.nombreActif),
          ),
        );
        continue;
      }
      final pack = (await _catalogue.packs()).firstWhere((k) => k.code == l.code);
      final produits = <String, Produit>{
        for (final c in pack.lignes) c.produitCode: (await _catalogue.produitParCode(c.produitCode))!,
      };
      final prix = Panier.prixComposantsPack(pack, produits);
      for (final c in pack.lignes) {
        if (c.quantite <= 0) continue;
        final produit = produits[c.produitCode]!;
        panier = panier.ajouter(
          PanierLigne(
            produit: produit,
            pack: pack,
            quantite: c.quantite * l.quantite,
            prixUnitaire: prix[produit.code] ?? 0,
            nombreExige: produit.exigeNombre(global: p.nombreActif),
          ),
        );
      }
    }
    return panier;
  }

  /// Encaisse les [lignes] : un paiement [mode] de [montant] (des espèces au-delà du total sont la monnaie rendue ;
  /// un autre mode est ramené au total). Sans crédit : un montant insuffisant est refusé.
  Future<Vente> vendre({
    required List<LigneMobile> lignes,
    String clientCode = 'CLN0000',
    required String mode,
    required double montant,
  }) async {
    if (!(await modesPaiement()).contains(mode)) throw const VenteException(ErreurVente.modePaiementInvalide);
    final session = await SessionCaisseService(db, utilisateurCode: utilisateurCode).courante();
    if (session == null) throw const VenteException(ErreurVente.sessionRequise);
    final p = await _parametres();
    var panier = await _panier(lignes, clientCode, p);
    final m = mode == 'Espèces' ? montant : montant.clamp(0, panier.totalNet).toDouble();
    panier = panier.copyWith(
      modePaiement: mode,
      paiements: [if (m > 0) Paiement(mode: mode, montant: CalculsPrix.arrondir(m))],
    );
    return VenteService(
      db,
      utilisateurCode: utilisateurCode,
      parametres: p,
      periodeCloturee: ClotureService.periodeCloturee,
    ).encaisser(
      panier,
      session: session,
      magasinCode: await StockService(db, utilisateurCode: utilisateurCode).magasinPrincipal(utilisateurCode),
    );
  }
}
