import 'dart:math' as math;

import 'package:sqflite_common/sqlite_api.dart';

import '../data/alertes_produits_repository.dart';
import '../data/parametre_repository.dart';
import '../data/stock_repository.dart';
import '../domain/alertes_produits.dart';
import '../domain/code_generator.dart';
import '../domain/models/parametres_vente.dart';
import '../domain/models/session.dart';
import '../domain/permissions.dart';

/// Les 20 alertes produits (Situation › Alertes produits, carte du tableau de bord) : un seul service, des
/// requêtes en lecture seule ; seuls les seuils sont des données ([SeuilsAlertesProduits], Paramètres › Alertes).
///
/// Ventes nettes des retours clients ; stock lu dans le journal des mouvements ; les produits téléchargés du
/// catalogue BENS jamais entrés en stock ne sont comptés que par les alertes du marché (19 et 20). Hors Admin,
/// ventes et stock se limitent aux magasins de l'utilisateur. Les alertes sur le prix d'achat demandent la
/// permission « Voir les prix d'achat ».
class AlertesProduitsService {
  const AlertesProduitsService(this.db);

  final Database db;

  Future<SeuilsAlertesProduits> seuils() async =>
      SeuilsAlertesProduits.depuisCles(await ParametreRepository(db).lirePlusieurs(SeuilsAlertesProduits.cles));

  /// Types visibles par [session] (module Produits, Stock ou Besoins ; prix d'achat) parmi les alertes actives.
  static List<TypeAlerteProduit> typesVisibles(Session session, SeuilsAlertesProduits seuils) {
    if (!['produits', 'stock', 'besoins'].any(session.peutAcceder)) return const [];
    final cout = session.a(Permission.voirPrixAchat);
    return [
      for (final t in TypeAlerteProduit.values)
        if (seuils.active(t) && (cout || !t.cout)) t,
    ];
  }

  Future<AlertesProduits> calculer(Session session, {DateTime? maintenant, SeuilsAlertesProduits? seuils}) async {
    final s = seuils ?? await this.seuils();
    final types = typesVisibles(session, s);
    if (types.isEmpty) return AlertesProduits.vide;
    final now = maintenant ?? DateTime.now();
    final jour0 = DateTime(now.year, now.month, now.day);
    DateTime avant(int jours) => DateTime(jour0.year, jour0.month, jour0.day - jours);
    final repo = AlertesProduitsRepository(db);
    final magasins = session.estAdmin ? null : await StockRepository(db).magasinsUtilisateur(session.utilisateur.code);
    final vente = ParametresVente.depuisCles(
      await ParametreRepository(db).lirePlusieurs([ParametresVente.cleSeuil, ParametresVente.cleMarge]),
    );
    final p = s.periodeJours;
    final recul = math.max(2 * p, 2 * s.hausseJours);
    bool veut(TypeAlerteProduit t) => types.contains(t);

    // Remises actives : ventes des mêmes nombres de jours avant et depuis leur début.
    final remises = <_RemiseSuivie>[];
    if (veut(TypeAlerteProduit.remisesInefficaces)) {
      for (final r in await repo.remisesActives(now)) {
        final debut = DateTime(r.debut.year, r.debut.month, r.debut.day);
        // Jours depuis son début, aujourd'hui compris (au plus la période d'analyse).
        final jours = math.min(jour0.difference(debut).inDays + 1, p);
        if (jours < _joursMinRemise) continue;
        remises.add(
          _RemiseSuivie(
            code: r.code,
            designation: r.designation,
            produitCode: r.produitCode,
            categorieCode: r.categorieCode,
            jours: jours,
            avant: await repo.ventesEntre(
              DateTime(debut.year, debut.month, debut.day - jours),
              debut,
              magasins: magasins,
            ),
            apres: await repo.ventesEntre(
              debut,
              DateTime(debut.year, debut.month, debut.day + jours),
              magasins: magasins,
            ),
          ),
        );
      }
    }
    final anneeDerniere = DateTime(jour0.year, jour0.month, jour0.day - 365);
    final calcul = _Calcul(
      s: s,
      jour0: jour0,
      seuilGlobal: vente.seuilStockGlobal,
      margeDefautPct: vente.margeDefautPct,
      produits: await repo.produits(),
      stocks: await repo.stocks(magasins: magasins),
      ventes: await repo.ventesParJour(avant(recul - 1), magasins: magasins),
      dernieres: await repo.dernieresVentes(magasins: magasins),
      prixAchat: veut(TypeAlerteProduit.margeFaible) || veut(TypeAlerteProduit.hausseFournisseur)
          ? await repo.derniersPrixAchat()
          : const {},
      commandes: veut(TypeAlerteProduit.ruptureSansCommande) ? await repo.commandesOuvertes() : const {},
      anomalies: veut(TypeAlerteProduit.stockAnormal)
          ? await repo.anomalies(avant(p - 1), magasins: magasins)
          : const {},
      mouvements: veut(TypeAlerteProduit.rupturesFrequentes)
          ? await repo.mouvementsParJour(avant(p - 1), magasins: magasins)
          : const {},
      paires: veut(TypeAlerteProduit.achetesEnsemble) ? await repo.paires(avant(p - 1)) : const [],
      saison: veut(TypeAlerteProduit.saisonniers)
          ? await repo.ventesEntre(
              anneeDerniere,
              DateTime(anneeDerniere.year, anneeDerniere.month, anneeDerniere.day + s.saisonJours),
              magasins: magasins,
            )
          : const {},
      magasins: veut(TypeAlerteProduit.stockDesequilibre)
          ? [
              for (final m in await repo.magasinsActifs())
                if (magasins == null || magasins.contains(m)) m,
            ]
          : const [],
      imports: veut(TypeAlerteProduit.nouveautesMarche) ? await repo.importsRayons() : const {},
      remises: remises,
    );
    return AlertesProduits({for (final t in types) t: calcul.alertes(t)});
  }

