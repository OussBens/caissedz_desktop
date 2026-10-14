import 'valeur_referentiel.dart';

export 'valeur_referentiel.dart';

/// Référentiel unique des listes de valeurs (§13, `donnees/ref.js` du DS).
///
/// ⚠️ PROVISOIRE : listes et traductions reprises de la commande initiale ;
/// à remplacer par la traduction exacte de `docs/design/CaisseDZ-DS-v2.2/donnees/ref.js`
/// dès réception. La valeur stockée est TOUJOURS la valeur FR.
class Referentiel {
  const Referentiel._();

  static const ListeReferentiel modesPaiement = ListeReferentiel('modes_paiement', [
    ValeurReferentiel(stocke: 'Espèces', fr: 'Espèces', ar: 'نقدًا', en: 'Cash'),
    ValeurReferentiel(stocke: 'Carte', fr: 'Carte', ar: 'بطاقة', en: 'Card'),
    ValeurReferentiel(stocke: 'Chèque', fr: 'Chèque', ar: 'شيك', en: 'Cheque'),
    ValeurReferentiel(stocke: 'Virement', fr: 'Virement', ar: 'تحويل', en: 'Transfer'),
    ValeurReferentiel(stocke: 'Points', fr: 'Points', ar: 'نقاط', en: 'Points'),
  ]);

  static const ListeReferentiel motifsSortie = ListeReferentiel('motifs_sortie', [
    ValeurReferentiel(stocke: 'Casse', fr: 'Casse', ar: 'كسر', en: 'Breakage'),
    ValeurReferentiel(stocke: 'Périmé', fr: 'Périmé', ar: 'منتهي الصلاحية', en: 'Expired'),
    ValeurReferentiel(stocke: 'Perte/vol', fr: 'Perte/vol', ar: 'ضياع/سرقة', en: 'Loss/theft'),
    ValeurReferentiel(
        stocke: 'Consommation interne', fr: 'Consommation interne', ar: 'استهلاك داخلي', en: 'Internal use'),
    ValeurReferentiel(stocke: 'Don', fr: 'Don', ar: 'هبة', en: 'Donation'),
    ValeurReferentiel(stocke: 'Échantillon', fr: 'Échantillon', ar: 'عينة', en: 'Sample'),
  ]);

  static const ListeReferentiel statutsBesoin = ListeReferentiel('statuts_besoin', [
    ValeurReferentiel(stocke: 'En attente', fr: 'En attente', ar: 'قيد الانتظار', en: 'Pending'),
    ValeurReferentiel(stocke: 'Commande', fr: 'Commande', ar: 'طلبية', en: 'Ordered'),
    ValeurReferentiel(stocke: 'Disponible', fr: 'Disponible', ar: 'متوفر', en: 'Available'),
  ]);

  static const ListeReferentiel typesCaisse = ListeReferentiel('types_caisse', [
    ValeurReferentiel(stocke: 'Physique', fr: 'Physique', ar: 'مادي', en: 'Physical'),
    ValeurReferentiel(stocke: 'Compte', fr: 'Compte', ar: 'حساب', en: 'Account'),
  ]);

  static const ListeReferentiel licences = ListeReferentiel('licences', [
    ValeurReferentiel(stocke: 'Basic', fr: 'Basic', ar: 'أساسي', en: 'Basic'),
    ValeurReferentiel(stocke: 'Avancé', fr: 'Avancé', ar: 'متقدم', en: 'Advanced'),
  ]);

  static const ListeReferentiel roles = ListeReferentiel('roles', [
    ValeurReferentiel(stocke: 'Admin', fr: 'Admin', ar: 'مدير', en: 'Admin'),
    ValeurReferentiel(stocke: 'Caissier', fr: 'Caissier', ar: 'أمين الصندوق', en: 'Cashier'),
    ValeurReferentiel(stocke: 'Magasinier', fr: 'Magasinier', ar: 'أمين المخزن', en: 'Storekeeper'),
  ]);

  static const List<ListeReferentiel> toutes = [
    modesPaiement,
    motifsSortie,
    statutsBesoin,
    typesCaisse,
    licences,
    roles,
  ];
}
