import 'package:caissedz_desktop/core/i18n/generated/app_localizations.dart';
import 'package:caissedz_desktop/domain/models/parametres_vente.dart';
import 'package:caissedz_desktop/features/commun/detail_prix.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('fr'));

  String texte(String affichage, {double taux = 19}) =>
      texteDetailPrix(l10n, prix: 119, tauxPct: taux, affichage: affichage, devise: 'DA');

  test('détail du prix selon Paramètres › Affichage des prix', () {
    expect(texte(ParametresVente.affichagePrixTtc), 'HT 100,00 · TTC 119,00 DA');
    expect(texte(ParametresVente.affichagePrixTva), 'HT 100,00 · TVA 19 % 19,00 DA');
    expect(texte(ParametresVente.affichagePrixTous), 'HT 100,00 · TVA 19 % 19,00 · TTC 119,00 DA');
  });

  test('sans TVA (vente HT ou IFU) : le seul prix', () {
    expect(texte(ParametresVente.affichagePrixTous, taux: 0), isNot(contains('TVA')));
    expect(texte(ParametresVente.affichagePrixTous, taux: 0), contains('119'));
  });

  test('valeur stockée inconnue : les trois prix', () {
    expect(
      ParametresVente.depuisCles({ParametresVente.cleAffichagePrix: 'x'}).affichagePrix,
      ParametresVente.affichagePrixTous,
    );
    expect(ParametresVente.depuisCles({ParametresVente.cleAffichagePrix: 'TVA'}).afficheTtc, isFalse);
  });
}
