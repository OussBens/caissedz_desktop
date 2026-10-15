import 'dart:io';

import 'package:caissedz_desktop/app/providers.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:caissedz_desktop/core/print/imprimante.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/features/rapports/rapports_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

const _taille = Size(1600, 1000);

Finder _cle(String cle) => find.byKey(ValueKey(cle));

Finder _champ(String cle) => find.descendant(of: _cle(cle), matching: find.byType(TextField)).first;

void main() {
  group('Paramètres (DS v2.2)', () {
    testWidgets('barre unique : validation, puis tous les groupes enregistrés ensemble', (tester) async {
      final c = await pumpApp(tester, routeInitiale: '/parametres', taille: _taille);
      expect(find.text('Préférences du poste, de la boutique et de l\'application.'), findsOneWidget);
      expect(tester.widget<DsButton>(_cle('param_enregistrer')).onPressed, isNull);
      // Système : valeur invalide refusée, rien n'est écrit.
      await tester.enterText(_champ('param_marge_pct'), '-5');
      await tester.pump();
      expect(_cle('param_modifie'), findsOneWidget);
      await clic(tester, _cle('param_enregistrer'));
      expect(find.text('Valeur invalide.'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      await tester.enterText(_champ('param_marge_pct'), '30');
      await clic(tester, find.descendant(of: _cle('param_marge_type'), matching: find.text('Montant')));
      await tester.enterText(_champ('param_marge_montant'), '40');
      await tester.enterText(_champ('param_nissab'), '1615000');
      // Boutique.
      await clic(tester, _cle('param_nav_boutique'));
      await tester.enterText(_champ('param_email'), 'contact@baraka.dz');
      await tester.enterText(_champ('param_nis'), '000216123456789');
      // Caisse et ventes.
      await clic(tester, _cle('param_nav_caisse'));
      await clic(tester, _cle('param_mode_Chèque'));
      await clic(tester, _cle('param_mode_Points'));
      await clic(tester, find.text('Interdire'));
      // Impression : réseau sans adresse refusé.
      await clic(tester, _cle('param_nav_impression'));
      await clic(tester, find.text('Réseau'));
      await clic(tester, _cle('param_enregistrer'));
      expect(find.text('Indiquez la file d\'attente ou l\'adresse de l\'imprimante.'), findsOneWidget);
      await clic(tester, find.text('Fermer').last);
      await tester.enterText(_champ('param_imprimante_adresse'), '10.0.0.5:9100');
      // Alertes.
      await clic(tester, _cle('param_nav_alertes'));
      await clic(tester, _cle('param_alertes_connexion'));
      await tester.enterText(_champ('param_seuil_credit'), '20000');
      await tester.pump();
      await clic(tester, _cle('param_enregistrer'));
      expect(find.text('Paramètres enregistrés'), findsOneWidget);
      expect(_cle('param_modifie'), findsNothing);
      final p = await c.read(parametresServiceProvider).lireTout();
      expect(p.vente.margeDefautPct, 30);
      expect(p.vente.typeMarge, ParametresVente.typeMargeMontant);
      expect(p.vente.margeMontant, 40);
      expect(p.vente.venteSousAchat, ParametresVente.venteSousAchatInterdire);
      expect(p.zakat.nissab, 1615000);
      expect(p.boutique.email, 'contact@baraka.dz');
      expect(p.boutique.nis, '000216123456789');
      expect(p.paiements.cheque, isTrue);
      expect(p.paiements.points, isFalse);
      expect(p.impression.type, TypesImprimante.reseau);
      expect(p.impression.adresse, '10.0.0.5:9100');
      expect(p.alertes.afficherConnexion, isFalse);
      expect(p.alertes.seuilCreditClient, 20000);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('thème appliqué tout de suite ; sauvegarde chiffrée avec mot de passe', (tester) async {
      final dossier = Directory.systemTemp.createTempSync('caissedz_param_');
      addTearDown(() => dossier.deleteSync(recursive: true));
      final chemin = '${dossier.path}/sauvegarde.cdz';
      final c = await pumpApp(
        tester,
        routeInitiale: '/parametres',
        taille: _taille,
        overrides: [selecteurEnregistrementProvider.overrideWithValue((nom, ext) async => chemin)],
      );
      await clic(tester, _cle('param_theme_sombre'));
      expect(c.read(themeModeProvider), ThemeMode.dark);
      expect(_cle('param_modifie'), findsNothing, reason: 'préférence du poste, sans enregistrement');
      await clic(tester, _cle('param_nav_sauvegarde'));
      await clic(tester, _cle('param_sauvegarder'));
      expect(tester.widget<DsButton>(_cle('sauvegarde_mdp_ok')).onPressed, isNull);
      await tester.enterText(_champ('sauvegarde_mdp'), 'secret');
      await tester.pump();
      await clic(tester, _cle('sauvegarde_mdp_ok'));
      await tester.runAsync(() async {
        for (var i = 0; i < 50 && !File(chemin).existsSync(); i++) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      });
      await tester.pumpAndSettle();
      expect(File(chemin).existsSync(), isTrue);
      expect(find.text('Sauvegarde terminée'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('arabe : Paramètres en RTL', (tester) async {
      await pumpApp(tester, routeInitiale: '/parametres', locale: const Locale('ar'), taille: _taille);
      final nav = _cle('param_nav_systeme');
      expect(nav, findsOneWidget);
      expect(Directionality.of(tester.element(nav)), TextDirection.rtl);
    });
  });
}
