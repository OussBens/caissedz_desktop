import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../app/providers.dart';
import '../../application/session_caisse_service.dart';
import '../../application/vente_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../core/print/documents_pdf.dart';
import '../../core/print/imprimante.dart';
import '../../core/print/ticket_escpos.dart';
import '../../data/boutique_repository.dart';
import '../../data/client_repository.dart';
import '../../data/parametre_repository.dart';
import '../../domain/models/boutique.dart';
import '../../domain/models/tiers.dart';
import '../../domain/models/vente.dart';
import '../produits/produits_providers.dart';
import 'pos_controller.dart';

String messageErreurSession(AppLocalizations l10n, ErreurSession e) => switch (e) {
  ErreurSession.dejaOuverte => l10n.posErreurSessionDejaOuverte,
  ErreurSession.aucuneOuverte => l10n.posErreurSessionAucune,
  ErreurSession.caisseInconnue => l10n.posErreurCaisse,
  ErreurSession.montantInvalide => l10n.posErreurMontant,
};

String messageErreurVente(AppLocalizations l10n, VenteException e, String devise) => switch (e.erreur) {
  ErreurVente.sessionRequise => l10n.posSessionAucune,
  ErreurVente.panierVide => l10n.posErreurPanierVide,
  ErreurVente.paiementInsuffisant => l10n.posErreurPaiementInsuffisant(e.detail ?? ''),
  ErreurVente.modePaiementInvalide => l10n.posErreurModePaiement,
  ErreurVente.pointsInsuffisants => l10n.posErreurPoints,
  ErreurVente.stockInsuffisant => l10n.posErreurStock(e.detail ?? ''),
  ErreurVente.creditNonAutorise => l10n.posErreurCredit,
  ErreurVente.venteInconnue => l10n.communAucunResultat,
  ErreurVente.dejaAnnulee => l10n.communAucunResultat,
  ErreurVente.periodeCloturee => l10n.posErreurPeriodeCloturee,
  ErreurVente.quantiteInvalide => l10n.posErreurQuantite,
};

String libelleModePaiement(AppLocalizations l10n, String mode) => switch (mode) {
  'Espèces' => l10n.modePaiementEspeces,
  'Carte' => l10n.modePaiementCarte,
  'Chèque' => l10n.modePaiementCheque,
  'Virement' => l10n.modePaiementVirement,
  'Points' => l10n.modePaiementPoints,
  _ => mode,
};

/// Ouverture de session : caisse + fond initial.
Future<void> afficherOuvertureSession(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final caisses = await ref.read(caissesProvider.future);
  if (!context.mounted || caisses.isEmpty) return;
  var caisse = caisses.first['code'] as String;
  final fond = TextEditingController(text: '0');
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => DsDialog(
        titre: l10n.posSessionOuvrir,
        largeur: 440,
        icone: Icon(LucideIcons.doorOpen, color: ctx.ds.colors.primaire),
        actions: [
          DsButton(
            libelle: l10n.communAnnuler,
            variante: DsButtonVariante.secondaire,
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          DsButton(
            libelle: l10n.posSessionOuvrir,
            icone: LucideIcons.check,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DsSelect<String>(
              titre: l10n.posSessionCaisse,
              valeur: caisse,
              options: caisses.map((c) => c['code'] as String).toList(),
              libelle: (c) => caisses.firstWhere((x) => x['code'] == c)['nom'] as String,
              onChanged: (v) => setState(() => caisse = v ?? caisse),
            ),
            const SizedBox(height: DsSpacing.md),
            DsTextField(
              controller: fond,
              libelle: l10n.posSessionFond,
              typeClavier: TextInputType.number,
              autofocus: true,
              onSubmitted: (_) => Navigator.of(ctx).pop(true),
            ),
          ],
        ),
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    await ref
        .read(posControllerProvider.notifier)
        .ouvrirSession(caisseCode: caisse, fondInitial: double.tryParse(fond.text.replaceAll(',', '.')) ?? -1);
  } on SessionException catch (e) {
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.posSessionOuvrir,
        message: messageErreurSession(l10n, e.erreur),
      ),
    );
  }
}

