import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../tokens/ds_theme.dart';
import 'ds_button.dart';

/// Teinte stable dérivée d'une chaîne (avatars, tuiles produit) : palette `DsColors.teintes`.
Color teintePour(String? texte) {
  final s = texte ?? '';
  var somme = 0;
  for (final r in s.runes) {
    somme += r;
  }
  return DsColors.teintes[somme % DsColors.teintes.length];
}

/// Carte de surface du DS (`Card`) : fond carte, bordure, rayon 12, ombre xs.
///
/// Avec [titre] : en-tête (icône dans une boîte 28 px, titre 600 14, [actions], icône info).
/// [interactif] ou [onTap] : bordure forte + ombre md au survol.
class DsCard extends StatefulWidget {
  const DsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DsTailles.cardPadding),
    this.elevee = false,
    this.onTap,
    this.titre,
    this.icone,
    this.actions,
    this.info,
    this.interactif = false,
    this.remplir = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  /// Ombre md permanente (popovers, panneaux flottants).
  final bool elevee;
  final VoidCallback? onTap;
  final String? titre;
  final IconData? icone;
  final Widget? actions;
  final String? info;
  final bool interactif;

  /// `true` : la carte prend toute la hauteur disponible (colonne étirée).
  final bool remplir;

  @override
  State<DsCard> createState() => _DsCardState();
}

class _DsCardState extends State<DsCard> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final interactif = widget.interactif || widget.onTap != null;
    final actif = interactif && _survol;
    final pad = widget.padding.resolve(Directionality.of(context));
    final aEnTete = widget.titre != null || widget.actions != null;

    final corps = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: widget.remplir ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (aEnTete)
          Padding(
            padding: EdgeInsets.fromLTRB(pad.left, pad.top, pad.right, 0),
            child: Row(
              spacing: 10,
              children: [
                if (widget.icone != null) DsIconBox(widget.icone!),
                Expanded(
                  child: Text(
                    widget.titre ?? '',
                    style: t.cardTitle.copyWith(height: 1.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                ?widget.actions,
                if (widget.info != null)
                  Tooltip(
                    message: widget.info!,
                    child: Icon(LucideIcons.info, size: DsTailles.iconeSm, color: c.iconMuted),
                  ),
              ],
            ),
          ),
        if (widget.remplir)
          Expanded(
            child: Padding(padding: widget.padding, child: widget.child),
          )
        else
          Padding(padding: widget.padding, child: widget.child),
      ],
    );

    final boite = AnimatedContainer(
      duration: DsMotion.base,
      curve: DsMotion.standard,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: actif ? c.borderStrong : c.borderDefault),
        boxShadow: widget.elevee || actif ? c.shadowMd : c.shadowXs,
      ),
      child: corps,
    );
    if (!interactif) return boite;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.onTap, child: boite),
    );
  }
}

/// Tons du [DsBadge] (`Badge.tone`).
enum DsBadgeTon { neutre, primaire, succes, avertissement, danger, info, accent }

/// Pastille d'état (`Badge`) : hauteur 22 (sm 18), rayon 6, 600 12 (sm 10).
class DsBadge extends StatelessWidget {
  const DsBadge({
    super.key,
    required this.libelle,
    this.ton = DsBadgeTon.neutre,
    this.icone,
    this.point = false,
    this.petit = false,
  });

  final String libelle;
  final DsBadgeTon ton;
  final IconData? icone;

  /// Point coloré devant le libellé (`dot`).
  final bool point;

  /// Taille `sm`.
  final bool petit;