  /// Une remise n'est jugée qu'après ce nombre de jours.
  static const int _joursMinRemise = 7;
}

class _RemiseSuivie {
  const _RemiseSuivie({
    required this.code,
    required this.designation,
    required this.produitCode,
    required this.categorieCode,
    required this.jours,
    required this.avant,
    required this.apres,
  });
  final String code;
  final String designation;
  final String? produitCode;
  final String? categorieCode;
  final int jours;
  final Map<String, double> avant;
  final Map<String, double> apres;
}

/// Règles des alertes sur les données chargées (aucun accès à la base).
class _Calcul {
  _Calcul({
    required this.s,
    required this.jour0,
    required this.seuilGlobal,
    required this.margeDefautPct,
    required this.produits,
    required this.stocks,
    required this.ventes,
    required this.dernieres,
    required this.prixAchat,
    required this.commandes,
    required this.anomalies,
    required this.mouvements,
    required this.paires,
    required this.saison,
    required this.magasins,
    required this.imports,
    required this.remises,
  }) : _cles = [
         for (var i = 0; i < math.max(2 * s.periodeJours, 2 * s.hausseJours); i++)
           AlertesProduitsRepository.jour(DateTime(jour0.year, jour0.month, jour0.day - i)),
       ];

  final SeuilsAlertesProduits s;
  final DateTime jour0;
  final int seuilGlobal;
  final double margeDefautPct;
  final List<ProduitAlerte> produits;
  final Map<String, Map<String, double>> stocks;
  final Map<String, Map<String, JourVentes>> ventes;
  final Map<String, DateTime> dernieres;
  final Map<String, List<double>> prixAchat;
  final Map<String, DateTime> commandes;
  final Map<String, ({int casses, double ecart})> anomalies;
  final Map<String, Map<String, double>> mouvements;
  final List<({String p1, String p2, int tickets})> paires;
  final Map<String, double> saison;
  final List<String> magasins;
  final Map<String, DateTime> imports;
  final List<_RemiseSuivie> remises;

