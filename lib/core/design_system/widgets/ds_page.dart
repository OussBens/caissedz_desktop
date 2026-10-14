import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_primitives.dart';

/// Gabarit de page module : titre, actions, barre de recherche, contenu.
class DsPage extends StatelessWidget {
  const DsPage({
    super.key,
    required this.titre,
    required this.child,
    this.actions = const [],
    this.onRecherche,
    this.indiceRecherche,
    this.filtres,
    this.sousTitre,
    this.defilable = false,
  });

  final String titre;
  final String? sousTitre;
  final Widget child;
  final List<Widget> actions;
  final ValueChanged<String>? onRecherche;
  final String? indiceRecherche;
  final Widget? filtres;

  /// `true` : le contenu est placé dans une liste défilante (formulaires longs).
  final bool defilable;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final entete = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          runSpacing: DsSpacing.sm,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titre, style: t.titreLg),
                if (sousTitre != null) Text(sousTitre!, style: t.petit.copyWith(color: c.texteSecondaire)),
              ],
            ),
            Wrap(spacing: DsSpacing.sm, runSpacing: DsSpacing.sm, children: actions),
          ],
        ),
        if (onRecherche != null || filtres != null) ...[
          const SizedBox(height: DsSpacing.lg),
          Row(
            children: [
              if (onRecherche != null)
                SizedBox(
                  width: 320,
                  child: DsTextField(
                    indice: indiceRecherche ?? l10n.communRechercher,
                    iconePrefixe: LucideIcons.search,
                    onChanged: onRecherche,
                    taille: DsTailles.controleSm + 4,
                  ),
                ),
              if (filtres != null) ...[const SizedBox(width: DsSpacing.md), Expanded(child: filtres!)],
            ],
          ),
        ],
        const SizedBox(height: DsSpacing.lg),
      ],
    );
    if (defilable) {
      return ListView(padding: const EdgeInsets.all(DsSpacing.xl), children: [entete, child]);
    }
    return Padding(
      padding: const EdgeInsets.all(DsSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          entete,
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Onglets horizontaux du DS.
class DsOnglets extends StatelessWidget {
  const DsOnglets({super.key, required this.onglets, required this.courant, required this.onChanged});
  final List<String> onglets;
  final int courant;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.bordure)),
      ),
      child: Row(
        children: [
          for (final (i, o) in onglets.indexed)
            InkWell(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: DsSpacing.lg, vertical: DsSpacing.md),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: i == courant ? c.primaire : const Color(0x00000000), width: 2),
                  ),
                ),
                child: Text(
                  o,
                  style: (i == courant ? t.corpsFort : t.corps).copyWith(
                    color: i == courant ? c.primaire : c.texteSecondaire,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Liste déroulante du DS.
class DsSelect<T> extends StatelessWidget {
  const DsSelect({
    super.key,
    required this.valeur,
    required this.options,
    required this.libelle,
    required this.onChanged,
    this.titre,
    this.erreur,
    this.actif = true,
  });
  final T? valeur;
  final List<T> options;
  final String Function(T) libelle;
  final ValueChanged<T?> onChanged;
  final String? titre;
  final String? erreur;
  final bool actif;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final champ = Container(
      height: DsTailles.controleMd,
      padding: const EdgeInsetsDirectional.only(start: DsSpacing.md, end: DsSpacing.xs),
      decoration: BoxDecoration(
        color: actif ? c.surface : c.surfaceAttenuee,
        borderRadius: DsRadius.borderMd,
        border: Border.all(color: erreur != null ? c.danger : c.bordureForte),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: options.contains(valeur) ? valeur : null,
          isExpanded: true,
          style: t.corps,
          dropdownColor: c.surfaceElevee,
          icon: Icon(LucideIcons.chevronDown, size: DsTailles.iconeSm, color: c.texteAttenue),
          items: [
            for (final o in options)
              DropdownMenuItem(
                value: o,
                child: Text(libelle(o), overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: actif ? onChanged : null,
        ),
      ),
    );
    if (titre == null && erreur == null) return champ;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (titre != null) ...[
          Text(titre!, style: t.petitFort.copyWith(color: c.texteSecondaire)),
          const SizedBox(height: DsSpacing.xs),
        ],
        champ,
        if (erreur != null) ...[
          const SizedBox(height: DsSpacing.xxs),
          Text(erreur!, style: t.legende.copyWith(color: c.danger)),
        ],
      ],
    );
  }
}

/// Interrupteur avec libellé.
class DsSwitch extends StatelessWidget {
  const DsSwitch({super.key, required this.valeur, required this.libelle, required this.onChanged, this.aide});
  final bool valeur;
  final String libelle;
  final String? aide;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return InkWell(
      onTap: () => onChanged(!valeur),
      borderRadius: DsRadius.borderMd,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: DsSpacing.xs),
        child: Row(
          children: [
            Switch(value: valeur, activeTrackColor: c.primaire, onChanged: onChanged),
            const SizedBox(width: DsSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(libelle, style: t.corps),
                  if (aide != null) Text(aide!, style: t.legende.copyWith(color: c.texteAttenue)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Zone vide (aucune donnée) avec icône et action facultative.
class DsVide extends StatelessWidget {
  const DsVide({super.key, required this.message, this.icone = LucideIcons.inbox, this.action});
  final String message;
  final IconData icone;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 40, color: c.texteAttenue),
          const SizedBox(height: DsSpacing.md),
          Text(
            message,
            style: t.corps.copyWith(color: c.texteSecondaire),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[const SizedBox(height: DsSpacing.lg), action!],
        ],
      ),
    );
  }
}

/// Formatage monétaire commun (2 décimales, virgule, devise).
String formaterMontant(double v, [String devise = 'DA']) {
  final neg = v < 0;
  final s = v.abs().toStringAsFixed(2);
  final parties = s.split('.');
  final entier = parties[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');
  return '${neg ? '-' : ''}$entier,${parties[1]} $devise';
}
