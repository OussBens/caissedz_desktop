import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';

/// Liste des produits d'un document (action « Liste des produits » à côté de « Détail » : entrées, sorties,
/// transferts, listes de besoins) : tableau des lignes avec totaux, bouton Fermer.
Future<void> afficherListeProduits<T>(
  BuildContext context, {
  required String code,
  required List<T> lignes,
  required List<DsColonne<T>> colonnes,
  required Object Function(T) cle,
}) async {
  final l10n = AppLocalizations.of(context);
  await afficherDialog<void>(
    context,
    builder: (dialogue) => DsDialog(
      key: const ValueKey('liste_produits'),
      titre: l10n.stkListeProduitsTitre(code),
      iconeData: LucideIcons.listOrdered,
      largeur: 900,
      actions: [
        DsButton(
          libelle: l10n.communFermer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(dialogue).pop(),
        ),
      ],
      contenu: DsDataTable<T>(
        dense: true,
        encadre: false,
        pagine: false,
        reserveEcran: 260,
        hauteurFixe: true,
        afficherTotaux: true,
        cle: cle,
        lignes: lignes,
        messageVide: l10n.dsAucunElement,
        colonnes: colonnes,
      ),
    ),
  );
}