  static (Color fond, Color texte, Color? bordure) couleurs(DsColors c, DsBadgeTon ton) => switch (ton) {
    DsBadgeTon.neutre => (c.surfaceSunken, c.textSecondary, c.borderDefault),
    DsBadgeTon.primaire => (c.primaryTint, c.primaryTintFg, null),
    DsBadgeTon.succes => (c.successTint, c.successFg, null),
    DsBadgeTon.avertissement => (c.warningTint, c.warningFg, null),
    DsBadgeTon.danger => (c.dangerTint, c.dangerFg, null),
    DsBadgeTon.info => (c.infoTint, c.infoFg, null),
    DsBadgeTon.accent => (c.accentTint, c.accentTintFg, null),
  };

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final (fond, texte, bordure) = couleurs(c, ton);
    return Container(
      height: petit ? 18 : 22,
      padding: EdgeInsets.symmetric(horizontal: petit ? 6 : 8),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: DsRadius.borderSm,
        border: Border.all(color: bordure ?? DsColors.transparent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          if (point)
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: texte, shape: BoxShape.circle),
            ),
          if (icone != null) Icon(icone, size: 12, color: texte),
          Flexible(
            child: Text(
              libelle,
              style: t.caption.copyWith(
                fontSize: petit ? 10 : 12,
                fontWeight: FontWeight.w600,
                height: 1,
                letterSpacing: petit ? .4 : 0,
                color: texte,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Statuts métier connus du DS (`StatusBadge.presets`) : ton + libellé FR par défaut.
class DsStatut {
  const DsStatut._();
  static const Map<String, (DsBadgeTon, String)> presets = {
    'actif': (DsBadgeTon.succes, 'Actif'),
    'inactif': (DsBadgeTon.danger, 'Inactif'),
    'paye': (DsBadgeTon.succes, 'Payé'),
    'partiel': (DsBadgeTon.info, 'Partiel'),
    'credit': (DsBadgeTon.avertissement, 'Crédit'),
    'annule': (DsBadgeTon.danger, 'Annulé'),
    'enAttente': (DsBadgeTon.neutre, 'En attente'),
    'recu': (DsBadgeTon.info, 'Reçu'),
    'traite': (DsBadgeTon.succes, 'Traité'),
    'erreur': (DsBadgeTon.danger, 'Erreur'),
    'ouverte': (DsBadgeTon.succes, 'Ouverte'),
    'fermee': (DsBadgeTon.neutre, 'Fermée'),
    'cloturee': (DsBadgeTon.primaire, 'Clôturée'),
    'rupture': (DsBadgeTon.danger, 'En rupture'),
    'seuil': (DsBadgeTon.avertissement, 'Sous le seuil'),
    'expire': (DsBadgeTon.danger, 'Expiré'),
    'bientotExpire': (DsBadgeTon.avertissement, 'Bientôt expiré'),
    'brouillon': (DsBadgeTon.neutre, 'Brouillon'),
    'valide': (DsBadgeTon.succes, 'Validé'),
    'commande': (DsBadgeTon.info, 'Commande'),
    'disponible': (DsBadgeTon.succes, 'Disponible'),
    'entree': (DsBadgeTon.succes, 'Entrée'),
    'sortie': (DsBadgeTon.danger, 'Sortie'),
    'retourne': (DsBadgeTon.avertissement, 'Avec retour'),
    'client': (DsBadgeTon.info, 'Client'),
    'fournisseur': (DsBadgeTon.primaire, 'Fournisseur'),
  };
}

/// Pastille de statut (`StatusBadge`) : point + libellé selon le preset [statut].
class DsStatusBadge extends StatelessWidget {
  const DsStatusBadge({super.key, required this.statut, this.libelle, this.point = true, this.petit = false});
  final String statut;

  /// Libellé traduit (sinon libellé FR du preset).
  final String? libelle;
  final bool point;
  final bool petit;

  @override
  Widget build(BuildContext context) {
    final p = DsStatut.presets[statut] ?? (DsBadgeTon.neutre, statut);
    return DsBadge(libelle: libelle ?? p.$2, ton: p.$1, point: point, petit: petit);
  }
}

/// Variation en % (`TrendBadge`) : accent si favorable, danger sinon.
class DsTrendBadge extends StatelessWidget {
  const DsTrendBadge({super.key, required this.valeur, this.inverser = false, this.texte});

  /// Pourcentage signé (ex. `12.5`, `-3`).
  final double valeur;

  /// `true` quand une hausse est défavorable (achats, dettes).
  final bool inverser;

  /// Texte libre à la place du pourcentage.
  final String? texte;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final hausse = valeur >= 0;
    final bon = inverser ? !hausse : hausse;
    final fond = bon ? c.accentTint : c.dangerTint;
    final couleur = bon ? c.accentTintFg : c.dangerFg;
    final bordure = (bon ? c.accent : c.danger).withValues(alpha: bon ? .3 : .25);
    final v = valeur.abs();
    final libelle =
        texte ?? '${v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1).replaceAll('.', ',')} %';
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: fond,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: bordure),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 2,
        children: [
          Text(
            libelle,
            style: t.caption.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1,
              color: couleur,
              fontFeatures: DsTypography.tabular,
            ),
          ),
          Icon(hausse ? LucideIcons.arrowUpRight : LucideIcons.arrowDownRight, size: 12, color: couleur),
        ],
      ),
    );
  }
}

/// Infobulle seulement s'il y a un message.
class _Infobulle extends StatelessWidget {
  const _Infobulle({required this.message, required this.child});
  final String? message;
  final Widget child;

  @override
  Widget build(BuildContext context) => message == null ? child : Tooltip(message: message!, child: child);
}

/// Carte d'indicateur (`StatCard`) : titre, valeur 700 28 tabulaire, tendance, légende.
class DsStatCard extends StatelessWidget {
  const DsStatCard({
    super.key,
    required this.libelle,
    required this.valeur,
    this.icone,
    this.sousTexte,
    this.ton = DsBadgeTon.primaire,
    this.prefixe,
    this.suffixe,
    this.tendance,
    this.tendanceInverser = false,
    this.info,
    this.onTap,
  });

  final String libelle;

  /// Valeur déjà formatée (chiffres tabulaires).
  final String valeur;
  final IconData? icone;

