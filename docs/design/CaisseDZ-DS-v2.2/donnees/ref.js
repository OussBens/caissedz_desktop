// Référentiel unique des listes de valeurs (§13) — valeur stockée en français, libellés FR / AR / EN (W2)
// [valeur stockée, libellé FR, libellé AR, libellé EN]
export const LISTES = [
  ['modePaiement', 'Modes de paiement', 'Le crédit n’est pas un mode : c’est le reste d’un document.', [
    ['Espèces', 'Espèces', 'نقدا', 'Cash'], ['Carte', 'Carte CIB', 'بطاقة CIB', 'CIB card'], ['Chèque', 'Chèque', 'صك', 'Cheque'], ['Virement', 'Virement', 'تحويل بنكي', 'Bank transfer'], ['Points', 'Points fidélité', 'نقاط الوفاء', 'Loyalty points']]],
  ['typePannier', 'Types de panier', 'BL et BL_SC s’affichent « Facture ».', [
    ['Ticket', 'Ticket', 'تذكرة', 'Receipt'], ['BL', 'Facture (BL)', 'فاتورة (وصل تسليم)', 'Invoice (DN)'], ['BL_SC', 'Facture (BL sans cachet)', 'فاتورة (بدون ختم)', 'Invoice (no stamp)']]],
  ['typeVersement', 'Types de versement', '', [
    ['Avancement', 'Avancement', 'تسبيق', 'Advance'], ['Complément de facture', 'Complément de facture', 'تكملة فاتورة', 'Invoice top-up'], ['Dette', 'Dette', 'دين', 'Debt'], ['Paiement', 'Paiement', 'دفع', 'Payment'], ['Remboursement', 'Remboursement', 'استرداد', 'Refund'], ['Acompte', 'Acompte', 'عربون', 'Deposit'], ['Remise', 'Remise', 'تخفيض', 'Discount']]],
  ['typeSortie', 'Types de sortie', 'Décision phase 0 : liste du design acceptée (Expiration devient Périmé).', [
    ['Casse', 'Casse', 'كسر', 'Breakage'], ['Périmé', 'Périmé', 'منتهي الصلاحية', 'Expired'], ['Perte / vol', 'Perte / vol', 'ضياع / سرقة', 'Loss / theft'], ['Consommation interne', 'Consommation interne', 'استهلاك داخلي', 'Internal use'], ['Don', 'Don', 'تبرع', 'Donation'], ['Échantillon', 'Échantillon', 'عينة', 'Sample']]],
  ['typeMouvement', 'Types de mouvement de stock', '', [
    ['Vente', 'Vente', 'بيع', 'Sale'], ['Achat', 'Achat', 'شراء', 'Purchase'], ['Retour', 'Retour', 'إرجاع', 'Return'], ['Sortie', 'Sortie', 'إخراج', 'Write-off'], ['Distribution', 'Distribution', 'توزيع', 'Distribution'], ['Transfert', 'Transfert', 'تحويل', 'Transfer']]],
  ['typeCaisse', 'Types de caisse', '« Coffre » reste un nom de caisse, pas un type.', [['Physique', 'Physique', 'فعلي', 'Physical'], ['Compte', 'Compte', 'حساب', 'Account']]],
  ['typeClient', 'Types de client', '', [
    ['Consommateur', 'Consommateur', 'مستهلك', 'Consumer'], ['Détaillant', 'Détaillant', 'تاجر تجزئة', 'Retailer'], ['Semi-Grossiste', 'Semi-grossiste', 'نصف جملة', 'Semi-wholesaler'], ['Grossiste', 'Grossiste', 'تاجر جملة', 'Wholesaler'], ['Société', 'Société', 'شركة', 'Company'], ['Usine', 'Usine', 'مصنع', 'Factory'], ['Autre', 'Autre', 'آخر', 'Other']]],
  ['typeFournisseur', 'Types de fournisseur', '', [
    ['Usine', 'Usine', 'مصنع', 'Factory'], ['Société', 'Société', 'شركة', 'Company'], ['Importateur', 'Importateur', 'مستورد', 'Importer'], ['Grossiste', 'Grossiste', 'تاجر جملة', 'Wholesaler'], ['Semi-Grossiste', 'Semi-grossiste', 'نصف جملة', 'Semi-wholesaler'], ['Détaillant', 'Détaillant', 'تاجر تجزئة', 'Retailer'], ['Autre', 'Autre', 'آخر', 'Other']]],
  ['typeBesoinProduit', 'Statuts des besoins', '', [['En Attente', 'En attente', 'في الانتظار', 'Pending'], ['Commande', 'Commande', 'مطلوب', 'Ordered'], ['Disponible', 'Disponible', 'متوفر', 'Available']]],
  ['colis', 'Colis', '', [['Toujours demandé', 'Toujours demandé', 'يطلب دائما', 'Always ask'], ['Petit colis', 'Petit colis', 'طرد صغير', 'Small pack'], ['Grand colis', 'Grand colis', 'طرد كبير', 'Large pack']]],
  ['uniteMesure', 'Unités de mesure', '', [['Pièce', 'Pièce', 'قطعة', 'Piece'], ['Kg', 'Kg', 'كغ', 'Kg'], ['Litre', 'Litre', 'لتر', 'Litre'], ['Mètre', 'Mètre', 'متر', 'Metre']]],
  ['typeCalcul', 'Types de calcul (marge, remise)', '', [['Montant', 'Montant', 'مبلغ', 'Amount'], ['Pourcentage', 'Pourcentage', 'نسبة مئوية', 'Percentage']]],
  ['typeVenteSousAchat', 'Vente sous le prix d’achat', '', [['Interdire', 'Interdire', 'منع', 'Forbid'], ['Avertir', 'Avertir', 'تنبيه', 'Warn'], ['Autoriser', 'Autoriser', 'سماح', 'Allow']]],
  ['statutZakat', 'Statuts de zakat', 'Extension acceptée : Brouillon.', [['Brouillon', 'Brouillon', 'مسودة', 'Draft'], ['Non payé', 'Non payée', 'غير مدفوعة', 'Unpaid'], ['Payée', 'Payée', 'مدفوعة', 'Paid']]],
];

