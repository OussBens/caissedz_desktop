import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/permissions.dart';
import '../../domain/referentiel/referentiel.dart';
import '../roles/roles_page.dart';

/// Page interne de vérification du design system (clair / sombre / RTL).
class GaleriePage extends ConsumerWidget {
  const GaleriePage({super.key});

  static const String route = '/galerie';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final mode = ref.watch(themeModeProvider);

    return ListView(
      padding: const EdgeInsets.all(DsSpacing.xl),
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.galerieTitre, style: t.titreLg)),
            Text(l10n.galerieLangue, style: t.petitFort.copyWith(color: c.texteSecondaire)),
            const SizedBox(width: DsSpacing.sm),
            for (final l in localesSupportees) ...[
              DsButton(
                libelle: l.languageCode.toUpperCase(),
                taille: DsButtonTaille.sm,
                variante: locale == l ? DsButtonVariante.primaire : DsButtonVariante.secondaire,
                onPressed: () => ref.read(localeProvider.notifier).changer(l),
              ),
              const SizedBox(width: DsSpacing.xs),
            ],
            const SizedBox(width: DsSpacing.lg),
            Text(l10n.galerieTheme, style: t.petitFort.copyWith(color: c.texteSecondaire)),
            const SizedBox(width: DsSpacing.sm),
            DsButton(
              libelle: mode == ThemeMode.dark ? l10n.galerieClair : l10n.galerieSombre,
              icone: mode == ThemeMode.dark ? LucideIcons.sun : LucideIcons.moon,
              taille: DsButtonTaille.sm,
              variante: DsButtonVariante.secondaire,
              onPressed: () => ref.read(themeModeProvider.notifier).basculer(),
            ),
          ],
        ),
        const SizedBox(height: DsSpacing.xl),
        _Section(
          titre: 'Couleurs',
          enfant: Wrap(
            spacing: DsSpacing.sm,
            runSpacing: DsSpacing.sm,
            children: [
              for (final e in {
                'fond': c.fond,
                'surface': c.surface,
                'surfaceAttenuee': c.surfaceAttenuee,
                'bordure': c.bordure,
                'texte': c.texte,
                'texteSecondaire': c.texteSecondaire,
                'primaire': c.primaire,
                'primaireDoux': c.primaireDoux,
                'succes': c.succes,
                'avertissement': c.avertissement,
                'danger': c.danger,
                'info': c.info,
                'sidebarFond': c.sidebarFond,
              }.entries)
                _Pastille(nom: e.key, couleur: e.value),
            ],
          ),
        ),
        _Section(
          titre: 'Typographie',
          enfant: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('titreXl — ${t.famille}', style: t.titreXl),
              Text('titreLg', style: t.titreLg),
              Text('titreMd', style: t.titreMd),
              Text('titreSm', style: t.titreSm),
              Text('corps — Le prix TTC est de 1 250,00 DA', style: t.corps),
              Text('corpsFort', style: t.corpsFort),
              Text('petit', style: t.petit),
              Text('legende', style: t.legende),
              Text('12 345,67 DA', style: t.chiffreXl),
              Text('MAG0001 · CLN0042', style: t.mono),
            ],
          ),
        ),
        _Section(
          titre: 'Boutons',
          enfant: Wrap(
            spacing: DsSpacing.sm,
            runSpacing: DsSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              DsButton(libelle: 'Primaire', icone: LucideIcons.check, onPressed: () {}),
              DsButton(libelle: 'Secondaire', variante: DsButtonVariante.secondaire, onPressed: () {}),
              DsButton(libelle: 'Fantôme', variante: DsButtonVariante.fantome, onPressed: () {}),
              DsButton(libelle: 'Danger', variante: DsButtonVariante.danger, icone: LucideIcons.trash2, onPressed: () {}),
              DsButton(libelle: 'Succès', variante: DsButtonVariante.succes, onPressed: () {}),
              const DsButton(libelle: 'Désactivé'),
              const DsButton(libelle: 'Chargement', chargement: true),
              DsButton(
                libelle: 'Async (garde 2 s)',
                variante: DsButtonVariante.secondaire,
                onPressed: () => Future<void>.delayed(const Duration(seconds: 2)),
              ),
              DsButton(libelle: 'Petit', taille: DsButtonTaille.sm, onPressed: () {}),
              DsButton(libelle: 'Grand', taille: DsButtonTaille.lg, onPressed: () {}),
              DsIconButton(icone: LucideIcons.settings, tooltip: 'Icône', onPressed: () {}),
            ],
          ),
        ),
        const _Section(
          titre: 'Champs',
          enfant: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: DsTextField(libelle: 'Libellé', indice: 'Saisir…', iconePrefixe: LucideIcons.search)),
              SizedBox(width: DsSpacing.md),
              Expanded(child: DsTextField(libelle: 'Erreur', erreur: 'Valeur obligatoire')),
              SizedBox(width: DsSpacing.md),
              Expanded(child: DsTextField(libelle: 'Désactivé', actif: false, indice: 'Non modifiable')),
            ],
          ),
        ),
        _Section(
          titre: 'Pastilles',
          enfant: Wrap(
            spacing: DsSpacing.sm,
            runSpacing: DsSpacing.sm,
            children: [
              for (final ton in DsBadgeTon.values) DsBadge(libelle: ton.name, ton: ton),
              for (final v in Referentiel.statutsBesoin.valeurs)
                DsBadge(libelle: v.libelle(locale), ton: DsBadgeTon.info, icone: LucideIcons.clock),
            ],
          ),
        ),
        const _Section(
          titre: 'Indicateurs',
          enfant: Row(
            children: [
              Expanded(child: DsStatCard(libelle: 'Ventes du jour', valeur: '125 400,00 DA', icone: LucideIcons.receipt, sousTexte: '+12 % vs hier')),
              SizedBox(width: DsSpacing.md),
              Expanded(child: DsStatCard(libelle: 'Tickets', valeur: '87', icone: LucideIcons.ticket, ton: DsBadgeTon.info)),
              SizedBox(width: DsSpacing.md),
              Expanded(child: DsStatCard(libelle: 'Stock sous seuil', valeur: '14', icone: LucideIcons.triangleAlert, ton: DsBadgeTon.avertissement)),
            ],
          ),
        ),
        _Section(
          titre: 'Dialogues',
          enfant: Wrap(
            spacing: DsSpacing.sm,
            children: [
              DsButton(
                libelle: 'Confirmation',
                variante: DsButtonVariante.secondaire,
                onPressed: () => afficherConfirmation(context, titre: 'Supprimer ?', message: 'Cette action est irréversible.', destructif: true),
              ),
              DsButton(
                libelle: 'Résultat succès',
                variante: DsButtonVariante.secondaire,
                onPressed: () => afficherResultat(context, type: DsResultatType.succes, titre: 'Enregistré', message: 'La vente a été encaissée.'),
              ),
              DsButton(
                libelle: 'Résultat erreur',
                variante: DsButtonVariante.secondaire,
                onPressed: () => afficherResultat(context, type: DsResultatType.erreur, titre: 'Échec', message: 'Stock insuffisant.'),
              ),
              DsButton(
                libelle: 'Sélecteur',
                variante: DsButtonVariante.secondaire,
                onPressed: () => afficherSelecteur<ValeurReferentiel>(
                  context,
                  titre: 'Mode de paiement',
                  elements: Referentiel.modesPaiement.valeurs,
                  libelle: (v) => v.libelle(locale),
                  sousLibelle: (v) => v.stocke,
                ),
              ),
            ],
          ),
        ),
        const _Section(
          titre: 'Étapes (assistants)',
          enfant: DsStepper(etapes: ['Boutique', 'Administrateur', 'Marge et vente', 'Récapitulatif'], courante: 1),
        ),
        const _Section(
          titre: 'Garde de licence',
          enfant: SizedBox(height: 220, child: LicenceGate(autorise: false, compact: true, child: SizedBox())),
        ),
        _Section(
          titre: 'Grille des permissions',
          enfant: PermissionGrid(
            lignes: [for (final p in Permission.values.take(3)) PermissionGridLigne(id: p.code, libelle: libellePermission(l10n, p), icone: LucideIcons.shieldCheck)],
            colonnes: [for (final r in Roles.tous) PermissionGridColonne(id: r, libelle: libelleRole(l10n, r), verrouillee: r == Roles.admin, infoVerrou: l10n.rolesAdminTotal)],
            estCoche: (role, id) => Roles.permissionsParDefaut[role]?.contains(Permission.parCode(id)) ?? false,
            onBasculer: (_, _) {},
          ),
        ),
        _Section(
          titre: 'Tableau',
          enfant: SizedBox(
            height: 420,
            child: DsDataTable<_LigneDemo>(
              colonnes: [
                DsColonne(id: 'code', libelle: 'Code', valeur: (l) => l.code, largeur: 110),
                DsColonne(id: 'nom', libelle: 'Désignation', valeur: (l) => l.nom, flex: 2),
                DsColonne(
                  id: 'statut',
                  libelle: 'Statut',
                  valeur: (l) => l.statut,
                  cellule: (ctx, l) => DsBadge(libelle: Referentiel.statutsBesoin.libelle(l.statut, locale), ton: DsBadgeTon.primaire),
                ),
                DsColonne(id: 'qte', libelle: 'Quantité', valeur: (l) => l.quantite, numerique: true, total: (ls) => ls.fold<int>(0, (s, l) => s + l.quantite).toString()),
                DsColonne(id: 'prix', libelle: 'Prix', valeur: (l) => l.prix, numerique: true, visibleParDefaut: false, total: (ls) => '${ls.fold<double>(0, (s, l) => s + l.prix).toStringAsFixed(2)} DA'),
              ],
              lignes: _LigneDemo.exemples,
              cle: (l) => l.code,
              onSelectionChanged: (_) {},
              afficherTotaux: true,
              taillePage: 10,
              actionsContextuelles: [
                DsActionContextuelle(libelle: 'Ouvrir', icone: LucideIcons.externalLink, onSelected: (_) {}),
                DsActionContextuelle(libelle: 'Supprimer', icone: LucideIcons.trash2, destructif: true, onSelected: (_) {}),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.titre, required this.enfant});
  final String titre;
  final Widget enfant;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DsSectionTitre(titre),
          DsCard(child: enfant),
        ],
      ),
    );
  }
}

class _Pastille extends StatelessWidget {
  const _Pastille({required this.nom, required this.couleur});
  final String nom;
  final Color couleur;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Column(
      children: [
        Container(
          width: 72,
          height: 44,
          decoration: BoxDecoration(color: couleur, borderRadius: DsRadius.borderMd, border: Border.all(color: c.bordure)),
        ),
        const SizedBox(height: DsSpacing.xs),
        Text(nom, style: t.legende.copyWith(color: c.texteSecondaire)),
      ],
    );
  }
}

class _LigneDemo {
  const _LigneDemo(this.code, this.nom, this.statut, this.quantite, this.prix);
  final String code;
  final String nom;
  final String statut;
  final int quantite;
  final double prix;

  static final List<_LigneDemo> exemples = [
    for (var i = 1; i <= 23; i++)
      _LigneDemo(
        'PRD${i.toString().padLeft(4, '0')}',
        'Produit de démonstration $i',
        Referentiel.statutsBesoin.valeurs[i % 3].stocke,
        (i * 7) % 40 + 1,
        (i * 125.5) % 2000 + 50,
      ),
  ];
}
