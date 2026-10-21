import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/data/zakat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

const _taille = Size(1600, 1000);

Finder _cle(String cle) => find.byKey(ValueKey(cle));

Finder _champ(String cle) => find.descendant(of: _cle(cle), matching: find.byType(TextField)).first;

void main() {
  group('Zakat (DS v2.2)', () {
    testWidgets('nouveau calcul, marquer payée, annulation bloquée une fois payée', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/zakat', taille: _taille);
      expect(find.byKey(const ValueKey('zakat_nouveau')), findsOneWidget);
      await clic(tester, _cle('zakat_nouveau'));
      await tester.enterText(_champ('zakat_stock'), '1000000');
      await tester.enterText(_champ('zakat_liquidites'), '200000');
      await tester.enterText(_champ('zakat_creances'), '0');
      await tester.enterText(_champ('zakat_dettes'), '0');
      await tester.enterText(_champ('zakat_nissab'), '850000');
      await tester.pump();
      expect(find.text('Zakat obligatoire'), findsOneWidget);
      await clic(tester, _cle('zakat_enregistrer'));
      expect(find.text('Calcul enregistré'), findsOneWidget);
      final repo = ZakatRepository(c.read(appDatabaseProvider).db);
      final z = (await repo.parCode('ZKT0001'))!;
      expect(z.capital, 1200000);
      expect(z.montant, 30000, reason: '2,5 % du capital au-dessus du nissab');
      expect(z.creePar, 'USR0000');

      await clic(tester, find.text('ZKT0001').first);
      await clic(tester, _cle('zakat_payee'));
      expect(find.text('Zakat marquée payée'), findsOneWidget);
      expect((await repo.parCode('ZKT0001'))!.estPayee, isTrue);
      await tester.pump(const Duration(seconds: 5));

      // Un calcul payé ne peut plus être annulé (la ligne reste sélectionnée).
      await clic(tester, _cle('zakat_annuler'));
      expect(find.text('Déjà payée'), findsOneWidget);
      expect(find.text('Annuler (1)'), findsNothing);
      await clic(tester, find.text('Fermer').last);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('arabe : écran Zakat en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/zakat', locale: const Locale('ar'), taille: _taille);
      final bouton = _cle('zakat_nouveau');
      expect(bouton, findsOneWidget);
      expect(Directionality.of(tester.element(bouton)), TextDirection.rtl);
    });
  });
}
