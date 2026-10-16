import 'package:caissedz_desktop/application/parametres_service.dart';
import 'package:caissedz_desktop/application/zakat_service.dart';
import 'package:caissedz_desktop/domain/zakat.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/bases.dart';

Zakat _zakat({double stock = 900000, double nissab = 1020000, String statut = StatutsZakat.brouillon}) => Zakat(
  code: '',
  annee: 2026,
  debutHawl: DateTime(2026, 3, 15),
  dateDue: CalculZakat.echeance(DateTime(2026, 3, 15)),
  stock: stock,
  liquidites: 300000,
  creances: 100000,
  dettes: 200000,
  nissab: nissab,
  statut: statut,
);

Matcher _erreur(ErreurZakat e) => throwsA(isA<ZakatException>().having((x) => x.erreur, 'erreur', e));

void main() {
  group('CalculZakat (§9.15)', () {
    test('capital, obligation au nissab, montant 2,5 %, hawl de 354 jours', () {
      final z = _zakat();
      expect(z.capital, 1100000);
      expect(z.obligatoire, isTrue);
      expect(z.montant, 27500);
      expect(_zakat(stock: 100000).obligatoire, isFalse);
      expect(_zakat(stock: 100000).montant, 0);
      expect(_zakat(nissab: 0).obligatoire, isFalse, reason: 'nissab non renseigné');
      expect(CalculZakat.echeance(DateTime(2026, 3, 15)), DateTime(2027, 3, 4));
    });
  });

  group('ZakatService', () {
    test('création ZKT0001 pré-remplie, modification, paiement puis modification refusée', () async {
      final base = await ouvrirBaseDeTest();
      await ParametresService(
        base.db,
        utilisateurCode: 'USR0000',
      ).enregistrerZakat(const ParametresZakat(nissab: 1020000, tauxPct: 2.5));
      final s = ZakatService(base.db, utilisateurCode: 'USR0000');
      expect((await s.parametres()).nissab, 1020000);
      expect((await s.patrimoine()).capital, 0, reason: 'base vide');
      expect(await s.prochainCode(), 'ZKT0001');
      await expectLater(s.creer(_zakat(stock: -1)), _erreur(ErreurZakat.valeurInvalide));
      final z = await s.creer(_zakat());
      expect(z.code, 'ZKT0001');
      expect(z.creePar, 'USR0000');
      final ligne = (await base.db.query('zakat')).single;
      expect(ligne['capital_total'], 1100000);
      expect(ligne['obligatoire'], 1);
      expect(ligne['montant_zakat'], 27500);
      final m = await s.modifier(
        Zakat(
          code: z.code,
          annee: 2026,
          debutHawl: z.debutHawl,
          dateDue: z.dateDue,
          stock: 1000000,
          liquidites: 300000,
          creances: 100000,
          dettes: 200000,
          nissab: z.nissab,
          statut: StatutsZakat.nonPaye,
        ),
      );
      expect(m.montant, 30000);
      expect(m.statut, StatutsZakat.nonPaye);
      final p = await s.marquerPayee(z.code, le: DateTime(2027, 3, 1));
      expect(p.estPayee, isTrue);
      expect(p.datePaiement, DateTime(2027, 3, 1));
      await expectLater(s.modifier(p), _erreur(ErreurZakat.dejaPayee));
      await expectLater(s.marquerPayee(z.code), _erreur(ErreurZakat.dejaPayee));
      await expectLater(s.annuler([z.code], motif: 'x'), _erreur(ErreurZakat.dejaPayee));
    });

    test('annulation douce avec motif obligatoire', () async {
      final base = await ouvrirBaseDeTest();
      final s = ZakatService(base.db, utilisateurCode: 'USR0000');
      final z = await s.creer(_zakat());
      await expectLater(s.annuler([z.code], motif: ' '), _erreur(ErreurZakat.motifObligatoire));
      await s.annuler([z.code], motif: 'Erreur de saisie');
      final a = (await s.calculs()).single;
      expect(a.actif, isFalse);
      expect(a.motifAnnulation, 'Erreur de saisie');
      expect(s.blocageAnnulation(a), ErreurZakat.annulee);
      final h = await base.db.query('historique', where: "entite = 'zakat'", orderBy: 'id');
      expect(h.map((r) => r['action']), ['Création', 'Annulation']);
    });
  });
}