  /// Jours `AAAA-MM-JJ`, aujourd'hui d'abord.
  final List<String> _cles;

  /// Minimum de ventes pour juger une évolution, un taux de retour ou une saison.
  static const double _minimum = 5;
  static final String _categorieSysteme = CodeGenerator.systeme(CodeGenerator.categorie);
  static final String _sousCategorieSysteme = CodeGenerator.systeme(CodeGenerator.sousCategorie);

  int get _p => s.periodeJours;

  late final Map<String, ProduitAlerte> _parCode = {for (final p in produits) p.code: p};

  /// Produits suivis : hors produits du catalogue BENS jamais entrés en stock.
  late final List<ProduitAlerte> _suivis = [
    for (final p in produits)
      if (!_catalogueAbsent(p)) p,
  ];

  bool _catalogueAbsent(ProduitAlerte p) =>
      p.source == AlertesProduitsRepository.sourceCatalogue && p.premierMouvement == null;

  double _stock(String code) => stocks[code]?.values.fold<double>(0, (a, b) => a + b) ?? 0;
  int _seuil(ProduitAlerte p) => p.seuil ?? seuilGlobal;
  int _depuis(DateTime d) => jour0.difference(DateTime(d.year, d.month, d.day)).inDays;
  static double _arrondi(double v, [int decimales = 2]) {
    final f = math.pow(10, decimales);
    return (v * f).round() / f;
  }

  /// Somme sur les [n] jours qui précèdent ([decalage] jours avant aujourd'hui, aujourd'hui compris à 0).
  double _somme(String code, int n, double Function(JourVentes) f, [int decalage = 0]) {
    final jours = ventes[code];
    if (jours == null) return 0;
    var t = 0.0;
    for (var i = decalage; i < decalage + n && i < _cles.length; i++) {
      if (jours[_cles[i]] case final v?) t += f(v);
    }
    return t;
  }

  double _net(String code, int n, [int decalage = 0]) => _somme(code, n, (v) => v.vendu - v.retourne, decalage);
  double _vendu(String code, int n) => _somme(code, n, (v) => v.vendu);
  double _retourne(String code, int n) => _somme(code, n, (v) => v.retourne);
  double _tickets(String code, int n) => _somme(code, n, (v) => v.tickets.toDouble());

  AlerteProduit _alerte(
    TypeAlerteProduit t,
    ProduitAlerte p, {
    double? quantite,
    double? quantite2,
    double? stock,
    double? jours,
    double? pct,
    double? evolution,
    double? montant,
    double? suggestion,
    String? produit2Code,
    String? produit2,
    String? magasin,
    String? magasin2,
    String? remiseCode,
    String? remise,
    List<String> motifs = const [],
    bool critique = false,
  }) => AlerteProduit(
    type: t,
    produitCode: p.code,
    designation: p.designation,
    categorie: p.categorie,
    quantite: quantite,
    quantite2: quantite2,
    stock: stock,
    jours: jours,
    pct: pct,
    evolution: evolution,
    montant: montant,
    suggestion: suggestion,
    produit2Code: produit2Code,
    produit2: produit2,
    magasin: magasin,
    magasin2: magasin2,
    remiseCode: remiseCode,
    remise: remise,
    motifs: motifs,
    critique: critique,
  );

