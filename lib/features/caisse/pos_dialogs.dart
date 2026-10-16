import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../app/providers.dart';
import '../../application/facture_service.dart';
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
import '../commun/selecteurs.dart';
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
  ErreurVente.dejaAnnulee => l10n.ventesBloqueDejaAnnule,
  ErreurVente.periodeCloturee => l10n.posErreurPeriodeCloturee,
  ErreurVente.quantiteInvalide => l10n.posErreurQuantite,
  ErreurVente.motifObligatoire => l10n.posErreurMotif,
  ErreurVente.montantPayeInferieur => l10n.posErreurMontantPaye(
    formaterMontant(double.tryParse(e.detail ?? '') ?? 0, devise),
  ),
  ErreurVente.retourLie => l10n.posErreurRetourLie,
  ErreurVente.plafondCredit => () {
    final [plafond, solde] = [for (final x in (e.detail ?? '0|0').split('|')) double.tryParse(x) ?? 0];
    return l10n.posErreurPlafondCredit(formaterMontant(plafond, devise), formaterMontant(solde, devise));
  }(),
  ErreurVente.nombreObligatoire => l10n.communNombreObligatoire,
};

String libelleModePaiement(AppLocalizations l10n, String mode) => switch (mode) {
  'Espèces' => l10n.modePaiementEspeces,
  'Carte' => l10n.modePaiementCarte,
  'Chèque' => l10n.modePaiementCheque,
  'Virement' => l10n.modePaiementVirement,
  'Points' => l10n.modePaiementPoints,
  _ => mode,
};

/// Sélection d'un client actif (dialog commun des listes métier : recherche, filtres, liste ou cartes),
/// avec « Nouveau client ».
Future<Client?> afficherChoixClient(BuildContext context, WidgetRef ref, {VoidCallback? onCreer}) async {
  final l10n = AppLocalizations.of(context);
  final clients = await ClientRepository(ref.read(appDatabaseProvider).db).tous(actifsSeulement: true);
  if (!context.mounted) return null;
  final code = await choisirDansListe(
    context,
    ref,
    ListeMetier.client,
    codes: {for (final c in clients) c.code},
    titre: l10n.posChoisirClient,
    onCreer: onCreer,
    libelleCreer: onCreer == null ? null : l10n.posNouveauClient,
  );
  return clients.where((c) => c.code == code).firstOrNull;
}

/// Calculatrice (`Calculator` du DS).
Future<double?> afficherCalculatrice(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return afficherDialog<double>(
    context,
    builder: (ctx) => DsDialog(
      titre: l10n.calcTitre,
      largeur: 380,
      iconeData: LucideIcons.calculator,
      contenu: DsCalculator(libelleUtiliser: l10n.calcUtiliser, onUtiliser: (v) => Navigator.of(ctx).pop(v)),
    ),
  );
}

