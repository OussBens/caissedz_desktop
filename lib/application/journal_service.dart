import 'package:sqflite_common/sqlite_api.dart';

import '../data/historique_repository.dart';

/// Journalisation des actions qui n'écrivent rien d'autre en base (§9.17) : exports de tableaux et de rapports,
/// export de contrôle fiscal.
class JournalService {
  const JournalService(this.db, {required this.utilisateurCode});

  final DatabaseExecutor db;
  final String utilisateurCode;

  /// Action `Export` : [id] = identifiant du tableau ou du rapport, [format] (`Excel`, `PDF`, `ZIP`…),
  /// [fichier] = nom du fichier écrit (sans dossier).
  Future<void> export({required String id, required String format, String? fichier}) => HistoriqueRepository(db)
      .journaliser(
        utilisateurCode: utilisateurCode,
        action: 'Export',
        entite: 'export',
        entiteCode: id,
        detail: fichier == null ? format : '$format · $fichier',
      );
}
