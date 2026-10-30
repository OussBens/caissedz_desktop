import 'package:caissedz_desktop/application/stock_service.dart';
import 'package:caissedz_desktop/application/utilisateur_service.dart';
import 'package:caissedz_desktop/core/securite/mot_de_passe.dart';
import 'package:caissedz_desktop/data/utilisateur_repository.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

/// Desktop — Plans & Pricing : magasins et caissiers par palier (Basic et Advanced 1 / 5, Max 15 / 15).
void main() {
  const hachage = MotDePasse(iterations: 300);

  test('les paliers et leurs limites', () {
    expect([for (final n in NiveauLicence.values) (n.magasins, n.caissiers)], [(1, 5), (1, 5), (15, 15)]);
  });

  test('caissiers : au-delà du palier, création et réactivation refusées ; l’administrateur ne compte pas', () async {
    final base = await ouvrirBaseDeTest();
    final s = UtilisateurService(base.db, utilisateurCode: 'USR0000', hachage: hachage, maxCaissiers: 2);
    Future<void> creer(String identifiant) => s.creer(
      identifiant: identifiant,
      motDePasse: 'Amina2026',
      telephone: '0661 20 30 40',
      roleCode: Roles.caissier,
      caisses: const ['CIS0000'],
      magasins: const ['MAG0000'],
    );
    await creer('amina');
    await creer('yacine');
    expect(await UtilisateurService.nombreCaissiers(base.db), 2, reason: 'ni admin, ni le compte démo désactivé');
    final plein = throwsA(
      isA<UtilisateurException>().having((e) => e.erreur, 'erreur', ErreurUtilisateur.limiteCaissiers),
    );
    await expectLater(creer('karim'), plein);
    // Une place libérée se reprend ; la réactiver ensuite est refusé tant que le palier est plein.
    final yacine = (await UtilisateurRepository(base.db).parIdentifiant('yacine'))!;
    await s.desactiver([yacine.code]);
    await creer('karim');
    await expectLater(
      s.modifier(
        yacine.code,
        identifiant: 'yacine',
        telephone: '0661 20 30 40',
        roleCode: Roles.caissier,
        caisses: const ['CIS0000'],
        magasins: const ['MAG0000'],
      ),
      plein,
    );
    // Sans limite (aucune licence lue, tests) : rien n'est refusé.
    await UtilisateurService(base.db, utilisateurCode: 'USR0000', hachage: hachage).creer(
      identifiant: 'nadia',
      motDePasse: 'Nadia2026',
      telephone: '0661 20 30 41',
      roleCode: Roles.caissier,
      caisses: const ['CIS0000'],
      magasins: const ['MAG0000'],
    );
  });

  test('magasins : le magasin principal compte ; en Max jusqu’à 15', () async {
    final base = await ouvrirBaseDeTest();
    final plein = throwsA(isA<StockException>().having((e) => e.erreur, 'erreur', ErreurStock.limiteMagasins));
    await expectLater(
      StockService(
        base.db,
        utilisateurCode: 'USR0000',
        maxMagasins: NiveauLicence.basic.magasins,
      ).creerMagasin('Dépôt'),
      plein,
    );
    final palierMax = StockService(base.db, utilisateurCode: 'USR0000', maxMagasins: 3);
    final depot = await palierMax.creerMagasin('Dépôt');
    await palierMax.creerMagasin('Annexe');
    await expectLater(palierMax.creerMagasin('Troisième'), plein);
    await palierMax.changerEtatMagasins([depot.code], actif: false);
    await palierMax.creerMagasin('Troisième');
    await expectLater(
      palierMax.changerEtatMagasins([depot.code], actif: true),
      plein,
      reason: 'réactiver reprend une place',
    );
  });
}
