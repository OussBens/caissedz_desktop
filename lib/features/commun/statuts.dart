import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';

/// Libellé localisé d'un statut du DS (`StatusBadge.presets`).
String libelleStatut(AppLocalizations l10n, String statut) => switch (statut) {
  'actif' => l10n.statutActif,
  'inactif' => l10n.statutInactif,
  'paye' => l10n.statutPaye,
  'partiel' => l10n.statutPartiel,
  'credit' => l10n.statutCredit,
  'annule' => l10n.statutAnnule,
  'enAttente' => l10n.statutBesoinEnAttente,
  'commande' => l10n.statutBesoinCommande,
  'disponible' => l10n.statutBesoinDisponible,
  'ouverte' => l10n.statutOuverte,
  'fermee' => l10n.statutFermee,
  'cloturee' => l10n.statutCloturee,
  'rupture' => l10n.statutRupture,
  'seuil' => l10n.statutSeuil,
  'expire' => l10n.statutExpire,
  'bientotExpire' => l10n.statutBientotExpire,
  'brouillon' => l10n.statutBrouillon,
  'valide' => l10n.statutValide,
  'entree' => l10n.statutEntree,
  'sortie' => l10n.statutSortie,
  'retourne' => l10n.statutRetourne,
  'client' => l10n.statutClient,
  'fournisseur' => l10n.statutFournisseur,
  'recu' => l10n.statutRecu,
  'traite' => l10n.statutTraite,
  'ticket' => l10n.statutTicket,
  'facture' => l10n.statutFacture,
  _ => DsStatut.presets[statut]?.$2 ?? statut,
};

/// Pastille de statut localisée.
class BadgeStatut extends StatelessWidget {
  const BadgeStatut(this.statut, {super.key, this.petit = false});
  final String statut;
  final bool petit;

  @override
  Widget build(BuildContext context) =>
      DsStatusBadge(statut: statut, libelle: libelleStatut(AppLocalizations.of(context), statut), petit: petit);
}

/// Formats communs des écrans de module.
final DateFormat formatDate = DateFormat('dd/MM/yyyy');
final DateFormat formatDateHeure = DateFormat('dd/MM/yyyy HH:mm');

String dateOuTiret(DateTime? d) => d == null ? '—' : formatDate.format(d);

/// Montant sans devise (`f2` du DS) : `1 234,50`.
String f2(double v) => formaterNombre(v, decimales: 2);
