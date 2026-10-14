import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/demarrage_providers.dart';
import '../../application/parametres_service.dart';
import '../../application/sauvegarde_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/print/imprimante.dart';
import '../../domain/models/boutique.dart';
import '../../domain/models/parametres_vente.dart';
import '../../domain/permissions.dart';
import '../activation/activation_page.dart';
import '../produits/produits_providers.dart';
import '../rapports/rapports_providers.dart';
import '../roles/roles_page.dart';

/// Paramètres (lot 8) : général (rôles, licence), boutique, vente, impression, serveurs, sauvegarde.
class ParametresPage extends ConsumerStatefulWidget {
  const ParametresPage({super.key});

  @override
  ConsumerState<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends ConsumerState<ParametresPage> {
  int _onglet = 0;
  bool _charge = false;
  // Boutique
  final _nom = TextEditingController();
  final _rc = TextEditingController();
  final _nif = TextEditingController();
  final _adresse = TextEditingController();
  final _telephone = TextEditingController();
  final _email = TextEditingController();
  // Vente
  final _marge = TextEditingController();
  final _devise = TextEditingController();
  final _seuil = TextEditingController();
  final _points = TextEditingController();
  bool _fidelite = false;
  // Impression
  String _typeImprimante = TypesImprimante.normale;
  final _adresseImprimante = TextEditingController();
  String _largeur = '80';
  // Serveurs
  final _url = TextEditingController();
  final _cle = TextEditingController();
  final _mantouj = TextEditingController();
  // Sauvegarde
  final _motDePasse = TextEditingController();
  final _motDePasseRestauration = TextEditingController();
  String? _fichierRestauration;

  @override
  void initState() {
    super.initState();
    unawaited(_charger());
  }

  @override
  void dispose() {
    for (final c in [
      _nom,
      _rc,
      _nif,
      _adresse,
      _telephone,
      _email,
      _marge,
      _devise,
      _seuil,
      _points,
      _adresseImprimante,
      _url,
      _cle,
      _mantouj,
      _motDePasse,
      _motDePasseRestauration,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _charger() async {
    final s = ref.read(parametresServiceProvider);
    final b = await s.lireBoutique();
    final v = await s.lireVente();
    final i = await s.lireImpression();
    final srv = await s.lireServeur();
    if (!mounted) return;
    setState(() {
      _nom.text = b?.nom ?? '';
      _rc.text = b?.rc ?? '';
      _nif.text = b?.nif ?? '';
      _adresse.text = b?.adresse ?? '';
      _telephone.text = b?.telephone ?? '';
      _email.text = b?.email ?? '';
      _marge.text = _fmt(v.margeDefautPct);
      _devise.text = v.devise;
      _seuil.text = '${v.seuilStockGlobal}';
      _points.text = _fmt(v.pointsParDinar);
      _fidelite = v.fideliteActive;
      _typeImprimante = i.type;
      _adresseImprimante.text = i.adresse;
      _largeur = i.largeur;
      _url.text = srv.url;
      _cle.text = srv.cle;
      _mantouj.text = srv.urlMantouj;
      _charge = true;
    });
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  Future<void> _executer(String titre, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      if (!mounted) return;
      unawaited(
        afficherResultat(context, type: DsResultatType.succes, titre: titre, message: l10n.parametresEnregistre),
      );
    } on ParametresException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: titre,
          message: messageErreurParametres(l10n, e.erreur),
        ),
      );
    }
  }

  Future<void> _enregistrerBoutique() => _executer(AppLocalizations.of(context).parametresOngletBoutique, () async {
    await ref
        .read(parametresServiceProvider)
        .enregistrerBoutique(
          Boutique(
            nom: _nom.text,
            rc: _rc.text.trim(),
            nif: _nif.text.trim(),
            adresse: _adresse.text.trim(),
            telephone: _telephone.text.trim(),
            email: _email.text.trim(),
          ),
        );
  });

  Future<void> _enregistrerVente() => _executer(AppLocalizations.of(context).parametresOngletVente, () async {
    double? d(String s) => double.tryParse(s.trim().replaceAll(',', '.'));
    await ref
        .read(parametresServiceProvider)
        .enregistrerVente(
          ParametresVente(
            margeDefautPct: d(_marge.text) ?? -1,
            seuilStockGlobal: int.tryParse(_seuil.text.trim()) ?? -1,
            fideliteActive: _fidelite,
            pointsParDinar: d(_points.text) ?? -1,
            devise: _devise.text,
          ),
        );
    ref.invalidate(parametresVenteProvider);
  });

  Future<void> _enregistrerImpression() => _executer(AppLocalizations.of(context).parametresOngletImpression, () async {
    await ref
        .read(parametresServiceProvider)
        .enregistrerImpression(
          ParametresImpression(type: _typeImprimante, adresse: _adresseImprimante.text, largeur: _largeur),
        );
  });

  Future<void> _enregistrerServeur() => _executer(AppLocalizations.of(context).parametresOngletServeur, () async {
    await ref
        .read(parametresServiceProvider)
        .enregistrerServeur(ParametresServeur(url: _url.text, cle: _cle.text, urlMantouj: _mantouj.text));
    ref.invalidate(serveurCaisseDzProvider);
  });

  Future<void> _sauvegarder() async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(sauvegardeServiceProvider);
    try {
      if (_motDePasse.text.isEmpty) throw const SauvegardeException(ErreurSauvegarde.motDePasseVide);
      final d = DateTime.now();
      final nom =
          'caissedz_${d.year}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}_${d.hour.toString().padLeft(2, '0')}${d.minute.toString().padLeft(2, '0')}.cdz';
      final chemin = await ref.read(selecteurEnregistrementProvider)(nom, 'cdz');
      if (chemin == null || !mounted) return;
      await service.sauvegarder(chemin: chemin, motDePasse: _motDePasse.text);
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.succes,
          titre: l10n.sauvegardeCreer,
          message: l10n.sauvegardeOk(chemin),
        ),
      );
    } on SauvegardeException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.sauvegardeCreer,
          message: messageErreurSauvegarde(l10n, e),
        ),
      );
    }
  }

  Future<void> _restaurer() async {
    final l10n = AppLocalizations.of(context);
    final service = ref.read(sauvegardeServiceProvider);
    final chemin = _fichierRestauration;
    if (chemin == null) return;
    try {
      final info = await service.verifier(chemin: chemin, motDePasse: _motDePasseRestauration.text);
      if (!mounted) return;
      final ok = await afficherConfirmation(
        context,
        titre: l10n.sauvegardeRestaurer,
        message:
            '${l10n.sauvegardeInfo(info.boutique, info.nbVentes, info.nbProduits, info.version)}\n\n${l10n.sauvegardeConfirmerRestauration}',
        destructif: true,
      );
      if (!ok || !mounted) return;
      await service.preparerRestauration(chemin: chemin, motDePasse: _motDePasseRestauration.text);
      if (!mounted) return;
      setState(() {});
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.avertissement,
          titre: l10n.sauvegardeRestaurer,
          message: l10n.sauvegardeRestaurationPreparee,
        ),
      );
    } on SauvegardeException catch (e) {
      if (!mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.sauvegardeRestaurer,
          message: messageErreurSauvegarde(l10n, e),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DsPage(
      titre: l10n.parametresTitre,
      defilable: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DsOnglets(
            onglets: [
              l10n.parametresOngletGeneral,
              l10n.parametresOngletBoutique,
              l10n.parametresOngletVente,
              l10n.parametresOngletImpression,
              l10n.parametresOngletServeur,
              l10n.parametresOngletSauvegarde,
            ],
            courant: _onglet,
            onChanged: (i) => setState(() => _onglet = i),
          ),
          const SizedBox(height: DsSpacing.lg),
          if (!_charge)
            const SizedBox.shrink()
          else
            switch (_onglet) {
              0 => _general(l10n),
              1 => _boutique(l10n),
              2 => _vente(l10n),
              3 => _impression(l10n),
              4 => _serveurs(l10n),
              _ => _sauvegarde(l10n),
            },
        ],
      ),
    );
  }

  Widget _formulaire(List<Widget> champs, {required String libelleBouton, required VoidCallback onEnregistrer}) =>
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: DsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, w) in champs.indexed) ...[if (i > 0) const SizedBox(height: DsSpacing.md), w],
              const SizedBox(height: DsSpacing.lg),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: DsButton(libelle: libelleBouton, icone: LucideIcons.save, onPressed: onEnregistrer),
              ),
            ],
          ),
        ),
      );

  Widget _general(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final licence = ref.watch(licenceProvider);
    final peutRoles = ref.watch(permissionProvider(Permission.gererUtilisateurs));
    final niveau = licence.demo
        ? l10n.licenceDemo
        : (licence.niveau == NiveauLicence.avance ? l10n.licenceAvance : l10n.licenceBasic);
    Widget carte({required IconData icone, required String titre, required String detail, VoidCallback? onTap}) =>
        SizedBox(
          width: 320,
          child: DsCard(
            onTap: onTap,
            child: Row(
              children: [
                Icon(icone, size: DsTailles.iconeLg, color: onTap == null ? c.texteAttenue : c.primaire),
                const SizedBox(width: DsSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(titre, style: t.corpsFort.copyWith(color: onTap == null ? c.texteAttenue : c.texte)),
                      Text(detail, style: t.petit.copyWith(color: c.texteSecondaire)),
                    ],
                  ),
                ),
                Icon(LucideIcons.chevronRight, size: DsTailles.iconeSm, color: c.texteAttenue),
              ],
            ),
          ),
        );
    return Wrap(
      spacing: DsSpacing.md,
      runSpacing: DsSpacing.md,
      children: [
        carte(
          icone: LucideIcons.shield,
          titre: l10n.parametresRolesCarte,
          detail: peutRoles ? l10n.parametresRolesCarteDetail : l10n.shellAccesRestreint,
          onTap: peutRoles ? () => context.go(RolesPage.route) : null,
        ),
        carte(
          icone: LucideIcons.keyRound,
          titre: l10n.parametresLicenceCarte,
          detail: l10n.licenceNiveau(niveau),
          onTap: () => context.push(ActivationPage.route),
        ),
      ],
    );
  }

  Widget _boutique(AppLocalizations l10n) => _formulaire(
    [
      DsTextField(controller: _nom, libelle: l10n.parametresBoutiqueNom),
      Row(
        children: [
          Expanded(
            child: DsTextField(controller: _rc, libelle: l10n.parametresBoutiqueRc),
          ),
          const SizedBox(width: DsSpacing.md),
          Expanded(
            child: DsTextField(controller: _nif, libelle: l10n.parametresBoutiqueNif),
          ),
        ],
      ),
      DsTextField(controller: _adresse, libelle: l10n.parametresBoutiqueAdresse),
      Row(
        children: [
          Expanded(
            child: DsTextField(controller: _telephone, libelle: l10n.parametresBoutiqueTelephone),
          ),
          const SizedBox(width: DsSpacing.md),
          Expanded(
            child: DsTextField(
              controller: _email,
              libelle: l10n.parametresBoutiqueEmail,
              typeClavier: TextInputType.emailAddress,
            ),
          ),
        ],
      ),
    ],
    libelleBouton: l10n.communEnregistrer,
    onEnregistrer: () => _enregistrerBoutique(),
  );

  Widget _vente(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    return _formulaire(
      [
        Row(
          children: [
            Expanded(
              child: DsTextField(controller: _marge, libelle: l10n.parametresMarge, typeClavier: TextInputType.number),
            ),
            const SizedBox(width: DsSpacing.md),
            Expanded(
              child: DsTextField(controller: _devise, libelle: l10n.parametresDevise),
            ),
            const SizedBox(width: DsSpacing.md),
            Expanded(
              child: DsTextField(controller: _seuil, libelle: l10n.parametresSeuil, typeClavier: TextInputType.number),
            ),
          ],
        ),
        DsSwitch(valeur: _fidelite, libelle: l10n.parametresFidelite, onChanged: (v) => setState(() => _fidelite = v)),
        DsTextField(
          controller: _points,
          libelle: l10n.parametresPoints,
          typeClavier: TextInputType.number,
          actif: _fidelite,
        ),
        Row(
          children: [
            Icon(LucideIcons.shieldCheck, size: DsTailles.iconeSm, color: c.succes),
            const SizedBox(width: DsSpacing.sm),
            Expanded(
              child: Text(l10n.parametresGardeStock, style: t.petit.copyWith(color: c.texteSecondaire)),
            ),
          ],
        ),
      ],
      libelleBouton: l10n.communEnregistrer,
      onEnregistrer: () => _enregistrerVente(),
    );
  }

  Widget _impression(AppLocalizations l10n) => _formulaire(
    [
      DsSelect<String>(
        titre: l10n.parametresImprimanteType,
        valeur: _typeImprimante,
        options: TypesImprimante.tous,
        libelle: (t) => switch (t) {
          TypesImprimante.usb => l10n.parametresImprimanteUsb,
          TypesImprimante.reseau => l10n.parametresImprimanteReseau,
          TypesImprimante.bluetooth => l10n.parametresImprimanteBluetooth,
          _ => l10n.parametresImprimanteNormale,
        },
        onChanged: (v) => setState(() => _typeImprimante = v ?? _typeImprimante),
      ),
      DsTextField(
        controller: _adresseImprimante,
        libelle: l10n.parametresImprimanteAdresse,
        actif: _typeImprimante != TypesImprimante.normale,
        indice: _typeImprimante == TypesImprimante.reseau ? '192.168.1.50:9100' : 'POS-80',
      ),
      DsSelect<String>(
        titre: l10n.parametresImprimanteLargeur,
        valeur: _largeur,
        options: const ['58', '80'],
        libelle: (v) => '$v mm',
        onChanged: (v) => setState(() => _largeur = v ?? _largeur),
      ),
    ],
    libelleBouton: l10n.communEnregistrer,
    onEnregistrer: () => _enregistrerImpression(),
  );

  Widget _serveurs(AppLocalizations l10n) => _formulaire(
    [
      DsTextField(controller: _url, libelle: l10n.parametresServeurUrl, indice: 'https://api.caissedz.dz'),
      DsTextField(controller: _cle, libelle: l10n.parametresServeurCle, obscur: true),
      DsTextField(controller: _mantouj, libelle: l10n.parametresMantoujUrl, indice: 'https://mantouj.dz/api'),
    ],
    libelleBouton: l10n.communEnregistrer,
    onEnregistrer: () => _enregistrerServeur(),
  );

  Widget _sauvegarde(AppLocalizations l10n) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final service = ref.watch(sauvegardeServiceProvider);
    final enAttente = service.restaurationEnAttente;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 720),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (enAttente) ...[
            DsCard(
              child: Row(
                children: [
                  Icon(LucideIcons.triangleAlert, color: c.avertissement),
                  const SizedBox(width: DsSpacing.md),
                  Expanded(child: Text(l10n.sauvegardeRestaurationEnAttente, style: t.corps)),
                  DsButton(
                    libelle: l10n.sauvegardeAnnulerRestauration,
                    variante: DsButtonVariante.secondaire,
                    taille: DsButtonTaille.sm,
                    onPressed: () async {
                      await service.annulerRestauration();
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: DsSpacing.md),
          ],
          DsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DsSectionTitre(l10n.sauvegardeCreer),
                const SizedBox(height: DsSpacing.sm),
                Text(l10n.sauvegardeIntro, style: t.petit.copyWith(color: c.texteSecondaire)),
                const SizedBox(height: DsSpacing.md),
                DsTextField(controller: _motDePasse, libelle: l10n.sauvegardeMotDePasse, obscur: true),
                const SizedBox(height: DsSpacing.lg),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: DsButton(
                    libelle: l10n.sauvegardeCreer,
                    icone: LucideIcons.databaseBackup,
                    onPressed: () {
                      _sauvegarder();
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: DsSpacing.md),
          DsCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DsSectionTitre(l10n.sauvegardeRestaurer),
                const SizedBox(height: DsSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _fichierRestauration ?? l10n.sauvegardeFichier,
                        style: t.corps.copyWith(color: _fichierRestauration == null ? c.texteAttenue : c.texte),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: DsSpacing.md),
                    DsButton(
                      libelle: l10n.sauvegardeChoisirFichier,
                      icone: LucideIcons.folderOpen,
                      variante: DsButtonVariante.secondaire,
                      onPressed: () async {
                        final f = await ref.read(selecteurFichierProvider)(['cdz']);
                        if (f != null && mounted) setState(() => _fichierRestauration = f);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: DsSpacing.md),
                DsTextField(controller: _motDePasseRestauration, libelle: l10n.sauvegardeMotDePasse, obscur: true),
                const SizedBox(height: DsSpacing.lg),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: DsButton(
                    libelle: l10n.sauvegardeRestaurer,
                    icone: LucideIcons.rotateCcw,
                    variante: DsButtonVariante.danger,
                    onPressed: _fichierRestauration == null
                        ? null
                        : () {
                            _restaurer();
                          },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
