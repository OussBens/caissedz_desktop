import 'package:caissedz_desktop/app/demarrage_providers.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:caissedz_desktop/features/roles/roles_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

void main() {
  testWidgets('Rôles : cocher une permission et un module puis enregistrer', (tester) async {
    final c = await pumpApp(
      tester,
      etat: EtatApp.connecteeAdmin,
      routeInitiale: RolesPage.route,
      taille: const Size(1400, 1000),
    );
    expect(find.text('Rôles et permissions'), findsWidgets);
    final caseCaissier = find.byKey(const ValueKey('perm_Caissier_voirPrixAchat'));
    expect(tester.widget<Checkbox>(caseCaissier).value, isFalse);
    await tester.tap(caseCaissier);
    await tester.pumpAndSettle();
    expect(tester.widget<Checkbox>(caseCaissier).value, isTrue);
    await clic(tester, find.byKey(const ValueKey('perm_Magasinier_clotures')));
    await tester.scrollUntilVisible(find.text('Enregistrer'), -300, scrollable: find.byType(Scrollable).last);
    await clic(tester, find.text('Enregistrer'));
    expect(find.text('Grille des rôles enregistrée.'), findsOneWidget);
    final grille = await c.read(permissionServiceProvider).lireGrille();
    expect(grille.permissions[Roles.caissier], contains(Permission.voirPrixAchat));
    expect(grille.modules[Roles.magasinier], contains('clotures'));
    expect(grille.permissions[Roles.admin], Permission.values.toSet());
  });
}
