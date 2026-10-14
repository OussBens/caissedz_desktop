import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/features/galerie/galerie_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

/// La galerie contient un bouton « Chargement » animé en continu : pumpAndSettle ne converge jamais.
Future<void> pompe(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  testWidgets('galerie : bascule clair/sombre et langue', (tester) async {
    final container = await pumpApp(
      tester,
      routeInitiale: GaleriePage.route,
      taille: const Size(1400, 900),
      settle: false,
    );
    await pompe(tester);

    expect(find.text('Galerie du design system'), findsNWidgets(3)); // page + sidebar + barre de titre
    expect(find.byType(DsDataTable<dynamic>), findsNothing); // générique : vérifié via un texte
    final listePage = find.descendant(of: find.byType(GaleriePage), matching: find.byType(Scrollable)).first;
    await tester.scrollUntilVisible(
      find.text('PRD0001'),
      300,
      scrollable: listePage,
      duration: const Duration(milliseconds: 50),
    );
    expect(find.text('PRD0001'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sombre'),
      -300,
      scrollable: listePage,
      duration: const Duration(milliseconds: 50),
    );
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
