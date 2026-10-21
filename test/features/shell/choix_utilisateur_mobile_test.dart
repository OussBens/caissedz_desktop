import 'dart:async';

import 'package:caissedz_desktop/app/mobile_providers.dart';
import 'package:caissedz_desktop/application/serveur_mobile.dart';
import 'package:caissedz_desktop/core/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/app_test_helper.dart';

const _demande = DemandeAppairage(
  nom: 'Samsung SM-A515F',
  plateforme: 'android',
  systeme: 'Android 14',
  adresse: '192.168.1.40',
  administrateur: 'USR0000',
);

void main() {
  testWidgets('QR de l’Admin scanné : le poste ouvre le choix de l’utilisateur du téléphone', (tester) async {
    final c = await pumpApp(tester, taille: const Size(1400, 900));
    String? choisi = 'pas encore';
    unawaited(c.read(demandeAppairageProvider.notifier).demander(_demande).then((v) => choisi = v));
    await tester.pumpAndSettle();
    expect(find.text('Nouveau téléphone à connecter'), findsOneWidget);
    expect(find.text('Samsung SM-A515F'), findsOneWidget);
    expect(find.textContaining('Android 14'), findsOneWidget);
    expect(find.textContaining('192.168.1.40'), findsOneWidget);
    expect(tester.widget<DsButton>(find.byKey(const ValueKey('mobile_choix_connecter'))).onPressed, isNull);
    await clic(tester, find.byKey(const ValueKey('mobile_choix_USR0000')));
    await clic(tester, find.byKey(const ValueKey('mobile_choix_connecter')));
    expect(choisi, 'USR0000');
    expect(find.text('Nouveau téléphone à connecter'), findsNothing);
    expect(c.read(demandeAppairageProvider), isNull);

    // Refus : le téléphone reçoit « refusé ».
    choisi = 'pas encore';
    unawaited(c.read(demandeAppairageProvider.notifier).demander(_demande).then((v) => choisi = v));
    await tester.pumpAndSettle();
    await clic(tester, find.byKey(const ValueKey('mobile_choix_refuser')));
    expect(choisi, isNull);
  });
}