  List<AlerteProduit> alertes(TypeAlerteProduit t) => switch (t) {
    TypeAlerteProduit.meilleuresVentes => _meilleuresVentes(),
    TypeAlerteProduit.stockDormant => _stockDormant(),
    TypeAlerteProduit.candidatsRemise => _candidatsRemise(),
    TypeAlerteProduit.margeFaible => _margeFaible(),
    TypeAlerteProduit.retoursEleves => _retoursEleves(),
    TypeAlerteProduit.enHausse => _enHausse(),
    TypeAlerteProduit.stockLent => _stockLent(),
    TypeAlerteProduit.jamaisVendus => _jamaisVendus(),
    TypeAlerteProduit.remisesInefficaces => _remisesInefficaces(),
    TypeAlerteProduit.stockAnormal => _stockAnormal(),
    TypeAlerteProduit.hausseFournisseur => _hausseFournisseur(),
    TypeAlerteProduit.achetesEnsemble => _achetesEnsemble(),
    TypeAlerteProduit.stockDesequilibre => _stockDesequilibre(),
    TypeAlerteProduit.ruptureSansCommande => _ruptureSansCommande(),
    TypeAlerteProduit.saisonniers => _saisonniers(),
    TypeAlerteProduit.rupturesFrequentes => _rupturesFrequentes(),
    TypeAlerteProduit.ficheIncomplete => _ficheIncomplete(),
    TypeAlerteProduit.bonneMargePeuVendus => _bonneMargePeuVendus(),
    TypeAlerteProduit.nouveautesMarche => _nouveautesMarche(),
    TypeAlerteProduit.tendancesMarche => _tendancesMarche(),
  };

  /// Critiques d'abord, puis selon [cle] décroissante.
  static List<AlerteProduit> _trier(List<AlerteProduit> l, double Function(AlerteProduit) cle) => l
    ..sort((a, b) {
      if (a.critique != b.critique) return a.critique ? -1 : 1;
      return cle(b).compareTo(cle(a));
    });

  // 1 · Les N plus vendus sur la période ; à réapprovisionner si le stock couvre moins de Y jours de ventes.
  List<AlerteProduit> _meilleuresVentes() {
    final classes = [
      for (final p in _suivis)
        if (_net(p.code, _p) case final q when q > 0) (p, q),
    ]..sort((a, b) => b.$2.compareTo(a.$2));
    return _trier([
      for (final (p, q) in classes.take(s.topN))
        if (_stock(p.code) case final st)
          _alerte(
            TypeAlerteProduit.meilleuresVentes,
            p,
            quantite: q,
            stock: st,
            jours: _arrondi(math.max(0, st) / (q / _p), 1),
            critique: st / (q / _p) < s.couvertureJours,
          ),
    ], (a) => a.quantite!);
  }

  /// Produits en stock sans vente depuis plus de X jours (ils se sont vendus avant).
  late final Map<String, int> _dormants = {
    for (final p in _suivis)
      if (_stock(p.code) > 0 && dernieres[p.code] != null && _depuis(dernieres[p.code]!) > s.dormantJours)
        p.code: _depuis(dernieres[p.code]!),
  };

  // 2 · Stock dormant, classé par valeur immobilisée.
  List<AlerteProduit> _stockDormant() => [
    for (final p in _suivis)
      if (_dormants[p.code] case final jours?)
        _alerte(
          TypeAlerteProduit.stockDormant,
          p,
          stock: _stock(p.code),
          jours: jours.toDouble(),
          montant: _arrondi(_stock(p.code) * p.prixAchat),
        ),
  ]..sort((a, b) => b.montant!.compareTo(a.montant!));

  /// Remise conseillée : la moitié de la remise qui ramènerait la marge au seuil, arrondie (5 % au-delà de 10 %).
  static double _remiseConseillee(double maximum) {
    final x = maximum / 2;
    if (x >= 10) return math.min(50, (x / 5).floor() * 5).toDouble();
    return math.max(1, x.floor()).toDouble();
  }

