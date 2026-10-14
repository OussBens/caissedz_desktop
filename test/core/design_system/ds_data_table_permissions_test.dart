import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

class _P {
  const _P(this.code, this.prixAchat, this.prixVente);
  final String code;
  final double prixAchat;
  final double prixVente;
}

List<DsColonne<_P>> _colonnes() => [
  DsColonne(id: 'code', libelle: 'Code', valeur: (p) => p.code),
  DsColonne(
    id: 'pa',
    libelle: "Prix d'achat",
    valeur: (p) => p.prixAchat,
    numerique: true,
    permission: 'voirPrixAchat',
  ),
  DsColonne(id: 'pv', libelle: 'Prix de vente', valeur: (p) => p.prixVente, numerique: true),
];

const _lignes = [_P('P1', 100, 150), _P('P2', 200, 260)];

void main() {
  testWidgets('colonne « prix d’achat » masquée sans la permission voirPrixAchat', (tester) async {
    await pumpDs(tester, DsDataTable<_P>(colonnes: _colonnes(), lignes: _lignes, cle: (p) => p.code, pagine: false));
    expect(find.text("Prix d'achat"), findsNothing);
    expect(find.text('100.0'), findsNothing);
    expect(find.text('150.0'), findsOneWidget);
    // Absente aussi du menu « Colonnes » : impossible de la réafficher.
    await tester.tap(find.byTooltip('Colonnes'));
    await tester.pumpAndSettle();
    expect(find.text("Prix d'achat"), findsNothing);
  });

  testWidgets('colonne visible avec la permission', (tester) async {
    await pumpDs(
      tester,
      DsDataTable<_P>(
        colonnes: _colonnes(),
        lignes: _lignes,
        cle: (p) => p.code,
        pagine: false,
        permissions: const {'voirPrixAchat'},
      ),
    );
    expect(find.text("Prix d'achat"), findsOneWidget);
    expect(find.text('100.0'), findsOneWidget);
  });
}