  /// Légende sous la valeur (`caption`).
  final String? sousTexte;

  /// Conservé pour compatibilité (lots 0 à 9) ; sans effet visuel dans le DS v2.2.
  final DsBadgeTon ton;
  final String? prefixe;

  /// Unité affichée après la valeur (ex. « DA »).
  final String? suffixe;

  /// Variation en % par rapport à la période précédente.
  final double? tendance;
  final bool tendanceInverser;
  final String? info;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return DsCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: DsSpacing.s3,
        children: [
          Row(
            spacing: 10,
            children: [
              if (icone != null) DsIconBox(icone!),
              Expanded(
                child: Text(
                  libelle,
                  style: t.body.copyWith(fontWeight: FontWeight.w500, height: 1.3, color: c.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Cliquable : une flèche dit qu'on part vers un autre module (l'explication en infobulle) ;
              // sinon l'icône « info ».
              if (onTap != null)
                _Infobulle(
                  message: info,
                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? LucideIcons.arrowUpLeft
                        : LucideIcons.arrowUpRight,
                    key: const ValueKey('stat_fleche'),
                    size: DsTailles.icone,
                    color: c.iconActive,
                  ),
                )
              else if (info != null)
                Tooltip(
                  message: info!,
                  child: Icon(LucideIcons.info, size: DsTailles.iconeSm, color: c.iconMuted),
                ),
            ],
          ),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 4,
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    if (prefixe != null)
                      TextSpan(
                        text: '$prefixe ',
                        style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w500),
                      ),
                    TextSpan(text: valeur),
                    if (suffixe != null)
                      TextSpan(
                        text: ' $suffixe',
                        style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w500, fontSize: 18),
                      ),
                  ],
                ),
                style: t.kpi,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (tendance != null) DsTrendBadge(valeur: tendance!, inverser: tendanceInverser),
            ],
          ),
          if (sousTexte != null)
            Padding(
              padding: const EdgeInsets.only(top: -4 + 4),
              child: Text(sousTexte!, style: t.caption.copyWith(color: c.textMuted)),
            ),
        ],
      ),
    );
  }
}

/// Champ de saisie du DS (`TextField`) : libellé 500 13 au-dessus, boîte 36 (sm 32, lg 44),
/// rayon 8, anneau de focus, aide / erreur 12 en dessous.
class DsTextField extends StatefulWidget {
  const DsTextField({
    super.key,
    this.controller,
    this.libelle,
    this.indice,
    this.erreur,
    this.aide,
    this.iconePrefixe,
    this.suffixe,
    this.suffixeTexte,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.obscur = false,
    this.actif = true,
    this.autofocus = false,
    this.lectureSeule = false,
    this.obligatoire = false,
    this.numerique = false,
    this.multiligne = false,
    this.lignes = 3,
    this.typeClavier,
    this.inputFormatters,
    this.alignement = TextAlign.start,
    this.taille = DsTailles.controleMd,
    this.largeur,
    this.valeurInitiale,
    this.ltr,
  });

  final TextEditingController? controller;
  final String? libelle;
  final String? indice;
  final String? erreur;
  final String? aide;
  final IconData? iconePrefixe;

  /// Widget de fin (bouton œil, action…).
  final Widget? suffixe;

  /// Unité de fin (« DA », « % »…).
  final String? suffixeTexte;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FocusNode? focusNode;
  final bool obscur;
  final bool actif;
  final bool autofocus;
  final bool lectureSeule;

  /// Astérisque rouge après le libellé.
  final bool obligatoire;

  /// Alignement à droite, chiffres tabulaires, clavier décimal.
  final bool numerique;
  final bool multiligne;
  final int lignes;
  final TextInputType? typeClavier;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign alignement;

  /// Hauteur de la boîte (32 / 36 / 44).
  final double taille;
  final double? largeur;
  final String? valeurInitiale;

  /// Saisie de gauche à droite même en arabe. Par défaut : les champs [numerique] et les claviers
  /// numériques ou téléphone.
  final bool? ltr;

  @override
  State<DsTextField> createState() => _DsTextFieldState();
}

bool _clavierChiffres(TextInputType? t) =>
    t != null && (t.index == TextInputType.number.index || t.index == TextInputType.phone.index);

/// [TextAlign.start] / [TextAlign.end] de la langue, en gauche / droite (le champ passe en LTR).
TextAlign _alignementPhysique(TextAlign a, {required bool rtl}) => switch (a) {
  TextAlign.start => rtl ? TextAlign.right : TextAlign.left,
  TextAlign.end => rtl ? TextAlign.left : TextAlign.right,
  _ => a,
};

class _DsTextFieldState extends State<DsTextField> {
  FocusNode? _interne;
  bool _focus = false;

  /// Contrôleur interne quand [DsTextField.valeurInitiale] est fourni sans contrôleur.
  TextEditingController? _controleurInterne;

