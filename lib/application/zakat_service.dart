import 'package:sqflite_common/sqlite_api.dart';

import '../data/historique_repository.dart';
import '../data/statistiques_repository.dart';
import '../data/zakat_repository.dart';
import '../domain/zakat.dart';
import 'parametres_service.dart';

enum ErreurZakat { zakatInconnue, valeurInvalide, dejaPayee, annulee, motifObligatoire }

class ZakatException implements Exception {
  const ZakatException(this.erreur);
  final ErreurZakat erreur;
  @override
  String toString() => 'ZakatException($erreur)';
}

/// Zakat (§9.15) : calculs annuels enregistrés (CRUD), marquage payé, annulation douce avec motif.
class ZakatService {
  const ZakatService(this.db, {required this.utilisateurCode});

  final Database db;
  final String utilisateurCode;

  ZakatRepository get _repo => ZakatRepository(db);

  Future<List<Zakat>> calculs() => _repo.tous();

  Future<String> prochainCode() => _repo.prochainCode();

  /// Valeurs reprises automatiquement : stock au prix d'achat, soldes des caisses, crédits clients et fournisseurs.
  Future<PatrimoineZakat> patrimoine() async {
    final s = StatistiquesRepository(db);
    return PatrimoineZakat(
      stock: await s.valeurStockAchat(),
      liquidites: await s.soldeCaisses(),
      creances: await s.creancesClients(),
      dettes: await s.dettesFournisseurs(),
    );
  }

  /// Nissab et taux par défaut (Paramètres).
  Future<ParametresZakat> parametres() => ParametresService(db, utilisateurCode: utilisateurCode).lireZakat();

  Future<Zakat> creer(Zakat z) => db.transaction((txn) async {
    _valider(z);
    final repo = ZakatRepository(txn);
    final code = await repo.prochainCode();
    final c = _avecCode(z, code);
    await repo.inserer(c, par: utilisateurCode);
    await _journal(txn, 'Création', c);
    return (await repo.parCode(code))!;
  });

  Future<Zakat> modifier(Zakat z) => db.transaction((txn) async {
    final repo = ZakatRepository(txn);
    final avant = await repo.parCode(z.code);
    if (avant == null) throw const ZakatException(ErreurZakat.zakatInconnue);
    if (!avant.actif) throw const ZakatException(ErreurZakat.annulee);
    if (avant.estPayee) throw const ZakatException(ErreurZakat.dejaPayee);
    _valider(z);
    await repo.mettreAJour(z, par: utilisateurCode);
    await _journal(txn, 'Modification', z);
    return (await repo.parCode(z.code))!;
  });

  /// Passe le calcul au statut « Payée » avec la date de paiement.
  Future<Zakat> marquerPayee(String code, {DateTime? le}) => db.transaction((txn) async {
    final repo = ZakatRepository(txn);
    final z = await repo.parCode(code);
    if (z == null) throw const ZakatException(ErreurZakat.zakatInconnue);
    final blocage = blocagePaiement(z);
    if (blocage != null) throw ZakatException(blocage);
    final p = _copie(z, statut: StatutsZakat.payee, datePaiement: le ?? DateTime.now());
    await repo.mettreAJour(p, par: utilisateurCode);
    await _journal(txn, 'Paiement', p);
    return (await repo.parCode(code))!;
  });

  ErreurZakat? blocagePaiement(Zakat z) {
    if (!z.actif) return ErreurZakat.annulee;
    if (z.estPayee) return ErreurZakat.dejaPayee;
    return null;
  }

  ErreurZakat? blocageAnnulation(Zakat z) {
    if (!z.actif) return ErreurZakat.annulee;
    if (z.estPayee) return ErreurZakat.dejaPayee;
    return null;
  }

  Future<void> annuler(List<String> codes, {required String motif}) => db.transaction((txn) async {
    if (motif.trim().isEmpty) throw const ZakatException(ErreurZakat.motifObligatoire);
    final repo = ZakatRepository(txn);
    for (final code in codes) {
      final z = await repo.parCode(code);
      if (z == null) throw const ZakatException(ErreurZakat.zakatInconnue);
      final blocage = blocageAnnulation(z);
      if (blocage != null) throw ZakatException(blocage);
      await repo.annuler(code, par: utilisateurCode, motif: motif.trim());
      await _journal(txn, 'Annulation', z, detail: motif.trim());
    }
  });

  void _valider(Zakat z) {
    final montants = [z.stock, z.liquidites, z.creances, z.dettes, z.nissab];
    if (z.annee < 1900 || montants.any((m) => m < 0) || z.tauxPct <= 0 || z.tauxPct > 100) {
      throw const ZakatException(ErreurZakat.valeurInvalide);
    }
    if (z.dateDue.isBefore(z.debutHawl)) throw const ZakatException(ErreurZakat.valeurInvalide);
  }

  Future<void> _journal(DatabaseExecutor txn, String action, Zakat z, {String? detail}) =>
      HistoriqueRepository(txn).journaliser(
        utilisateurCode: utilisateurCode,
        action: action,
        entite: 'zakat',
        entiteCode: z.code,
        detail: detail ?? '${z.annee} · ${z.montant}',
      );

  static Zakat _avecCode(Zakat z, String code) => Zakat(
    code: code,
    annee: z.annee,
    debutHawl: z.debutHawl,
    dateDue: z.dateDue,
    stock: z.stock,
    liquidites: z.liquidites,
    creances: z.creances,
    dettes: z.dettes,
    nissab: z.nissab,
    tauxPct: z.tauxPct,
    statut: z.statut,
    datePaiement: z.statut == StatutsZakat.payee ? (z.datePaiement ?? DateTime.now()) : null,
    observation: z.observation,
  );

  static Zakat _copie(Zakat z, {required String statut, DateTime? datePaiement}) => Zakat(
    code: z.code,
    annee: z.annee,
    debutHawl: z.debutHawl,
    dateDue: z.dateDue,
    stock: z.stock,
    liquidites: z.liquidites,
    creances: z.creances,
    dettes: z.dettes,
    nissab: z.nissab,
    tauxPct: z.tauxPct,
    statut: statut,
    datePaiement: datePaiement,
    observation: z.observation,
  );
}