  // 3 · Dormants ou ventes en baisse de plus de X %, avec une marge encore au-dessus de Y % : remise conseillée.
  List<AlerteProduit> _candidatsRemise() {
    final r = <AlerteProduit>[];
    for (final p in _suivis) {
      final st = _stock(p.code);
      if (st <= 0 || p.prixVente <= 0 || p.prixAchat <= 0) continue;
      final marge = (p.prixVente - p.prixAchat) / p.prixAchat * 100;
      if (marge <= s.margeRemisePct) continue;
      final courant = _net(p.code, _p);
      final precedent = _net(p.code, _p, _p);
      final baisse = precedent > 0 && courant < precedent * (1 - s.baisseVentesPct / 100);
      final dormant = _dormants.containsKey(p.code);
      if (!dormant && !baisse) continue;
      final maximum = (1 - p.prixAchat * (1 + s.margeRemisePct / 100) / p.prixVente) * 100;
      r.add(
        _alerte(
          TypeAlerteProduit.candidatsRemise,
          p,
          quantite: courant,
          quantite2: precedent,
          stock: st,
          pct: _arrondi(marge, 1),
          evolution: baisse ? _arrondi((courant - precedent) / precedent * 100, 1) : null,
          jours: dormant ? _dormants[p.code]!.toDouble() : null,
          suggestion: _remiseConseillee(maximum),
          motifs: [if (dormant) 'dormant', if (baisse) 'baisse'],
        ),
      );
    }
    return r..sort((a, b) => b.pct!.compareTo(a.pct!));
  }

  // 4 · Prix de vente HT proche du dernier prix d'achat HT (marge < X %) ou en dessous (vente à perte).
  List<AlerteProduit> _margeFaible() {
    final r = <AlerteProduit>[];
    for (final p in _suivis) {
      final achat = prixAchat[p.code]?.first ?? p.prixAchat;
      if (p.prixVente <= 0 || achat <= 0) continue;
      final marge = (p.prixVente - achat) / achat * 100;
      if (marge >= s.margeFaiblePct) continue;
      r.add(
        _alerte(
          TypeAlerteProduit.margeFaible,
          p,
          stock: _stock(p.code),
          pct: _arrondi(marge, 1),
          montant: achat,
          suggestion: _arrondi(achat * (1 + margeDefautPct / 100)),
          critique: p.prixVente < achat,
        ),
      );
    }
    return _trier(r, (a) => -a.pct!);
  }

  // 5 · Taux de retour au-dessus de X % (au moins 5 vendus sur la période).
  List<AlerteProduit> _retoursEleves() => [
    for (final p in _suivis)
      if ((_vendu(p.code, _p), _retourne(p.code, _p)) case (final v, final rt)
          when v >= _minimum && rt / v * 100 > s.retoursPct)
        _alerte(
          TypeAlerteProduit.retoursEleves,
          p,
          quantite: rt,
          quantite2: v,
          pct: _arrondi(rt / v * 100, 1),
          stock: _stock(p.code),
        ),
  ]..sort((a, b) => b.pct!.compareTo(a.pct!));

  // 6 · Ventes des X derniers jours au moins Y % au-dessus des X jours d'avant.
  List<AlerteProduit> _enHausse() {
    final h = s.hausseJours;
    return _trier([
      for (final p in _suivis)
        if ((_net(p.code, h), _net(p.code, h, h)) case (final q, final avant)
            when avant > 0 && q >= _minimum && (q - avant) / avant * 100 > s.haussePct)
          _alerte(
            TypeAlerteProduit.enHausse,
            p,
            quantite: q,
            quantite2: avant,
            evolution: _arrondi((q - avant) / avant * 100, 1),
            stock: _stock(p.code),
            critique: _stock(p.code) < q,
          ),
    ], (a) => a.evolution!);
  }

  // 7 · Stock qui mettrait plus de X jours à s'écouler au rythme de la période.
  List<AlerteProduit> _stockLent() => [
    for (final p in _suivis)
      if ((_stock(p.code), _net(p.code, _p)) case (final st, final q)
          when st > 0 && q > 0 && st / (q / _p) > s.lentJours)
        _alerte(
          TypeAlerteProduit.stockLent,
          p,
          stock: st,
          quantite: q,
          jours: (st / (q / _p)).roundToDouble(),
          montant: _arrondi(st * p.prixAchat),
        ),
  ]..sort((a, b) => b.jours!.compareTo(a.jours!));

