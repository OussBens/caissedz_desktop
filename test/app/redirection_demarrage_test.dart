import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/features/activation/activation_page.dart';
import 'package:caissedz_desktop/features/connexion/connexion_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('redirigerDemarrage', () {
    String? r({bool activee = true, bool connecte = true, required String cible}) =>
        redirigerDemarrage(activee: activee, connecte: connecte, cible: cible);

    test('non connecté : activation si non activée, sinon connexion', () {
      expect(r(activee: false, connecte: false, cible: routeAccueil), ActivationPage.route);
      expect(r(connecte: false, cible: routeAccueil), ConnexionPage.route);
      expect(r(connecte: false, cible: '/produits'), ConnexionPage.route);
    });

    test('écrans de démarrage accessibles sans session (demo/demo depuis la connexion)', () {
      expect(r(activee: false, connecte: false, cible: ConnexionPage.route), isNull);
      expect(r(activee: false, connecte: false, cible: ActivationPage.route), isNull);
      expect(r(connecte: false, cible: ActivationPage.route), isNull);
    });

    test('connecté : la connexion renvoie à la caisse, l\'activation reste accessible', () {
      expect(routeAccueil, '/caisse');
      expect(r(cible: ConnexionPage.route), routeAccueil);
      expect(r(cible: ActivationPage.route), isNull);
      expect(r(cible: '/produits'), isNull);
    });
  });
}
