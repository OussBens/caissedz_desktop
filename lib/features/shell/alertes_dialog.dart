import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/alerte.dart';
import '../../domain/modules.dart';

/// Ouvre les alertes du jour (DS `AlertesDialog`).
Future<void> afficherAlertes(BuildContext context) =>
    afficherDialog<void>(context, builder: (_) => const AlertesDialog());

/// Présentation d'une famille d'alertes (libellés, icônes, actions du DS).
class _Famille {
  const _Famille({
    required this.libelle,
    required this.icone,
    required this.aide,
    required this.action,
    required this.iconeAction,
    required this.actionLigne,
    this.jauge = false,
    this.relative = false,
    this.inverse = false,
    this.routeAction,
  });
  final String libelle;
  final IconData icone;
  final String aide;
  final String action;
  final IconData iconeAction;
  final String actionLigne;

  /// Jauge valeur / seuil (ruptures, bientôt expirés).
  final bool jauge;

  /// Jauge relative au plus gros montant (crédits, dettes).
  final bool relative;
  final bool inverse;

  /// Écran de l'action (sinon le module de la famille).
  final String? routeAction;
}

_Famille _famille(AppLocalizations l10n, FamilleAlerte f) => switch (f) {
  FamilleAlerte.rupture => _Famille(
    libelle: l10n.alertesRupture,
    icone: LucideIcons.packageX,
    aide: l10n.alertesRuptureAide,
    action: l10n.alertesRuptureAction,
    iconeAction: LucideIcons.clipboardList,
    actionLigne: l10n.alertesRuptureLigne,
    jauge: true,
  ),
  FamilleAlerte.expire => _Famille(
    libelle: l10n.alertesExpire,
    icone: LucideIcons.calendarX,
    aide: l10n.alertesExpireAide,
    action: l10n.alertesExpireAction,
    iconeAction: LucideIcons.packageMinus,
    actionLigne: l10n.alertesExpireLigne,
  ),
  FamilleAlerte.sessions => _Famille(
    libelle: l10n.alertesSessions,
    icone: LucideIcons.lockOpen,
    aide: l10n.alertesSessionsAide,
    action: l10n.alertesSessionsAction,
    iconeAction: LucideIcons.fileLock2,
    actionLigne: l10n.alertesSessionsAction,
  ),
  FamilleAlerte.bientot => _Famille(
    libelle: l10n.alertesBientot,
    icone: LucideIcons.calendarClock,
    aide: l10n.alertesBientotAide,
    action: l10n.alertesBientotAction,
    iconeAction: LucideIcons.percent,
    actionLigne: l10n.alertesBientotLigne,
    jauge: true,
    inverse: true,
  ),
  FamilleAlerte.clients => _Famille(
    libelle: l10n.alertesClients,
    icone: LucideIcons.users,
    aide: l10n.alertesClientsAide,
    action: l10n.alertesClientsAction,
    iconeAction: LucideIcons.handCoins,
    actionLigne: l10n.alertesClientsLigne,
    relative: true,
    routeAction: Modules.parId('versements')!.route,
  ),
  FamilleAlerte.fournisseurs => _Famille(
    libelle: l10n.alertesFournisseurs,
    icone: LucideIcons.truck,
    aide: l10n.alertesFournisseursAide,
    action: l10n.alertesFournisseursAction,
    iconeAction: LucideIcons.banknote,
    actionLigne: l10n.alertesFournisseursLigne,
    relative: true,
    routeAction: Modules.parId('versements')!.route,
  ),
};

/// Alertes du jour : familles « Urgent » / « À surveiller » à gauche, lignes de la famille à droite,
/// « Ne plus afficher aujourd'hui » et lien vers Paramètres.
class AlertesDialog extends ConsumerStatefulWidget {
  const AlertesDialog({super.key});

  @override
  ConsumerState<AlertesDialog> createState() => _AlertesDialogState();
}

class _AlertesDialogState extends ConsumerState<AlertesDialog> {
  FamilleAlerte? _courante;
  final Set<String> _traitees = {};
  bool _masquer = false;