  // 8 · En stock, entré (ou créé) depuis plus de X jours, jamais vendu.
  List<AlerteProduit> _jamaisVendus() => [
    for (final p in _suivis)
      if (_stock(p.code) > 0 &&
          dernieres[p.code] == null &&
          _depuis(p.premierMouvement ?? p.creeLe) > s.jamaisVenduJours)
        _alerte(
          TypeAlerteProduit.jamaisVendus,
          p,
          stock: _stock(p.code),
          jours: _depuis(p.premierMouvement ?? p.creeLe).toDouble(),
          montant: _arrondi(_stock(p.code) * p.prixAchat),
        ),
  ]..sort((a, b) => b.montant!.compareTo(a.montant!));

  // 9 · Remise active depuis au moins 7 jours dont les ventes n'ont pas augmenté (mêmes jours avant son début).
  List<AlerteProduit> _remisesInefficaces() {
    final r = <AlerteProduit>[];
    for (final remise in remises) {
      for (final p in _suivis) {
        final concerne =
            p.remiseCode == remise.code ||
            remise.produitCode == p.code ||
            (remise.categorieCode != null && remise.categorieCode == p.categorieCode);
        if (!concerne || _stock(p.code) <= 0) continue;
        final apres = remise.apres[p.code] ?? 0;
        final avant = remise.avant[p.code] ?? 0;
        if (apres > avant) continue;
        r.add(
          _alerte(
            TypeAlerteProduit.remisesInefficaces,
            p,
            quantite: apres,
            quantite2: avant,
            jours: remise.jours.toDouble(),
            evolution: avant > 0 ? _arrondi((apres - avant) / avant * 100, 1) : null,
            stock: _stock(p.code),
            remiseCode: remise.code,
            remise: remise.designation,
          ),
        );
      }
    }
    return r;
  }

  // 10 · Stock négatif, sorties « Casse » répétées ou gros écart d'inventaire sur la période.
  List<AlerteProduit> _stockAnormal() {
    final r = <AlerteProduit>[];
    for (final p in _suivis) {
      final st = _stock(p.code);
      final a = anomalies[p.code];
      final motifs = [
        if (st < 0) 'negatif',
        if (a != null && a.casses >= s.casseMax) 'casse',
        if (a != null && a.ecart >= s.ecartInventaire) 'inventaire',
      ];
      if (motifs.isEmpty) continue;
      r.add(
        _alerte(
          TypeAlerteProduit.stockAnormal,
          p,
          stock: st,
          quantite: (a?.casses ?? 0).toDouble(),
          quantite2: a?.ecart ?? 0,
          motifs: motifs,
          critique: st < 0,
        ),
      );
    }
    return _trier(r, (a) => a.motifs.length.toDouble());
  }

  // 11 · Dernier prix d'achat plus de X % au-dessus du précédent : prix de vente conseillé (même marge).
  List<AlerteProduit> _hausseFournisseur() {
    final r = <AlerteProduit>[];
    for (final p in _suivis) {
      final prix = prixAchat[p.code];
      if (prix == null || prix.length < 2 || prix[1] <= 0) continue;
      final hausse = (prix[0] - prix[1]) / prix[1] * 100;
      if (hausse <= s.hausseAchatPct) continue;
      r.add(
        _alerte(
          TypeAlerteProduit.hausseFournisseur,
          p,
          montant: prix[0],
          quantite2: prix[1],
          evolution: _arrondi(hausse, 1),
          suggestion: p.prixVente > 0 ? _arrondi(p.prixVente * prix[0] / prix[1]) : null,
          stock: _stock(p.code),
          critique: p.prixVente > 0 && p.prixVente < prix[0],
        ),
      );
    }
    return _trier(r, (a) => a.evolution!);
  }

  // 12 · Deux produits sur un même ticket dans plus de X % des ventes du moins vendu des deux.
  List<AlerteProduit> _achetesEnsemble() {
    final r = <AlerteProduit>[];
    for (final paire in paires) {
      final p1 = _parCode[paire.p1], p2 = _parCode[paire.p2];
      if (p1 == null || p2 == null) continue;
      final base = math.min(_tickets(p1.code, _p), _tickets(p2.code, _p));
      if (base <= 0 || paire.tickets / base * 100 < s.ensemblePct) continue;
      r.add(
        _alerte(
          TypeAlerteProduit.achetesEnsemble,
          p1,
          quantite: paire.tickets.toDouble(),
          pct: _arrondi(math.min(100, paire.tickets / base * 100), 1),
          produit2Code: p2.code,
          produit2: p2.designation,
        ),
      );
    }
    return r..sort((a, b) => b.quantite!.compareTo(a.quantite!));
  }