// Codification §8.10 : [entité, préfixe, exemple v2.2, maquette v2.1]
export const CODES = [
  ['Panier (ticket, facture)', 'PN', 'PN0000233', 'PAN000233'], ['Client / client système', 'CL / CLN', 'CL000012 · CLN0000', 'CLI000012'], ['Fournisseur / système', 'FRN / FOR', 'FRN000004 · FOR0000', '—'],
  ['Produit', 'PRD', 'PRD000014', '—'], ['Code-barres automatique', 'CAISSEDZ + date + séq.', 'CAISSEDZ202610100017', 'absent'], ['Mouvement de stock', 'MV', 'MV00000412', '—'],
  ['Versement', 'VRS', 'VRS000088', '—'], ['Retour / Sortie', 'RET / SRT', 'RET000021 · SRT000045', 'SOR000045'], ['Smart Scan (entrée)', 'SS', 'SS000233', 'ENT000233'],
  ['Catégorie / sous-catégorie', 'CAT / SC', 'CAT000007 · SC000031', 'SCT000031'], ['Magasin / Caisse', 'MAG / CS', 'MAG000002 · CS000003', 'CAI000003'], ['Transfert caisse / magasin', 'TRF / TRM', 'TRF000009 · TRM000012', 'TRC / TRF inversés'],
  ['Zakat / Liste de besoins', 'ZKT / BL', 'ZKT000003 · BL000118', 'ZKT-2026-0001 · BES000118'], ['Session / Mouvement de caisse', 'SES / MVC', 'SES000214 · MVC000077', 'SES00000214 · MVM000077'], ['Clôture / Journal fiscal', 'CLT / JF', 'CLT000042 · JF000042', 'Z-000042'],
];
