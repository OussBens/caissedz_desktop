import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/design_system/design_system.dart';
import '../../core/i18n/generated/app_localizations.dart';
import '../../domain/models/produit.dart';
import '../../domain/models/stock.dart';

/// Éditeur de lignes (produit, quantité, nombre) partagé par les transferts, sorties, entrées.
class LignesStockEditeur extends StatelessWidget {
  const LignesStockEditeur({
    super.key,
    required this.produits,
    required this.lignes,
    required this.onChanged,
    this.libelleAjouter,
  });

  final List<Produit> produits;
  final List<LigneStock> lignes;
  final ValueChanged<List<LigneStock>> onChanged;
  final String? libelleAjouter;

  @override
  Widget build(BuildContext context) {
    final c = context.ds.colors;
    final t = context.ds.typo;
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(l10n.transfertLignes, style: t.titreSm)),
            DsButton(
              libelle: libelleAjouter ?? l10n.transfertAjouterLigne,
              icone: LucideIcons.plus,
              taille: DsButtonTaille.sm,
              variante: DsButtonVariante.secondaire,
              onPressed: () async {
                final p = await afficherSelecteur<Produit>(
                  context,
                  titre: l10n.transfertAjouterLigne,
                  elements: produits,
                  libelle: (p) => p.designation,
                  sousLibelle: (p) => '${p.code}${p.codeBarres == null ? '' : ' · ${p.codeBarres}'}',
                );
                if (p == null) return;
                if (lignes.any((l) => l.produitCode == p.code)) return;
                onChanged([...lignes, LigneStock(produitCode: p.code, quantite: 1)]);
              },
            ),
          ],
        ),
        const SizedBox(height: DsSpacing.sm),
        if (lignes.isEmpty) Text(l10n.stockErreurLignes, style: t.petit.copyWith(color: c.texteAttenue)),
        for (final (i, l) in lignes.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: DsSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    produits.where((p) => p.code == l.produitCode).firstOrNull?.designation ?? l.produitCode,
                    style: t.corps,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: DsTextField(
                    key: ValueKey('qte_${l.produitCode}'),
                    controller: TextEditingController(text: _fmt(l.quantite)),
                    indice: l10n.communQuantite,
                    typeClavier: TextInputType.number,
                    alignement: TextAlign.end,
                    taille: DsTailles.controleSm,
                    onChanged: (v) => _maj(i, quantite: double.tryParse(v.replaceAll(',', '.')) ?? 0),
                  ),
                ),
                if (produits.where((p) => p.code == l.produitCode).firstOrNull?.suiviNombre ?? false) ...[
                  const SizedBox(width: DsSpacing.sm),
                  SizedBox(
                    width: 110,
                    child: DsTextField(
                      key: ValueKey('nb_${l.produitCode}'),
                      controller: TextEditingController(text: _fmt(l.nombre)),
                      indice: l10n.stockColNombre,
                      typeClavier: TextInputType.number,
                      alignement: TextAlign.end,
                      taille: DsTailles.controleSm,
                      onChanged: (v) => _maj(i, nombre: double.tryParse(v.replaceAll(',', '.')) ?? 0),
                    ),
                  ),
                ],
                DsIconButton(
                  icone: LucideIcons.trash2,
                  tooltip: l10n.communSupprimer,
                  couleur: c.danger,
                  onPressed: () => onChanged([...lignes]..removeAt(i)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  static String _fmt(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toString();

  void _maj(int i, {double? quantite, double? nombre}) {
    final l = lignes[i];
    final copie = [...lignes];
    copie[i] = LigneStock(produitCode: l.produitCode, quantite: quantite ?? l.quantite, nombre: nombre ?? l.nombre);
    onChanged(copie);
  }
}
