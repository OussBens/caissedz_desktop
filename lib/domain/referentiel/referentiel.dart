import 'valeur_referentiel.dart';

export 'valeur_referentiel.dart';

/// Référentiel unique des listes de valeurs (§13) : traduction de `docs/design/CaisseDZ-DS-v2.2/donnees/ref.js`.
///
/// La valeur stockée en base est TOUJOURS la valeur FR [ValeurReferentiel.stocke] ; les libellés
/// FR / AR / EN ne servent qu'à l'affichage (W2).
class Referentiel {
  const Referentiel._();

  /// Modes de paiement. Le crédit n’est pas un mode : c’est le reste d’un document.
  static const ListeReferentiel modesPaiement = ListeReferentiel('modePaiement', [
    ValeurReferentiel(stocke: 'Espèces', fr: 'Espèces', ar: 'نقدا', en: 'Cash'),
    ValeurReferentiel(stocke: 'Carte', fr: 'Carte CIB', ar: 'بطاقة CIB', en: 'CIB card'),
    ValeurReferentiel(stocke: 'Chèque', fr: 'Chèque', ar: 'صك', en: 'Cheque'),
    ValeurReferentiel(stocke: 'Virement', fr: 'Virement', ar: 'تحويل بنكي', en: 'Bank transfer'),
    ValeurReferentiel(stocke: 'Points', fr: 'Points fidélité', ar: 'نقاط الوفاء', en: 'Loyalty points'),
  ]);

  /// Types de versement.
  static const ListeReferentiel typesVersement = ListeReferentiel('typeVersement', [
    ValeurReferentiel(stocke: 'Avancement', fr: 'Avancement', ar: 'تسبيق', en: 'Advance'),
    ValeurReferentiel(
      stocke: 'Complément de facture',
      fr: 'Complément de facture',
      ar: 'تكملة فاتورة',
      en: 'Invoice top-up',
    ),
    ValeurReferentiel(stocke: 'Dette', fr: 'Dette', ar: 'دين', en: 'Debt'),
    ValeurReferentiel(stocke: 'Paiement', fr: 'Paiement', ar: 'دفع', en: 'Payment'),
    ValeurReferentiel(stocke: 'Remboursement', fr: 'Remboursement', ar: 'استرداد', en: 'Refund'),
    ValeurReferentiel(stocke: 'Acompte', fr: 'Acompte', ar: 'عربون', en: 'Deposit'),
    ValeurReferentiel(stocke: 'Remise', fr: 'Remise', ar: 'تخفيض', en: 'Discount'),
  ]);

  /// Types de sortie. Décision phase 0 : liste du design acceptée (Expiration devient Périmé).
  static const ListeReferentiel motifsSortie = ListeReferentiel('typeSortie', [
    ValeurReferentiel(stocke: 'Casse', fr: 'Casse', ar: 'كسر', en: 'Breakage'),
    ValeurReferentiel(stocke: 'Périmé', fr: 'Périmé', ar: 'منتهي الصلاحية', en: 'Expired'),
    ValeurReferentiel(stocke: 'Perte / vol', fr: 'Perte / vol', ar: 'ضياع / سرقة', en: 'Loss / theft'),
    ValeurReferentiel(
      stocke: 'Consommation interne',
      fr: 'Consommation interne',
      ar: 'استهلاك داخلي',
      en: 'Internal use',
    ),
    ValeurReferentiel(stocke: 'Don', fr: 'Don', ar: 'تبرع', en: 'Donation'),
    ValeurReferentiel(stocke: 'Échantillon', fr: 'Échantillon', ar: 'عينة', en: 'Sample'),
  ]);