  FocusNode get _node => widget.focusNode ?? (_interne ??= FocusNode());

  TextEditingController? get _controleur => widget.controller ?? _controleurInterne;

  @override
  void initState() {
    super.initState();
    _node.addListener(_ecoute);
    if (widget.controller == null && widget.valeurInitiale != null) {
      _controleurInterne = TextEditingController(text: widget.valeurInitiale);
    }
  }

  @override
  void didUpdateWidget(covariant DsTextField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _interne)?.removeListener(_ecoute);
      _node.addListener(_ecoute);
    }
    if (widget.controller == null && widget.valeurInitiale != old.valeurInitiale) {
      // Champ en lecture seule alimenté par l'écran (ex. valeur choisie dans un sélecteur).
      if (_controleurInterne == null) {
        _controleurInterne = TextEditingController(text: widget.valeurInitiale);
      } else if (!widget.actif || widget.lectureSeule) {
        _controleurInterne!.text = widget.valeurInitiale ?? '';
      }
    }
  }

  void _ecoute() {
    if (mounted && _focus != _node.hasFocus) setState(() => _focus = _node.hasFocus);
  }

  @override
  void dispose() {
    _node.removeListener(_ecoute);
    _interne?.dispose();
    _controleurInterne?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final erreur = widget.erreur;
    final desactive = !widget.actif;
    final styleTexte = (widget.taille >= DsTailles.controleLg ? t.body.copyWith(fontSize: 15) : t.body).copyWith(
      height: 1.4,
      color: c.textPrimary,
      fontFeatures: widget.numerique ? DsTypography.tabular : null,
    );
    final couleurBordure = erreur != null ? c.danger : (_focus ? c.borderFocus : c.borderDefault);
    // Chiffres (montants, quantités, téléphones) : toujours saisis de gauche à droite, même en arabe ;
    // l'alignement reste celui de la langue (début / fin résolus avant de passer en LTR).
    final ltr = widget.ltr ?? (widget.numerique || _clavierChiffres(widget.typeClavier));
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final alignement = widget.numerique ? TextAlign.end : widget.alignement;
    final champ = TextField(
      controller: _controleur,
      focusNode: _node,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      obscureText: widget.obscur,
      enabled: widget.actif,
      autofocus: widget.autofocus,
      readOnly: widget.lectureSeule,
      keyboardType:
          widget.typeClavier ??
          (widget.numerique
              ? const TextInputType.numberWithOptions(decimal: true)
              : (widget.multiligne ? TextInputType.multiline : null)),
      inputFormatters: widget.inputFormatters,
      textAlign: ltr ? _alignementPhysique(alignement, rtl: rtl) : alignement,
      textDirection: ltr ? TextDirection.ltr : null,
      maxLines: widget.multiligne ? widget.lignes : 1,
      style: styleTexte,
      cursorColor: c.primary,
      decoration: InputDecoration(
        isDense: true,
        isCollapsed: true,
        hintText: widget.indice,
        hintTextDirection: ltr ? TextDirection.ltr : null,
        hintStyle: styleTexte.copyWith(color: c.textMuted),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        filled: false,
      ),
    );

    final boite = AnimatedContainer(
      duration: DsMotion.fast,
      curve: DsMotion.standard,
      height: widget.multiligne ? null : widget.taille,
      padding: widget.multiligne
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 9)
          : const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: desactive ? c.surfaceSunken : c.surfaceCard,
        borderRadius: DsRadius.borderMd,
        border: Border.all(color: couleurBordure),
        boxShadow: _focus
            ? [BoxShadow(color: erreur != null ? c.dangerTint : c.ringFocus, spreadRadius: 3)]
            : c.shadowXs,
      ),
      child: Row(
        crossAxisAlignment: widget.multiligne ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        spacing: DsSpacing.s2,
        children: [
          if (widget.iconePrefixe != null)
            Padding(
              padding: EdgeInsets.only(top: widget.multiligne ? 2 : 0),
              child: Icon(widget.iconePrefixe, size: DsTailles.iconeSm, color: _focus ? c.iconActive : c.iconMuted),
            ),
          Expanded(child: champ),
          if (widget.suffixeTexte != null) Text(widget.suffixeTexte!, style: t.label.copyWith(color: c.textMuted)),
          ?widget.suffixe,
        ],
      ),
    );

    final colonne = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        if (widget.libelle != null)
          Text.rich(
            TextSpan(
              text: widget.libelle,
              children: [
                if (widget.obligatoire)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: c.danger),
                  ),
              ],
            ),
            style: t.label.copyWith(height: 1.3, color: c.textBody),
          ),
        Opacity(opacity: desactive ? .7 : 1, child: boite),
        if (erreur != null || widget.aide != null)
          Row(
            spacing: 4,
            children: [
              if (erreur != null) Icon(LucideIcons.circleAlert, size: 13, color: c.dangerFg),
              Flexible(
                child: Text(
                  erreur ?? widget.aide!,
                  style: t.caption.copyWith(height: 1.4, color: erreur != null ? c.dangerFg : c.textMuted),
                ),
              ),
            ],
          ),
      ],
    );
    if (widget.largeur != null) return SizedBox(width: widget.largeur, child: colonne);
    return colonne;
  }
}

