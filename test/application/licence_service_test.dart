import 'dart:convert';

import 'package:caissedz_desktop/application/licence_service.dart';
import 'package:caissedz_desktop/core/licence/compte_bens_api.dart';
import 'package:caissedz_desktop/data/licence_repository.dart';
import 'package:caissedz_desktop/domain/models/licence.dart';
import 'package:caissedz_desktop/domain/permissions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../helpers/bases.dart';
import '../helpers/licence_test_helper.dart';

/// Le serveur BENS des tests : chaque appel noté, la réponse donnée par [repondre].
class _Serveur {
  _Serveur(this.repondre);

  final Future<http.Response> Function(http.Request r) repondre;
  final List<http.Request> appels = [];

  CompteBensApi get api => CompteBensApi(
    client: MockClient((r) async {
      appels.add(r);
      return repondre(r);
    }),
    baseUrl: 'https://bens.test/api',
  );
}

http.Response _json(Object corps, [int code = 200]) =>
    http.Response(jsonEncode(corps), code, headers: {'content-type': 'application/json; charset=utf-8'});

void main() {
  group('LicenceService — clé collée (hors ligne)', () {
    test('une clé de ce poste active le palier signé, et le reste après relecture', () async {
      final base = await ouvrirBaseDeTest();
      final s = await licenceServiceTest(base);
      expect((await s.lire()).estActivee, isFalse);
      expect(await s.codePoste(), codePosteTest());
      final l = await s.activer(await cleTest(NiveauLicence.max));
      expect(l.niveau, NiveauLicence.max);
      expect(l.expireLe, isNull);
      final relu = await (await licenceServiceTest(base)).lire();
      expect(relu.niveau, NiveauLicence.max);
    });

    test('refus : vide, autre poste, autre produit, expirée, ancienne clé SHA-256', () async {
      final base = await ouvrirBaseDeTest();
      final s = await licenceServiceTest(base);
      Matcher motif(MotifLicence m) => throwsA(isA<ActivationException>().having((e) => e.motif, 'motif', m));
      await expectLater(s.activer('  '), motif(MotifLicence.invalide));
      await expectLater(s.activer(await cleTest(NiveauLicence.basic, poste: 'AUTRE')), motif(MotifLicence.autrePoste));
      await expectLater(s.activer(await cleTest(NiveauLicence.basic, produit: 2)), motif(MotifLicence.invalide));
      await expectLater(
        s.activer(await cleTest(NiveauLicence.basic, fin: DateTime.utc(2026, 1, 31))),
        motif(MotifLicence.expiree),
      );
      await expectLater(s.activer('f' * 64), motif(MotifLicence.invalide));
      expect((await s.lire()).estActivee, isFalse, reason: 'rien n’est gardé');
    });

    test('essai terminé : la licence expirée gardée ouvre l’application en lecture seule', () async {
      final base = await ouvrirBaseDeTest();
      await LicenceRepository(base.db)
          .ecrireValeur('license_key', await cleTest(NiveauLicence.avance, fin: DateTime.utc(2026, 9, 30)));
      final l = await (await licenceServiceTest(base)).lire();
      expect((l.estActivee, l.lectureSeule, l.peutOuvrir, l.finMotif), (false, true, true, DateTime.utc(2026, 9, 30)));
      expect(l.couvre(NiveauLicence.basic), isTrue, reason: 'les modules de consultation');
      expect(l.couvre(NiveauLicence.avance), isFalse);
    });

    test('la date du poste reculée : la licence gardée n’est plus valable', () async {
      final base = await ouvrirBaseDeTest();
      var maintenant = DateTime.utc(2026, 10, 20);
      final s = await licenceServiceTest(base, horloge: () => maintenant);
      await s.activer(await cleTest(NiveauLicence.basic));
      maintenant = DateTime.utc(2026, 10, 10);
      final l = await (await licenceServiceTest(base, horloge: () => maintenant)).lire();
      expect((l.estActivee, l.motif), (false, MotifLicence.dateReculee));
    });
  });

  group('LicenceService — compte BENS', () {
    test('inscription : essai du palier choisi, compte et session gardés, l’en-tête du check-in', () async {
      final base = await ouvrirBaseDeTest();
      final aujourdhui = DateTime.now().toUtc();
      final fin = DateTime.utc(aujourdhui.year, aujourdhui.month, aujourdhui.day).add(const Duration(days: 14));
      final cle = await cleTest(NiveauLicence.avance, fin: fin);
      final serveur = _Serveur((r) async {
        final b = jsonDecode(r.body) as Map;
        return switch (r.url.path) {
          '/api/app/caissedz-desktop/register' => _json({
            'token': 'jeton-1',
            'trialGiven': true,
            'device': b['device'],
            'key': cle,
            'entitlements': {
              'app': {'active': true, 'until': '2026-11-02', 'source': 'trial', 'tier': 1},
              'smartscan': {'active': true, 'until': '2026-11-02', 'source': 'trial', 'scans': 14},
            },
            'trial': {'startedOn': '2026-10-19', 'endsOn': '2026-11-02', 'active': true},
            'offers': [],
            'scans': {
              'remaining': 14,
              'total': 14,
              'status': 'trial',
              'buckets': [],
              'expiringSoon': [
                {'kind': 'included', 'remaining': 14, 'endsOn': '2026-11-02'},
              ],
            },
          }, 201),
          '/api/app/caissedz-desktop/check-in' => _json({
            'device': b['device'],
            'key': cle,
            'entitlements': {
              'app': {'active': true, 'until': '2026-11-02', 'source': 'trial', 'tier': 1},
            },
            'trial': null,
            'offers': [],
          }),
          _ => _json({'error': 'not_found'}, 404),
        };
      });
      final s = await licenceServiceTest(base, api: serveur.api);
      final r = await s.inscrire(
        telephone: '0555 11 22 33',
        nom: 'Karim Haddad',
        commerce: 'Supérette Haddad',
        motDePasse: 'secret pass 1',
        offre: 'DSK-ADV',
      );
      expect(r.essaiDonne, isTrue);
      expect((r.licence.niveau, r.licence.essai, r.licence.expireLe), (NiveauLicence.avance, true, fin));
      expect(
        r.licence.compte,
        const CompteBens(telephone: '+213555112233', nom: 'Karim Haddad', commerce: 'Supérette Haddad'),
      );
      expect(r.licence.scansSmartScan, 14);
      expect(r.licence.expirationsScans.single, (restant: 14, fin: DateTime(2026, 11, 2)));
      final corps = jsonDecode(serveur.appels.single.body) as Map;
      expect(
        (corps['phone'], corps['offer'], corps['device'], corps['platform']),
        ('0555 11 22 33', 'DSK-ADV', codePosteTest(), 'windows'),
      );
      expect(serveur.appels.single.headers['X-Requested-With'], 'bens');

      final l = await s.synchroniser();
      expect(serveur.appels.last.headers['Authorization'], 'Bearer jeton-1');
      expect(l.compte!.nom, 'Karim Haddad', reason: 'le check-in ne renvoie pas le nom : il est gardé');
      expect(l.niveau, NiveauLicence.avance);
    });

    test('connexion : identifiants faux, puis bons ; déconnecté par le serveur : compte et clé oubliés', () async {
      final base = await ouvrirBaseDeTest();
      final cle = await cleTest(NiveauLicence.max);
      var deplace = false;
      final serveur = _Serveur((r) async {
        final b = jsonDecode(r.body) as Map;
        if (r.url.path.endsWith('/login')) {
          return b['password'] == 'bon mot de passe'
              ? _json({
                  'token': 'jeton-2',
                  'device': b['device'],
                  'key': cle,
                  'entitlements': {
                    'app': {'active': true, 'until': null, 'source': 'offline', 'tier': 2},
                  },
                  'trial': null,
                  'offers': [],
                })
              : _json({'error': 'bad_login', 'message': 'Wrong phone number or password.'}, 401);
        }
        return deplace
            ? _json({'error': 'signed_out', 'message': 'Signed out: sign in again.'}, 401)
            : _json({
                'device': '',
                'key': cle,
                'entitlements': {
                  'app': {'active': true, 'source': 'offline', 'tier': 2},
                },
              });
      });
      final s = await licenceServiceTest(base, api: serveur.api);
      await expectLater(
        s.connecter(telephone: '+213555112233', motDePasse: 'faux'),
        throwsA(isA<CompteBensException>().having((e) => e.erreur, 'erreur', ErreurCompteBens.identifiants)),
      );
      final l = await s.connecter(telephone: '+213555112233', motDePasse: 'bon mot de passe');
      expect((l.niveau, l.essai, l.compte?.telephone), (NiveauLicence.max, false, '+213555112233'));

      // Le compte s'est connecté sur un autre poste : ce poste est déconnecté, sa clé retirée.
      deplace = true;
      final apres = await s.synchroniser();
      expect((apres.estActivee, apres.compte), (false, null));
      expect(serveur.appels.last.headers['Authorization'], 'Bearer jeton-2');
    });

    test('une licence du serveur refusée ici : le pourquoi est gardé, puis effacé par une bonne', () async {
      final base = await ouvrirBaseDeTest();
      String? cle = await cleTest(NiveauLicence.max, produit: 2);
      final serveur = _Serveur((r) async {
        final reponse = {
          'key': cle,
          'entitlements': {
            'app': {'active': true, 'source': 'trial', 'tier': 2},
          },
        };
        return _json(r.url.path.endsWith('/login') ? {'token': 'jeton-4', ...reponse} : reponse);
      });
      final s = await licenceServiceTest(base, api: serveur.api);
      // Une autre application (ou une version sans la bonne clé publique).
      var l = await s.connecter(telephone: '0555112233', motDePasse: 'x');
      expect((l.estActivee, l.compte != null, l.refusServeur), (false, true, MotifLicence.invalide));
      expect((await (await licenceServiceTest(base, api: serveur.api)).lire()).refusServeur, MotifLicence.invalide);
      // Un autre PC.
      cle = await cleTest(NiveauLicence.max, poste: 'AUTRE-PC');
      expect((await s.synchroniser()).refusServeur, MotifLicence.autrePoste);
      // La bonne : activée, plus de refus.
      cle = await cleTest(NiveauLicence.max);
      l = await s.synchroniser();
      expect((l.niveau, l.refusServeur), (NiveauLicence.max, null));
    });

    test('révocation : aucune clé et pas d’app active au check-in retire la clé gardée', () async {
      final base = await ouvrirBaseDeTest();
      final cle = await cleTest(NiveauLicence.basic);
      var revoque = false;
      final serveur = _Serveur((r) async {
        if (r.url.path.endsWith('/login')) {
          return _json({
            'token': 'jeton-3',
            'key': cle,
            'entitlements': {
              'app': {'active': true, 'source': 'offline', 'tier': 0},
            },
          });
        }
        return revoque
            ? _json({'key': null, 'entitlements': {}, 'trial': null, 'offers': []})
            : _json({
                'key': cle,
                'entitlements': {
                  'app': {'active': true, 'source': 'offline', 'tier': 0},
                },
              });
      });
      final s = await licenceServiceTest(base, api: serveur.api);
      await s.connecter(telephone: '0555112233', motDePasse: 'x');
      expect((await s.synchroniser()).niveau, NiveauLicence.basic);
      revoque = true;
      final l = await s.synchroniser();
      expect(l.estActivee, isFalse);
      expect(l.compte, isNotNull, reason: 'toujours connecté au compte : il peut acheter une formule');
    });

    test('hors ligne : le check-in échoue sans rien changer ; les offres connues restent proposées', () async {
      final base = await ouvrirBaseDeTest();
      final cle = await cleTest(NiveauLicence.avance);
      var enLigne = true;
      final serveur = _Serveur((r) async {
        if (!enLigne) throw http.ClientException('hors ligne');
        return _json({
          'token': 'jeton-4',
          'key': cle,
          'entitlements': {
            'app': {'active': true, 'source': 'offline', 'tier': 1},
          },
        });
      });
      final s = await licenceServiceTest(base, api: serveur.api);
      await s.connecter(telephone: '0555112233', motDePasse: 'x');
      enLigne = false;
      expect((await s.synchroniser()).niveau, NiveauLicence.avance);
      final o = await s.offres();
      expect(o.enLigne, isFalse);
      expect(o.paliers.map((p) => p.code), ['DSK-BASIC', 'DSK-ADV', 'DSK-ULTRA']);
      expect(o.joursEssai, 14);
    });

    test('mot de passe oublié : le code de récupération, puis la réinitialisation connecte le poste', () async {
      final base = await ouvrirBaseDeTest();
      final cle = await cleTest(NiveauLicence.basic);
      final serveur = _Serveur((r) async {
        final b = jsonDecode(r.body) as Map;
        return switch (r.url.path.split('/').last) {
          'recover' => _json({'code': 'RC-AB12-CD34'}),
          'reset' =>
            b['code'] == 'K7QM-3XPD'
                ? _json({
                    'token': 'jeton-5',
                    'key': cle,
                    'entitlements': {
                      'app': {'active': true, 'source': 'offline', 'tier': 0},
                    },
                  })
                : _json({'error': 'bad_code'}, 400),
          _ => _json({'error': 'not_found'}, 404),
        };
      });
      final s = await licenceServiceTest(base, api: serveur.api);
      expect(await s.demanderRecuperation('0555 11 22 33'), 'RC-AB12-CD34');
      await expectLater(
        s.reinitialiser(telephone: '0555112233', code: 'ZZZZ-ZZZZ', motDePasse: 'nouveau pass'),
        throwsA(isA<CompteBensException>().having((e) => e.erreur, 'erreur', ErreurCompteBens.codeInvalide)),
      );
      final l = await s.reinitialiser(telephone: '0555112233', code: 'K7QM-3XPD', motDePasse: 'nouveau pass');
      expect((l.niveau, l.compte?.telephone), (NiveauLicence.basic, '+213555112233'));
    });

    test('numéros : forme gardée par le serveur', () {
      expect(LicenceService.telephoneE164('0555 12 34 56'), '+213555123456');
      expect(LicenceService.telephoneE164('00213 555 12 34 56'), '+213555123456');
      expect(LicenceService.telephoneE164('213555123456'), '+213555123456');
      expect(LicenceService.telephoneE164('+33 6 12 34 56 78'), '+33612345678');
    });
  });
}