  /// Types de mouvement de stock.
  static const ListeReferentiel typesMouvement = ListeReferentiel('typeMouvement', [
    ValeurReferentiel(stocke: 'Vente', fr: 'Vente', ar: 'بيع', en: 'Sale'),
    ValeurReferentiel(stocke: 'Achat', fr: 'Achat', ar: 'شراء', en: 'Purchase'),
    ValeurReferentiel(stocke: 'Retour', fr: 'Retour', ar: 'إرجاع', en: 'Return'),
    ValeurReferentiel(stocke: 'Sortie', fr: 'Sortie', ar: 'إخراج', en: 'Write-off'),
    ValeurReferentiel(stocke: 'Distribution', fr: 'Distribution', ar: 'توزيع', en: 'Distribution'),
    ValeurReferentiel(stocke: 'Transfert', fr: 'Transfert', ar: 'تحويل', en: 'Transfer'),
  ]);

  /// Types de caisse. « Coffre » reste un nom de caisse, pas un type.
  static const ListeReferentiel typesCaisse = ListeReferentiel('typeCaisse', [
    ValeurReferentiel(stocke: 'Physique', fr: 'Physique', ar: 'فعلي', en: 'Physical'),
    ValeurReferentiel(stocke: 'Compte', fr: 'Compte', ar: 'حساب', en: 'Account'),
  ]);

  /// Types de client.
  static const ListeReferentiel typesClient = ListeReferentiel('typeClient', [
    ValeurReferentiel(stocke: 'Consommateur', fr: 'Consommateur', ar: 'مستهلك', en: 'Consumer'),
    ValeurReferentiel(stocke: 'Détaillant', fr: 'Détaillant', ar: 'تاجر تجزئة', en: 'Retailer'),
    ValeurReferentiel(stocke: 'Semi-Grossiste', fr: 'Semi-grossiste', ar: 'نصف جملة', en: 'Semi-wholesaler'),
    ValeurReferentiel(stocke: 'Grossiste', fr: 'Grossiste', ar: 'تاجر جملة', en: 'Wholesaler'),
    ValeurReferentiel(stocke: 'Société', fr: 'Société', ar: 'شركة', en: 'Company'),
    ValeurReferentiel(stocke: 'Usine', fr: 'Usine', ar: 'مصنع', en: 'Factory'),
    ValeurReferentiel(stocke: 'Autre', fr: 'Autre', ar: 'آخر', en: 'Other'),
  ]);

  /// Types de fournisseur.
  static const ListeReferentiel typesFournisseur = ListeReferentiel('typeFournisseur', [
    ValeurReferentiel(stocke: 'Usine', fr: 'Usine', ar: 'مصنع', en: 'Factory'),
    ValeurReferentiel(stocke: 'Société', fr: 'Société', ar: 'شركة', en: 'Company'),
    ValeurReferentiel(stocke: 'Importateur', fr: 'Importateur', ar: 'مستورد', en: 'Importer'),
    ValeurReferentiel(stocke: 'Grossiste', fr: 'Grossiste', ar: 'تاجر جملة', en: 'Wholesaler'),
    ValeurReferentiel(stocke: 'Semi-Grossiste', fr: 'Semi-grossiste', ar: 'نصف جملة', en: 'Semi-wholesaler'),
    ValeurReferentiel(stocke: 'Détaillant', fr: 'Détaillant', ar: 'تاجر تجزئة', en: 'Retailer'),
    ValeurReferentiel(stocke: 'Autre', fr: 'Autre', ar: 'آخر', en: 'Other'),
  ]);

  /// Statuts des besoins.
  static const ListeReferentiel statutsBesoin = ListeReferentiel('typeBesoinProduit', [
    ValeurReferentiel(stocke: 'En Attente', fr: 'En attente', ar: 'في الانتظار', en: 'Pending'),
    ValeurReferentiel(stocke: 'Commande', fr: 'Commande', ar: 'مطلوب', en: 'Ordered'),
    ValeurReferentiel(stocke: 'Disponible', fr: 'Disponible', ar: 'متوفر', en: 'Available'),
  ]);

