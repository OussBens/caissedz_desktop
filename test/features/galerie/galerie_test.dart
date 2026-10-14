import 'package:caissedz_desktop/app/app.dart';
import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/features/galerie/galerie_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/bases.dart';

/// La galerie contient un bouton « Chargement » animé en continu : pumpAndSettle ne converge jamais.
Future<void> pompe(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('galerie : bascule clair/sombre et langue', (tester) async {
    final base = await ouvrirBaseEnMemoire();
    const taille = Size(1400, 900);
    await tester.binding.setSurfaceSize(taille);
    tester.view.physicalSize = taille;
    tester.view.devicePixelRatio = 1;
    addTearDown(() => tester.view.reset());
    final container = ProviderContainer(overrides: [
      appDatabaseProvider.overrideWithValue(base),
      controlesFenetreProvider.overrideWithValue(false),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const CaisseDzApp(routeInitiale: GaleriePage.route),
    ));
    await pompe(tester);

    expect(find.text('Galerie du design system'), findsNWidgets(3)); // page + sidebar + barre de titre
    expect(find.byType(DsDataTable<dynamic>), findsNothing); // générique : vérifié via un texte
    final listePage = find.descendant(of: find.byType(GaleriePage), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(find.text('PRD0001'), 300, scrollable: listePage, duration: const Duration(milliseconds: 50));
    expect(find.text('PRD0001'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Sombre'), -300, scrollable: listePage, duration: const Duration(milliseconds: 50));
    await pompe(tester);
    expect(tester.element(find.text('Couleurs')).ds.colors.fond, DsColors.clair.fond);

    await tester.tap(find.text('Sombre'));
    await pompe(tester);
    expect(tester.element(find.text('Couleurs')).ds.colors.fond, DsColors.sombre.fond);
    expect(await container.read(parametresAppRepositoryProvider).lire('theme'), 'sombre');

    await tester.tap(find.text('AR'));
    await pompe(tester);
    expect(find.text('معرض نظام التصميم'), findsNWidgets(3));
    expect(Directionality.of(tester.element(find.text('Couleurs'))), TextDirection.rtl);
  });
}
