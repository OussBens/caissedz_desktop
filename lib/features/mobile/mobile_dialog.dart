import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../app/mobile_providers.dart';
import '../../application/serveur_mobile.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/appareil_mobile.dart';

/// Ouvre « Application mobile » : le QR code personnel de l'utilisateur connecté (son téléphone se connecte
/// avec son compte) et les téléphones appairés.
Future<void> afficherMobile(BuildContext context, WidgetRef ref) async {
  final etat = ref.read(mobileProvider);
  if (!etat.qrValablePour(ref.read(sessionProvider)?.utilisateur.code)) {
    unawaited(ref.read(mobileProvider.notifier).demarrer());
  }
  await afficherDialog<void>(context, builder: (_) => const MobileDialog());
}

/// `MobileDialog` (820 px) : à gauche le QR personnel à scanner avec le téléphone (même réseau), à droite les
/// étapes ; en dessous les téléphones appairés, révocables (tous pour l'Admin, sinon les siens).
class MobileDialog extends ConsumerStatefulWidget {
  const MobileDialog({super.key});

  @override
  ConsumerState<MobileDialog> createState() => _MobileDialogState();
}

class _MobileDialogState extends ConsumerState<MobileDialog> {
  Timer? _minuterie;

  @override
  void initState() {
    super.initState();
    // Le QR expire : un nouveau est préparé à l'échéance tant que le dialog est ouvert.
    _minuterie = Timer.periodic(const Duration(seconds: 15), (_) {
      final e = ref.read(mobileProvider);
      if (e.actif && e.expireLe != null && e.expireLe!.isBefore(DateTime.now())) {
        unawaited(ref.read(mobileProvider.notifier).nouveauQr());
      }
      ref.invalidate(appareilsConnectesProvider);
    });
  }

  @override
  void dispose() {
    _minuterie?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final etat = ref.watch(mobileProvider);
    final session = ref.watch(sessionProvider);
    final admin = session?.estAdmin ?? false;
    final nom = session == null
        ? ''
        : (session.utilisateur.nomComplet.isEmpty ? session.utilisateur.identifiant : session.utilisateur.nomComplet);
    final connectes = ref.watch(appareilsConnectesProvider);
    // Les téléphones connectés d'abord.
    final appareils = [...ref.watch(appareilsMobilesProvider).value ?? const <AppareilMobile>[]]
      ..sort((a, b) => (connectes.contains(a.code) ? 0 : 1).compareTo(connectes.contains(b.code) ? 0 : 1));
    return DsDialog(
      titre: l10n.mobileTitre,
      iconeData: LucideIcons.smartphone,
      largeur: 820,
      // Le service est commun au poste : seul l'Admin l'arrête.
      piedDebut: etat.actif && admin
          ? DsButton(
              key: const ValueKey('mobile_desactiver'),
              libelle: l10n.mobileDesactiver,
              icone: LucideIcons.power,
              variante: DsButtonVariante.fantome,
              onPressed: () => ref.read(mobileProvider.notifier).arreter(),
            )
          : null,
      actions: [
        DsButton(
          key: const ValueKey('mobile_fermer'),
          libelle: l10n.communFermer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s5,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: DsSpacing.s6,
            children: [
              _CarteQr(etat: etat, nom: nom),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: DsSpacing.s3,
                  children: [
                    for (final (i, texte) in [
                      l10n.mobileEtape1,
                      l10n.mobileEtape2,
                      l10n.mobileEtape3,
                      l10n.mobileEtape4,
                    ].indexed)
                      _Etape(numero: i + 1, texte: texte),
                    if (etat.actif && etat.adresses.isEmpty)
                      DsNote(icone: LucideIcons.wifiOff, ton: DsBadgeTon.avertissement, texte: l10n.mobileAucunReseau),
                    if (etat.erreur != null)
                      DsNote(
                        icone: LucideIcons.circleAlert,
                        ton: DsBadgeTon.danger,
                        texte: l10n.mobileErreurDemarrage(etat.erreur!),
                      ),
                  ],
                ),
              ),
            ],
          ),
          DsSectionTitre(
            admin ? l10n.mobileAppareils(appareils.length) : l10n.mobileMesAppareils(appareils.length),
            icone: LucideIcons.smartphone,
          ),
          if (appareils.isEmpty)
            Text(l10n.mobileAucunAppareil, style: t.bodySm.copyWith(color: c.textSecondary))
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: appareils.length,
                separatorBuilder: (_, _) => const DsDivider(),
                itemBuilder: (_, i) => _LigneAppareil(
                  appareil: appareils[i],
                  afficherUtilisateur: admin,
                  connecte: connectes.contains(appareils[i].code),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CarteQr extends ConsumerWidget {
  const _CarteQr({required this.etat, required this.nom});
  final EtatMobile etat;

  /// Utilisateur à qui appartient le QR.
  final String nom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final heure = etat.expireLe == null
        ? ''
        : DateFormat.Hm(Localizations.localeOf(context).toLanguageTag()).format(etat.expireLe!);
    return SizedBox(
      width: 280,
      child: Column(
        spacing: DsSpacing.s3,
        children: [
          Container(
            width: 280,
            height: 280,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // Toujours blanc : le QR reste lisible par l'appareil photo en thème sombre.
              color: DsColors.blanc,
              borderRadius: DsRadius.borderXl,
              border: Border.all(color: c.borderDefault),
            ),
            child: etat.qr != null
                ? DsBarcode(
                    key: const ValueKey('mobile_qr'),
                    valeur: etat.qr!,
                    format: DsBarcodeFormat.qr,
                    tailleQr: 236,
                  )
                : etat.actif || etat.erreur == null
                ? const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5))
                : Icon(LucideIcons.qrCode, size: 64, color: c.iconMuted),
          ),
          if (etat.qr != null) ...[
            Text(
              l10n.mobileQrDe(nom),
              key: const ValueKey('mobile_qr_utilisateur'),
              style: t.bodySmStrong.copyWith(color: c.textPrimary),
            ),
            Text(l10n.mobileQrExpire(heure), style: t.caption.copyWith(color: c.textMuted)),
          ],
          DsButton(
            key: const ValueKey('mobile_nouveau_qr'),
            libelle: etat.actif ? l10n.mobileNouveauQr : l10n.mobileActiver,
            icone: etat.actif ? LucideIcons.refreshCw : LucideIcons.power,
            variante: etat.actif ? DsButtonVariante.secondaire : DsButtonVariante.primaire,
            pleineLargeur: true,
            onPressed: () => etat.actif
                ? ref.read(mobileProvider.notifier).nouveauQr()
                : ref.read(mobileProvider.notifier).demarrer(),
          ),
        ],
      ),
    );
  }
}

