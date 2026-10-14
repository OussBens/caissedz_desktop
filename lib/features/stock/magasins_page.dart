import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../app/providers.dart';
import '../../application/stock_service.dart';
import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/stock.dart';
import 'stock_providers.dart';

/// Magasins : liste, création, magasins de l'utilisateur (le premier est le principal).
class MagasinsPage extends ConsumerWidget {
  const MagasinsPage({super.key});

  Future<void> _executer(BuildContext context, WidgetRef ref, Future<void> Function() action) async {
    final l10n = AppLocalizations.of(context);
    try {
      await action();
      rafraichirStock(ref);
    } on StockException catch (e) {
      if (!context.mounted) return;
      unawaited(
        afficherResultat(
          context,
          type: DsResultatType.erreur,
          titre: l10n.magasinsTitre,
          message: messageErreurStock(l10n, e.erreur),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    final magasins = ref.watch(magasinsProvider).value ?? const [];
    final miens = ref.watch(mesMagasinsProvider).value ?? const [];
    final utilisateur = ref.watch(utilisateurCourantCodeProvider);
    final service = ref.read(stockServiceProvider);
    return DsPage(
      titre: l10n.magasinsTitre,
      actions: [
        DsButton(
          libelle: l10n.magasinNouveau,
          icone: LucideIcons.plus,
          onPressed: () {
            _formulaire(context, ref);
          },
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: DsDataTable<Magasin>(
              colonnes: [
                DsColonne(id: 'code', libelle: l10n.produitsColCode, valeur: (m) => m.code, largeur: 100),
                DsColonne(id: 'nom', libelle: l10n.magasinNom, valeur: (m) => m.nom, flex: 2),
                DsColonne(id: 'adr', libelle: l10n.magasinAdresse, valeur: (m) => m.adresse, flex: 3),
                DsColonne(
                  id: 'a',
                  libelle: l10n.communActif,
                  valeur: (m) => m.actif ? 1 : 0,
                  largeur: 90,
                  cellule: (_, m) => DsBadge(
                    libelle: m.actif ? l10n.communActif : l10n.communInactif,
                    ton: m.actif ? DsBadgeTon.succes : DsBadgeTon.neutre,
                  ),
                ),
                DsColonne(
                  id: 'p',
                  libelle: l10n.magasinPrincipal,
                  valeur: (m) => miens.isNotEmpty && miens.first == m.code ? 1 : 0,
                  largeur: 100,
                  cellule: (_, m) => miens.isNotEmpty && miens.first == m.code
                      ? Icon(LucideIcons.star, size: DsTailles.iconeSm, color: c.avertissement)
                      : const SizedBox.shrink(),
                ),
              ],
              lignes: magasins,
              cle: (m) => m.code,
              pagine: false,
              onDoubleClic: (m) => _formulaire(context, ref, magasin: m),
              actionsContextuelles: [
                DsActionContextuelle(
                  libelle: l10n.communModifier,
                  icone: LucideIcons.pencil,
                  onSelected: (m) => _formulaire(context, ref, magasin: m),
                ),
                DsActionContextuelle(
                  libelle: l10n.magasinDefinirPrincipal,
                  icone: LucideIcons.star,
                  onSelected: (m) => _executer(
                    context,
                    ref,
                    () => service.definirMagasinsUtilisateur(utilisateur, [m.code, ...miens.where((x) => x != m.code)]),
                  ),
                ),
                DsActionContextuelle(
                  libelle: l10n.magasinAjouterAuxMiens,
                  icone: LucideIcons.plus,
                  onSelected: (m) => _executer(
                    context,
                    ref,
                    () => service.definirMagasinsUtilisateur(
                      utilisateur,
                      miens.contains(m.code) ? miens : [...miens, m.code],
                    ),
                  ),
                ),
                DsActionContextuelle(
                  libelle: l10n.magasinRetirerDesMiens,
                  icone: LucideIcons.minus,
                  destructif: true,
                  onSelected: (m) => _executer(
                    context,
                    ref,
                    () => service.definirMagasinsUtilisateur(utilisateur, miens.where((x) => x != m.code).toList()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: DsSpacing.lg),
          Expanded(
            flex: 2,
            child: DsCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DsSectionTitre(l10n.magasinMesMagasins),
                  if (miens.isEmpty) Text(l10n.communAucune, style: t.petit.copyWith(color: c.texteAttenue)),
                  for (final (i, code) in miens.indexed)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        i == 0 ? LucideIcons.star : LucideIcons.warehouse,
                        size: DsTailles.icone,
                        color: i == 0 ? c.avertissement : c.texteSecondaire,
                      ),
                      title: Text(
                        magasins.where((m) => m.code == code).firstOrNull?.nom ?? code,
                        style: i == 0 ? t.corpsFort : t.corps,
                      ),
                      subtitle: i == 0
                          ? Text(l10n.magasinPrincipal, style: t.legende.copyWith(color: c.texteAttenue))
                          : null,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _formulaire(BuildContext context, WidgetRef ref, {Magasin? magasin}) async {
    final l10n = AppLocalizations.of(context);
    final nom = TextEditingController(text: magasin?.nom ?? '');
    final adresse = TextEditingController(text: magasin?.adresse ?? '');
    var actif = magasin?.actif ?? true;
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: context.ds.colors.overlay,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => DsDialog(
          titre: magasin == null ? l10n.magasinNouveau : l10n.communModifier,
          largeur: 480,
          actions: [
            DsButton(
              libelle: l10n.communAnnuler,
              variante: DsButtonVariante.secondaire,
              onPressed: () => Navigator.of(ctx).pop(false),
            ),
            DsButton(libelle: l10n.communEnregistrer, onPressed: () => Navigator.of(ctx).pop(true)),
          ],
          contenu: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DsTextField(controller: nom, libelle: l10n.magasinNom, autofocus: true),
              const SizedBox(height: DsSpacing.md),
              DsTextField(controller: adresse, libelle: l10n.magasinAdresse),
              if (magasin != null)
                DsSwitch(valeur: actif, libelle: l10n.communActif, onChanged: (v) => setState(() => actif = v)),
            ],
          ),
        ),
      ),
    );
    if (ok != true || !context.mounted || nom.text.trim().isEmpty) return;
    final service = ref.read(stockServiceProvider);
    await _executer(context, ref, () async {
      if (magasin == null) {
        await service.creerMagasin(nom.text, adresse: adresse.text);
      } else {
        await service.modifierMagasin(
          Magasin(
            code: magasin.code,
            nom: nom.text.trim(),
            adresse: adresse.text.trim(),
            actif: actif,
            systeme: magasin.systeme,
          ),
        );
      }
    });
  }
}