/// Aide des raccourcis clavier de la caisse.
Future<void> afficherAideRaccourcis(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  final raccourcis = [
    ('F1', l10n.posRaccourciF1),
    ('F2', l10n.posRaccourciF2),
    ('F3', l10n.posRaccourciF3),
    ('F4', l10n.posRaccourciF4),
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
    ('E', l10n.posRaccourciE),
  ];
  return afficherDialog<void>(
    context,
    builder: (ctx) {
      final c = ctx.ds.colors;
      final t = ctx.ds.typo;
      return DsDialog(
        titre: l10n.posRaccourcisTitre,
        largeur: 560,
        iconeData: LucideIcons.keyboard,
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (touche, libelle) in raccourcis)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  spacing: DsSpacing.s3,
                  children: [
                    SizedBox(
                      width: 84,
                      child: Align(alignment: AlignmentDirectional.centerStart, child: DsKbd(touche)),
                    ),
                    Expanded(
                      child: Text(libelle, style: t.body.copyWith(color: c.textPrimary)),
                    ),
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
        afficherToast(context, titre: l10n.posImpressionOk);
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

  Future<void> facture() => imprimerFactureVente(context, ref, vente);

  await afficherDialog<void>(
    context,
    builder: (ctx) {
      final c = ctx.ds.colors;
      final t = ctx.ds.typo;
      return DsDialog(
        titre: l10n.posImprimerTicket,
        largeur: 480,
        iconeData: LucideIcons.printer,
        ton: DsDialogTon.succes,
        contenu: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.posVenteEnregistree(vente.code, formaterMontant(vente.monnaie, devise)),
              style: t.body.copyWith(color: c.textPrimary),
            ),
            if (vente.monnaie > 0) ...[
              const SizedBox(height: DsSpacing.s2),
              Text(
                formaterMontant(vente.monnaie, devise),
                style: t.montantXl.copyWith(color: c.infoFg),
                textAlign: TextAlign.center,
              ),
            ],
            if (vente.pointsGagnes > 0)
              Text(
                '${l10n.posPointsGagnes} : +${vente.pointsGagnes}',
                style: t.bodySm.copyWith(color: c.textSecondary),
              ),
            const SizedBox(height: DsSpacing.s4),
            Wrap(
              spacing: DsSpacing.s2,
              runSpacing: DsSpacing.s2,
              children: [
                DsButton(
                  key: const ValueKey('vente_apercu'),
                  libelle: l10n.posApercuTicket,
                  icone: LucideIcons.eye,
                  variante: DsButtonVariante.secondaire,
                  onPressed: () => afficherApercuTicket(context, ref, vente),
                ),
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

/// Facture fiscale A4 d'une vente : émise au premier appel (FAC, timbre éventuel), puis réimprimée en
/// duplicata avec ses avoirs ; le reste dû est celui du jour (versements imputés déduits).
Future<void> imprimerFactureVente(BuildContext context, WidgetRef ref, Vente vente, {bool partager = false}) async {
  final l10n = AppLocalizations.of(context);
  final devise = ref.read(deviseProvider);
  final arabe = Localizations.localeOf(context).languageCode == 'ar';
  final service = ref.read(factureServiceProvider);
  try {
    final existante = await service.factureDeVente(vente.code);
    final facture = existante ?? await service.emettre(vente.code);
    final avoirs = await service.avoirsDe(facture.code);
    final reste = await service.resteAujourdhui(vente);
    final police = await policePdf(arabe);
    final octets =
        await DocumentsPdf(
          libelles: arabe ? LibellesTicket.ar : LibellesTicket.fr,
          devise: devise,
          police: police,
        ).facturesFiscales(
          [facture, ...avoirs],
          mentions: arabe ? LibellesFacture.ar : LibellesFacture.fr,
          duplicata: existante != null,
          resteDu: reste,
        );
    if (partager) {
      await Printing.sharePdf(bytes: octets, filename: 'facture_${facture.code}.pdf');
    } else {
      await Printing.layoutPdf(onLayout: (_) async => octets, name: 'facture_${facture.code}.pdf');
    }
  } on FactureException catch (e) {
    if (!context.mounted) return;
    await afficherResultat(
      context,
      type: DsResultatType.erreur,
      titre: l10n.posImprimerFacture,
      message: e.erreur == ErreurFacture.venteAnnulee ? l10n.factureVenteAnnulee : l10n.posImpressionErreur('$e'),
    );
  } on Object catch (e) {
    if (!context.mounted) return;
    await afficherResultat(
      context,
      type: DsResultatType.erreur,
      titre: l10n.posImprimerFacture,
      message: l10n.posImpressionErreur('$e'),
    );
  }
}

/// Envoie le ticket à l'imprimante ESC/POS configurée. Retourne `false` sans imprimante thermique
/// (l'appelant propose alors l'aperçu PDF).
Future<bool> imprimerTicketDirect(BuildContext context, WidgetRef ref, Vente vente) async {
  final imprimante = await lireImprimante(ref);
  final transport = construireImprimante(imprimante.type, imprimante.adresse);
  if (transport == null || !context.mounted) return false;
  final l10n = AppLocalizations.of(context);
  final arabe = Localizations.localeOf(context).languageCode == 'ar';
  final db = ref.read(appDatabaseProvider).db;
  final boutique = await BoutiqueRepository(db).lire() ?? const Boutique(nom: 'CaisseDZ');
  final client = await ClientRepository(db).parCode(vente.clientCode);
  try {
    await transport.envoyer(
      TicketEscPos(
        largeur: imprimante.largeur,
        libelles: arabe ? LibellesTicket.ar : LibellesTicket.fr,
        devise: ref.read(deviseProvider),
      ).generer(
        vente,
        boutique: boutique,
        nomClient: client == null || client.estDePassage ? null : client.nom,
        ouvrirTiroir: true,
      ),
    );
    return true;
  } on ImpressionException catch (e) {
    if (context.mounted) {
      await afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.posImprimerTicket,
        message: l10n.posImpressionErreur(e.message),
      );
    }
    return true;
  }
}

/// Aperçu du ticket (`PreviewDialog` du DS v2.2, genre « ticket ») : rendu PDF du ticket tel qu'il sera imprimé,
/// largeur 58 / 80 mm, gabarit latin ou arabe, puis impression (ESC/POS si configurée, sinon spouleur Windows).
Future<void> afficherApercuTicket(BuildContext context, WidgetRef ref, Vente vente) async {
  final db = ref.read(appDatabaseProvider).db;
  final boutique = await BoutiqueRepository(db).lire() ?? const Boutique(nom: 'CaisseDZ');
  final client = await ClientRepository(db).parCode(vente.clientCode);
  final imprimante = await lireImprimante(ref);
  if (!context.mounted) return;
  await afficherDialog<void>(
    context,
    builder: (_) => _ApercuTicket(
      vente: vente,
      boutique: boutique,
      nomClient: client == null || client.estDePassage ? null : client.nom,
      imprimante: imprimante,
    ),
  );
}

class _ApercuTicket extends ConsumerStatefulWidget {
  const _ApercuTicket({required this.vente, required this.boutique, required this.imprimante, this.nomClient});
  final Vente vente;
  final Boutique boutique;
  final String? nomClient;
  final ({String type, String adresse, LargeurTicket largeur}) imprimante;

  @override
  ConsumerState<_ApercuTicket> createState() => _ApercuTicketState();
}

class _ApercuTicketState extends ConsumerState<_ApercuTicket> {
  late LargeurTicket _largeur = widget.imprimante.largeur;
  late bool _arabe = Localizations.localeOf(context).languageCode == 'ar';

  LibellesTicket get _libelles => _arabe ? LibellesTicket.ar : LibellesTicket.fr;

  Future<Uint8List> _pdf() async => DocumentsPdf(
    libelles: _libelles,
    devise: ref.read(deviseProvider),
    police: await policePdf(_arabe),
  ).ticket(widget.vente, boutique: widget.boutique, largeur: _largeur, nomClient: widget.nomClient);

  Future<void> _imprimer() async {
    final l10n = AppLocalizations.of(context);
    final transport = construireImprimante(widget.imprimante.type, widget.imprimante.adresse);
    try {
      if (transport != null) {
        await transport.envoyer(
          TicketEscPos(
            largeur: _largeur,
            libelles: _libelles,
            devise: ref.read(deviseProvider),
          ).generer(widget.vente, boutique: widget.boutique, nomClient: widget.nomClient),
        );
        if (mounted) afficherToast(context, titre: l10n.posImpressionOk);
      } else {
        final octets = await _pdf();
        await Printing.layoutPdf(onLayout: (_) async => octets, name: 'ticket_${widget.vente.code}.pdf');
      }
    } on ImpressionException catch (e) {
      if (!mounted) return;
      await afficherResultat(
        context,
        type: DsResultatType.erreur,
        titre: l10n.posImprimerTicket,
        message: l10n.posImpressionErreur(e.message),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.ds.colors;
    return DsDialog(
      key: const ValueKey('apercu_ticket'),
      titre: l10n.posApercuTicket,
      description: l10n.posApercuTicketDesc,
      iconeData: LucideIcons.receipt,
      largeur: 860,
      actions: [
        DsButton(
          libelle: l10n.communFermer,
          variante: DsButtonVariante.secondaire,
          onPressed: () => Navigator.of(context).pop(),
        ),
        DsButton(
          key: const ValueKey('apercu_imprimer'),
          libelle: l10n.posImprimer,
          icone: LucideIcons.printer,
          onPressed: _imprimer,
        ),
      ],
      contenu: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: DsSpacing.s3,
        children: [
          Wrap(
            spacing: DsSpacing.s2,
            runSpacing: DsSpacing.s2,
            children: [
              DsSegmentedControl<LargeurTicket>(
                key: const ValueKey('apercu_largeur'),
                petit: true,
                valeur: _largeur,
                options: const [
                  DsOption(LargeurTicket.mm58, libelle: '58 mm'),
                  DsOption(LargeurTicket.mm80, libelle: '80 mm'),
                ],
                onChanged: (v) => setState(() => _largeur = v),
              ),
              DsSegmentedControl<bool>(
                key: const ValueKey('apercu_langue'),
                petit: true,
                valeur: _arabe,
                options: [
                  DsOption(false, libelle: l10n.posGabaritLatin),
                  const DsOption(true, libelle: 'العربية'),
                ],
                onChanged: (v) => setState(() => _arabe = v),
              ),
            ],
          ),
          Container(
            height: 520,
            decoration: BoxDecoration(color: c.surfaceSunken, borderRadius: DsRadius.borderLg),
            child: ref.read(apercuPdfProvider)(
              ValueKey('${_largeur.name}_$_arabe'),
              _pdf,
              'ticket_${widget.vente.code}.pdf',
            ),
          ),
        ],
      ),
    );
  }
}

/// Rendu d'un PDF dans un aperçu (`PdfPreview`), remplacé dans les tests (rastérisation native).
final apercuPdfProvider = Provider<Widget Function(Key key, Future<Uint8List> Function() pdf, String nom)>(
  (_) =>
      (key, pdf, nom) => PdfPreview(
        key: key,
        build: (_) => pdf(),
        useActions: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowSharing: false,
        allowPrinting: false,
        pdfFileName: nom,
      ),
);