/// Séparateur horizontal aux tokens.
class DsDivider extends StatelessWidget {
  const DsDivider({super.key, this.subtil = false});
  final bool subtil;
  @override
  Widget build(BuildContext context) => Divider(
    height: 1,
    thickness: 1,
    color: subtil ? context.ds.colors.borderSubtle : context.ds.colors.borderDefault,
  );
}

/// Titre de section (600 14) avec action facultative.
class DsSectionTitre extends StatelessWidget {
  const DsSectionTitre(this.texte, {super.key, this.action, this.icone, this.surligne = false});
  final String texte;
  final Widget? action;
  final IconData? icone;

  /// Style `overline` (11 px capitales) pour les sous-titres de groupe.
  final bool surligne;
  @override
  Widget build(BuildContext context) {
    final t = context.ds.typo;
    final c = context.ds.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: DsSpacing.s3),
      child: Row(
        spacing: DsSpacing.s2,
        children: [
          if (icone != null) Icon(icone, size: DsTailles.iconeSm, color: c.iconActive),
          Expanded(
            child: Text(
              surligne ? texte.toUpperCase() : texte,
              style: surligne ? t.overline.copyWith(color: c.textMuted) : t.cardTitle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Avatar à initiales (`Avatar`) : teinte stable par nom, rond ou carré.
class DsAvatar extends StatelessWidget {
  const DsAvatar({super.key, required this.nom, this.taille = 32, this.carre = false});
  final String nom;
  final double taille;
  final bool carre;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final mots = nom.trim().split(RegExp(r'\s+')).where((m) => m.isNotEmpty).take(2);
    final initiales = mots.map((m) => m.characters.first.toUpperCase()).join();
    return Tooltip(
      message: nom,
      child: Container(
        width: taille,
        height: taille,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: teintePour(nom),
          shape: carre ? BoxShape.rectangle : BoxShape.circle,
          borderRadius: carre ? BorderRadius.circular((taille * .25).roundToDouble()) : null,
          border: Border.all(color: c.borderSubtle),
        ),
        child: Text(
          initiales,
          style: t.body.copyWith(
            fontSize: (taille * .38).roundToDouble(),
            fontWeight: FontWeight.w600,
            height: 1,
            color: DsColors.blanc,
          ),
        ),
      ),
    );
  }
}

/// Logo de la marque (`Logo`) : tuile dégradée avec le glyphe panier et le mot-symbole « Caisse DZ ».
class DsLogo extends StatelessWidget {
  const DsLogo({super.key, this.taille = 28, this.afficherTexte = true, this.inverse = false});
  final double taille;
  final bool afficherTexte;

  /// Sur fond sombre (écran de connexion) : tuile blanche, texte blanc.
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: (taille * .36).roundToDouble(),
      children: [
        Container(
          width: taille,
          height: taille,
          decoration: BoxDecoration(
            color: inverse ? DsColors.blanc : null,
            gradient: inverse ? null : DsColors.gradientBrand,
            borderRadius: BorderRadius.circular((taille * .28).roundToDouble()),
            boxShadow: [
              BoxShadow(
                color: DsColors.violet700.withValues(alpha: .6),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: -4,
              ),
            ],
          ),
          child: CustomPaint(painter: _GlyphePanier(inverse ? DsColors.violet700 : DsColors.blanc)),
        ),
        if (afficherTexte)
          Text.rich(
            TextSpan(
              text: 'Caisse',
              children: [
                TextSpan(
                  text: ' DZ',
                  style: TextStyle(color: inverse ? DsColors.violet300 : c.brand),
                ),
              ],
            ),
            style: t.heading.copyWith(
              fontSize: (taille * .64).roundToDouble(),
              fontWeight: FontWeight.w700,
              height: 1,
              letterSpacing: -(taille * .64) * .02,
              color: inverse ? DsColors.blanc : c.textPrimary,
            ),
          ),
      ],
    );
  }
}

/// Glyphe « panier + » du logo (viewBox 32 × 32), tracé aux traits.
class _GlyphePanier extends CustomPainter {
  const _GlyphePanier(this.couleur);
  final Color couleur;

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / 32;
    final trait = Paint()
      ..color = couleur
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * k
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final plein = Paint()..color = couleur;
    final marge = size.width * .13;
    canvas.translate(marge, marge);
    final s = (size.width - 2 * marge) / 32;
    Offset p(double x, double y) => Offset(x * s, y * s);
    final chemin = Path()
      ..moveTo(4 * s, 6 * s)
      ..lineTo(7 * s, 6 * s)
      ..lineTo(9.6 * s, 19.2 * s)
      ..quadraticBezierTo(10 * s, 20.8 * s, 11.6 * s, 20.8 * s)
      ..lineTo(22.4 * s, 20.8 * s)
      ..quadraticBezierTo(24 * s, 20.8 * s, 24.4 * s, 19.3 * s)
      ..lineTo(27 * s, 11 * s)
      ..lineTo(9.2 * s, 11 * s);
    canvas.drawPath(chemin, trait..strokeWidth = 2.4 * k * (32 * s / size.width));
    canvas.drawCircle(p(12.5, 26), 1.6 * s, plein);
    canvas.drawCircle(p(22.5, 26), 1.6 * s, plein);
    final plus = trait..strokeWidth = 2 * s;
    canvas.drawLine(p(17.5, 13.2), p(17.5, 17.8), plus);
    canvas.drawLine(p(15.2, 15.5), p(19.8, 15.5), plus);
  }