class _Etape extends StatelessWidget {
  const _Etape({required this.numero, required this.texte});
  final int numero;
  final String texte;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: DsSpacing.s3,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.primaryTint, shape: BoxShape.circle),
          child: Text('$numero', style: t.bodySmStrong.copyWith(color: c.primaryTintFg)),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(texte, style: t.body.copyWith(color: c.textBody)),
          ),
        ),
      ],
    );
  }
}

class _LigneAppareil extends ConsumerWidget {
  const _LigneAppareil({required this.appareil, required this.afficherUtilisateur, required this.connecte});
  final AppareilMobile appareil;

  /// Requête récente du téléphone : pastille « Connecté ».
  final bool connecte;

  /// L'Admin voit à qui appartient chaque téléphone.
  final bool afficherUtilisateur;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final noms = ref.watch(nomsUtilisateursProvider).value ?? const {};
    final acces = appareil.dernierAcces;
    final proprietaire = appareil.utilisateurCode;
    final details = [
      if (afficherUtilisateur && proprietaire != null) noms[proprietaire] ?? proprietaire,
      if (appareil.plateforme.isNotEmpty) appareil.plateforme == 'ios' ? 'iOS' : 'Android',
      l10n.mobileAppaireLe(DateFormat.yMd(locale).format(appareil.creeLe)),
      if (acces != null) l10n.mobileDernierAcces(DateFormat.yMd(locale).add_Hm().format(acces)),
    ].join('  ·  ');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DsSpacing.s2),
      child: Row(
        spacing: DsSpacing.s3,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: DsRadius.borderMd),
            child: Icon(LucideIcons.smartphone, size: 18, color: c.iconDefault),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: DsSpacing.s2,
                  children: [
                    Flexible(
                      child: Text(
                        appareil.nom,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodyStrong.copyWith(color: c.textPrimary),
                      ),
                    ),
                    if (connecte)
                      DsBadge(
                        key: ValueKey('mobile_connecte_${appareil.code}'),
                        libelle: l10n.mobileConnecte,
                        ton: DsBadgeTon.succes,
                        point: true,
                      ),
                  ],
                ),
                Text(details, style: t.caption.copyWith(color: c.textMuted)),
              ],
            ),
          ),
          DsButton(
            key: ValueKey('mobile_revoquer_${appareil.code}'),
            libelle: l10n.mobileRevoquer,
            icone: LucideIcons.unlink,
            variante: DsButtonVariante.fantome,
            taille: DsButtonTaille.sm,
            onPressed: () async {
              final ok = await afficherConfirmation(
                context,
                titre: l10n.mobileRevoquerTitre(appareil.nom),
                message: l10n.mobileRevoquerMessage,
                libelleConfirmer: l10n.mobileRevoquer,
                destructif: true,
              );
              if (ok) await ref.read(mobileProvider.notifier).revoquer(appareil.code);
            },
          ),
        ],
      ),
    );
  }
}

/// Ouvre le choix de l'utilisateur d'un téléphone qui vient de scanner le QR de l'Admin ; la réponse part au
/// téléphone (utilisateur choisi, ou refus). Se ferme seul quand la demande expire.
Future<void> afficherChoixUtilisateurMobile(BuildContext context, DemandeAppairage demande) =>
    afficherDialog<void>(context, fermableParVoile: false, builder: (_) => ChoixUtilisateurMobileDialog(demande));