  /// Colis.
  static const ListeReferentiel colis = ListeReferentiel('colis', [
    ValeurReferentiel(stocke: 'Toujours demandé', fr: 'Toujours demandé', ar: 'يطلب دائما', en: 'Always ask'),
    ValeurReferentiel(stocke: 'Petit colis', fr: 'Petit colis', ar: 'طرد صغير', en: 'Small pack'),
    ValeurReferentiel(stocke: 'Grand colis', fr: 'Grand colis', ar: 'طرد كبير', en: 'Large pack'),
  ]);

  /// Unités de mesure.
  static const ListeReferentiel unitesMesure = ListeReferentiel('uniteMesure', [
    ValeurReferentiel(stocke: 'Pièce', fr: 'Pièce', ar: 'قطعة', en: 'Piece'),
    ValeurReferentiel(stocke: 'Kg', fr: 'Kg', ar: 'كغ', en: 'Kg'),
    ValeurReferentiel(stocke: 'Litre', fr: 'Litre', ar: 'لتر', en: 'Litre'),
    ValeurReferentiel(stocke: 'Mètre', fr: 'Mètre', ar: 'متر', en: 'Metre'),
  ]);

  /// Types de calcul (marge, remise).
  static const ListeReferentiel typesCalcul = ListeReferentiel('typeCalcul', [
    ValeurReferentiel(stocke: 'Montant', fr: 'Montant', ar: 'مبلغ', en: 'Amount'),
    ValeurReferentiel(stocke: 'Pourcentage', fr: 'Pourcentage', ar: 'نسبة مئوية', en: 'Percentage'),
  ]);

  /// Vente sous le prix d’achat.
  static const ListeReferentiel ventesSousAchat = ListeReferentiel('typeVenteSousAchat', [
    ValeurReferentiel(stocke: 'Interdire', fr: 'Interdire', ar: 'منع', en: 'Forbid'),
    ValeurReferentiel(stocke: 'Avertir', fr: 'Avertir', ar: 'تنبيه', en: 'Warn'),
    ValeurReferentiel(stocke: 'Autoriser', fr: 'Autoriser', ar: 'سماح', en: 'Allow'),
  ]);

  /// Statuts de zakat. Extension acceptée : Brouillon.
  static const ListeReferentiel statutsZakat = ListeReferentiel('statutZakat', [
    ValeurReferentiel(stocke: 'Brouillon', fr: 'Brouillon', ar: 'مسودة', en: 'Draft'),
    ValeurReferentiel(stocke: 'Non payé', fr: 'Non payée', ar: 'غير مدفوعة', en: 'Unpaid'),
    ValeurReferentiel(stocke: 'Payée', fr: 'Payée', ar: 'مدفوعة', en: 'Paid'),
  ]);

  /// Paliers de licence (§6.1).
  static const ListeReferentiel licences = ListeReferentiel('licences', [
    ValeurReferentiel(stocke: 'Basic', fr: 'Basic', ar: 'أساسي', en: 'Basic'),
    ValeurReferentiel(stocke: 'Avancé', fr: 'Avancé', ar: 'متقدم', en: 'Advanced'),
  ]);

  /// Rôles système.
  static const ListeReferentiel roles = ListeReferentiel('roles', [
    ValeurReferentiel(stocke: 'Admin', fr: 'Admin', ar: 'مدير', en: 'Admin'),
    ValeurReferentiel(stocke: 'Caissier', fr: 'Caissier', ar: 'أمين الصندوق', en: 'Cashier'),
    ValeurReferentiel(stocke: 'Magasinier', fr: 'Magasinier', ar: 'أمين المخزن', en: 'Storekeeper'),
  ]);

