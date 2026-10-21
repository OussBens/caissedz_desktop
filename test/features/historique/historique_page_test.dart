import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

const _taille = Size(1600, 1000);

void main() {
  group('Historique (DS v2.2)', () {
    testWidgets('KPI sur 7 jours et quatre filtres du DS', (tester) async {
      await pumpApp(tester, routeInitiale: '/historique', taille: _taille);
      expect(find.text('Actions (7 j)'), findsNothing, reason: 'chiffres repliés par défaut');
      expect(find.byKey(const ValueKey('filtre_poste_historique')), findsNothing, reason: 'filtres fermés par défaut');
      await ouvrirChiffres(tester);
      await ouvrirFiltres(tester);
      expect(find.text('Actions (7 j)'), findsOneWidget);
      expect(find.text('Créations'), findsOneWidget);
      expect(find.text('Modifications'), findsOneWidget);
      expect(find.text('Annulations'), findsWidgets);
      expect(find.byKey(const ValueKey('filtre_poste_historique')), findsOneWidget);
    });

    testWidgets('arabe : écran Historique en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/historique', locale: const Locale('ar'), taille: _taille);
      await ouvrirChiffres(tester);
      await ouvrirFiltres(tester);
      final filtre = find.byKey(const ValueKey('filtre_module_historique'));
      expect(filtre, findsOneWidget);
      expect(Directionality.of(tester.element(filtre)), TextDirection.rtl);
      expect(find.text('العمليات (7 أيام)'), findsOneWidget);
    });
  });
}
