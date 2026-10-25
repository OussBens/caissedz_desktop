import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../application/catalogue_ia_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/codes_barres.dart';
import '../../domain/referentiel/referentiel.dart';
import '../commun/referentiel_ui.dart';
import 'produits_donnees.dart';

/// Fiche trouvée par la reconnaissance IA d'un code-barres : photo, nom (et nom arabe), code-barres, marque,
/// quantité, catégorie, prix et la source qui l'a fournie. Le commerçant répond « C'est ça » (`true`) ou « Ce
/// n'est pas ça » (`false`) ; fermé sans répondre : `null`.
Future<bool?> afficherFicheIa(BuildContext context, FicheProduitIa fiche, {required String devise}) =>
    afficherDialog<bool>(
      context,
      builder: (ctx) => _FicheIaDialog(fiche: fiche, devise: devise),
    );

class _FicheIaDialog extends StatelessWidget {
  const _FicheIaDialog({required this.fiche, required this.devise});
  final FicheProduitIa fiche;
  final String devise;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final f = fiche;
    final photo = imageProduit(f.image, largeur: 672);
    const icone = DsIconBox(LucideIcons.package, taille: 336, tailleIcone: 96);
    final quantite = f.quantite == null
        ? null
        : (f.typeQuantite == null
              ? f.quantite!
              : '${libelleRef(context, Referentiel.typesTaille, f.typeQuantite!)} : ${f.quantite}');
    return DsDialog(
      titre: l10n.iaFicheTitre,
      iconeData: LucideIcons.sparkles,
      ton: DsDialogTon.info,
      largeur: 860,
      actions: [
        DsButton(
          key: const ValueKey('ia_fiche_non'),
          libelle: l10n.iaFicheNon,
          icone: LucideIcons.thumbsDown,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        DsButton(
          key: const ValueKey('ia_fiche_oui'),
          libelle: l10n.iaFicheOui,
          icone: LucideIcons.thumbsUp,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
      contenu: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s4,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DsSpacing.s4,
            children: [
              if (photo == null)
                icone
              else
                ClipRRect(
                  key: const ValueKey('ia_fiche_photo'),
                  borderRadius: DsRadius.borderMd,
                  child: Container(
                    width: 336,
                    height: 336,
                    color: c.surfaceSunken,
                    child: Image(image: photo, fit: BoxFit.contain, errorBuilder: (_, _, _) => icone),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: DsSpacing.s2,
                  children: [
                    Text(f.designation, key: const ValueKey('ia_fiche_nom'), style: t.cardTitle),
                    if (f.designationAr != null)
                      Text(f.designationAr!, textDirection: TextDirection.rtl, style: t.body),
                    DsBadge(
                      key: const ValueKey('ia_fiche_source'),
                      libelle: l10n.iaTrouve(f.source),
                      ton: DsBadgeTon.info,
                      icone: LucideIcons.sparkles,
                    ),
                    DsKeyValueGrid(
                      colonnes: 2,
                      dense: true,
                      items: [
                        DsKeyValue(l10n.produitsColCodeBarres, f.codeBarres, mono: true),
                        DsKeyValue(l10n.iaFicheMarque, f.marque),
                        DsKeyValue(l10n.iaFicheQuantite, quantite),
                        DsKeyValue(l10n.iaFicheCategorie, f.categorie),
                        if (f.prixVente != null) DsKeyValue(l10n.iaFichePrix, formaterMontant(f.prixVente!, devise)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          DsBarcodeCard(
            valeur: f.codeBarres,
            format: CodesBarres.ean13Valide(f.codeBarres) ? DsBarcodeFormat.ean13 : DsBarcodeFormat.code128,
          ),
          if (f.aConfirmer)
            DsNote(
              key: const ValueKey('ia_fiche_a_confirmer'),
              ton: DsBadgeTon.avertissement,
              icone: LucideIcons.users,
              texte: l10n.iaFicheAConfirmer(f.confirmation ?? 0, f.seuilConfirmation ?? 5),
            ),
          Text(l10n.iaFicheQuestion, style: t.bodyStrong.copyWith(color: c.textPrimary)),
        ],
      ),
    );
  }
}