  /// Couleurs proposées pour un produit (`PRODUCT_COLORS` du DS v2.2, 16 couleurs).
  static const ListeReferentiel couleursProduit = ListeReferentiel('couleurProduit', [
    ValeurReferentiel(stocke: 'Blanc', fr: 'Blanc', ar: 'أبيض', en: 'White'),
    ValeurReferentiel(stocke: 'Noir', fr: 'Noir', ar: 'أسود', en: 'Black'),
    ValeurReferentiel(stocke: 'Gris', fr: 'Gris', ar: 'رمادي', en: 'Grey'),
    ValeurReferentiel(stocke: 'Beige', fr: 'Beige', ar: 'بيج', en: 'Beige'),
    ValeurReferentiel(stocke: 'Marron', fr: 'Marron', ar: 'بني', en: 'Brown'),
    ValeurReferentiel(stocke: 'Rouge', fr: 'Rouge', ar: 'أحمر', en: 'Red'),
    ValeurReferentiel(stocke: 'Bordeaux', fr: 'Bordeaux', ar: 'عنابي', en: 'Burgundy'),
    ValeurReferentiel(stocke: 'Rose', fr: 'Rose', ar: 'وردي', en: 'Pink'),
    ValeurReferentiel(stocke: 'Orange', fr: 'Orange', ar: 'برتقالي', en: 'Orange'),
    ValeurReferentiel(stocke: 'Jaune', fr: 'Jaune', ar: 'أصفر', en: 'Yellow'),
    ValeurReferentiel(stocke: 'Vert', fr: 'Vert', ar: 'أخضر', en: 'Green'),
    ValeurReferentiel(stocke: 'Kaki', fr: 'Kaki', ar: 'كاكي', en: 'Khaki'),
    ValeurReferentiel(stocke: 'Bleu ciel', fr: 'Bleu ciel', ar: 'أزرق سماوي', en: 'Sky blue'),
    ValeurReferentiel(stocke: 'Bleu', fr: 'Bleu', ar: 'أزرق', en: 'Blue'),
    ValeurReferentiel(stocke: 'Marine', fr: 'Marine', ar: 'كحلي', en: 'Navy'),
    ValeurReferentiel(stocke: 'Violet', fr: 'Violet', ar: 'بنفسجي', en: 'Purple'),
  ]);

  /// Types de taille du formulaire produit (`SIZE_TYPES` du DS v2.2).
  static const ListeReferentiel typesTaille = ListeReferentiel('typeTaille', [
    ValeurReferentiel(
      stocke: 'Lettres (vêtements)',
      fr: 'Lettres (vêtements)',
      ar: 'حروف (ملابس)',
      en: 'Letters (clothing)',
    ),
    ValeurReferentiel(stocke: 'Pointure', fr: 'Pointure', ar: 'مقاس الحذاء', en: 'Shoe size'),
    ValeurReferentiel(
      stocke: 'Numérique (pantalon)',
      fr: 'Numérique (pantalon)',
      ar: 'رقمي (سروال)',
      en: 'Numeric (trousers)',
    ),
    ValeurReferentiel(stocke: 'Enfant (âge)', fr: 'Enfant (âge)', ar: 'طفل (العمر)', en: 'Child (age)'),
    ValeurReferentiel(stocke: 'Contenance', fr: 'Contenance', ar: 'السعة', en: 'Capacity'),
    ValeurReferentiel(stocke: 'Poids', fr: 'Poids', ar: 'الوزن', en: 'Weight'),
    ValeurReferentiel(stocke: 'Taille unique', fr: 'Taille unique', ar: 'مقاس واحد', en: 'One size'),
  ]);

  /// Types de remise (§7 `remises.type`, §8.9).
  static const ListeReferentiel typesRemise = ListeReferentiel('typeRemise', [
    ValeurReferentiel(stocke: 'Par Produit', fr: 'Par produit', ar: 'حسب المنتج', en: 'Per product'),
    ValeurReferentiel(
      stocke: 'Par Montant',
      fr: 'Par montant (panier)',
      ar: 'حسب المبلغ (السلة)',
      en: 'By amount (basket)',
    ),
  ]);

  static const List<ListeReferentiel> toutes = [
    modesPaiement,
    typesVersement,
    motifsSortie,
    typesMouvement,
    typesCaisse,
    typesClient,
    typesFournisseur,
    statutsBesoin,
    colis,
    unitesMesure,
    typesCalcul,
    ventesSousAchat,
    statutsZakat,
    licences,
    roles,
  ];
}