  @override
  bool shouldRepaint(covariant _GlyphePanier old) => old.couleur != couleur;
}

/// Tons de la barre de progression.
enum DsProgressTon { primaire, accent, succes, avertissement, danger }

/// Barre de progression (`ProgressBar`) : piste `chartTrack`, hauteur 6, rayon 4.
class DsProgressBar extends StatelessWidget {
  const DsProgressBar({
    super.key,
    required this.valeur,
    this.max = 100,
    this.ton = DsProgressTon.primaire,
    this.hauteur = 6,
    this.afficherLibelle = false,
    this.couleur,
  });
  final double valeur;
  final double max;
  final DsProgressTon ton;
  final double hauteur;
  final bool afficherLibelle;
  final Color? couleur;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final p = max <= 0 ? 0.0 : (valeur / max).clamp(0.0, 1.0);
    final couleurBarre =
        couleur ??
        switch (ton) {
          DsProgressTon.primaire => c.primary,
          DsProgressTon.accent => c.accent,
          DsProgressTon.succes => c.success,
          DsProgressTon.avertissement => c.warning,
          DsProgressTon.danger => c.danger,
        };
    return Row(
      spacing: 10,
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: DsRadius.borderXs,
            child: Container(
              height: hauteur,
              color: c.chartTrack,
              alignment: AlignmentDirectional.centerStart,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: p),
                duration: DsMotion.slower,
                curve: DsMotion.emphasized,
                builder: (_, v, _) => FractionallySizedBox(
                  widthFactor: v,
                  child: Container(
                    decoration: BoxDecoration(color: couleurBarre, borderRadius: DsRadius.borderXs),
                  ),
                ),
              ),
            ),
          ),
        ),
        if (afficherLibelle)
          SizedBox(
            width: 36,
            child: Text(
              '${(p * 100).round()} %',
              textAlign: TextAlign.end,
              style: t.label.copyWith(color: c.textSecondary, fontFeatures: DsTypography.tabular),
            ),
          ),
      ],
    );
  }
}

/// Élément d'un [DsKeyValueGrid].
class DsKeyValue {
  const DsKeyValue(this.libelle, this.valeur, {this.fort = false, this.mono = false, this.span = 1, this.widget});
  final String libelle;
  final String? valeur;
  final bool fort;
  final bool mono;

  /// Nombre de colonnes occupées.
  final int span;

  /// Rendu personnalisé de la valeur (badge, lien…).
  final Widget? widget;
}