/// Fermeture de session : montant compté, écart.
Future<void> afficherFermetureSession(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final session = ref.read(posControllerProvider).session;
  if (session == null) return;
  final devise = ref.read(deviseProvider);
  final attendu = await ref.read(sessionCaisseServiceProvider).especesAttendues(session.code);
  if (!context.mounted) return;
  final compte = TextEditingController(text: attendu.toStringAsFixed(2));
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) => DsDialog(
      titre: l10n.posSessionFermer,
      largeur: 440,
      icone: Icon(LucideIcons.doorClosed, color: ctx.ds.colors.avertissement),
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        DsButton(
          libelle: l10n.posSessionFermer,
          icone: LucideIcons.check,
          variante: DsButtonVariante.danger,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('${l10n.posSessionAttendu} : ${formaterMontant(attendu, devise)}', style: ctx.ds.typo.corps),
          const SizedBox(height: DsSpacing.md),
          DsTextField(
            controller: compte,
            libelle: l10n.posSessionMontantCompte,
            typeClavier: TextInputType.number,
            autofocus: true,
          ),
        ],
      ),
    ),
  );
  if (ok != true || !context.mounted) return;
  try {
    final s = await ref
        .read(posControllerProvider.notifier)
        .fermerSession(montantCompte: double.tryParse(compte.text.replaceAll(',', '.')) ?? -1);
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.info,
        titre: l10n.posSessionFermer,
        message: l10n.posSessionFermee(s.code, formaterMontant(s.ecart ?? 0, devise)),
      ),
    );
  } on SessionException catch (e) {
    if (!context.mounted) return;
    unawaited(
      afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.posSessionFermer,
        message: messageErreurSession(l10n, e.erreur),
      ),
    );
  }
}

/// Sélection d'un client.
Future<Client?> afficherChoixClient(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final clients = await ClientRepository(ref.read(appDatabaseProvider).db).tous(actifsSeulement: true);
  if (!context.mounted) return null;
  return afficherSelecteur<Client>(
    context,
    titre: l10n.posChoisirClient,
    elements: clients,
    libelle: (c) => c.estDePassage ? l10n.posClientPassage : c.nom,
    sousLibelle: (c) =>
        '${c.code}${c.telephone.isEmpty ? '' : ' · ${c.telephone}'}${c.points > 0 ? ' · ${c.points} pts' : ''}',
  );
}

/// Saisie d'un pourcentage de remise.
Future<double?> afficherRemise(BuildContext context, {required double initiale}) async {
  final l10n = AppLocalizations.of(context);
  final ctrl = TextEditingController(text: initiale == 0 ? '' : initiale.toString());
  return showDialog<double>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) => DsDialog(
      titre: l10n.posRemiseGlobale,
      largeur: 380,
      contenu: DsTextField(
        controller: ctrl,
        libelle: l10n.posRemisePct,
        typeClavier: TextInputType.number,
        autofocus: true,
        onSubmitted: (v) => Navigator.of(ctx).pop(double.tryParse(v.replaceAll(',', '.')) ?? 0),
      ),
      actions: [
        DsButton(
          libelle: l10n.communAnnuler,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        DsButton(
          libelle: l10n.communValider,
          onPressed: () => Navigator.of(ctx).pop(double.tryParse(ctrl.text.replaceAll(',', '.')) ?? 0),
        ),
      ],
    ),
  );
}

/// Calculatrice.
Future<double?> afficherCalculatrice(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<double>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) => DsDialog(
      titre: l10n.calcTitre,
      largeur: 360,
      icone: Icon(LucideIcons.calculator, color: ctx.ds.colors.primaire),
      contenu: Calculator(libelleUtiliser: l10n.calcUtiliser, onUtiliser: (v) => Navigator.of(ctx).pop(v)),
    ),
  );
}

