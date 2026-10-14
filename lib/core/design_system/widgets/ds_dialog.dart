import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../i18n/generated/app_localizations.dart';
import '../tokens/ds_theme.dart';
import 'ds_button.dart';

/// Conteneur de dialogue du design system (titre, contenu, actions).
class DsDialog extends StatelessWidget {
  const DsDialog({
    super.key,
    required this.titre,
    required this.contenu,
    this.actions = const [],
    this.largeur = 480,
    this.icone,
    this.fermable = true,
  });

  final String titre;
  final Widget contenu;
  final List<Widget> actions;
  final double largeur;
  final Widget? icone;
  final bool fermable;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: c.surfaceElevee,
      shape: RoundedRectangleBorder(
        borderRadius: DsRadius.borderLg,
        side: BorderSide(color: c.bordure),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: largeur),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(DsSpacing.xl, DsSpacing.lg, DsSpacing.md, DsSpacing.md),
              child: Row(
                children: [
                  if (icone != null) ...[icone!, const SizedBox(width: DsSpacing.md)],
                  Expanded(child: Text(titre, style: t.titreMd)),
                  if (fermable)
                    DsIconButton(
                      icone: LucideIcons.x,
                      tooltip: l10n.communFermer,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: DsSpacing.xl),
                child: contenu,
              ),
            ),
            if (actions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(DsSpacing.lg),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: DsSpacing.sm),
                      actions[i],
                    ],
                  ],
                ),
              )
            else
              const SizedBox(height: DsSpacing.lg),
          ],
        ),
      ),
    );
  }
}

/// Dialogue de confirmation. Retourne `true` si confirmé.
Future<bool> afficherConfirmation(
  BuildContext context, {
  required String titre,
  required String message,
  String? libelleConfirmer,
  String? libelleAnnuler,
  bool destructif = false,
}) async {
  final l10n = AppLocalizations.of(context);
  final c = context.ds.colors;
  final resultat = await showDialog<bool>(
    context: context,
    barrierColor: c.overlay,
    builder: (ctx) => DsDialog(
      titre: titre,
      icone: Icon(
        destructif ? LucideIcons.triangleAlert : LucideIcons.circleHelp,
        color: destructif ? c.danger : c.primaire,
      ),
      contenu: Text(message, style: ctx.ds.typo.corps),
      actions: [
        DsButton(
          libelle: libelleAnnuler ?? l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        DsButton(
          libelle: libelleConfirmer ?? l10n.communConfirmer,
          variante: destructif ? DsButtonVariante.danger : DsButtonVariante.primaire,
          autofocus: true,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
  return resultat ?? false;
}

enum DsResultatType { succes, erreur, info, avertissement }

/// Dialogue de résultat (succès / erreur / information).
Future<void> afficherResultat(
  BuildContext context, {
  required DsResultatType type,
  required String titre,
  required String message,
}) async {
  final l10n = AppLocalizations.of(context);
  final c = context.ds.colors;
  final (icone, couleur) = switch (type) {
    DsResultatType.succes => (LucideIcons.circleCheck, c.succes),
    DsResultatType.erreur => (LucideIcons.circleX, c.danger),
    DsResultatType.info => (LucideIcons.info, c.info),
    DsResultatType.avertissement => (LucideIcons.triangleAlert, c.avertissement),
  };
  await showDialog<void>(
    context: context,
    barrierColor: c.overlay,
    builder: (ctx) => DsDialog(
      titre: titre,
      icone: Icon(icone, color: couleur),
      contenu: Text(message, style: ctx.ds.typo.corps),
      actions: [
        DsButton(libelle: l10n.communOk, autofocus: true, onPressed: () => Navigator.of(ctx).pop()),
      ],
    ),
  );
}

/// Dialogue de sélection dans une liste filtrable. Retourne l'élément choisi.
Future<T?> afficherSelecteur<T>(
  BuildContext context, {
  required String titre,
  required List<T> elements,
  required String Function(T) libelle,
  String Function(T)? sousLibelle,
  String? indiceRecherche,
}) async {
  final c = context.ds.colors;
  return showDialog<T>(
    context: context,
    barrierColor: c.overlay,
    builder: (ctx) => _SelecteurDialog<T>(
      titre: titre,
      elements: elements,
      libelle: libelle,
      sousLibelle: sousLibelle,
      indiceRecherche: indiceRecherche,
    ),
  );
}

class _SelecteurDialog<T> extends StatefulWidget {
  const _SelecteurDialog({
    required this.titre,
    required this.elements,
    required this.libelle,
    this.sousLibelle,
    this.indiceRecherche,
  });
  final String titre;
  final List<T> elements;
  final String Function(T) libelle;
  final String Function(T)? sousLibelle;
  final String? indiceRecherche;

  @override
  State<_SelecteurDialog<T>> createState() => _SelecteurDialogState<T>();
}

class _SelecteurDialogState<T> extends State<_SelecteurDialog<T>> {
  String _filtre = '';

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final filtres = widget.elements
        .where((e) => widget.libelle(e).toLowerCase().contains(_filtre.toLowerCase()))
        .toList();
    return DsDialog(
      titre: widget.titre,
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            autofocus: true,
            onChanged: (v) => setState(() => _filtre = v),
            style: t.corps,
            decoration: InputDecoration(
              hintText: widget.indiceRecherche ?? l10n.communRechercher,
              prefixIcon: const Icon(LucideIcons.search, size: DsTailles.icone),
              isDense: true,
              border: OutlineInputBorder(borderRadius: DsRadius.borderMd),
            ),
          ),
          const SizedBox(height: DsSpacing.md),
          SizedBox(
            height: 320,
            child: filtres.isEmpty
                ? Center(child: Text(l10n.communAucunResultat, style: t.corps.copyWith(color: c.texteAttenue)))
                : ListView.builder(
                    itemCount: filtres.length,
                    itemBuilder: (ctx, i) {
                      final e = filtres[i];
                      return InkWell(
                        onTap: () => Navigator.of(ctx).pop(e),
                        borderRadius: DsRadius.borderSm,
                        hoverColor: c.surfaceAttenuee,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: DsSpacing.md, vertical: DsSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(widget.libelle(e), style: t.corpsFort),
                              if (widget.sousLibelle != null)
                                Text(widget.sousLibelle!(e), style: t.petit.copyWith(color: c.texteAttenue)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
