import 'package:sqflite_common/sqlite_api.dart';

import '../core/db/machine_key.dart';
import '../core/licence/cle_activation.dart';
import '../data/licence_repository.dart';
import '../domain/models/licence.dart';
import '../domain/permissions.dart';

enum ErreurActivation { formatInvalide, cleInconnue }

class ActivationException implements Exception {
  const ActivationException(this.erreur);
  final ErreurActivation erreur;
  @override
  String toString() => 'ActivationException($erreur)';
}

/// Activation et lecture de la licence.
class LicenceService {
  const LicenceService(this.db, {this.identifiant = const MachineIdentifiantSysteme(), this.cles = const CleActivation()});

  final Database db;
  final MachineIdentifiant identifiant;
  final CleActivation cles;

  LicenceRepository get _repo => LicenceRepository(db);

  Future<Licence> lire() => _repo.lire();

  /// Identifiant machine affiché à l'utilisateur pour obtenir sa clé.
  Future<String> identifiantMachine() => identifiant.lire();

  /// Active l'application avec une clé SHA-256 (64 hex). Remplace un éventuel mode démo.
  Future<Licence> activer(String cle) async {
    if (!CleActivation.formatValide(cle)) throw const ActivationException(ErreurActivation.formatInvalide);
    final niveau = cles.resoudre(cle, await identifiant.lire());
    if (niveau == null) throw const ActivationException(ErreurActivation.cleInconnue);
    final licence = Licence(niveau: niveau, cle: CleActivation.normaliser(cle));
    await _repo.ecrire(licence);
    return licence;
  }

  /// Entre en mode démo (licence Avancé, sans clé). Refusé si une vraie licence est active.
  Future<Licence> activerDemo() async {
    final courante = await _repo.lire();
    if (courante.estActivee && !courante.demo) return courante;
    const licence = Licence(niveau: NiveauLicence.avance, demo: true);
    await _repo.ecrire(licence);
    return licence;
  }
}
