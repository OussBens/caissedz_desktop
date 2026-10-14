import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/features/activation/activation_page.dart';
import 'package:caissedz_desktop/features/configuration/configuration_page.dart';
import 'package:caissedz_desktop/features/connexion/connexion_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('redirigerDemarrage', () {
    String? r({bool activee = true, bool configuree = true, bool connecte = true, required String cible}) =>
        redirigerDemarrage(activee: activee, configuree: configuree, connecte: connecte, cible: cible);

    test('ordre activation → configuration → connexion', () {
      expect(r(activee: false, configuree: false, connecte: false, cible: routeAccueil), ActivationPage.route);
      expect(r(configuree: false, connecte: false, cible: ActivationPage.route), ConfigurationPage.route);
      expect(r(connecte: false, cible: routeAccueil), ConnexionPage.route);
      expect(r(cible: ConnexionPage.route), routeAccueil);
    });

    test('activation accessible une fois activée (sortie du mode démo)', () {
      expect(r(connecte: false, cible: ActivationPage.route), isNull);
      expect(r(cible: ActivationPage.route), isNull);
    });
  });
}