  // 13 · Bas ou en rupture dans un magasin, largement au-dessus du seuil dans un autre : transfert conseillé.
  List<AlerteProduit> _stockDesequilibre() {
    if (magasins.length < 2) return const [];
    final r = <AlerteProduit>[];
    for (final p in _suivis) {
      final seuil = _seuil(p);
      final parMagasin = {for (final m in magasins) m: stocks[p.code]?[m] ?? 0.0};
      final bas = parMagasin.entries.where((e) => e.value <= seuil).toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      final riche = parMagasin.entries.where((e) => e.value > seuil && e.value >= 2 * seuil).toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (bas.isEmpty || riche.isEmpty) continue;
      final (m1, s1) = (bas.first.key, bas.first.value);
      final (m2, s2) = (riche.first.key, riche.first.value);
      final quantite = math.min(((s2 - s1) / 2).floorToDouble(), (s2 - seuil).floorToDouble());
      if (quantite < 1) continue;
      r.add(
        _alerte(
          TypeAlerteProduit.stockDesequilibre,
          p,
          stock: s1,
          quantite: s2,
          suggestion: quantite,
          magasin: m1,
          magasin2: m2,
          critique: s1 <= 0,
        ),
      );
    }
    return _trier(r, (a) => a.suggestion!);
  }

  // 14 · Rupture ou sous le seuil, sans commande fournisseur ouverte, ou avec une commande en retard de X jours.
  List<AlerteProduit> _ruptureSansCommande() {
    final r = <AlerteProduit>[];
    for (final p in _suivis) {
      final st = _stock(p.code);
      final seuil = _seuil(p);
      if (st > seuil) continue;
      final echeance = commandes[p.code];
      final retard = echeance == null ? null : _depuis(echeance);
      if (retard != null && retard <= s.retardCommandeJours) continue;
      r.add(
        _alerte(
          TypeAlerteProduit.ruptureSansCommande,
          p,
          stock: st,
          jours: retard?.toDouble(),
          suggestion: math.max(1, (2 * seuil - st).ceilToDouble()),
          motifs: [if (echeance == null) 'aucune' else 'retard'],
          critique: st <= 0,
        ),
      );
    }
    return _trier(r, (a) => -(a.stock ?? 0));
  }

  // 15 · Vendu dans les X prochains jours de l'an passé plus que le stock actuel.
  List<AlerteProduit> _saisonniers() => _trier([
    for (final p in _suivis)
      if ((saison[p.code] ?? 0, _stock(p.code)) case (final an, final st) when an >= _minimum && st < an)
        _alerte(
          TypeAlerteProduit.saisonniers,
          p,
          quantite: an,
          stock: st,
          jours: s.saisonJours.toDouble(),
          suggestion: (an - math.max(0, st)).ceilToDouble(),
          critique: st <= 0,
        ),
  ], (a) => a.quantite!);

  // 16 · Plus de X jours en rupture sur la période (stock de fin de journée reconstitué), ventes perdues estimées.
  List<AlerteProduit> _rupturesFrequentes() {
    final r = <AlerteProduit>[];
    for (final p in _suivis) {
      if (dernieres[p.code] == null || p.premierMouvement == null) continue;
      final jours = mouvements[p.code] ?? const {};
      var fin = _stock(p.code);
      var enRupture = 0;
      // Les jours avant la première entrée en stock ne sont pas des ruptures.
      final premier = _depuis(p.premierMouvement!);
      for (var i = 0; i < _p && i < _cles.length && i <= premier; i++) {
        if (fin <= 0) enRupture++;
        fin -= jours[_cles[i]] ?? 0;
      }
      if (enRupture <= s.rupturesJours) continue;
      final vendus = _net(p.code, _p);
      final parJour = vendus / math.max(1, _p - enRupture);
      r.add(
        _alerte(
          TypeAlerteProduit.rupturesFrequentes,
          p,
          jours: enRupture.toDouble(),
          quantite: _arrondi(parJour * enRupture, 1),
          stock: _stock(p.code),
          critique: _stock(p.code) <= 0,
        ),
      );
    }
    return _trier(r, (a) => a.jours!);
  }

