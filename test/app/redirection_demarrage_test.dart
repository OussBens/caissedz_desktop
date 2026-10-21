import 'package:caissedz_desktop/app/router.dart';
import 'package:caissedz_desktop/features/activation/activation_page.dart';
import 'package:caissedz_desktop/features/compte_bens/compte_bens_pages.dart';
import 'package:caissedz_desktop/features/connexion/connexion_page.dart';
import 'package:caissedz_desktop/features/offres/offres_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('redirigerDemarrage', () {
    String? r({bool activee = true, bool connecte = true, required String cible, bool lectureSeule = false}) =>
        redirigerDemarrage(activee: activee, connecte: connecte, cible: cible, lectureSeule: lectureSeule);

    test('non connecté : les formules sans licence valable, sinon la connexion', () {
      expect(r(activee: false, connecte: false, cible: routeAccueil), OffresPage.route);
      expect(r(connecte: false, cible: routeAccueil), ConnexionPage.route);
      expect(r(connecte: false, cible: '/produits'), ConnexionPage.route);
    });

    test('sans licence valable : la connexion locale renvoie aux formules ; compte et clé accessibles', () {
      expect(r(activee: false, connecte: false, cible: ConnexionPage.route), OffresPage.route);
      for (final route in [
        OffresPage.route,
        InscriptionPage.route,
        ConnexionComptePage.route,
        MotDePasseOubliePage.route,
        ActivationPage.route,
      ]) {
        expect(r(activee: false, connecte: false, cible: route), isNull, reason: route);
      }
      expect(r(connecte: false, cible: ActivationPage.route), isNull);
    });

    test('connecté : la connexion renvoie à la caisse ; formules et clé restent accessibles', () {
      expect(routeAccueil, '/caisse');
      expect(r(cible: ConnexionPage.route), routeAccueil);
      expect(r(cible: ActivationPage.route), isNull);
      expect(r(cible: OffresPage.route), isNull);
      expect(r(cible: '/produits'), isNull);
    });

    test('lecture seule (essai terminé) : après la connexion, le tableau de bord plutôt que la caisse', () {
      expect(r(cible: ConnexionPage.route, lectureSeule: true), routeAccueilLectureSeule);
    });
  });
}