  List<Alerte> _restantes(AlertesDuJour a, FamilleAlerte f) =>
      a.de(f).where((x) => !_traitees.contains('${f.name}/${x.cle}')).toList();

  Future<void> _fermer() async {
    if (_masquer) {
      final code = ref.read(sessionProvider)?.utilisateur.code;
      if (code != null) await ref.read(alertesServiceProvider).masquerAujourdhui(code);
    }
    if (mounted) Navigator.of(context).pop();
  }

  void _ouvrir(String route) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.go(route);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final alertes = ref.watch(alertesProvider);
    final familles = alertes.familles.toList();
    final urgentes = familles.where((f) => f.urgente).fold(0, (n, f) => n + _restantes(alertes, f).length);
    final aSurveiller = familles.where((f) => !f.urgente).fold(0, (n, f) => n + _restantes(alertes, f).length);
    final courante = _courante ?? familles.where((f) => alertes.de(f).isNotEmpty).firstOrNull ?? familles.firstOrNull;

    return DsDialog(
      key: const ValueKey('dialog_alertes'),
      titre: l10n.alertesTitre,
      iconeData: LucideIcons.bell,
      largeur: 1000,
      piedDebut: Wrap(
        spacing: DsSpacing.s4,
        runSpacing: DsSpacing.s2,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          DsCheckbox(
            valeur: _masquer,
            libelle: l10n.alertesNePlusAfficher,
            onChanged: (v) => setState(() => _masquer = v),
          ),
          InkWell(
            onTap: () => _ouvrir(Modules.parId('parametres')!.route),
            child: Text(l10n.alertesLienParametres, style: t.bodySm.copyWith(color: c.textLink)),
          ),
        ],
      ),
      actions: [DsButton(libelle: l10n.communFermer, onPressed: _fermer)],
      contenu: courante == null
          ? DsVide(message: l10n.alertesRienTitre, icone: LucideIcons.circleCheck, ton: DsVideTon.succes)
          : Container(
              height: 440,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.borderDefault),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 236,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: c.surfaceSunken,
                      border: BorderDirectional(end: BorderSide(color: c.borderSubtle)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: 14,
                      children: [
                        for (final urgent in [true, false])
                          if (familles.any((f) => f.urgente == urgent))
                            _Groupe(
                              libelle: urgent ? l10n.alertesUrgent : l10n.alertesASurveiller,
                              total: urgent ? urgentes : aSurveiller,
                              children: [
                                for (final f in familles.where((f) => f.urgente == urgent))
                                  _EntreeFamille(
                                    key: ValueKey('famille_${f.name}'),
                                    famille: f,
                                    presentation: _famille(l10n, f),
                                    nombre: _restantes(alertes, f).length,
                                    active: f == courante,
                                    onTap: () => setState(() => _courante = f),
                                  ),
                              ],
                            ),
                      ],
                    ),
                  ),
                  Expanded(child: _section(context, alertes, courante)),
                ],
              ),
            ),
    );
  }

  Widget _section(BuildContext context, AlertesDuJour alertes, FamilleAlerte f) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final p = _famille(l10n, f);
    final items = _restantes(alertes, f);
    // Module de la famille hors formule (Besoins en Basic) : on ouvre le Stock, sans l'action de la famille.
    final module = Modules.parId(f.moduleId)!;
    final inclus = ref.watch(licenceProvider).couvre(module.niveauRequis);
    final route = inclus ? module.route : Modules.parId('stock')!.route;
    final routeAction = inclus ? (p.routeAction ?? route) : route;
    final maxValeur = alertes.de(f).fold<double>(1, (m, x) => (x.valeur ?? 0) > m ? x.valeur! : m);
    return Container(
      color: c.surfaceCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: c.borderSubtle)),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Tuile(ton: f.urgente ? _Ton.danger : _Ton.warning, icone: p.icone, taille: 40),
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 180, maxWidth: 380),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    spacing: 2,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: p.libelle,
                          children: [
                            TextSpan(
                              text: '  · ${items.length}',
                              style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        style: t.bodyStrong.copyWith(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      Text(p.aide, style: t.bodySm.copyWith(color: c.textSecondary)),
                    ],
                  ),
                ),
                DsButton(
                  libelle: l10n.alertesOuvrirModule,
                  iconeDroite: LucideIcons.arrowRight,
                  variante: DsButtonVariante.fantome,
                  taille: DsButtonTaille.sm,
                  onPressed: () => _ouvrir(route),
                ),
                if (items.isNotEmpty && inclus)
                  DsButton(
                    libelle: p.action,
                    icone: p.iconeAction,
                    variante: DsButtonVariante.doux,
                    taille: DsButtonTaille.sm,
                    onPressed: () => _ouvrir(routeAction),
                  ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: DsVide(
                      message: l10n.alertesRienTitre,
                      description: l10n.alertesRienDetail,
                      icone: LucideIcons.circleCheck,
                      ton: DsVideTon.succes,
                      petit: true,
                    ),
                  )
                : ListView(
                    children: [
                      for (final (i, x) in items.indexed)
                        _LigneAlerte(
                          key: ValueKey('alerte_${f.name}_${x.cle}'),
                          alerte: x,
                          mesure: _mesure(l10n, x),
                          detail: x.famille == FamilleAlerte.clients || x.famille == FamilleAlerte.fournisseurs
                              ? (x.date == null
                                    ? x.detail
                                    : l10n.alertesDernierDocument(x.detail, _date(context, x.date!)))
                              : x.detail,
                          pourcentage: p.jauge && x.max != null && x.max! > 0
                              ? ((p.inverse ? x.max! - (x.valeur ?? 0) : (x.valeur ?? 0)) / x.max!).clamp(.04, 1.0)
                              : p.relative
                              ? ((x.valeur ?? 0) / maxValeur).clamp(.06, 1.0)
                              : null,
                          premiere: i == 0,
                          libelleAction: inclus ? p.actionLigne : l10n.alertesVoirStock,
                          onAction: () => _ouvrir(routeAction),
                          onTraitee: () => setState(() => _traitees.add('${f.name}/${x.cle}')),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _date(BuildContext context, DateTime d) =>
      DateFormat('dd/MM', Localizations.localeOf(context).languageCode).format(d);

  String _mesure(AppLocalizations l10n, Alerte x) => switch (x.famille) {
    FamilleAlerte.rupture =>
      (x.valeur ?? 0) <= 0 ? l10n.alertesMesureRupture : '${formaterNombre(x.valeur!)} / ${formaterNombre(x.max ?? 0)}',
    FamilleAlerte.sessions => x.date == null ? '' : l10n.alertesOuverteDepuis(_date(context, x.date!)),
    FamilleAlerte.clients || FamilleAlerte.fournisseurs => formaterMontant(x.valeur ?? 0),
    FamilleAlerte.expire || FamilleAlerte.bientot =>
      x.valeur == null
          ? ''
          : x.valeur! < 0
          ? l10n.alertesExpireDepuis(-x.valeur!.round())
          : l10n.alertesJours(x.valeur!.round()),
  };
}

enum _Ton { danger, warning, succes }

class _Tuile extends StatelessWidget {
  const _Tuile({required this.ton, required this.icone, required this.taille});
  final _Ton ton;
  final IconData icone;
  final double taille;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final (fond, couleur) = switch (ton) {
      _Ton.danger => (c.dangerTint, c.dangerFg),
      _Ton.warning => (c.warningTint, c.warningFg),
      _Ton.succes => (c.successTint, c.successFg),
    };
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(color: fond, borderRadius: DsRadius.borderMd),
      child: Icon(icone, size: taille > 32 ? 18 : 15, color: couleur),
    );
  }
}