  // 17 · Sans code-barres, sans photo, rangé dans la catégorie Divers (CATE0000 / SC0000) ou sans prix de vente.
  List<AlerteProduit> _ficheIncomplete() => _trier([
    for (final p in _suivis)
      if ([
            if ((p.codeBarres ?? '').trim().isEmpty) 'codeBarres',
            if (!p.photo) 'photo',
            if (p.categorieCode == _categorieSysteme || p.sousCategorieCode == _sousCategorieSysteme) 'categorie',
            if (p.prixVente <= 0) 'prix',
          ]
          case final motifs when motifs.isNotEmpty)
        _alerte(
          TypeAlerteProduit.ficheIncomplete,
          p,
          quantite: motifs.length.toDouble(),
          stock: _stock(p.code),
          motifs: motifs,
          critique: motifs.contains('prix'),
        ),
  ], (a) => a.quantite!);

  // 18 · Dans les X % des meilleures marges, mais dans la moitié la moins vendue.
  List<AlerteProduit> _bonneMargePeuVendus() {
    final candidats = [
      for (final p in _suivis)
        if (p.prixVente > 0 && p.prixAchat > 0 && _stock(p.code) > 0)
          (p: p, marge: (p.prixVente - p.prixAchat) / p.prixAchat * 100, vendus: _net(p.code, _p)),
    ];
    if (candidats.length < 4) return const [];
    final parMarge = [...candidats]..sort((a, b) => b.marge.compareTo(a.marge));
    final meilleures = parMarge.take(math.max(1, (candidats.length * s.bonneMargePct / 100).ceil()));
    final parVentes = [...candidats]..sort((a, b) => a.vendus.compareTo(b.vendus));
    final moitie = parVentes.take(candidats.length ~/ 2).map((c) => c.p.code).toSet();
    return [
      for (final c in meilleures)
        if (moitie.contains(c.p.code))
          _alerte(
            TypeAlerteProduit.bonneMargePeuVendus,
            c.p,
            pct: _arrondi(c.marge, 1),
            quantite: c.vendus,
            stock: _stock(c.p.code),
          ),
    ];
  }

  // 19 · Produits arrivés du catalogue BENS après le téléchargement de leur rayon (nouveautés du marché, mises à
  // jour au lancement), depuis moins de X jours, jamais entrés en stock.
  List<AlerteProduit> _nouveautesMarche() => [
    for (final p in produits)
      if (_catalogueAbsent(p) &&
          _depuis(p.creeLe) < s.nouveautesJours &&
          (imports[p.categorieCode] == null ||
              p.creeLe.isAfter(imports[p.categorieCode]!.add(const Duration(minutes: 10)))))
        _alerte(TypeAlerteProduit.nouveautesMarche, p, jours: _depuis(p.creeLe).toDouble()),
  ]..sort((a, b) => a.jours!.compareTo(b.jours!));

  // 20 · Produits que le catalogue BENS signale tendance (vendus dans plusieurs boutiques) et jamais entrés en stock.
  List<AlerteProduit> _tendancesMarche() => [
    for (final p in produits)
      if (_catalogueAbsent(p) && p.tendanceLe != null)
        _alerte(TypeAlerteProduit.tendancesMarche, p, jours: _depuis(p.tendanceLe!).toDouble()),
  ]..sort((a, b) => a.jours!.compareTo(b.jours!));
}
