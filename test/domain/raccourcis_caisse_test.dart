import 'package:caissedz_desktop/domain/raccourcis_caisse.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Raccourcis clavier de la caisse', () {
    test('par défaut : une touche par action, aucune touche répétée', () {
      final d = RaccourcisCaisse.defaut;
      expect(d.valide, isTrue);
      expect(d.libelle(ActionCaisse.encaisser), 'F4');
      expect(d.libelle(ActionCaisse.nouveauPanier), 'Ctrl+N');
      expect(d.libelle(ActionCaisse.retirerLigne), 'Suppr');
      expect(d.libelle(ActionCaisse.quantitePlus), '+');
      expect(d.libelle(ActionCaisse.entreeRapide), 'E');
      expect({for (final a in ActionCaisse.values) d.touche(a)}.length, ActionCaisse.values.length);
    });

    test('codage stocké : aller-retour, valeurs illisibles ou interdites → touche par défaut', () {
      const t = ToucheRaccourci(LogicalKeyboardKey.keyP, ctrl: true, shift: true);
      expect(ToucheRaccourci.decoder(t.encoder()), t);
      expect(t.libelle, 'Ctrl+Maj+P');
      final r = RaccourcisCaisse.depuisCles({
        RaccourcisCaisse.cle(ActionCaisse.vider): const ToucheRaccourci(LogicalKeyboardKey.f5).encoder(),
        RaccourcisCaisse.cle(ActionCaisse.client): 'n’importe quoi',
        RaccourcisCaisse.cle(ActionCaisse.remise): const ToucheRaccourci(LogicalKeyboardKey.enter).encoder(),
      });
      expect(r.libelle(ActionCaisse.vider), 'F5');
      expect(r.libelle(ActionCaisse.client), 'F7');
      expect(r.libelle(ActionCaisse.remise), 'F8');
      expect(r.valide, isTrue);
      expect(RaccourcisCaisse.depuisCles(r.versCles()), r);
    });

    test('touche répétée ou réservée : refusée', () {
      final d = RaccourcisCaisse.defaut;
      final double = d.avec(ActionCaisse.vider, const ToucheRaccourci(LogicalKeyboardKey.f4));
      expect(double.valide, isFalse);
      expect(
        d.utiliseePar(const ToucheRaccourci(LogicalKeyboardKey.f4), sauf: ActionCaisse.vider),
        ActionCaisse.encaisser,
      );
      for (final t in const [
        ToucheRaccourci(LogicalKeyboardKey.enter),
        ToucheRaccourci(LogicalKeyboardKey.numpadEnter),
        ToucheRaccourci(LogicalKeyboardKey.escape),
        ToucheRaccourci(LogicalKeyboardKey.tab),
        ToucheRaccourci(LogicalKeyboardKey.space),
        ToucheRaccourci(LogicalKeyboardKey.keyC, ctrl: true),
        ToucheRaccourci(LogicalKeyboardKey.f4, alt: true),
      ]) {
        expect(t.estInterdite, isTrue, reason: t.libelle);
      }
      expect(const ToucheRaccourci(LogicalKeyboardKey.tab, ctrl: true).estInterdite, isFalse);
    });

    test('pavé numérique et clavier principal : une seule et même touche', () {
      final d = RaccourcisCaisse.defaut;
      expect(d.actionPour(LogicalKeyboardKey.add, ctrl: false, shift: true, alt: false), ActionCaisse.quantitePlus);
      expect(
        d.actionPour(LogicalKeyboardKey.numpadAdd, ctrl: false, shift: false, alt: false),
        ActionCaisse.quantitePlus,
      );
      expect(d.actionPour(LogicalKeyboardKey.minus, ctrl: false, shift: false, alt: false), ActionCaisse.quantiteMoins);
      // « + » du clavier principal déjà pris par Quantité +1 (pavé numérique).
      expect(d.utiliseePar(const ToucheRaccourci(LogicalKeyboardKey.add)), ActionCaisse.quantitePlus);
      expect(d.actionPour(LogicalKeyboardKey.keyN, ctrl: false, shift: false, alt: false), isNull);
      expect(d.actionPour(LogicalKeyboardKey.keyN, ctrl: true, shift: false, alt: false), ActionCaisse.nouveauPanier);
    });
  });
}
