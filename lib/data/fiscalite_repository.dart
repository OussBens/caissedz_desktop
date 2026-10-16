import 'package:sqflite_common/sqlite_api.dart';

import '../domain/calculs_prix.dart';
import '../domain/fiscalite.dart';
import 'facture_repository.dart';

/// Base HT et TVA d'un taux.
typedef BaseTva = ({double ht, double tva});

/// Éléments de la déclaration mensuelle G50 (TVA et droit de timbre) d'une période.
class DeclarationG50 {
  const DeclarationG50({
    required this.debut,
    required this.fin,
    required this.ventes,
    required this.retoursClients,
    required this.achats,
    required this.retoursFournisseurs,
    required this.timbre,
  });
  final DateTime debut;
  final DateTime fin;

  /// Chiffre d'affaires par taux (tickets validés), retours clients déduits à part.
  final Map<double, BaseTva> ventes;
  final Map<double, BaseTva> retoursClients;

  /// TVA déductible par taux (entrées validées), retours fournisseurs déduits à part.
  final Map<double, BaseTva> achats;
  final Map<double, BaseTva> retoursFournisseurs;
  final double timbre;

  static double _somme(Map<double, BaseTva> m, double Function(BaseTva) f) =>
      CalculsPrix.arrondir(m.values.fold(0.0, (s, b) => s + f(b)));

  /// Taux présents (ventes ou retours), triés décroissants.
  List<double> get taux => {...ventes.keys, ...retoursClients.keys}.toList()..sort((a, b) => b.compareTo(a));

  double get caHt => CalculsPrix.arrondir(_somme(ventes, (b) => b.ht) - _somme(retoursClients, (b) => b.ht));
  double get tvaCollectee => CalculsPrix.arrondir(_somme(ventes, (b) => b.tva) - _somme(retoursClients, (b) => b.tva));
  double get tvaDeductible =>
      CalculsPrix.arrondir(_somme(achats, (b) => b.tva) - _somme(retoursFournisseurs, (b) => b.tva));

  /// TVA à payer (positive) ou crédit de TVA à reporter (négative).
  double get tvaNette => CalculsPrix.arrondir(tvaCollectee - tvaDeductible);
}

/// Lecture des bases fiscales (SQL) pour la G50.
class FiscaliteRepository {
  const FiscaliteRepository(this.db);
  final DatabaseExecutor db;

  /// Bases de la période ; [caisseCode] limite les ventes et retours clients à une caisse (clôture Z).
  Future<DeclarationG50> g50(DateTime debut, DateTime fin, {String? caisseCode}) async {
    final caisse = caisseCode == null ? '' : ' AND v.caisse_code = ?';
    final caisseRetour = caisseCode == null ? '' : ' AND r.caisse_code = ?';
    final d = debut.toUtc().toIso8601String();
    final f = fin.toUtc().toIso8601String();
    Map<double, BaseTva> parTaux(List<Map<String, Object?>> rows, {bool ttc = false}) => {
      for (final r in rows)
        (r['t']! as num).toDouble(): ttc
            ? Fiscalite.ventiler(CalculsPrix.arrondir((r['m']! as num).toDouble()), (r['t']! as num).toDouble())
            : (
                ht: CalculsPrix.arrondir((r['ht']! as num).toDouble()),
                tva: CalculsPrix.arrondir((r['tva']! as num).toDouble()),
              ),
    };
    final ventes = await db.rawQuery(
      '''
      SELECT l.taux_tva t, SUM(l.montant_ht) ht, SUM(l.montant_tva) tva FROM vente_ligne l
      JOIN vente v ON v.code = l.vente_code
      WHERE v.statut = 'Validée' AND v.date >= ? AND v.date <= ?$caisse GROUP BY l.taux_tva
      ''',
      [d, f, ?caisseCode],
    );
    final retoursClients = await db.rawQuery(
      '''
      SELECT COALESCE(vl.taux_tva, 0) t, SUM(rl.total) m FROM retour_ligne rl
      JOIN retour r ON r.code = rl.retour_code
      LEFT JOIN vente_ligne vl ON vl.vente_code = r.document_code AND vl.ordre = rl.ordre_origine
      WHERE r.type = 'Client' AND r.etat = 1 AND r.date >= ? AND r.date <= ?$caisseRetour GROUP BY 1
      ''',
      [d, f, ?caisseCode],
    );
    final achats = await db.rawQuery(
      '''
      SELECT l.taux_tva t, SUM(l.total - l.montant_tva) ht, SUM(l.montant_tva) tva FROM achat_ligne l
      JOIN achat a ON a.code = l.achat_code
      WHERE a.statut = 'Validé' AND a.date >= ? AND a.date <= ? GROUP BY l.taux_tva
      ''',
      [d, f],
    );
    final retoursFournisseurs = await db.rawQuery(
      '''
      SELECT COALESCE(p.tva_pct, 0) t, SUM(rl.total) m FROM retour_ligne rl
      JOIN retour r ON r.code = rl.retour_code LEFT JOIN produit p ON p.code = rl.produit_code
      WHERE r.type = 'Fournisseur' AND r.etat = 1 AND r.date >= ? AND r.date <= ? GROUP BY 1
      ''',
      [d, f],
    );
    return DeclarationG50(
      debut: debut,
      fin: fin,
      ventes: parTaux(ventes),
      retoursClients: parTaux(retoursClients, ttc: true),
      achats: parTaux(achats),
      retoursFournisseurs: parTaux(retoursFournisseurs, ttc: true),
      timbre: await FactureRepository(db).timbres(debut, fin),
    );
  }
}