class _Groupe extends StatelessWidget {
  const _Groupe({required this.libelle, required this.total, required this.children});
  final String libelle;
  final int total;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 2,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(libelle.toUpperCase(), style: t.overline.copyWith(color: c.textMuted)),
              ),
              Text('$total', style: t.overline.copyWith(color: c.textMuted)),
            ],
          ),
        ),
        ...children,
      ],
    );
  }
}

class _EntreeFamille extends StatelessWidget {
  const _EntreeFamille({
    super.key,
    required this.famille,
    required this.presentation,
    required this.nombre,
    required this.active,
    required this.onTap,
  });
  final FamilleAlerte famille;
  final _Famille presentation;
  final int nombre;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final ton = famille.urgente ? _Ton.danger : _Ton.warning;
    final (plein, teinte, texte) = famille.urgente
        ? (c.danger, c.dangerTint, c.dangerFg)
        : (c.warning, c.warningTint, c.warningFg);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: DsMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: active ? c.surfaceCard : DsColors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: active ? c.borderDefault : DsColors.transparent),
          boxShadow: active ? c.shadowSm : null,
        ),
        child: Row(
          spacing: 10,
          children: [
            _Tuile(
              ton: nombre > 0 ? ton : _Ton.succes,
              icone: nombre > 0 ? presentation.icone : LucideIcons.check,
              taille: 30,
            ),
            Expanded(
              child: Text(
                presentation.libelle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodySm.copyWith(
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: nombre > 0 ? c.textPrimary : c.textMuted,
                ),
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 24),
              height: 22,
              padding: const EdgeInsets.symmetric(horizontal: 7),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: nombre == 0 ? DsColors.transparent : (active ? plein : teinte),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                nombre == 0 ? '—' : '$nombre',
                style: t.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: nombre == 0 ? c.textMuted : (active ? DsColors.blanc : texte),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LigneAlerte extends StatefulWidget {
  const _LigneAlerte({
    super.key,
    required this.alerte,
    required this.mesure,
    required this.detail,
    required this.pourcentage,
    required this.premiere,
    required this.libelleAction,
    required this.onAction,
    required this.onTraitee,
  });
  final Alerte alerte;
  final String mesure;
  final String detail;
  final double? pourcentage;
  final bool premiere;
  final String libelleAction;
  final VoidCallback onAction;
  final VoidCallback onTraitee;

  @override
  State<_LigneAlerte> createState() => _LigneAlerteState();
}

class _LigneAlerteState extends State<_LigneAlerte> {
  bool _survol = false;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final x = widget.alerte;
    final (couleur, texte) = x.critique ? (c.danger, c.dangerFg) : (c.warning, c.warningFg);
    return MouseRegion(
      onEnter: (_) => setState(() => _survol = true),
      onExit: (_) => setState(() => _survol = false),
      child: AnimatedContainer(
        duration: DsMotion.fast,
        padding: const EdgeInsetsDirectional.fromSTEB(20, 12, 16, 12),
        decoration: BoxDecoration(
          color: _survol ? c.surfaceHover : DsColors.transparent,
          border: widget.premiere ? null : Border(top: BorderSide(color: c.borderSubtle)),
        ),
        child: Row(
          spacing: 12,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: couleur, shape: BoxShape.circle),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(x.titre, style: t.bodySmStrong.copyWith(fontSize: 13.5)),
                  Text(widget.detail, style: t.caption.copyWith(color: c.textMuted)),
                ],
              ),
            ),
            SizedBox(
              width: 112,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                spacing: 5,
                children: [
                  Text(widget.mesure, style: t.bodySmStrong.copyWith(fontSize: 13, color: texte)),
                  if (widget.pourcentage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SizedBox(
                        height: 4,
                        child: Stack(
                          children: [
                            Container(color: c.surfaceSunken),
                            FractionallySizedBox(
                              widthFactor: widget.pourcentage,
                              child: Container(color: couleur),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (_survol)
              DsButton(
                libelle: widget.libelleAction,
                variante: DsButtonVariante.secondaire,
                taille: DsButtonTaille.sm,
                onPressed: widget.onAction,
              ),
            DsIconButton(
              icone: LucideIcons.check,
              tooltip: l10n.alertesMarquerTraite,
              taille: DsTailles.controleSm,
              onPressed: widget.onTraitee,
            ),
          ],
        ),
      ),
    );
  }
}
