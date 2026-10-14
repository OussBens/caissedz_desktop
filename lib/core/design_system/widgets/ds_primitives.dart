import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/ds_theme.dart';

/// Carte de surface standard.
class DsCard extends StatelessWidget {
  const DsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DsSpacing.lg),
    this.elevee = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool elevee;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final contenu = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: elevee ? c.surfaceElevee : c.surface,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: c.bordure),
        boxShadow: elevee ? DsShadows.md : DsShadows.sm,
      ),
      child: child,
    );
    if (onTap == null) return contenu;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: contenu),
    );
  }
}

enum DsBadgeTon { neutre, primaire, succes, avertissement, danger, info }

/// Pastille d'état.
class DsBadge extends StatelessWidget {
  const DsBadge({super.key, required this.libelle, this.ton = DsBadgeTon.neutre, this.icone});

  final String libelle;
  final DsBadgeTon ton;
  final IconData? icone;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final (fond, texte) = switch (ton) {
      DsBadgeTon.neutre => (c.surfaceAttenuee, c.texteSecondaire),
      DsBadgeTon.primaire => (c.primaireDoux, c.primaire),
      DsBadgeTon.succes => (c.succesDoux, c.succes),
      DsBadgeTon.avertissement => (c.avertissementDoux, c.avertissement),
      DsBadgeTon.danger => (c.dangerDoux, c.danger),
      DsBadgeTon.info => (c.infoDoux, c.info),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.sm, vertical: DsSpacing.xxs),
      decoration: BoxDecoration(color: fond, borderRadius: BorderRadius.circular(DsRadius.pill)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[Icon(icone, size: 12, color: texte), const SizedBox(width: DsSpacing.xs)],
          Flexible(
            child: Text(
              libelle,
              style: t.legende.copyWith(color: texte),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Champ de saisie du design system.
class DsTextField extends StatelessWidget {
  const DsTextField({
    super.key,
    this.controller,
    this.libelle,
    this.indice,
    this.erreur,
    this.iconePrefixe,
    this.suffixe,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.obscur = false,
    this.actif = true,
    this.autofocus = false,
    this.lectureSeule = false,
    this.typeClavier,
    this.inputFormatters,
    this.alignement = TextAlign.start,
    this.taille = DsTailles.controleMd,
  });

  final TextEditingController? controller;
  final String? libelle;
  final String? indice;
  final String? erreur;
  final IconData? iconePrefixe;
  final Widget? suffixe;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool obscur;
  final bool actif;
  final bool autofocus;
  final bool lectureSeule;
  final TextInputType? typeClavier;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign alignement;
  final double taille;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    OutlineInputBorder bord(Color couleur, [double largeur = 1]) => OutlineInputBorder(
      borderRadius: DsRadius.borderMd,
      borderSide: BorderSide(color: couleur, width: largeur),
    );
    final champ = SizedBox(
      height: erreur == null ? taille : null,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        obscureText: obscur,
        enabled: actif,
        autofocus: autofocus,
        readOnly: lectureSeule,
        keyboardType: typeClavier,
        inputFormatters: inputFormatters,
        textAlign: alignement,
        style: t.corps,
        cursorColor: c.primaire,
        decoration: InputDecoration(
          isDense: true,
          hintText: indice,
          hintStyle: t.corps.copyWith(color: c.texteAttenue),
          errorText: erreur,
          errorStyle: t.legende.copyWith(color: c.danger),
          prefixIcon: iconePrefixe == null ? null : Icon(iconePrefixe, size: DsTailles.icone, color: c.texteAttenue),
          suffixIcon: suffixe,
          filled: true,
          fillColor: actif ? c.surface : c.surfaceAttenuee,
          contentPadding: const EdgeInsets.symmetric(horizontal: DsSpacing.md, vertical: DsSpacing.sm),
          enabledBorder: bord(c.bordureForte),
          disabledBorder: bord(c.bordure),
          focusedBorder: bord(c.primaire, 2),
          errorBorder: bord(c.danger),
          focusedErrorBorder: bord(c.danger, 2),
        ),
      ),
    );
    if (libelle == null) return champ;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(libelle!, style: t.petitFort.copyWith(color: c.texteSecondaire)),
        const SizedBox(height: DsSpacing.xs),
        champ,
      ],
    );
  }
}

/// Carte d'indicateur (KPI) : libellé, valeur, variation.
class DsStatCard extends StatelessWidget {
  const DsStatCard({
    super.key,
    required this.libelle,
    required this.valeur,
    this.icone,
    this.sousTexte,
    this.ton = DsBadgeTon.primaire,
  });

  final String libelle;
  final String valeur;
  final IconData? icone;
  final String? sousTexte;
  final DsBadgeTon ton;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final (fond, couleur) = switch (ton) {
      DsBadgeTon.neutre => (c.surfaceAttenuee, c.texteSecondaire),
      DsBadgeTon.primaire => (c.primaireDoux, c.primaire),
      DsBadgeTon.succes => (c.succesDoux, c.succes),
      DsBadgeTon.avertissement => (c.avertissementDoux, c.avertissement),
      DsBadgeTon.danger => (c.dangerDoux, c.danger),
      DsBadgeTon.info => (c.infoDoux, c.info),
    };
    return DsCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icone != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: fond, borderRadius: DsRadius.borderMd),
              child: Icon(icone, size: DsTailles.iconeLg, color: couleur),
            ),
            const SizedBox(width: DsSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(libelle, style: t.petit.copyWith(color: c.texteSecondaire)),
                const SizedBox(height: DsSpacing.xs),
                Text(valeur, style: t.chiffreLg, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (sousTexte != null) ...[
                  const SizedBox(height: DsSpacing.xxs),
                  Text(sousTexte!, style: t.legende.copyWith(color: c.texteAttenue)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Séparateur horizontal aux tokens.
class DsDivider extends StatelessWidget {
  const DsDivider({super.key});
  @override
  Widget build(BuildContext context) => Divider(height: 1, thickness: 1, color: context.ds.colors.bordure);
}

/// Titre de section.
class DsSectionTitre extends StatelessWidget {
  const DsSectionTitre(this.texte, {super.key, this.action});
  final String texte;
  final Widget? action;
  @override
  Widget build(BuildContext context) {
    final t = context.ds.typo;
    return Padding(
      padding: const EdgeInsets.only(bottom: DsSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(texte, style: t.titreMd, overflow: TextOverflow.ellipsis),
          ),
          ?action,
        ],
      ),
    );
  }
}