/// Aide des 16 raccourcis.
Future<void> afficherAideRaccourcis(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final raccourcis = [
    ('F1', l10n.posRaccourciF1),
    ('F2', l10n.posRaccourciF2),
    ('F3', l10n.posRaccourciF3),
    ('F4', l10n.posRaccourciF4),
    ('F5', l10n.posRaccourciF5),
    ('F6', l10n.posRaccourciF6),
    ('F7', l10n.posRaccourciF7),
    ('F8', l10n.posRaccourciF8),
    ('F9', l10n.posRaccourciF9),
    ('F10', l10n.posRaccourciF10),
    ('F11', l10n.posRaccourciF11),
    ('F12', l10n.posRaccourciF12),
    ('Ctrl+N', l10n.posRaccourciCtrlN),
    ('Ctrl+Tab', l10n.posRaccourciCtrlTab),
    ('Suppr', l10n.posRaccourciSuppr),
    ('+ / −', l10n.posRaccourciPlusMoins),
  ];
  return showDialog<void>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) {
      final c = ctx.ds.colors;
      final t = ctx.ds.typo;
      return DsDialog(
        titre: l10n.posRaccourcisTitre,
        largeur: 560,
        icone: Icon(LucideIcons.keyboard, color: c.primaire),
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (touche, libelle) in raccourcis)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 84,
                      padding: const EdgeInsets.symmetric(horizontal: DsSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.surfaceAttenuee,
                        borderRadius: DsRadius.borderSm,
                        border: Border.all(color: c.bordureForte),
                      ),
                      child: Text(touche, style: t.petitFort, textAlign: TextAlign.center),
                    ),
                    const SizedBox(width: DsSpacing.md),
                    Expanded(child: Text(libelle, style: t.corps)),
                  ],
                ),
              ),
          ],
        ),
        actions: [DsButton(libelle: l10n.communFermer, onPressed: () => Navigator.of(ctx).pop())],
      );
    },
  );
}

/// Paramètres d'impression (Paramètres, lot 8) lus depuis la table `parametre`.
Future<({String type, String adresse, LargeurTicket largeur})> lireImprimante(WidgetRef ref) async {
  final p = await ParametreRepository(ref.read(appDatabaseProvider).db)
      .lirePlusieurs(['imprimante_type', 'imprimante_adresse', 'imprimante_largeur']);
  return (
    type: p['imprimante_type'] ?? TypesImprimante.normale,
    adresse: p['imprimante_adresse'] ?? '',
    largeur: p['imprimante_largeur'] == '58' ? LargeurTicket.mm58 : LargeurTicket.mm80,
  );
}

ImprimanteEscPos? construireImprimante(String type, String adresse) {
  switch (type) {
    case TypesImprimante.reseau:
      final parts = adresse.split(':');
      return ImprimanteReseau(parts.first, port: parts.length > 1 ? int.tryParse(parts[1]) ?? 9100 : 9100);
    case TypesImprimante.usb:
      return ImprimanteUsbSpouleur(adresse);
    case TypesImprimante.bluetooth:
      return ImprimanteBluetooth(adresse);
    default:
      return null;
  }
}

/// Police PDF selon la langue (Cairo pour l'arabe).
Future<pw.Font?> policePdf(bool arabe) async {
  try {
    final data = await rootBundle.load(arabe ? 'assets/fonts/Cairo-400.ttf' : 'assets/fonts/PlusJakartaSans-400.ttf');
    return pw.Font.ttf(data);
  } on Object {
    return null;
  }
}