/// Grille libellé / valeur (`KeyValueGrid`) des fiches de détail.
class DsKeyValueGrid extends StatelessWidget {
  const DsKeyValueGrid({super.key, required this.items, this.colonnes = 3, this.dense = false});
  final List<DsKeyValue> items;
  final int colonnes;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final gapX = dense ? 20.0 : 24.0;
    final gapY = dense ? 12.0 : 16.0;
    return LayoutBuilder(
      builder: (context, contraintes) {
        final largeurCol = (contraintes.maxWidth - gapX * (colonnes - 1)) / colonnes;
        return Wrap(
          spacing: gapX,
          runSpacing: gapY,
          children: [
            for (final it in items)
              SizedBox(
                width: largeurCol * it.span.clamp(1, colonnes) + gapX * (it.span.clamp(1, colonnes) - 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      it.libelle,
                      style: t.caption.copyWith(fontWeight: FontWeight.w500, height: 1.3, color: c.textMuted),
                    ),
                    it.widget ??
                        Text(
                          (it.valeur == null || it.valeur!.isEmpty) ? '—' : it.valeur!,
                          style: (it.mono ? t.mono.copyWith(fontSize: 14) : t.body).copyWith(
                            fontWeight: it.fort ? FontWeight.w600 : FontWeight.w500,
                            height: 1.4,
                            color: (it.valeur == null || it.valeur!.isEmpty) ? c.textDisabled : c.textPrimary,
                            fontFeatures: DsTypography.tabular,
                          ),
                        ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Section de fiche de détail (`DetailSection`) : en-tête enfoncé 44 px, compteur, repliable.
class DsDetailSection extends StatefulWidget {
  const DsDetailSection({
    super.key,
    required this.titre,
    required this.child,
    this.icone,
    this.compte,
    this.actions,
    this.padding = const EdgeInsets.all(DsSpacing.s4),
    this.repliable = false,
    this.ouverteParDefaut = true,
  });
  final String titre;
  final Widget child;
  final IconData? icone;
  final int? compte;
  final Widget? actions;
  final EdgeInsetsGeometry padding;
  final bool repliable;
  final bool ouverteParDefaut;

  @override
  State<DsDetailSection> createState() => _DsDetailSectionState();
}

class _DsDetailSectionState extends State<DsDetailSection> {
  late bool _ouverte = widget.ouverteParDefaut;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final ouverte = !widget.repliable || _ouverte;
    final enTete = Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsetsDirectional.only(start: DsSpacing.s4, end: DsSpacing.s3),
      decoration: BoxDecoration(
        color: c.surfaceSunken,
        border: ouverte ? Border(bottom: BorderSide(color: c.borderDefault)) : null,
      ),
      child: Row(
        spacing: 10,
        children: [
          if (widget.icone != null) Icon(widget.icone, size: DsTailles.iconeSm, color: c.iconActive),
          Expanded(
            child: Text(widget.titre, style: t.cardTitle, overflow: TextOverflow.ellipsis),
          ),
          if (widget.compte != null)
            Container(
              height: 20,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: c.surfaceCard,
                borderRadius: DsRadius.borderPill,
                border: Border.all(color: c.borderDefault),
              ),
              child: Text(
                '${widget.compte}',
                style: t.caption.copyWith(fontWeight: FontWeight.w600, height: 1, color: c.textSecondary),
              ),
            ),
          ?widget.actions,
          if (widget.repliable)
            AnimatedRotation(
              turns: _ouverte ? .5 : 0,
              duration: DsMotion.base,
              curve: DsMotion.standard,
              child: Icon(LucideIcons.chevronDown, size: DsTailles.iconeSm, color: c.iconMuted),
            ),
        ],
      ),
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: c.surfaceCard,
        borderRadius: DsRadius.borderLg,
        border: Border.all(color: c.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.repliable) InkWell(onTap: () => setState(() => _ouverte = !_ouverte), child: enTete) else enTete,
          if (ouverte) Padding(padding: widget.padding, child: widget.child),
        ],
      ),
    );
  }
}

/// Élément d'un [DsStatsStrip].
class DsStatItem {
  const DsStatItem({required this.libelle, required this.valeur, this.icone, this.ton, this.suffixe, this.tonValeur});
  final String libelle;
  final String? valeur;
  final IconData? icone;
  final DsBadgeTon? ton;
  final String? suffixe;
  final DsBadgeTon? tonValeur;
}

/// Bandeau de compteurs (`StatsStrip`) : tuiles icône teintée + libellé + valeur 700 22.
class DsStatsStrip extends StatelessWidget {
  const DsStatsStrip({super.key, required this.items, this.compact = false, this.largeurMin = 150});
  final List<DsStatItem> items;
  final bool compact;
  final double largeurMin;

  static const _rotation = [
    DsBadgeTon.primaire,
    DsBadgeTon.info,
    DsBadgeTon.succes,
    DsBadgeTon.accent,
    DsBadgeTon.avertissement,
    DsBadgeTon.danger,
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final gap = compact ? 8.0 : 12.0;
    return LayoutBuilder(
      builder: (context, contraintes) {
        final n = ((contraintes.maxWidth + gap) / (largeurMin + gap)).floor().clamp(1, items.length);
        final largeur = (contraintes.maxWidth - gap * (n - 1)) / n;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final (i, it) in items.indexed)
              SizedBox(
                width: largeur,
                child: Container(
                  padding: EdgeInsets.all(compact ? 12 : 16),
                  decoration: BoxDecoration(
                    color: c.surfaceCard,
                    borderRadius: DsRadius.borderLg,
                    border: Border.all(color: c.borderDefault),
                  ),
                  child: Builder(
                    builder: (context) {
                      final ton = it.ton ?? _rotation[i % _rotation.length];
                      final (fond, couleur, _) = ton == DsBadgeTon.neutre
                          ? (c.surfaceSunken, c.iconDefault, null)
                          : DsBadge.couleurs(c, ton);
                      final couleurValeur = it.tonValeur == null
                          ? c.textPrimary
                          : DsBadge.couleurs(c, it.tonValeur!).$2;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: compact ? 8 : 12,
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              Container(
                                width: compact ? 26 : 30,
                                height: compact ? 26 : 30,
                                decoration: BoxDecoration(color: fond, borderRadius: DsRadius.borderMd),
                                child: Icon(it.icone ?? LucideIcons.hash, size: compact ? 14 : 16, color: couleur),
                              ),
                              Expanded(
                                child: Text(
                                  it.libelle,
                                  style: t.label.copyWith(fontSize: 12.5, height: 1.3, color: c.textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Text.rich(
                            TextSpan(
                              text: it.valeur ?? '—',
                              children: [
                                if (it.suffixe != null)
                                  TextSpan(
                                    text: ' ${it.suffixe}',
                                    style: t.label.copyWith(color: c.textMuted),
                                  ),
                              ],
                            ),
                            style: t.kpi.copyWith(fontSize: compact ? 18 : 22, height: 1, color: couleurValeur),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Tons du toast.
enum DsToastTon { succes, danger, avertissement, info }

/// Notification flottante (`Toast`) : 360 px, icône tonale, titre 600 14, description.
class DsToast extends StatelessWidget {
  const DsToast({
    super.key,
    required this.titre,
    this.description,
    this.ton = DsToastTon.succes,
    this.onFermer,
    this.action,
  });
  final String titre;
  final String? description;
  final DsToastTon ton;
  final VoidCallback? onFermer;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final (icone, couleur) = switch (ton) {
      DsToastTon.succes => (LucideIcons.circleCheck, c.success),
      DsToastTon.danger => (LucideIcons.circleX, c.danger),
      DsToastTon.avertissement => (LucideIcons.triangleAlert, c.warning),
      DsToastTon.info => (LucideIcons.info, c.info),
    };
    return Material(
      color: DsColors.transparent,
      child: Container(
        width: 360,
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 14, 14),
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: DsRadius.borderLg,
          border: Border.all(color: c.borderDefault),
          boxShadow: c.shadowMd,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icone, size: DsTailles.icone, color: couleur),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(titre, style: t.bodyStrong.copyWith(height: 1.35)),
                  if (description != null)
                    Text(description!, style: t.bodySm.copyWith(height: 1.45, color: c.textSecondary)),
                  if (action != null) Padding(padding: const EdgeInsets.only(top: 6), child: action),
                ],
              ),
            ),
            if (onFermer != null)
              GestureDetector(
                onTap: onFermer,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(LucideIcons.x, size: DsTailles.iconeSm, color: c.iconMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Affiche un [DsToast] en bas à droite (en bas à gauche en RTL) pendant [duree].
void afficherToast(
  BuildContext context, {
  required String titre,
  String? description,
  DsToastTon ton = DsToastTon.succes,
  Duration duree = const Duration(seconds: 4),
  String? libelleAction,
  IconData? iconeAction,
  VoidCallback? onAction,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  late OverlayEntry entree;
  entree = OverlayEntry(
    builder: (ctx) => PositionedDirectional(
      end: DsSpacing.s6,
      bottom: DsSpacing.s6,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: DsMotion.slow,
        curve: DsMotion.emphasized,
        builder: (_, v, enfant) => Opacity(
          opacity: v,
          child: Transform.translate(offset: Offset(0, (1 - v) * 8), child: enfant),
        ),
        child: DsToast(
          titre: titre,
          description: description,
          ton: ton,
          onFermer: () => entree.remove(),
          action: libelleAction == null
              ? null
              : DsButton(
                  libelle: libelleAction,
                  icone: iconeAction,
                  taille: DsButtonTaille.sm,
                  variante: DsButtonVariante.secondaire,
                  onPressed: () {
                    if (entree.mounted) entree.remove();
                    onAction?.call();
                  },
                ),
        ),
      ),
    ),
  );
  overlay.insert(entree);
  Future<void>.delayed(duree, () {
    if (entree.mounted) entree.remove();
  });
}

/// Encart d'information teinté (`Note` du DS v2.2) : icône, texte, action facultative.
class DsNote extends StatelessWidget {
  const DsNote({super.key, required this.texte, this.ton = DsBadgeTon.info, this.icone, this.action});
  final String texte;
  final DsBadgeTon ton;
  final IconData? icone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final (fond, texteCouleur) = switch (ton) {
      DsBadgeTon.succes => (c.successTint, c.successFg),
      DsBadgeTon.avertissement => (c.warningTint, c.warningFg),
      DsBadgeTon.danger => (c.dangerTint, c.dangerFg),
      DsBadgeTon.primaire || DsBadgeTon.accent => (c.primaryTint, c.primaryTintFg),
      DsBadgeTon.neutre => (c.surfaceSunken, c.textSecondary),
      DsBadgeTon.info => (c.infoTint, c.infoFg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s3, vertical: DsSpacing.s2 + 2),
      decoration: BoxDecoration(color: fond, borderRadius: DsRadius.borderLg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: DsSpacing.s2,
        children: [
          Icon(icone ?? LucideIcons.info, size: 15, color: texteCouleur),
          Expanded(
            child: Text(
              texte,
              style: t.bodySm.copyWith(fontWeight: FontWeight.w500, height: 1.45, color: texteCouleur),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