/// `ChoixUtilisateurMobileDialog` (640 px) : le téléphone (nom, système, modèle, version, adresse) et la liste des
/// utilisateurs ; l'Admin choisit celui qui ouvrira l'application sur ce téléphone. Un compte sans l'autorisation
/// mobile n'est pas sélectionnable.
class ChoixUtilisateurMobileDialog extends ConsumerStatefulWidget {
  const ChoixUtilisateurMobileDialog(this.demande, {super.key});
  final DemandeAppairage demande;

  @override
  ConsumerState<ChoixUtilisateurMobileDialog> createState() => _ChoixUtilisateurMobileDialogState();
}

class _ChoixUtilisateurMobileDialogState extends ConsumerState<ChoixUtilisateurMobileDialog> {
  String? _choisi;
  bool _repondu = false;

  void _repondre(String? code) {
    _repondu = true;
    ref.read(demandeAppairageProvider.notifier).repondre(code);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    final t = context.ds.typo;
    final d = widget.demande;
    // Demande expirée (ou traitée ailleurs) : le dialog se ferme.
    ref.listen(demandeAppairageProvider, (_, actuelle) {
      if (!_repondu && actuelle != d && mounted) Navigator.of(context).pop();
    });
    final utilisateurs = ref.watch(utilisateursMobileProvider).value ?? const [];
    final details = [
      if (d.systeme.isNotEmpty) d.systeme else if (d.plateforme.isNotEmpty) d.plateforme == 'ios' ? 'iOS' : 'Android',
      if (d.modele.isNotEmpty && d.modele != d.nom) d.modele,
      if (d.version.isNotEmpty) l10n.mobileChoixVersion(d.version),
      if (d.adresse.isNotEmpty) d.adresse,
    ].join('  ·  ');
    return DsDialog(
      titre: l10n.mobileChoixTitre,
      iconeData: LucideIcons.smartphone,
      largeur: 640,
      actions: [
        DsButton(
          key: const ValueKey('mobile_choix_refuser'),
          libelle: l10n.mobileChoixRefuser,
          variante: DsButtonVariante.secondaire,
          onPressed: () => _repondre(null),
        ),
        DsButton(
          key: const ValueKey('mobile_choix_connecter'),
          libelle: l10n.mobileChoixConnecter,
          icone: LucideIcons.check,
          onPressed: _choisi == null ? null : () => _repondre(_choisi),
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s4,
        children: [
          Container(
            padding: const EdgeInsets.all(DsSpacing.s4),
            decoration: BoxDecoration(
              color: c.surfaceSunken,
              borderRadius: DsRadius.borderLg,
              border: Border.all(color: c.borderSubtle),
            ),
            child: Row(
              spacing: DsSpacing.s3,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: c.primaryTint, borderRadius: DsRadius.borderMd),
                  child: Icon(LucideIcons.smartphone, size: 22, color: c.primaryTintFg),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        d.nom,
                        key: const ValueKey('mobile_choix_appareil'),
                        style: t.bodyStrong.copyWith(color: c.textPrimary),
                      ),
                      if (details.isNotEmpty) Text(details, style: t.caption.copyWith(color: c.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Text(l10n.mobileChoixMessage, style: t.body.copyWith(color: c.textBody)),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: utilisateurs.length,
              separatorBuilder: (_, _) => const DsDivider(),
              itemBuilder: (_, i) {
                final (:utilisateur, :autorise) = utilisateurs[i];
                final u = utilisateur;
                final nom = u.nomComplet.isEmpty ? u.identifiant : u.nomComplet;
                final choisi = _choisi == u.code;
                return InkWell(
                  key: ValueKey('mobile_choix_${u.code}'),
                  borderRadius: DsRadius.borderMd,
                  onTap: autorise ? () => setState(() => _choisi = u.code) : null,
                  child: Opacity(
                    opacity: autorise ? 1 : .55,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.s3, vertical: DsSpacing.s2),
                      decoration: BoxDecoration(
                        color: choisi ? c.surfaceActive : DsColors.transparent,
                        borderRadius: DsRadius.borderMd,
                      ),
                      child: Row(
                        spacing: DsSpacing.s3,
                        children: [
                          Icon(
                            choisi ? LucideIcons.circleCheck : LucideIcons.circle,
                            size: 18,
                            color: choisi ? c.iconActive : c.iconMuted,
                          ),
                          DsAvatar(nom: nom),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(nom, style: t.bodyStrong.copyWith(color: c.textPrimary)),
                                Text(
                                  autorise ? u.identifiant : l10n.mobileChoixNonAutorise,
                                  style: t.caption.copyWith(color: c.textMuted),
                                ),
                              ],
                            ),
                          ),
                          if ((u.roleNom ?? '').isNotEmpty)
                            DsBadge(libelle: u.roleNom!, ton: u.estAdmin ? DsBadgeTon.info : DsBadgeTon.neutre),
                        ],
                      ),
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