/// Résultat de vente : monnaie, impression ticket (ESC/POS ou PDF), facture A4.
Future<void> afficherResultatVente(BuildContext context, WidgetRef ref, Vente vente) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final boutique = await BoutiqueRepository(ref.read(appDatabaseProvider).db).lire() ?? const Boutique(nom: 'CaisseDZ');
  final client = await ClientRepository(ref.read(appDatabaseProvider).db).parCode(vente.clientCode);
  final imprimante = await lireImprimante(ref);
  if (!context.mounted) return;
  final arabe = Localizations.localeOf(context).languageCode == 'ar';
  final libelles = arabe ? LibellesTicket.ar : LibellesTicket.fr;
  final nomClient = client == null || client.estDePassage ? null : client.nom;

  Future<void> imprimerTicket(LargeurTicket largeur) async {
    final transport = construireImprimante(imprimante.type, imprimante.adresse);
    try {
      if (transport != null) {
        await transport.envoyer(
          TicketEscPos(
            largeur: largeur,
            libelles: libelles,
            devise: devise,
          ).generer(vente, boutique: boutique, nomClient: nomClient, ouvrirTiroir: true),
        );
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.posImpressionOk)));
      } else {
        final police = await policePdf(arabe);
        final octets = await DocumentsPdf(
          libelles: libelles,
          devise: devise,
          police: police,
        ).ticket(vente, boutique: boutique, largeur: largeur, nomClient: nomClient);
        await Printing.layoutPdf(onLayout: (_) async => octets, name: 'ticket_${vente.code}.pdf');
      }
    } on ImpressionException catch (e) {
      if (!context.mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.posImprimerTicket,
          message: l10n.posImpressionErreur(e.message),
        ),
      );
    }
  }

  Future<void> facture() async {
    final police = await policePdf(arabe);
    final Uint8List octets = await DocumentsPdf(libelles: libelles, devise: devise, police: police).factureA4(
      vente,
      boutique: boutique,
      nomClient: nomClient ?? l10n.posClientPassage,
      adresseClient: client?.adresse,
    );
    await Printing.layoutPdf(onLayout: (_) async => octets, name: 'facture_${vente.code}.pdf');
  }

  await showDialog<void>(
    context: context,
    barrierColor: context.ds.colors.overlay,
    builder: (ctx) {
      final c = ctx.ds.colors;
      final t = ctx.ds.typo;
      return DsDialog(
        titre: l10n.posEncaisser.replaceAll(' (F12)', ''),
        largeur: 480,
        icone: Icon(LucideIcons.circleCheck, color: c.succes),
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.posVenteEnregistree(vente.code, formaterMontant(vente.monnaie, devise)), style: t.corps),
            if (vente.monnaie > 0) ...[
              const SizedBox(height: DsSpacing.sm),
              Text(
                formaterMontant(vente.monnaie, devise),
                style: t.chiffreXl.copyWith(color: c.info),
                textAlign: TextAlign.center,
              ),
            ],
            if (vente.pointsGagnes > 0)
              Text(
                '${l10n.posPointsGagnes} : +${vente.pointsGagnes}',
                style: t.petit.copyWith(color: c.texteSecondaire),
              ),
            const SizedBox(height: DsSpacing.lg),
            Wrap(
              spacing: DsSpacing.sm,
              runSpacing: DsSpacing.sm,
              children: [
                DsButton(
                  libelle: l10n.posTicket58,
                  icone: LucideIcons.receipt,
                  variante: DsButtonVariante.secondaire,
                  onPressed: () => imprimerTicket(LargeurTicket.mm58),
                ),
                DsButton(
                  libelle: l10n.posTicket80,
                  icone: LucideIcons.receipt,
                  variante: DsButtonVariante.secondaire,
                  onPressed: () => imprimerTicket(LargeurTicket.mm80),
                ),
                DsButton(
                  libelle: l10n.posImprimerFacture,
                  icone: LucideIcons.fileText,
                  variante: DsButtonVariante.secondaire,
                  onPressed: facture,
                ),
              ],
            ),
          ],
        ),
        actions: [DsButton(libelle: l10n.communFermer, autofocus: true, onPressed: () => Navigator.of(ctx).pop())],
      );
    },
  );
}
