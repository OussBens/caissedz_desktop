import 'package:caissedz_desktop/core/print/documents_pdf.dart';
import 'package:caissedz_desktop/core/print/ticket_escpos.dart';
import 'package:caissedz_desktop/data/catalogue_repository.dart';
import 'package:caissedz_desktop/domain/models/boutique.dart';
import 'package:caissedz_desktop/domain/models/produit.dart';
import 'package:caissedz_desktop/domain/models/vente.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/bases.dart';

VenteLigne _ligne(String produit, String designation, {String? colis, String? pack, bool composant = false}) => VenteLigne(
  ordre: 1,
  produitCode: produit,
  colisCode: colis,
  packCode: pack,
  composantPack: composant,
  designation: designation,
  quantite: 1,
  uniteVente: 'Pièce',
  prixUnitaire: 100,
  remise: 0,
  total: 100,
);

Vente _vente(List<VenteLigne> lignes) => Vente(
  code: 'VTE0001',
  date: DateTime(2026, 10, 21, 10),
  sessionCode: 'SES0001',
  caisseCode: 'CIS0000',
  magasinCode: 'MAG0000',
  clientCode: 'CLN0000',
  utilisateurCode: 'USR0000',
  totalBrut: 100,
  totalRemise: 0,
  totalNet: 100,
  verse: 100,
  reste: 0,
  hash: 'a' * 64,
  hashPrecedent: '0' * 64,
  lignes: lignes,
);

void main() {
  const noms = {'PRD0001': 'حليب'};

  test('nom imprimé en arabe : le produit et le composant de pack, pas le colis ni l’ancien pack', () {
    expect(_ligne('PRD0001', 'Lait').nomImprime(noms), 'حليب');
    expect(_ligne('PRD0001', 'Lait', pack: 'PCK0001', composant: true).nomImprime(noms), 'حليب');
    expect(_ligne('PRD0001', 'Lait carton 12', colis: 'COL0001').nomImprime(noms), 'Lait carton 12');
    expect(_ligne('PRD0001', 'Pack petit-déjeuner', pack: 'PCK0001').nomImprime(noms), 'Pack petit-déjeuner');
    expect(_ligne('PRD0002', 'Eau').nomImprime(noms), 'Eau', reason: 'sans nom arabe');
  });

  test('ticket ESC/POS : nom arabe sur le ticket arabe seulement', () {
    final v = _vente([_ligne('PRD0001', 'Lait')]);
    const boutique = Boutique(nom: 'Superette');
    String texte(List<int> o) => String.fromCharCodes(o);
    final ar = const TicketEscPos(largeur: LargeurTicket.mm80, libelles: LibellesTicket.ar, nomsAr: noms)
        .generer(v, boutique: boutique);
    final arSansNom = const TicketEscPos(largeur: LargeurTicket.mm80, libelles: LibellesTicket.ar).generer(v, boutique: boutique);
    final fr = const TicketEscPos(largeur: LargeurTicket.mm80, libelles: LibellesTicket.fr, nomsAr: noms)
        .generer(v, boutique: boutique);
    expect(texte(ar), isNot(contains('Lait')));
    expect(texte(arSansNom), contains('Lait'));
    expect(texte(fr), contains('Lait'));
  });

  test('documents PDF : nom arabe des produits sur un document arabe', () async {
    const ar = DocumentsPdf(libelles: LibellesTicket.ar, nomsAr: noms);
    const fr = DocumentsPdf(libelles: LibellesTicket.fr, nomsAr: noms);
    expect(ar.nomProduit('PRD0001', 'Lait'), 'حليب');
    expect(ar.nomProduit('PRD0002', 'Eau'), 'Eau');
    expect(fr.nomProduit('PRD0001', 'Lait'), 'Lait');
    final pdf = await ar.ticket(_vente([_ligne('PRD0001', 'Lait')]), boutique: const Boutique(nom: 'S'), largeur: LargeurTicket.mm58);
    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
  });

  test('catalogue : recherche par nom arabe, noms arabes par code', () async {
    final base = await ouvrirBaseDeTest();
    final repo = CatalogueRepository(base.db);
    Produit p(String code, String designation, {String? ar}) => Produit(
      code: code,
      designation: designation,
      designationAr: ar,
      categorieCode: 'CATE0000',
      sousCategorieCode: 'SC0000',
    );
    await repo.insererProduit(p('PRD0001', 'Lait', ar: ' حليب '));
    await repo.insererProduit(p('PRD0002', 'Eau', ar: '   '));
    await repo.insererProduit(p('PRD0003', 'Huile'));
    expect((await repo.produits(recherche: 'حليب')).map((x) => x.code), ['PRD0001']);
    expect((await repo.produitParCode('PRD0001'))!.designationAr, 'حليب', reason: 'enregistré sans espaces');
    expect((await repo.produitParCode('PRD0002'))!.designationAr, isNull, reason: 'vide : rien');
    expect(await repo.nomsArabes(['PRD0001', 'PRD0002', 'PRD0003', 'PRD0001']), {'PRD0001': 'حليب'});
    expect(await repo.nomsArabes(const []), isEmpty);
    expect(p('PRD0001', 'Lait', ar: 'حليب').nom('ar'), 'حليب');
    expect(p('PRD0001', 'Lait', ar: 'حليب').nom('fr'), 'Lait');
    expect(p('PRD0003', 'Huile').nom('ar'), 'Huile');
  });
}
