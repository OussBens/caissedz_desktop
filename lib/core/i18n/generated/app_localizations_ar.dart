// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get shellNavGeneral => 'عام';

  @override
  String get shellNavStock => 'المخزون';

  @override
  String get shellNavTiers => 'الأطراف';

  @override
  String get shellNavGestion => 'الإدارة';

  @override
  String get shellMenuModules => 'الوحدات';

  @override
  String get shellFenetreReduire => 'تصغير';

  @override
  String get shellFenetreAgrandir => 'تكبير';

  @override
  String get shellFenetreRestaurer => 'استعادة';

  @override
  String get shellFenetreFermer => 'إغلاق';

  @override
  String get moduleTableauBord => 'لوحة القيادة';

  @override
  String get moduleCaisse => 'الصندوق';

  @override
  String get moduleVentes => 'المبيعات';

  @override
  String get moduleRetours => 'المرتجعات';

  @override
  String get moduleHistorique => 'السجل';

  @override
  String get moduleProduits => 'المنتجات';

  @override
  String get moduleStock => 'المخزون';

  @override
  String get moduleEntrees => 'الإدخالات / المشتريات';

  @override
  String get moduleTransferts => 'التحويلات';

  @override
  String get moduleBesoins => 'الاحتياجات';

  @override
  String get moduleSorties => 'الإخراجات';

  @override
  String get moduleClients => 'العملاء';

  @override
  String get moduleFournisseurs => 'الموردون';

  @override
  String get moduleVersements => 'الدفعات';

  @override
  String get moduleGestionCaisse => 'إدارة الصندوق';

  @override
  String get moduleClotures => 'الإقفالات';

  @override
  String get moduleSituation => 'الوضعية';

  @override
  String get moduleZakat => 'الزكاة';

  @override
  String get moduleParametres => 'الإعدادات';

  @override
  String get communAnnuler => 'إلغاء';

  @override
  String get communConfirmer => 'تأكيد';

  @override
  String get communFermer => 'إغلاق';

  @override
  String get communEnregistrer => 'حفظ';

  @override
  String get communSupprimer => 'حذف';

  @override
  String get communRechercher => 'بحث';

  @override
  String get communAucunResultat => 'لا توجد نتائج';

  @override
  String get communTotal => 'المجموع';

  @override
  String get communToutSelectionner => 'تحديد الكل';

  @override
  String communPagination(int debut, int fin, int total) {
    return '$debut–$fin من $total';
  }

  @override
  String communSelectionnes(int n) {
    return '$n محدد';
  }

  @override
  String get galerieTitre => 'معرض نظام التصميم';

  @override
  String get galerieTheme => 'المظهر';

  @override
  String get galerieLangue => 'اللغة';

  @override
  String get galerieClair => 'فاتح';

  @override
  String get galerieSombre => 'داكن';

  @override
  String get activationTitre => 'تفعيل CaisseDZ';

  @override
  String get activationIntro => 'أرسل معرّف هذا الجهاز إلى الموزّع؛ سيمنحك مفتاحًا مرتبطًا بهذا الحاسوب.';

  @override
  String get activationIdentifiantMachine => 'معرّف الجهاز';

  @override
  String get activationCopierIdentifiant => 'نسخ';

  @override
  String get activationIdentifiantCopie => 'تم النسخ';

  @override
  String get activationCle => 'مفتاح الرخصة';

  @override
  String get activationCleIndice => 'الصق المفتاح كاملًا في الخانة الأولى.';

  @override
  String get activationBouton => 'تفعيل';

  @override
  String get activationErreurInconnue => 'مفتاح غير صالح لهذا الجهاز — تحقق من المعرّف المرسل.';

  @override
  String get licenceBasic => 'أساسي';

  @override
  String get licenceAvance => 'متقدم';

  @override
  String get licenceDemo => 'وضع تجريبي';

  @override
  String licenceNiveau(String niveau) {
    return 'رخصة $niveau';
  }

  @override
  String get licenceRequiseDetail => 'رخصتك الحالية أساسية. فعّل رخصة متقدمة للوصول إلى هذه الوحدة.';

  @override
  String get connexionTitre => 'مرحبًا بعودتك';

  @override
  String get connexionIdentifiant => 'اسم المستخدم';

  @override
  String get connexionMotDePasse => 'كلمة المرور';

  @override
  String get connexionBouton => 'دخول';

  @override
  String get connexionErreurIdentifiants => 'المعرّف أو كلمة المرور غير صحيحة.';

  @override
  String get connexionErreurInactif => 'هذا الحساب معطّل.';

  @override
  String get connexionErreurNonConfigure => 'ليس لهذا الحساب كلمة مرور بعد: أكمل الإعداد الأولي.';

  @override
  String get connexionErreurDemo => 'الحساب demo/demo متاح فقط في الوضع التجريبي.';

  @override
  String get connexionDemoIndice => 'الوضع التجريبي: اسم المستخدم demo، كلمة المرور demo.';

  @override
  String get connexionSaisirCle => 'إدخال مفتاح التفعيل';

  @override
  String get connexionDeconnecter => 'تسجيل الخروج';

  @override
  String get configTitre => 'مرحبًا بك في CaisseDZ';

  @override
  String get configEtapeBoutique => 'المتجر';

  @override
  String get configEtapeVente => 'الهامش والمخزون';

  @override
  String get configBoutiqueNom => 'اسم المتجر';

  @override
  String get configBoutiqueRc => 'السجل التجاري';

  @override
  String get configBoutiqueNif => 'رقم التعريف الجبائي';

  @override
  String get configBoutiqueAdresse => 'العنوان';

  @override
  String get configBoutiqueTelephone => 'الهاتف';

  @override
  String get configBoutiqueEmail => 'البريد الإلكتروني';

  @override
  String get configMarge => 'الهامش الافتراضي';

  @override
  String get configMargeAide => 'يُطبّق لحساب سعر البيع من سعر الشراء للمنتجات الجديدة.';

  @override
  String get configSeuil => 'حد النفاد';

  @override
  String get configFidelite => 'الولاء';

  @override
  String get configPointsParDinar => 'النقاط المكتسبة لكل دينار';

  @override
  String get configDevise => 'العملة';

  @override
  String get configLangue => 'اللغة';

  @override
  String get configPrecedent => 'السابق';

  @override
  String get configSuivant => 'التالي';

  @override
  String get configTerminer => 'إنهاء';

  @override
  String get configErreurObligatoire => 'حقل إلزامي';

  @override
  String get configErreurIdentifiant => 'من 3 إلى 32 حرفًا: أحرف، أرقام، نقطة، شرطة، شرطة سفلية.';

  @override
  String get configErreurMotDePasseCourt => '4 أحرف على الأقل.';

  @override
  String get configErreurConfirmation => 'كلمتا المرور غير متطابقتين.';

  @override
  String get configErreurIdentifiantPris => 'هذا المعرّف مستعمل بالفعل.';

  @override
  String get configErreurMarge => 'قيمة بين 0 و 1000.';

  @override
  String get configErreurNombre => 'رقم غير صالح.';

  @override
  String get compteTitre => 'حسابي';

  @override
  String get compteMotDePasseActuel => 'كلمة المرور الحالية';

  @override
  String get compteNouveauMotDePasse => 'كلمة المرور الجديدة';

  @override
  String get compteChangerIdentifiant => 'تغيير المعرّف';

  @override
  String get compteChangerMotDePasse => 'تغيير كلمة المرور';

  @override
  String compteIdentifiantChange(String identifiant) {
    return 'تم تغيير المعرّف: سجّل الدخول من الآن بـ « $identifiant ».';
  }

  @override
  String get compteMotDePasseChange => 'تم تغيير كلمة المرور.';

  @override
  String get compteErreurMotDePasseActuel => 'كلمة المرور الحالية غير صحيحة.';

  @override
  String get comptePreferences => 'التفضيلات';

  @override
  String get compteDemoLectureSeule => 'لا يمكن تعديل الحساب التجريبي.';

  @override
  String get permVoirPrixAchat => 'عرض سعر الشراء';

  @override
  String get shellBandeauDemo => 'وضع تجريبي — البيانات ليست للاستعمال الفعلي';

  @override
  String get shellVerrouille => 'مخصص للرخصة المتقدمة';

  @override
  String get shellAccesRestreint => 'وصول غير مسموح';

  @override
  String get produitsOngletProduits => 'المنتجات';

  @override
  String get produitsOngletCategories => 'الفئات';

  @override
  String get produitsOngletPacks => 'الحزم';

  @override
  String get produitsOngletRemises => 'التخفيضات';

  @override
  String get produitsNouveau => 'منتج جديد';

  @override
  String get produitsColCode => 'الرمز';

  @override
  String get produitsColDesignation => 'التسمية';

  @override
  String get produitsColCodeBarres => 'الباركود';

  @override
  String get produitsColCategorie => 'الفئة';

  @override
  String get produitsColPrixAchat => 'سعر الشراء';

  @override
  String get produitsColPrixVente => 'سعر البيع دون رسوم';

  @override
  String get produitsColStock => 'المخزون';

  @override
  String get produitsAucun => 'لا توجد منتجات. أنشئ منتجًا أو استورد ملف Excel.';

  @override
  String get produitModifier => 'تعديل المنتج';

  @override
  String get produitChampSousCategorie => 'الفئة الفرعية';

  @override
  String get produitChampPrixAchat => 'سعر الشراء';

  @override
  String get produitChampPrixVente => 'سعر البيع دون رسوم';

  @override
  String get produitChampUnite => 'الوحدة';

  @override
  String get produitErreurDesignation => 'التسمية إلزامية.';

  @override
  String get produitErreurCodeBarres => 'باركود غير صالح.';

  @override
  String get produitErreurCodeBarresPris => 'هذا الباركود مستعمل بالفعل.';

  @override
  String get produitErreurPrix => 'سعر غير صالح.';

  @override
  String get produitErreurQuantite => 'كمية غير صالحة.';

  @override
  String get iaIntro => 'امسح رمزًا شريطيًا: يتم العثور على البطاقة تلقائيًا.';

  @override
  String get iaRechercher => 'بحث';

  @override
  String get iaAucun => 'لم يتم العثور على أي بطاقة.';

  @override
  String iaTrouve(String source) {
    return 'بطاقة موجودة عبر $source';
  }

  @override
  String get iaSaisieDetaillee => 'إدخال تفصيلي';

  @override
  String get importTitre => 'استيراد منتجات من Excel';

  @override
  String get importIntro =>
      'الأعمدة المتوقعة في السطر 1: designation (إلزامي)، code_barres، categorie، prix_achat، prix_vente.';

  @override
  String get importChoisirFichier => 'اختيار ملف .xlsx';

  @override
  String importResultat(int importees, int ignorees) {
    return '$importees منتج مستورد، $ignorees متجاهل.';
  }

  @override
  String importErreurFichier(String detail) {
    return 'ملف غير قابل للقراءة: $detail';
  }

  @override
  String get importErreurDesignationVide => 'تسمية فارغة';

  @override
  String get importErreurCodeBarresPris => 'باركود مستعمل بالفعل';

  @override
  String get importErreurPrix => 'سعر غير صالح';

  @override
  String synchroResultat(int envoyes, int recus) {
    return 'المزامنة: $envoyes مرسل، $recus محدّث.';
  }

  @override
  String synchroErreur(String detail) {
    return 'فشلت المزامنة: $detail';
  }

  @override
  String get categoriesNouvelle => 'فئة جديدة';

  @override
  String get categoriesNouvelleSous => 'فئة فرعية جديدة';

  @override
  String get categorieNom => 'الاسم';

  @override
  String get categorieErreurSysteme => 'لا يمكن تعديل فئة النظام.';

  @override
  String get categorieErreurUtilisee => 'توجد منتجات مرتبطة بهذه الفئة.';

  @override
  String get packNouveau => 'حزمة جديدة';

  @override
  String get packErreurLignes => 'أضف منتجًا واحدًا على الأقل إلى الحزمة.';

  @override
  String get remiseNouvelle => 'تخفيض جديد';

  @override
  String get remiseType => 'النوع';

  @override
  String get remiseValeur => 'القيمة';

  @override
  String get communNouveau => 'جديد';

  @override
  String get communModifier => 'تعديل';

  @override
  String get communActif => 'نشط';

  @override
  String get communOui => 'نعم';

  @override
  String get communNon => 'لا';

  @override
  String get communValider => 'تأكيد';

  @override
  String get communApercu => 'معاينة';

  @override
  String get communAucune => 'لا شيء';

  @override
  String get stockTitre => 'المخزون';

  @override
  String get stockColMagasin => 'المخزن';

  @override
  String get stockColQuantite => 'الكمية';

  @override
  String get stockColSeuil => 'الحد';

  @override
  String get stockColType => 'النوع';

  @override
  String get stockColMotif => 'السبب';

  @override
  String get stockColUtilisateur => 'المستخدم';

  @override
  String get stockColValeur => 'القيمة (سعر الشراء)';

  @override
  String get stockAucunMouvement => 'لا توجد حركات.';

  @override
  String get stockErreurQuantite => 'كمية غير صالحة.';

  @override
  String get stockErreurInsuffisant => 'مخزون غير كافٍ: حارس المخزون يرفض هذا الإخراج.';

  @override
  String get stockErreurMemeMagasin => 'يجب أن يكون مخزن الوجهة مختلفًا.';

  @override
  String get stockErreurLignes => 'أضف سطرًا واحدًا على الأقل.';

  @override
  String get stockErreurMotif => 'سبب غير صالح.';

  @override
  String get stockErreurMagasinInactif => 'مخزن معطّل أو غير معروف.';

  @override
  String get stockErreurMagasinSysteme => 'لا يمكن تعطيل المخزن الرئيسي.';

  @override
  String get stockErreurProduit => 'منتج غير معروف.';

  @override
  String get stockErreurStatut => 'حالة غير صالحة.';

  @override
  String get typeMouvementEntree => 'إدخال';

  @override
  String get typeMouvementSortie => 'إخراج';

  @override
  String get typeMouvementVente => 'بيع';

  @override
  String get typeMouvementRetour => 'مرتجع';

  @override
  String get typeMouvementTransfert => 'تحويل';

  @override
  String get typeMouvementInventaire => 'جرد';

  @override
  String get typeMouvementInitial => 'مخزون أولي';

  @override
  String get magasinPrincipal => 'رئيسي';

  @override
  String get statutBesoinEnAttente => 'قيد الانتظار';

  @override
  String get statutBesoinCommande => 'طلبية';

  @override
  String get statutBesoinDisponible => 'متوفر';

  @override
  String get motifCasse => 'كسر';

  @override
  String get motifPerime => 'منتهي الصلاحية';

  @override
  String get motifPerteVol => 'ضياع/سرقة';

  @override
  String get motifConsommationInterne => 'استهلاك داخلي';

  @override
  String get motifDon => 'هبة';

  @override
  String get motifEchantillon => 'عينة';

  @override
  String get communDate => 'التاريخ';

  @override
  String get communQuantite => 'الكمية';

  @override
  String get moduleMagasins => 'المخازن';

  @override
  String get posTitre => 'الصندوق';

  @override
  String get posMaxPaniers => '5 مبيعات متوازية كحد أقصى.';

  @override
  String get posReste => 'المتبقي';

  @override
  String get posPointsGagnes => 'النقاط المكتسبة';

  @override
  String get posClientPassage => 'زبون عابر';

  @override
  String get posChoisirClient => 'اختيار زبون';

  @override
  String get posCalculatrice => 'الآلة الحاسبة (F9)';

  @override
  String get posAide => 'اختصارات لوحة المفاتيح (F1)';

  @override
  String get posSessionAucune => 'لا توجد جلسة صندوق مفتوحة: افتح جلسة للتحصيل.';

  @override
  String get posSessionCaisse => 'الصندوق';

  @override
  String get posErreurSessionDejaOuverte => 'توجد جلسة مفتوحة بالفعل (المستخدم أو الصندوق).';

  @override
  String get posErreurSessionAucune => 'لا توجد جلسة مفتوحة.';

  @override
  String get posErreurCaisse => 'صندوق غير معروف أو معطّل.';

  @override
  String get posErreurMontant => 'مبلغ غير صالح.';

  @override
  String posErreurStock(String detail) {
    return 'مخزون غير كافٍ (محجوز في السلال المفتوحة): $detail';
  }

  @override
  String posErreurProduitInconnu(String code) {
    return 'رمز غير معروف: $code';
  }

  @override
  String get posErreurPanierVide => 'السلة فارغة.';

  @override
  String posErreurPaiementInsuffisant(String reste) {
    return 'الدفع غير كافٍ. المتبقي: $reste';
  }

  @override
  String get posErreurModePaiement => 'طريقة دفع غير صالحة.';

  @override
  String get posErreurPoints => 'نقاط غير كافية.';

  @override
  String get posErreurCredit => 'البيع بالدين غير مسموح لهذا الزبون.';

  @override
  String get posErreurQuantite => 'كمية غير صالحة.';

  @override
  String get posErreurPeriodeCloturee => 'عملية مرفوضة: فترة مقفلة.';

  @override
  String posVenteEnregistree(String code, String monnaie) {
    return 'تم تحصيل البيع $code. الباقي المسترجع: $monnaie';
  }

  @override
  String get posImprimerTicket => 'طباعة التذكرة';

  @override
  String get posImprimerFacture => 'فاتورة A4';

  @override
  String get posTicket58 => 'تذكرة 58 مم';

  @override
  String get posTicket80 => 'تذكرة 80 مم';

  @override
  String get posImpressionOk => 'أُرسلت التذكرة إلى الطابعة.';

  @override
  String posImpressionErreur(String detail) {
    return 'تعذرت الطباعة: $detail';
  }

  @override
  String get posRaccourcisTitre => 'اختصارات لوحة المفاتيح';

  @override
  String get posRaccourciF1 => 'مساعدة الاختصارات';

  @override
  String get posRaccourciF2 => 'بحث / مسح';

  @override
  String get posRaccourciF3 => 'بحث متقدم';

  @override
  String get posRaccourciF4 => 'تحصيل التذكرة';

  @override
  String get posRaccourciF6 => 'حفظ التذكرة (دين)';

  @override
  String get posRaccourciF7 => 'اختيار الزبون';

  @override
  String get posRaccourciF8 => 'اختيار تخفيض';

  @override
  String get posRaccourciF9 => 'الآلة الحاسبة';

  @override
  String get posRaccourciF10 => 'إفراغ السلة';

  @override
  String get posRaccourciF11 => 'إخفاء / إظهار المنتجات';

  @override
  String get posRaccourciF12 => 'مبيعات اليوم';

  @override
  String get posRaccourciCtrlN => 'سلة جديدة';

  @override
  String get posRaccourciCtrlTab => 'السلة التالية';

  @override
  String get posRaccourciSuppr => 'إزالة السطر المحدد';

  @override
  String get posRaccourciPlusMoins => 'الكمية +1 / −1 على السطر المحدد';

  @override
  String get posVendreNombre => 'البيع بالقطعة';

  @override
  String get posPack => 'حزمة';

  @override
  String get posCategoriesToutes => 'الكل';

  @override
  String get posAucunProduit => 'لا يوجد منتج نشط.';

  @override
  String get calcTitre => 'الآلة الحاسبة';

  @override
  String get calcUtiliser => 'استعمال كمبلغ';

  @override
  String get modePaiementEspeces => 'نقدًا';

  @override
  String get modePaiementCarte => 'بطاقة';

  @override
  String get modePaiementCheque => 'شيك';

  @override
  String get modePaiementVirement => 'تحويل';

  @override
  String get modePaiementPoints => 'نقاط';

  @override
  String get ventesAucune => 'لا توجد مبيعات.';

  @override
  String get ventesCreerRetour => 'إنشاء مرتجع';

  @override
  String get ventesVerifierChaine => 'التحقق من الختم';

  @override
  String get ventesChaineOk => 'سلسلة التذاكر سليمة.';

  @override
  String ventesChaineKo(String code) {
    return 'سلسلة معدّلة ابتداءً من التذكرة $code.';
  }

  @override
  String get retourErreurQuantite => 'كمية غير صالحة.';

  @override
  String get retourErreurDepasse => 'الكمية أكبر من الكمية المباعة (بما فيها المرتجع سابقًا).';

  @override
  String get retourErreurPeriode => 'فترة مقفلة: الإرجاع غير ممكن.';

  @override
  String get clientNouveau => 'عميل جديد';

  @override
  String get clientNom => 'الاسم';

  @override
  String get clientTelephone => 'الهاتف';

  @override
  String get clientAdresse => 'العنوان';

  @override
  String get clientEmail => 'البريد الإلكتروني';

  @override
  String get clientPoints => 'النقاط';

  @override
  String get fournisseurNouveau => 'مورد جديد';

  @override
  String get versementNouveau => 'دفعة جديدة';

  @override
  String get versementMontant => 'المبلغ';

  @override
  String get versementMode => 'الطريقة';

  @override
  String versementVerrouille(String retour) {
    return 'مقفل (مرتبط بالمرتجع $retour)';
  }

  @override
  String get versementImputations => 'التخصيصات (الأقدم أولاً)';

  @override
  String get versementErreurMontant => 'مبلغ غير صالح.';

  @override
  String get versementErreurMode => 'طريقة دفع غير صالحة.';

  @override
  String get versementErreurSysteme => 'غير ممكن للطرف النظامي.';

  @override
  String get versementErreurVerrouille => 'دفعة مقفلة: مرتبطة بمرتجع، لا يمكن تعديلها ولا حذفها.';

  @override
  String get versementErreurInconnu => 'الدفعة غير موجودة.';

  @override
  String get versementErreurTiers => 'طرف غير صالح.';

  @override
  String get tiersErreurNom => 'الاسم إلزامي.';

  @override
  String get tiersErreurSysteme => 'لا يمكن تعديل الطرف النظامي.';

  @override
  String get achatNouveau => 'إدخال جديد';

  @override
  String get achatFournisseur => 'المورد';

  @override
  String get achatAucun => 'لا توجد إدخالات.';

  @override
  String get achatColVerse => 'المدفوع';

  @override
  String get achatColReste => 'المتبقي';

  @override
  String get achatColSource => 'المصدر';

  @override
  String get achatColStatut => 'الحالة';

  @override
  String get achatErreurLignes => 'أضف سطرًا واحدًا على الأقل.';

  @override
  String get achatErreurQuantite => 'كمية غير صالحة.';

  @override
  String get achatErreurPrix => 'سعر أو مبلغ غير صالح.';

  @override
  String get achatErreurProduit => 'منتج غير معروف.';

  @override
  String get achatErreurFournisseur => 'مورد غير معروف.';

  @override
  String get achatErreurInconnu => 'الإدخال غير موجود.';

  @override
  String get achatErreurAnnule => 'الإدخال ملغى بالفعل.';

  @override
  String get achatErreurPeriode => 'فترة مقفلة: الإلغاء غير ممكن.';

  @override
  String get achatErreurStock => 'مخزون غير كافٍ للإلغاء (بيع سابق).';

  @override
  String get sourceSmartScan => 'Smart Scan';

  @override
  String get smartScanAucuneLigne => 'لم يُتعرف على أي سطر.';

  @override
  String get smartScanQuotaAtteintDetail => 'استعملت كل تحليلاتك. اطلب عرضًا للمتابعة.';

  @override
  String get smartScanDemandeOffre => 'طلب عرض';

  @override
  String get smartScanEmail => 'بريدك الإلكتروني';

  @override
  String get smartScanMessage => 'الرسالة';

  @override
  String get smartScanOffreEnvoyee => 'أُرسل الطلب، سنتصل بك قريبًا.';

  @override
  String get smartScanNonConfigure => 'أدخل عنوان خادم CaisseDZ في الإعدادات لاستعمال Smart Scan.';

  @override
  String smartScanErreurReseau(String detail) {
    return 'تعذر الوصول إلى الخادم: $detail';
  }

  @override
  String smartScanErreurServeur(String detail) {
    return 'خطأ في الخادم: $detail';
  }

  @override
  String get smartScanErreurFichier => 'ملف غير صالح.';

  @override
  String get caisseNouvelle => 'صندوق جديد';

  @override
  String get caisseModifier => 'تعديل الصندوق';

  @override
  String get caisseNom => 'الاسم';

  @override
  String get caisseType => 'النوع';

  @override
  String get caisseMagasin => 'المخزن';

  @override
  String get caisseActive => 'نشط';

  @override
  String get caisseInactive => 'غير نشط';

  @override
  String get caisseTypePhysique => 'مادي';

  @override
  String get caisseTypeCompte => 'حساب';

  @override
  String get caisseAucune => 'لا يوجد صندوق.';

  @override
  String get caisseDesactiver => 'تعطيل';

  @override
  String get mouvementColMontant => 'المبلغ';

  @override
  String get mouvementAucun => 'لا توجد حركات.';

  @override
  String get mouvementCaisse => 'الصندوق';

  @override
  String get mvtVente => 'بيع';

  @override
  String get mvtAnnulation => 'إلغاء بيع';

  @override
  String get mvtRemboursement => 'استرجاع مرتجع';

  @override
  String get mvtEncaissement => 'دفعة زبون';

  @override
  String get mvtDecaissement => 'دفعة مورد';

  @override
  String get mvtApport => 'إدخال يدوي';

  @override
  String get mvtDepense => 'إخراج يدوي';

  @override
  String get mvtTransfert => 'تحويل';

  @override
  String get mvtFondInitial => 'افتتاح';

  @override
  String get mvtRetrait => 'سحب عند الإقفال';

  @override
  String get mvtEcart => 'فرق الإقفال';

  @override
  String get transfertCaisseNouveau => 'تحويل جديد';

  @override
  String get transfertCaisseAucun => 'لا توجد تحويلات.';

  @override
  String get caisseErreurNom => 'الاسم إلزامي.';

  @override
  String get caisseErreurType => 'نوع الصندوق غير صالح.';

  @override
  String get caisseErreurMagasin => 'مخزن غير معروف.';

  @override
  String get caisseErreurInconnue => 'الصندوق غير موجود.';

  @override
  String get caisseErreurInactive => 'الصندوق غير نشط.';

  @override
  String get caisseErreurSysteme => 'لا يمكن تعطيل الصندوق الرئيسي.';

  @override
  String get caisseErreurMontant => 'مبلغ غير صالح.';

  @override
  String get caisseErreurMode => 'وسيلة دفع غير صالحة.';

  @override
  String get caisseErreurMemeCaisse => 'اختر صندوقين مختلفين.';

  @override
  String get caisseErreurSolde => 'الرصيد غير كافٍ في الصندوق المصدر.';

  @override
  String get caisseErreurSessionOuverte => 'توجد جلسة مفتوحة على هذا الصندوق.';

  @override
  String get cloturePeriode => 'الفترة';

  @override
  String get clotureColTotalVentes => 'إجمالي المبيعات';

  @override
  String get clotureColRemises => 'الخصومات';

  @override
  String get clotureColRetours => 'المرتجعات';

  @override
  String get clotureColEncaissements => 'التحصيلات';

  @override
  String get clotureColDecaissements => 'المصروفات';

  @override
  String get clotureAucune => 'لا يوجد إقفال.';

  @override
  String get clotureDerniereVente => 'آخر تذكرة';

  @override
  String get clotureErreurRien => 'لا شيء للإقفال منذ آخر إقفال.';

  @override
  String get exportFiscalGenerer => 'إنشاء الأرشيف';

  @override
  String get exportFiscalErreurDates => 'تواريخ غير صالحة.';

  @override
  String get exportFiscalVerifier => 'التحقق من أرشيف';

  @override
  String exportFiscalVerifOk(int ventes, int clotures) {
    return 'أرشيف صالح: $ventes مبيعات، $clotures إقفالات.';
  }

  @override
  String exportFiscalVerifKo(String erreurs) {
    return 'أرشيف غير صالح: $erreurs';
  }

  @override
  String get tableauBordTopProduits => 'أفضل 5 منتجات (30 يومًا)';

  @override
  String get situationExportExcel => 'تصدير Excel';

  @override
  String get situationApercuPdf => 'معاينة PDF';

  @override
  String situationExportOk(String chemin) {
    return 'تم حفظ الملف: $chemin';
  }

  @override
  String get parametresErreurNom => 'اسم المتجر إلزامي.';

  @override
  String get parametresErreurValeur => 'قيمة غير صالحة.';

  @override
  String get parametresErreurImprimanteType => 'نوع طابعة غير صالح.';

  @override
  String get parametresErreurImprimanteAdresse => 'حدد طابور الطباعة أو عنوان الطابعة.';

  @override
  String get sauvegardeIntro => 'النسخة الاحتياطية مشفّرة بكلمة المرور المختارة: احتفظ بها، ستُطلب عند الاستعادة.';

  @override
  String get sauvegardeRestaurer => 'استعادة نسخة احتياطية';

  @override
  String get sauvegardeMotDePasse => 'كلمة مرور النسخة';

  @override
  String sauvegardeInfo(String boutique, int ventes, int produits, int version) {
    return 'المتجر « $boutique »، $ventes مبيعات، $produits منتجات، المخطط v$version.';
  }

  @override
  String get sauvegardeConfirmerRestauration => 'استعادة هذه النسخة؟ سيتم استبدال البيانات الحالية عند التشغيل القادم.';

  @override
  String get sauvegardeRestaurationPreparee => 'الاستعادة جاهزة: أغلق CaisseDZ ثم أعد تشغيله لتطبيقها.';

  @override
  String get sauvegardeRestaurationEnAttente => 'استعادة قيد الانتظار: ستُطبّق عند التشغيل القادم.';

  @override
  String get sauvegardeAnnulerRestauration => 'إلغاء الاستعادة';

  @override
  String get sauvegardeErreurMotDePasse => 'كلمة مرور غير صالحة أو ملف تالف.';

  @override
  String get sauvegardeErreurMotDePasseVide => 'أدخل كلمة مرور.';

  @override
  String get sauvegardeErreurFichier => 'الملف غير موجود.';

  @override
  String sauvegardeErreurChemin(String detail) {
    return 'موقع غير صالح: $detail';
  }

  @override
  String get dsContinuer => 'متابعة';

  @override
  String get dsCompris => 'فهمت';

  @override
  String get dsLibelle => 'التسمية';

  @override
  String get dsCochezLignes => 'حدّد سطرًا أو أكثر';

  @override
  String get dsCliquezLigne => 'انقر سطرًا · نقر مزدوج للتأكيد';

  @override
  String get dsAjouter => 'إضافة';

  @override
  String get dsChoisir => 'اختيار';

  @override
  String get dsAnnules => 'ملغاة';

  @override
  String get dsSupprimes => 'محذوفة';

  @override
  String get dsActiver => 'تفعيل';

  @override
  String get dsActives => 'مفعّلة';

  @override
  String get dsDesactiver => 'تعطيل';

  @override
  String get dsDesactives => 'معطّلة';

  @override
  String dsLotPartiel(String ok, int total, String participe) {
    return '$ok من $total ستكون $participe.';
  }

  @override
  String get dsLotVerifier => 'تحقّق من التحديد قبل التأكيد.';

  @override
  String dsLotBloques(String n, String motif) {
    return '$n لا يمكن معالجتها: $motif.';
  }

  @override
  String get dsMotifAnnulation => 'سبب الإلغاء';

  @override
  String get dsMotifIndice => 'مثال: خطأ في الإدخال، غياب العميل…';

  @override
  String get dsObligatoires => 'إلزامية';

  @override
  String get dsToujoursAffichees => 'تُعرض دائمًا';

  @override
  String get dsColonnesParDefaut => 'الأعمدة الافتراضية';

  @override
  String get dsAutresColonnes => 'أعمدة أخرى';

  @override
  String get dsColonnesTitre => 'إظهار / إخفاء الأعمدة';

  @override
  String dsColonnesVisibles(int n, int total) {
    return '$n من $total أعمدة ظاهرة';
  }

  @override
  String get dsAppliquer => 'تطبيق';

  @override
  String get dsRechercherColonne => 'البحث عن عمود…';

  @override
  String get dsAfficherTout => 'إظهار الكل';

  @override
  String get dsMasquerTout => 'إخفاء الكل';

  @override
  String get dsParDefaut => 'افتراضي';

  @override
  String get dsAucuneColonne => 'لم يُعثر على أي عمود';

  @override
  String get dsGarderSelection => 'الاحتفاظ بتحديدي';

  @override
  String get dsGarderSelectionAide => 'وإلا تُستعاد الأعمدة الافتراضية عند الفتح التالي';

  @override
  String get dsParPage => 'في الصفحة';

  @override
  String get dsToutDeselectionner => 'إلغاء تحديد الكل';

  @override
  String dsSelectionneSur(int n, int total) {
    return '$n / $total محدّد';
  }

  @override
  String get dsSelectionnezUne => 'حدّد سطرًا واحدًا فقط';

  @override
  String get dsSelectionnezAuMoins => 'حدّد سطرًا واحدًا على الأقل';

  @override
  String get dsAucunElement => 'لا عناصر';

  @override
  String get dsDoubleClicDetail => 'نقر مزدوج: عرض التفاصيل';

  @override
  String dsColonnesMasquees(int n, int total) {
    return 'إظهار / إخفاء الأعمدة · $n/$total';
  }

  @override
  String get dsFiltres => 'عوامل التصفية';

  @override
  String get dsFiltrer => 'تصفية';

  @override
  String get dsReinitialiser => 'إعادة التعيين';

  @override
  String dsActifs(int n) {
    return '$n نشط';
  }

  @override
  String get dsExporter => 'تصدير';

  @override
  String get dsToutExporter => 'تصدير الكل';

  @override
  String get dsSelectionSeulement => 'التحديد فقط';

  @override
  String get dsRetour => 'رجوع';

  @override
  String get dsEffacer => 'مسح';

  @override
  String get dsThemeClair => 'السمة الفاتحة';

  @override
  String get dsThemeSombre => 'السمة الداكنة';

  @override
  String get dsEnLigne => 'متصل';

  @override
  String get dsHorsLigne => 'غير متصل';

  @override
  String get dsSynchronise => 'متزامن';

  @override
  String get dsHorsLigneLocal => 'غير متصل — تبقى البيانات محلية';

  @override
  String get dsAlertes => 'التنبيهات';

  @override
  String get dsMenuModules => 'قائمة الوحدات (Ctrl M)';

  @override
  String get dsReplier => 'طيّ';

  @override
  String get dsDeplier => 'بسط';

  @override
  String get dsAjouterFavoris => 'إضافة إلى المفضلة';

  @override
  String get dsRetirerFavoris => 'إزالة من المفضلة';

  @override
  String get dsFavorisComplets => 'المفضلة ممتلئة';

  @override
  String get dsModules => 'الوحدات';

  @override
  String get dsRechercherModule => 'البحث عن وحدة…';

  @override
  String get dsMagasin => 'المتجر';

  @override
  String get dsPagePrecedente => 'الصفحة السابقة';

  @override
  String get dsPageSuivante => 'الصفحة التالية';

  @override
  String get dsAucunResultat => 'لا نتائج';

  @override
  String get dsGateLicenceTitre => 'متاح مع الباقة المتقدمة';

  @override
  String get dsGateLicenceAction => 'الانتقال إلى الباقة المتقدمة';

  @override
  String get dsGateRoleTitre => 'وصول غير مصرّح به';

  @override
  String get dsGateRoleAction => 'طلب الوصول';

  @override
  String get dsGateRefuseTitre => 'تم رفض الوصول';

  @override
  String get dsGateRefuseAction => 'العودة إلى لوحة القيادة';

  @override
  String get dsGateActivationTitre => 'التطبيق غير مفعّل';

  @override
  String get dsGateActivationAction => 'تفعيل';

  @override
  String dsGateRefuseDetail(String module) {
    return 'لا يمنحك دورك الوصول إلى وحدة $module. اطلب من المسؤول تعديل صلاحياتك.';
  }

  @override
  String get dsPermTout => 'تحديد الكل';

  @override
  String get dsPermRien => 'إلغاء تحديد الكل';

  @override
  String get dsPermReserve => 'مخصّص للمسؤول';

  @override
  String get dsPosProduit => 'المنتج';

  @override
  String get dsPosColis => 'العبوة';

  @override
  String get dsPosQte => 'الكمية';

  @override
  String get dsPosPieces => 'القطع';

  @override
  String get dsPosMontant => 'المبلغ';

  @override
  String get dsPosMoins => 'أقل';

  @override
  String get dsPosPlus => 'أكثر';

  @override
  String get dsPosRetirer => 'إزالة';

  @override
  String get dsPosChangerColis => 'تغيير العبوة';

  @override
  String get dsPosOuverte => 'مفتوحة';

  @override
  String get dsPosFermee => 'مغلقة';

  @override
  String get dsPosAucuneSession => 'لا توجد جلسة مفتوحة';

  @override
  String dsPosOuverteA(String heure) {
    return 'مفتوحة في $heure';
  }

  @override
  String dsPosPar(String nom) {
    return 'بواسطة $nom';
  }

  @override
  String get dsPosSoldeCourant => 'الرصيد الحالي';

  @override
  String get dsPosMouvement => 'حركة';

  @override
  String get dsPosCloturer => 'إغلاق';

  @override
  String get dsPosOuvrir => 'فتح';

  @override
  String get dsPosOuvrirCaisse => 'فتح الصندوق';

  @override
  String get dsPosEffacer => 'مسح';

  @override
  String get dsPosToutEffacer => 'مسح الكل';

  @override
  String get dsPosTotalAvantRemise => 'الإجمالي قبل الخصم';

  @override
  String get dsPosRemise => 'الخصم';

  @override
  String get dsPosTotalAPayer => 'الإجمالي المستحق';

  @override
  String get dsPosPaiementComplet => 'دفع كامل';

  @override
  String get dsPosMontantPaye => 'المبلغ المدفوع';

  @override
  String get dsPosARendre => 'الباقي';

  @override
  String get dsPosMontantExact => 'المبلغ بالضبط';

  @override
  String get dsPosPartielImpossible => 'الدفع الجزئي غير ممكن لعميل الكاونتر';

  @override
  String get dsPosResteCredit => 'المتبقي (دين العميل)';

  @override
  String get dsPosRupture => 'نفد';

  @override
  String dsPosEnStock(String n) {
    return '$n في المخزون';
  }

  @override
  String get dsPosEntree => 'إدخال';

  @override
  String get dsPosEntreeRapide => 'إدخال سريع جديد لهذا المنتج';

  @override
  String get dsPosSmartScan => 'Smart Scan';

  @override
  String dsPosScansMois(int n) {
    return '/ $n مسحًا هذا الشهر';
  }

  @override
  String dsPosRestants(int n) {
    return '$n متبقية';
  }

  @override
  String dsPosRenouvellement(String date) {
    return 'التجديد $date';
  }

  @override
  String get dsPosQuotaHorsLigne => 'غير متصل — الحصة غير متاحة، يواصل الصندوق العمل.';

  @override
  String get dsPosActualiser => 'تحديث';

  @override
  String get dsPosNouvelleVente => 'بيع جديد';

  @override
  String get dsPosVentes => 'مبيعات';

  @override
  String get dsPosFermerVente => 'إغلاق هذا البيع';

  @override
  String dsPosMaxVentes(int n) {
    return 'الحد الأقصى $n مبيعات بالتوازي';
  }

  @override
  String dsPosArticles(int n) {
    return '$n سلعة';
  }

  @override
  String get dsPosSousTotal => 'المجموع الفرعي';

  @override
  String get dsPosLigneArticles => 'السلع';

  @override
  String get dsPosLigneQuantite => 'الكمية';

  @override
  String get dsPosLigneAjouter => 'إضافة منتجات';

  @override
  String get dsPosLigneVide => 'لا منتجات — أضف باستخدام الزر أدناه.';

  @override
  String get dsPosLigneRetirer => 'إزالة السطر';

  @override
  String get dsPosCode => 'الرمز';

  @override
  String get dsPosPrix => 'السعر';

  @override
  String get dsCalcUtiliser => 'استخدام النتيجة';

  @override
  String get dsBarcodeAucun => 'لا يملك هذا المنتج رمزًا شريطيًا.';

  @override
  String get dsBarcodeGenerer => 'توليد';

  @override
  String get dsBarcodeCopier => 'نسخ';

  @override
  String get dsBarcodeImprimer => 'طباعة الملصق';

  @override
  String get moduleUtilisateurs => 'المستخدمون';

  @override
  String get connexionSousTitre => 'سجّل الدخول لفتح صندوقك.';

  @override
  String get connexionAfficher => 'إظهار';

  @override
  String get connexionMasquer => 'إخفاء';

  @override
  String get connexionResterConnecte => 'البقاء متصلًا';

  @override
  String get connexionMotDePasseOublie => 'نسيت كلمة المرور؟ راجع المسؤول';

  @override
  String get connexionHorsLigne => 'يعمل دون اتصال · البيانات محفوظة على هذا الجهاز';

  @override
  String get connexionDemoNonActivee => 'التطبيق غير مفعّل: سجّل الدخول بـ demo / demo لتجربته، أو أدخل مفتاحًا.';

  @override
  String get connexionErreurNonActivee => 'التطبيق غير مفعّل: الحساب demo / demo فقط متاح.';

  @override
  String get connexionNonActivee => 'غير مفعّل';

  @override
  String connexionVersion(String version, String licence) {
    return 'الإصدار $version · $licence';
  }

  @override
  String get connexionNouveaute => 'جديد · المسح الذكي';

  @override
  String get connexionAccroche => 'المبيعات والمخزون والصندوق — ببساطة وسرعة وأمان.';

  @override
  String get connexionAccrocheDetail =>
      'امسح وصولات الشراء، تابع عدة مخازن واستلم المدفوعات بالفرنسية أو العربية أو الإنجليزية.';

  @override
  String get connexionAtoutHorsLigne => 'دون اتصال';

  @override
  String get connexionAtoutMultiMagasin => 'متعدد المخازن';

  @override
  String get activationNonActivee => 'غير مفعّل';

  @override
  String activationPalierDetecte(String palier) {
    return 'المستوى المكتشف: $palier';
  }

  @override
  String get activationPalierBasic => 'أساسي (مخزن واحد، صندوق واحد)';

  @override
  String get activationPalierAvance => 'متقدم (عدة مخازن، عدة صناديق)';

  @override
  String get activationUnMagasin => 'مخزن واحد';

  @override
  String get activationUneCaisse => 'صندوق واحد';

  @override
  String get activationMagasinsIllimites => 'مخازن غير محدودة وتحويلات';

  @override
  String get activationPlusieursCaisses => 'عدة صناديق';

  @override
  String get activationSmartScanQuota => 'المسح الذكي حسب حصة الخادم';

  @override
  String get activationRetourConnexion => 'تسجيل الدخول';

  @override
  String get activationReussieTitre => 'تم تفعيل التطبيق';

  @override
  String activationReussieDetail(String palier, String poste) {
    return 'المستوى $palier · مرتبط بالجهاز $poste.';
  }

  @override
  String get activationContinuer => 'متابعة';

  @override
  String get configDescription => 'أربع خطوات لإعداد المتجر. يبقى كل شيء قابلًا للتعديل في الإعدادات.';

  @override
  String get configEtapeLangue => 'اللغة والعملة';

  @override
  String get configEtapeLangueDetail => 'العرض';

  @override
  String get configEtapeBoutiqueDetail => 'التذكرة والبيانات';

  @override
  String get configEtapePaiements => 'المدفوعات';

  @override
  String get configEtapePaiementsDetail => 'الوسائل المقبولة';

  @override
  String get configEtapeVenteDetail => 'الأسعار والتنبيهات';

  @override
  String get configDecimales => 'أرقام الكميات العشرية';

  @override
  String get configDecimalesAide => '3 للبيع بالوزن';

  @override
  String get configBoutiqueNomIndice => 'مثال: متجر بن علي';

  @override
  String get configBoutiqueAdresseIndice => 'الشارع، البلدية، الولاية';

  @override
  String get configBoutiqueNis => 'ر.ت.إ';

  @override
  String get configBoutiqueArticle => 'مادة الضريبة';

  @override
  String get configBoutiqueMessage => 'رسالة التذكرة';

  @override
  String get configBoutiqueMessageIndice => 'شكرًا لزيارتكم!';

  @override
  String get configSeuilAide => 'حد عام، يُستبدل بحد المنتج إن وُجد';

  @override
  String get configFideliteActive => 'نقاط الولاء';

  @override
  String get configPlusTard => 'لاحقًا';

  @override
  String get compteIdentifiant => 'اسم المستخدم';

  @override
  String compteIdentite(String identifiant, String acces) {
    return '@$identifiant · آخر دخول $acces';
  }

  @override
  String get compteJamaisConnecte => 'أول دخول';

  @override
  String get compteOngletProfil => 'الملف الشخصي';

  @override
  String get compteOngletMotDePasse => 'كلمة المرور';

  @override
  String get compteCode => 'الرمز';

  @override
  String get compteMagasinDefaut => 'المخزن الافتراضي';

  @override
  String get compteConfirmer => 'تأكيد';

  @override
  String compteMotDePasseAide(int n) {
    return '$n أحرف على الأقل';
  }

  @override
  String get comptePreferencesAide => 'تنطبق هذه التفضيلات على هذا الجهاز.';

  @override
  String get alertesTitre => 'تنبيهات اليوم';

  @override
  String alertesResume(int urgentes, int surveiller) {
    return '$urgentes عاجلة · $surveiller للمتابعة';
  }

  @override
  String get alertesToutTraite => 'تمت معالجة الكل';

  @override
  String get alertesUrgent => 'عاجل';

  @override
  String get alertesASurveiller => 'للمتابعة';

  @override
  String get alertesNePlusAfficher => 'عدم الإظهار مجددًا اليوم';

  @override
  String get alertesLienParametres => 'الإعدادات › التنبيهات';

  @override
  String get alertesOuvrirModule => 'فتح الوحدة';

  @override
  String get alertesMarquerTraite => 'تعليم كمعالج';

  @override
  String get alertesRienTitre => 'لا شيء للإبلاغ';

  @override
  String get alertesRienDetail => 'تمت معالجة هذه الفئة من التنبيهات.';

  @override
  String get alertesMesureRupture => 'نفاد';

  @override
  String alertesOuverteDepuis(String date) {
    return 'مفتوحة منذ $date';
  }

  @override
  String alertesJours(int n) {
    return 'ي−$n';
  }

  @override
  String alertesDernierDocument(String code, String date) {
    return '$code · آخر مستند في $date';
  }

  @override
  String get alertesRupture => 'النفاد والحدود';

  @override
  String get alertesRuptureAide => 'منتجات نافدة أو تحت حد التنبيه.';

  @override
  String get alertesRuptureAction => 'إنشاء قائمة احتياجات';

  @override
  String get alertesRuptureLigne => 'طلب';

  @override
  String get alertesExpire => 'منتجات منتهية الصلاحية';

  @override
  String get alertesExpireAide => 'دفعات منتهية ما زالت في المخزون — يجب إخراجها قبل البيع.';

  @override
  String get alertesExpireAction => 'إخراج «منتهي الصلاحية»';

  @override
  String get alertesExpireLigne => 'إخراج';

  @override
  String get alertesSessions => 'جلسات مفتوحة';

  @override
  String get alertesSessionsAide => 'جلسات صندوق مفتوحة منذ يوم سابق.';

  @override
  String get alertesSessionsAction => 'إغلاق';

  @override
  String get alertesBientot => 'تنتهي قريبًا';

  @override
  String get alertesBientotAide => 'دفعات تنتهي خلال الثلاثين يومًا القادمة.';

  @override
  String get alertesBientotAction => 'إنشاء تخفيض';

  @override
  String get alertesBientotLigne => 'تخفيض';

  @override
  String get alertesClients => 'ديون الزبائن';

  @override
  String get alertesClientsAide => 'أكبر الديون الجارية.';

  @override
  String get alertesClientsAction => 'دفعة جديدة';

  @override
  String get alertesClientsLigne => 'تحصيل';

  @override
  String get alertesFournisseurs => 'ديون الموردين';

  @override
  String get alertesFournisseursAide => 'أكبر الديون وآخر شراء.';

  @override
  String get alertesFournisseursAction => 'تسوية جديدة';

  @override
  String get alertesFournisseursLigne => 'تسوية';

  @override
  String get dsPeriodeAujourdhui => 'اليوم';

  @override
  String get dsPeriodeHier => 'أمس';

  @override
  String get dsPeriodeSemaine => 'هذا الأسبوع';

  @override
  String get dsPeriodeSemaineDerniere => 'الأسبوع الماضي';

  @override
  String get dsPeriodeMois => 'هذا الشهر';

  @override
  String get dsPeriodeMoisDernier => 'الشهر الماضي';

  @override
  String get dsPeriode7Jours => 'آخر 7 أيام';

  @override
  String get dsPeriode30Jours => 'آخر 30 يومًا';

  @override
  String get dsPeriodeAnnee => 'هذه السنة';

  @override
  String get dsPeriodeAnneeDerniere => 'السنة الماضية';

  @override
  String get dsDu => 'من';

  @override
  String get dsAu => 'إلى';

  @override
  String get dsPeriodeRapide => 'فترة سريعة';

  @override
  String get dsRechercherIndice => 'بحث…';

  @override
  String get dsAffichageGrille => 'عرض شبكي';

  @override
  String get dsAffichageListe => 'عرض قائمة';

  @override
  String get dsModifiezRecherche => 'عدّل البحث أو عوامل التصفية.';

  @override
  String get auditTitre => 'التتبع';

  @override
  String get auditCreePar => 'أنشئ بواسطة';

  @override
  String get auditAnnuleLe => 'أُلغي في';

  @override
  String get auditAnnulePar => 'أُلغي بواسطة';

  @override
  String get auditMotif => 'السبب';

  @override
  String get dsAnnuler => 'إلغاء';

  @override
  String get dsValider => 'تأكيد';

  @override
  String get statutActif => 'نشط';

  @override
  String get statutInactif => 'غير نشط';

  @override
  String get statutPaye => 'مدفوع';

  @override
  String get statutPartiel => 'جزئي';

  @override
  String get statutCredit => 'دين';

  @override
  String get statutAnnule => 'ملغى';

  @override
  String get statutOuverte => 'مفتوحة';

  @override
  String get statutFermee => 'مغلقة';

  @override
  String get statutCloturee => 'مقفلة';

  @override
  String get statutRupture => 'نفاد';

  @override
  String get statutSeuil => 'تحت الحد';

  @override
  String get statutExpire => 'منتهي الصلاحية';

  @override
  String get statutBientotExpire => 'ينتهي قريبا';

  @override
  String get statutBrouillon => 'مسودة';

  @override
  String get statutValide => 'مصادق';

  @override
  String get statutEntree => 'دخول';

  @override
  String get statutSortie => 'خروج';

  @override
  String get statutRetourne => 'مُرجع';

  @override
  String get statutClient => 'زبون';

  @override
  String get statutFournisseur => 'مورد';

  @override
  String get statutRecu => 'مستلم';

  @override
  String get statutTraite => 'معالج';

  @override
  String get tiers15Chiffres => '15 رقما';

  @override
  String get tiers20Chiffres => '20 رقما';

  @override
  String get tiersActivite => 'النشاط';

  @override
  String get tiersActiviteIndice => 'مثال: مواد غذائية عامة';

  @override
  String get tiersAdministratifBanque => 'الإداري والبنك';

  @override
  String get tiersAdresseIndice => 'الشارع، البلدية';

  @override
  String get tiersAvance => 'تسبيق';

  @override
  String get tiersBanque => 'البنك';

  @override
  String get tiersBloqueCredit => 'دين جار — قم بتسويته أولا';

  @override
  String get tiersBloqueDejaAnnule => 'ملغى مسبقا';

  @override
  String get tiersBloqueSysteme => 'عنصر نظام';

  @override
  String get tiersChampsObligatoires => 'الحقول المعلمة بـ * إلزامية';

  @override
  String get tiersChoisir => 'اختر…';

  @override
  String get tiersChoisirClient => 'اختر زبونا';

  @override
  String get tiersChoisirFournisseur => 'اختر موردا';

  @override
  String get tiersCodeAuto => 'يُنشأ تلقائيا';

  @override
  String get tiersContact => 'الاتصال';

  @override
  String get tiersCredit => 'الدين';

  @override
  String get tiersCreditAide => 'دائن (مشتريات)';

  @override
  String get tiersDebit => 'مدين';

  @override
  String get tiersDebitAide => 'مدين (دفعات، مرتجعات)';

  @override
  String get tiersDernierAchat => 'آخر شراء';

  @override
  String get tiersDerniereEntree => 'آخر إدخال';

  @override
  String get tiersDernieresEntrees => 'آخر الإدخالات';

  @override
  String get tiersDerniersPaniers => 'آخر السلال';

  @override
  String tiersDescriptionClients(int n, int nb) {
    return '$n زبون · $nb بدين جار';
  }

  @override
  String tiersDescriptionFournisseurs(int n, int nb) {
    return '$n مورد · $nb بدين جار';
  }

  @override
  String get tiersDetail => 'التفاصيل';

  @override
  String get tiersEntiteClient => 'زبون';

  @override
  String get tiersEntiteClientMaj => 'الزبون';

  @override
  String get tiersEntiteClients => 'زبائن';

  @override
  String get tiersEntiteFournisseur => 'مورد';

  @override
  String get tiersEntiteFournisseurMaj => 'المورد';

  @override
  String get tiersEntiteFournisseurs => 'موردين';

  @override
  String get tiersErreurNomExistant => 'هذا الاسم موجود مسبقا';

  @override
  String get tiersEtat => 'الحالة';

  @override
  String get tiersFax => 'الفاكس';

  @override
  String get tiersFormatNif => 'يجب أن يحتوي الرقم الجبائي على 15 رقما';

  @override
  String get tiersFormatTelephone => 'الصيغة المتوقعة: 0X XX XX XX XX';

  @override
  String get tiersInfosAdministratives => 'المعلومات الإدارية';

  @override
  String get tiersInfosBancaires => 'المعلومات البنكية';

  @override
  String get tiersInfosGenerales => 'معلومات عامة';

  @override
  String get tiersKpiClientsActifs => 'الزبائن النشطون';

  @override
  String get tiersKpiCreditClients => 'ديون الزبائن';

  @override
  String get tiersKpiCreditFournisseurs => 'ديون الموردين';

  @override
  String get tiersKpiFournisseursActifs => 'الموردون النشطون';

  @override
  String get tiersKpiPoints => 'نقاط الولاء';

  @override
  String get tiersModifierClient => 'تعديل الزبون';

  @override
  String get tiersModifierFournisseur => 'تعديل المورد';

  @override
  String get tiersNatureAchat => 'شراء';

  @override
  String get tiersNatureRetour => 'إرجاع';

  @override
  String get tiersNatureVente => 'بيع';

  @override
  String get tiersNatureVersement => 'دفعة';

  @override
  String get tiersNatureVersementRetour => 'دفعة مرتجعة';

  @override
  String get tiersNomIndice => 'الاسم أو التسمية التجارية';

  @override
  String get tiersNoteInterne => 'ملاحظة داخلية';

  @override
  String get tiersNrc => 'رقم السجل التجاري';

  @override
  String get tiersObservation => 'ملاحظة';

  @override
  String get tiersPanier => 'السلة';

  @override
  String tiersPoints(int n) {
    return '$n نقطة';
  }

  @override
  String get tiersRechercheIndice => 'الاسم أو الرمز أو الهاتف…';

  @override
  String get tiersReference => 'المرجع';

  @override
  String get tiersReleveClient => 'كشف حساب الزبون';

  @override
  String get tiersReleveFournisseur => 'كشف حساب المورد';

  @override
  String get tiersReste => 'الباقي';

  @override
  String get tiersSituation => 'الوضعية';

  @override
  String tiersSituationDe(String nom) {
    return 'الوضعية — $nom';
  }

  @override
  String get tiersSoldeDu => 'الرصيد المستحق';

  @override
  String get tiersStatut => 'الحالة';

  @override
  String get tiersTotalAchats => 'مجموع المشتريات';

  @override
  String get tiersTotalPaye => 'مجموع المدفوع';

  @override
  String get tiersTotalRetours => 'مجموع المرتجعات';

  @override
  String get tiersTous => 'الكل';

  @override
  String get tiersToutes => 'الكل';

  @override
  String get tiersType => 'النوع';

  @override
  String get tiersVersement => 'دفعة';

  @override
  String get tiersWilaya => 'الولاية';

  @override
  String get versementAideClient => 'يُخصم المبلغ من سلال الزبون الآجلة، من الأقدم إلى الأحدث.';

  @override
  String get versementAideFournisseur => 'يُخصم المبلغ من إدخالات المورد الآجلة، من الأقدم إلى الأحدث.';

  @override
  String get versementAideRetourClient => 'مبلغ يُعاد إلى الزبون (تسبيق أو فائض): خروج من الصندوق.';

  @override
  String get versementAideRetourFournisseur => 'مبلغ يرده المورد: دخول إلى الصندوق.';

  @override
  String get versementAucunBeneficiaire => 'لم يتم اختيار مستفيد';

  @override
  String get versementAvanceTropPercu => 'تسبيق / فائض بعد هذه الدفعة';

  @override
  String get versementBeneficiaire => 'المستفيد';

  @override
  String get versementCaisse => 'الصندوق';

  @override
  String get versementCliquezChoisir => 'انقر للاختيار';

  @override
  String get versementCompteSolde => 'حساب مسوّى بعد هذه الدفعة';

  @override
  String versementCreditActuel(String montant) {
    return 'الدين الحالي: $montant';
  }

  @override
  String get versementCreditRestant => 'الدين المتبقي بعد هذه الدفعة';

  @override
  String get versementEntite => 'دفعة';

  @override
  String get versementEntites => 'دفعات';

  @override
  String get versementKpiEncaisse => 'المبلغ المحصل';

  @override
  String get versementKpiNombre => 'الدفعات';

  @override
  String get versementKpiPaye => 'المبلغ المدفوع';

  @override
  String get versementKpiRetour => 'الدفعات المرتجعة';

  @override
  String get versementModifier => 'تعديل الدفعة';

  @override
  String get versementNumero => 'الرقم';

  @override
  String get versementObsIndice => 'ملاحظة (اختياري)';

  @override
  String get versementRetourModifier => 'تعديل الدفعة المرتجعة';

  @override
  String get versementRetourNouveau => 'دفعة مرتجعة';

  @override
  String get versementRetourTitre => 'دفعة مرتجعة';

  @override
  String get versementSens => 'الاتجاه';

  @override
  String get versementSensPaye => 'مدفوع';

  @override
  String get versementSensRecu => 'مستلم';

  @override
  String get versementSensRetour => 'إرجاع';

  @override
  String get versementTitre => 'دفعة';

  @override
  String get versementType => 'النوع';

  @override
  String get dsChargement => 'جار التحميل…';

  @override
  String get tableauBordOnglet => 'لوحة القيادة';

  @override
  String get situationOnglet => 'الوضعية';

  @override
  String tableauBordDescription(String au, String du, int n) {
    return 'من $du إلى $au، مقارنة بالأيام الـ $n السابقة.';
  }

  @override
  String get situationDescription => 'تحليلات مفصلة للفترة — كل عرض قابل للتصدير بصيغة Excel وPDF.';

  @override
  String get tableauBordJour => 'يوم';

  @override
  String get tableauBordSemaine => 'أسبوع';

  @override
  String get tableauBordMois => 'شهر';

  @override
  String get tableauBordPeriode => 'فترة';

  @override
  String get tableauBordChoisirPeriode => 'اختيار الفترة';

  @override
  String get tableauBordIndicateur => 'المؤشر';

  @override
  String get tableauBordPeriodeCourante => 'الفترة';

  @override
  String get tableauBordPeriodePrecedente => 'الفترة السابقة';

  @override
  String get tableauBordVentes => 'المبيعات';

  @override
  String get tableauBordVentesInfo => 'مجموع السلال المحصلة خلال الفترة';

  @override
  String get tableauBordPrecedenteInfo => 'نفس عدد الأيام، قبل الفترة مباشرة';

  @override
  String get tableauBordAchats => 'المشتريات';

  @override
  String get tableauBordAchatsInfo => 'الإدخالات المصادق عليها (وصولات الشراء)';

  @override
  String get tableauBordNet => 'الصافي';

  @override
  String get tableauBordNetInfo => 'المبيعات − مشتريات الفترة';

  @override
  String get tableauBordDetteFournisseurs => 'ديون الموردين';

  @override
  String get tableauBordDetteInfo => 'المبالغ المتبقية للدفع على الإدخالات';

  @override
  String get tableauBordCreditClients => 'ديون الزبائن';

  @override
  String get tableauBordCreditInfo => 'المبالغ المستحقة على السلال';

  @override
  String get tableauBordCourbeVentes => 'منحنى المبيعات';

  @override
  String get tableauBordModesPaiement => 'طرق الدفع';

  @override
  String get tableauBordTotal => 'المجموع';

  @override
  String get tableauBordCaParJour => 'رقم الأعمال اليومي';

  @override
  String get tableauBordVentesCaissier => 'المبيعات حسب أمين الصندوق';

  @override
  String tableauBordTickets(int n) {
    return '$n تذكرة';
  }

  @override
  String tableauBordUnites(String qte) {
    return '$qte وحدة';
  }

  @override
  String get tableauBordDernieresVentes => 'آخر المبيعات';

  @override
  String get tableauBordPanier => 'رقم السلة';

  @override
  String get tableauBordHeure => 'الوقت';

  @override
  String get tableauBordPaiement => 'الدفع';

  @override
  String get tableauBordRuptures => 'منتجات نافدة';

  @override
  String get tableauBordAucuneRupture => 'لا توجد منتجات نافدة';

  @override
  String get tableauBordProduit => 'المنتج';

  @override
  String get tableauBordStock => 'المخزون';

  @override
  String get situationGroupeTresorerie => 'الخزينة';

  @override
  String get situationGroupeStock => 'المخزون';

  @override
  String get situationGroupeVentes => 'المبيعات';

  @override
  String get situationGroupeMarges => 'الهوامش';

  @override
  String get situationGroupeTiers => 'الأطراف';

  @override
  String get situationMvc => 'حركة الصندوق';

  @override
  String get situationMvp => 'حركة المنتج';

  @override
  String get situationRcp => 'الإيراد حسب السلة';

  @override
  String get situationRcpr => 'الإيراد حسب المنتج';

  @override
  String get situationMgp => 'الهامش حسب السلة';

  @override
  String get situationMgper => 'الهامش حسب الفترة';

  @override
  String get situationInv => 'الجرد';

  @override
  String get situationCout => 'تكلفة المنتج';

  @override
  String get situationScli => 'وضعية الزبائن';

  @override
  String get situationSfrn => 'وضعية الموردين';

  @override
  String get situationEntrees => 'المداخيل';

  @override
  String get situationSorties => 'المخارج';

  @override
  String get situationSoldeNet => 'الرصيد الصافي';

  @override
  String get situationRetours => 'المرتجعات';

  @override
  String get situationStockInitial => 'المخزون الأولي';

  @override
  String get situationStockFinal => 'المخزون النهائي';

  @override
  String get situationCaissier => 'أمين الصندوق';

  @override
  String get situationPaye => 'المدفوع';

  @override
  String get situationPaniers => 'السلال';

  @override
  String get situationRecette => 'الإيراد';

  @override
  String get situationPanierMoyen => 'متوسط السلة';

  @override
  String get situationCategorie => 'الفئة';

  @override
  String get situationQuantite => 'الكمية';

  @override
  String get situationPrixMoyen => 'متوسط السعر';

  @override
  String get situationProduitsVendus => 'المنتجات المباعة';

  @override
  String get situationVente => 'البيع';

  @override
  String get situationCoutLibelle => 'التكلفة';

  @override
  String get situationMarge => 'الهامش';

  @override
  String get situationTaux => 'النسبة';

  @override
  String get situationCa => 'رقم الأعمال';

  @override
  String get situationTauxMoyen => 'متوسط النسبة';

  @override
  String get situationMargeParPeriode => 'الهامش حسب الفترة';

  @override
  String get situationRegrouper => 'تجميع';

  @override
  String get situationParJour => 'حسب اليوم';

  @override
  String get situationParSemaine => 'حسب الأسبوع';

  @override
  String get situationParMois => 'حسب الشهر';

  @override
  String get situationMagasin => 'المخزن';

  @override
  String get situationTheorique => 'النظري';

  @override
  String get situationCompte => 'المعدود';

  @override
  String get situationEcart => 'الفرق';

  @override
  String get situationValeur => 'القيمة';

  @override
  String get situationProduitsComptes => 'المنتجات المعدودة';

  @override
  String get situationEcarts => 'الفروقات';

  @override
  String get situationValeurEcart => 'قيمة الفرق';

  @override
  String get situationValiderInventaire => 'تأكيد الجرد';

  @override
  String get situationInventaireMagasin => 'اختر مخزنا لتأكيد الجرد.';

  @override
  String get situationAucunEcart => 'لا يوجد فرق للتسجيل.';

  @override
  String situationConfirmerInventaire(int n) {
    return 'سيتم تعديل $n منتج(ات) وفق المخزون المعدود. هل تريد المتابعة؟';
  }

  @override
  String get situationInventaireValide => 'تم تأكيد الجرد';

  @override
  String situationProduitsAjustes(int n) {
    return 'تم تعديل $n منتج(ات)';
  }

  @override
  String get situationDernierAchat => 'آخر شراء';

  @override
  String get situationCmp => 'التكلفة المتوسطة المرجحة';

  @override
  String get situationMin => 'الأدنى';

  @override
  String get situationMax => 'الأقصى';

  @override
  String get situationPrixVente => 'سعر البيع';

  @override
  String get situationProduits => 'المنتجات';

  @override
  String get situationMargeMoyenne => 'متوسط الهامش';

  @override
  String get situationSous15 => 'أقل من 15 %';

  @override
  String get situationAchats => 'المشتريات';

  @override
  String get situationDette => 'الدين';

  @override
  String get situationDettes => 'الديون';

  @override
  String get situationCreditTotal => 'مجموع الديون';

  @override
  String get ventesDescription => 'كل السلال المحصلة — تذاكر ووصولات BL / SC';

  @override
  String get ventesKpiNombre => 'عدد المبيعات';

  @override
  String get ventesKpiCa => 'رقم الأعمال';

  @override
  String get ventesKpiMarge => 'الهامش';

  @override
  String get ventesKpiEncaisse => 'المحصل';

  @override
  String get ventesKpiCredit => 'ديون الزبائن';

  @override
  String get ventesType => 'النوع';

  @override
  String get ventesTous => 'الكل';

  @override
  String get ventesToutes => 'الكل';

  @override
  String get ventesStatut => 'الحالة';

  @override
  String get ventesCaissier => 'أمين الصندوق';

  @override
  String get ventesClient => 'الزبون';

  @override
  String get ventesCaisse => 'الصندوق';

  @override
  String get ventesSession => 'الجلسة';

  @override
  String get ventesMontant => 'المبلغ';

  @override
  String get ventesPaye => 'المدفوع';

  @override
  String get ventesReste => 'الباقي';

  @override
  String get ventesPaiement => 'الدفع';

  @override
  String get ventesArticles => 'المواد';

  @override
  String get ventesQuantite => 'الكمية';

  @override
  String get ventesNbVersements => 'عدد الدفعات';

  @override
  String get ventesMontantAchat => 'مبلغ الشراء';

  @override
  String get ventesAnnuleLe => 'أُلغي في';

  @override
  String get ventesAnnulePar => 'أُلغي بواسطة';

  @override
  String get ventesRechercheIndice => 'رقم السلة أو الزبون…';

  @override
  String get ventesNouvelle => 'بيع جديد';

  @override
  String get ventesEntite => 'سلة';

  @override
  String get ventesEntitePluriel => 'سلال';

  @override
  String ventesPanierTitre(String code) {
    return 'السلة $code';
  }

  @override
  String get ventesReimprimer => 'إعادة الطباعة';

  @override
  String get ventesMontantTotal => 'المبلغ الإجمالي';

  @override
  String get ventesVersements => 'الدفعات';

  @override
  String get ventesInfosGenerales => 'معلومات عامة';

  @override
  String get ventesPaiementMarge => 'الدفع والهامش';

  @override
  String get ventesTotalAchat => 'إجمالي الشراء';

  @override
  String get ventesMontantPaye => 'المبلغ المدفوع';

  @override
  String get ventesNombreVersements => 'عدد الدفعات';

  @override
  String get ventesModePaiement => 'طريقة الدفع';

  @override
  String get ventesProduitsPanier => 'منتجات السلة';

  @override
  String get ventesProduits => 'المنتجات';

  @override
  String get ventesProduit => 'المنتج';

  @override
  String get ventesQte => 'الكمية';

  @override
  String get ventesNumSerie => 'الرقم التسلسلي';

  @override
  String get ventesPrix => 'السعر';

  @override
  String get ventesTotal => 'المجموع';

  @override
  String get ventesAudit => 'التدقيق';

  @override
  String get ventesCreePar => 'أنشئ بواسطة';

  @override
  String get ventesCreeLe => 'أنشئ في';

  @override
  String get ventesMotifAnnulation => 'سبب الإلغاء';

  @override
  String get ventesEmpreinte => 'البصمة الجبائية';

  @override
  String get ventesModifierTitre => 'تعديل السلة';

  @override
  String ventesModifierDescription(String code) {
    return '$code · لا يمكن تعديل الأسطر — استعمل الإرجاع.';
  }

  @override
  String get ventesClientScelle => 'زبون التذكرة المختومة: لزبون آخر، قم بإرجاع ثم بيع جديد.';

  @override
  String get ventesComplementIndice => 'سيسجل الفرق كدفعة مخصصة لهذه السلة.';

  @override
  String get ventesNoteInterne => 'ملاحظة داخلية';

  @override
  String get ventesModifie => 'تم تعديل السلة';

  @override
  String get ventesBloqueDejaAnnule => 'ملغى مسبقا';

  @override
  String get ventesBloqueRetour => 'يوجد إرجاع مرتبط بهذه السلة';

  @override
  String get ventesAnnulesTitre => 'السلال الملغاة';

  @override
  String get ventesAnnulesMessage => 'أعيد إدماج مخزون المنتجات وسُحبت المبالغ من الجلسة.';

  @override
  String ventesAnnulesPartiel(String detail, int ok) {
    return 'أُلغيت $ok سلة. فشل: $detail';
  }

  @override
  String get posErreurMotif => 'السبب إلزامي.';

  @override
  String posErreurMontantPaye(String montant) {
    return 'لا يمكن تخفيض المبلغ المدفوع (المدفوع: $montant). استعمل الإرجاع.';
  }

  @override
  String get posErreurRetourLie => 'يوجد إرجاع مرتبط بهذه السلة: الإلغاء غير ممكن.';

  @override
  String get retoursDescription => 'مرتجعات الزبائن (إعادة إلى المخزون، استرداد) ومرتجعات الموردين';

  @override
  String get retoursOngletClients => 'مرتجعات الزبائن';

  @override
  String get retoursOngletFournisseurs => 'مرتجعات الموردين';

  @override
  String get retoursKpiNombre => 'مرتجعات الفترة';

  @override
  String get retoursKpiQuantite => 'الكمية المرتجعة';

  @override
  String get retoursKpiRembourse => 'المبلغ المسترد';

  @override
  String get retoursKpiDeduit => 'مخصوم من الديون';

  @override
  String get retoursClient => 'الزبون';

  @override
  String get retoursFournisseur => 'المورد';

  @override
  String get retoursRemboursement => 'الاسترداد';

  @override
  String get retoursReglement => 'التسوية';

  @override
  String get retoursEtat => 'الحالة';

  @override
  String get retoursTous => 'الكل';

  @override
  String get retoursRecherche => 'الرمز، الطرف أو المنتج…';

  @override
  String get retoursOrigine => 'الأصل';

  @override
  String get retoursProduit => 'المنتج';

  @override
  String get retoursQte => 'الكمية';

  @override
  String get retoursMontant => 'المبلغ';

  @override
  String get retoursPrixAchat => 'سعر الشراء';

  @override
  String get retoursPrixVente => 'سعر البيع';

  @override
  String get retoursObservation => 'ملاحظة';

  @override
  String get retoursRegEspeces => 'نقدا';

  @override
  String get retoursRegCarte => 'بطاقة CIB';

  @override
  String get retoursRegAvoir => 'رصيد للزبون';

  @override
  String get retoursRegDeduit => 'مخصوم من الدين';

  @override
  String get retoursRegRembEspeces => 'استرداد نقدي';

  @override
  String get retoursModifierTitre => 'تعديل المرتجع';

  @override
  String get retoursChoixClient => 'مرتجع زبون';

  @override
  String get retoursChoixClientDesc => 'يعيد إلى المخزون، يسترد أو ينشئ رصيدا';

  @override
  String get retoursChoixFournisseur => 'مرتجع مورد';

  @override
  String get retoursChoixFournisseurDesc => 'يخرج من المخزون، يُخصم من دين المورد';

  @override
  String get retoursTicketOrigine => 'التذكرة الأصلية';

  @override
  String get retoursEntreeOrigine => 'الإدخال الأصلي';

  @override
  String get retoursChoisirClientIndice => 'اختر زبونا ≡';

  @override
  String get retoursChoisirFournisseurIndice => 'اختر موردا ≡';

  @override
  String get retoursChoisirPanierIndice => 'اختر سلة ≡';

  @override
  String get retoursChoisirEntreeIndice => 'اختر إدخالا ≡';

  @override
  String get retoursChoisirTicket => 'اختر التذكرة الأصلية';

  @override
  String get retoursChoisirEntree => 'اختر الإدخال الأصلي';

  @override
  String get retoursProduitIndice => 'منتج الوثيقة الأصلية';

  @override
  String get retoursProduitAideTicket => 'اختر التذكرة الأصلية أولا';

  @override
  String get retoursProduitAideEntree => 'اختر الإدخال الأصلي أولا';

  @override
  String retoursOptionVendu(String nom, String prix, String qte) {
    return '$nom — $qte مباعة بـ $prix';
  }

  @override
  String retoursOptionRecu(String nom, String prix, String qte) {
    return '$nom — $qte مستلمة بـ $prix';
  }

  @override
  String get retoursQuantite => 'الكمية';

  @override
  String retoursQuantiteMax(String maximum) {
    return 'الحد الأقصى: $maximum';
  }

  @override
  String retoursQuantiteDepasse(String maximum) {
    return 'الحد الأقصى $maximum (كمية الوثيقة الأصلية)';
  }

  @override
  String get retoursNumSerie => 'الرقم التسلسلي';

  @override
  String get retoursNumSerieIndice => 'إذا كان المنتج متتبعا';

  @override
  String get retoursRemiseStock => 'الإعادة إلى المخزون';

  @override
  String get retoursRemiseOui => 'نعم — منتج قابل لإعادة البيع';

  @override
  String get retoursRemiseNon => 'لا — معيب، إخراج «كسر»';

  @override
  String get retoursMotifIndice => 'سبب الإرجاع';

  @override
  String get retoursARembourser => 'يُسترد للزبون';

  @override
  String get retoursAvoirClient => 'رصيد في حساب الزبون';

  @override
  String get retoursADeduire => 'يُخصم من دين المورد';

  @override
  String get retoursRembourseFournisseur => 'يسترده المورد';

  @override
  String get retoursEnregistre => 'تم تسجيل المرتجع';

  @override
  String retoursEnregistreDetail(String code) {
    return '$code · تم تحديث المخزون';
  }

  @override
  String get retoursModifie => 'تم تعديل المرتجع';

  @override
  String get retoursAnnulesTitre => 'المرتجعات الملغاة';

  @override
  String get retoursAnnulesDetail => 'تمت استعادة المخزون';

  @override
  String get retoursEntite => 'مرتجع';

  @override
  String get retoursEntitePluriel => 'مرتجعات';

  @override
  String retoursDetailTitre(String code) {
    return 'المرتجع $code';
  }

  @override
  String get retoursPieceOrigine => 'الوثيقة الأصلية';

  @override
  String get retoursBloqueDejaAnnule => 'ملغى مسبقا';

  @override
  String get retoursAucun => 'لا توجد مرتجعات في هذه الفترة.';

  @override
  String get retourErreurDocumentInconnu => 'الوثيقة الأصلية غير موجودة.';

  @override
  String get retourErreurDocumentAnnule => 'الوثيقة الأصلية ملغاة.';

  @override
  String get retourErreurProduitAbsent => 'هذا المنتج غير موجود في الوثيقة الأصلية.';

  @override
  String get retourErreurReglement => 'تسوية غير صالحة (لا رصيد للزبون العابر).';

  @override
  String get retourErreurStock => 'مخزون غير كاف لهذا المرتجع.';

  @override
  String get retourErreurInconnu => 'المرتجع غير موجود.';

  @override
  String get retourErreurDejaAnnule => 'المرتجع ملغى مسبقا.';

  @override
  String get retourErreurMotif => 'السبب إلزامي.';

  @override
  String get achatErreurRetourLie => 'يوجد مرتجع مورد مرتبط بهذا الإدخال: الإلغاء غير ممكن.';

  @override
  String get posVentesDuJour => 'مبيعات اليوم';

  @override
  String get posRecetteProduit => 'إيراد المنتجات';

  @override
  String get posMasquerProduits => 'إخفاء المنتجات';

  @override
  String get posAfficherProduits => 'إظهار المنتجات';

  @override
  String get posParametres => 'إعدادات الصندوق';

  @override
  String get posScanIndice => 'امسح رمزًا شريطيًا أو ابحث…';

  @override
  String get posRecherche => 'بحث';

  @override
  String get posProduits => 'المنتجات';

  @override
  String get posPacks => 'الحزم';

  @override
  String get posAffichageGrille => 'عرض شبكي';

  @override
  String get posAffichageListe => 'عرض قائمة';

  @override
  String posVente(int n) {
    return 'بيع $n';
  }

  @override
  String get posVenteVide => 'فارغ';

  @override
  String posVenteMeta(String montant, String pieces) {
    return '$pieces قطعة · $montant';
  }

  @override
  String get posPanierTitre => 'السلة';

  @override
  String get posNouveauProduit => 'منتج جديد';

  @override
  String get posNouveauClient => 'زبون جديد';

  @override
  String get posViderPanier => 'إفراغ السلة (F10)';

  @override
  String get posClientLabel => 'الزبون';

  @override
  String get posModePaiement => 'طريقة الدفع';

  @override
  String get posChoisirRemise => 'اختيار تخفيض';

  @override
  String get posAucuneRemise => 'بدون تخفيض';

  @override
  String get posPanierVideTitre => 'السلة فارغة';

  @override
  String get posPanierVideDesc => 'امسح رمزًا شريطيًا أو المس منتجًا.';

  @override
  String get posLigneAide => 'نقر مزدوج: تعديل السعر · نقر على الطرد: تغيير الطرد';

  @override
  String get posEnregistrer => 'حفظ';

  @override
  String get posEncaisserBouton => 'تحصيل';

  @override
  String get posEncTicketTitre => 'تحصيل التذكرة';

  @override
  String get posEncSaveTitre => 'حفظ التذكرة';

  @override
  String get posEncTicketDesc => 'تحقق من المبلغ المستلم ثم أكّد: تُطبع التذكرة.';

  @override
  String get posEncSaveDesc => 'تُحفظ التذكرة: يُسجَّل الباقي دينًا على الزبون.';

  @override
  String get posEncTicketOk => 'تحصيل وطباعة';

  @override
  String get posInfoVente => 'البيع';

  @override
  String get posInfoDate => 'التاريخ';

  @override
  String get posInfoProduits => 'المنتجات';

  @override
  String get posInfoPieces => 'القطع';

  @override
  String get posInfoPaiement => 'الدفع';

  @override
  String get posInfoCaissier => 'أمين الصندوق';

  @override
  String posToastEncaisse(String code, String type) {
    return 'تم تحصيل $type $code';
  }

  @override
  String posToastEnregistre(String code) {
    return 'تم حفظ التذكرة $code';
  }

  @override
  String posToastResteCredit(String montant) {
    return 'الباقي دينًا: $montant';
  }

  @override
  String posToastRendu(String montant, String rendu) {
    return 'المجموع $montant · الباقي للزبون $rendu';
  }

  @override
  String get posReimprimer => 'إعادة الطباعة';

  @override
  String get posTicket => 'التذكرة';

  @override
  String get posSelTitre => 'الكمية والطرد';

  @override
  String get posSelTitreModif => 'تعديل الكمية والطرد';

  @override
  String posSelScanne(String code) {
    return 'منتج ممسوح · $code';
  }

  @override
  String posSelAuto(String detail, String secondes) {
    return 'إضافة تلقائية لـ $detail خلال $secondes ث · المس للتعديل';
  }

  @override
  String get posSelAutoAnnule => 'أُلغيت الإضافة التلقائية — أكّد بزر الإدخال';

  @override
  String posSelParPiece(String prix) {
    return '$prix / قطعة';
  }

  @override
  String posSelStock(String quantite) {
    return 'المخزون: $quantite قطعة';
  }

  @override
  String get posSelColis => 'الطرد';

  @override
  String get posSelUnite => 'بالوحدة';

  @override
  String posSelParColis(String nom, String quantite) {
    return '$nom ($quantite قطعة)';
  }

  @override
  String get posSelQuantite => 'الكمية';

  @override
  String get posSelPieces => 'القطع';

  @override
  String posSelStockInsuffisant(String quantite) {
    return 'مخزون غير كافٍ ($quantite قطعة)';
  }

  @override
  String posSelAjouter(String montant) {
    return 'إضافة · $montant';
  }

  @override
  String posSelModifier(String montant) {
    return 'تعديل · $montant';
  }

  @override
  String get posPrixTitre => 'تعديل سعر المنتج';

  @override
  String get posPrixDesc => 'مخصص للأدوار المرخصة — كلمة المرور مطلوبة.';

  @override
  String get posPrixAchat => 'سعر الشراء';

  @override
  String get posPrixVente => 'سعر البيع';

  @override
  String get posPrixMotDePasse => 'كلمة المرور';

  @override
  String get posPrixMotDePasseIndice => 'كلمة مرورك';

  @override
  String get posPrixPortee => 'النطاق';

  @override
  String get posPrixPorteeTicket => 'هذه التذكرة فقط';

  @override
  String get posPrixPorteeTicketDesc => 'لا يتغير سعر الكتالوج';

  @override
  String get posPrixPorteeProduit => 'المنتج بالكامل';

  @override
  String get posPrixPorteeProduitDesc => 'يحدّث سعر البيع';

  @override
  String get posPrixInvalide => 'سعر غير صالح';

  @override
  String get posPrixMdpRequis => 'كلمة المرور مطلوبة';

  @override
  String get posPrixMdpIncorrect => 'كلمة المرور غير صحيحة';

  @override
  String get posPrixSousAchat => 'أقل من سعر الشراء';

  @override
  String posPrixMarge(String montant) {
    return 'الهامش: $montant';
  }

  @override
  String get posPrixSousAchatTitre => 'البيع بأقل من سعر الشراء؟';

  @override
  String posPrixSousAchatMsg(String achat, String vente) {
    return 'سعر البيع $vente أقل من سعر الشراء $achat.';
  }

  @override
  String get posPrixSousAchatOk => 'البيع على أي حال';

  @override
  String get posPrixModifie => 'تم تعديل السعر';

  @override
  String posPrixModifieTicket(String nom) {
    return '$nom · هذه التذكرة فقط';
  }

  @override
  String posPrixModifieProduit(String nom) {
    return '$nom · تم تحديث سعر الكتالوج';
  }

  @override
  String get posRechTitre => 'البحث عن منتج';

  @override
  String get posRechDesc => 'صفِّ ثم حدد المنتجات لإضافتها إلى السلة.';

  @override
  String get posRechAjouter => 'إضافة إلى السلة';

  @override
  String get posRechIndice => 'الاسم أو الرمز أو الرمز الشريطي…';

  @override
  String posRechAjoutes(int n) {
    return 'تمت إضافة $n منتج';
  }

  @override
  String get posIntrouvableTitre => 'المنتج غير موجود';

  @override
  String get posIntrouvableDesc => 'لا يوجد منتج نشط يطابق هذا الرمز الشريطي.';

  @override
  String get posIntrouvableCreer => 'إنشاء المنتج';

  @override
  String get posFermeeTitre => 'لا توجد جلسة مفتوحة';

  @override
  String posFermeeDesc(String caisse) {
    return 'افتح جلسة لـ « $caisse » قبل البيع.';
  }

  @override
  String get posOuvrirCaisse => 'فتح الصندوق';

  @override
  String posOuvertureTitre(String caisse) {
    return 'فتح $caisse';
  }

  @override
  String get posOuvertureDesc => 'عُدّ رصيد الصندوق قبل البدء.';

  @override
  String get posOuvertureSolde => 'رصيد الافتتاح';

  @override
  String get posOuverturePar => 'فتحها';

  @override
  String get posOuvertureOk => 'فتح الجلسة';

  @override
  String get posCaisseOuverte => 'الصندوق مفتوح';

  @override
  String posCaisseOuverteDesc(String montant) {
    return 'رصيد الصندوق: $montant';
  }

  @override
  String posClotureTitre(String caisse) {
    return 'إقفال $caisse';
  }

  @override
  String posClotureDesc(String code, String heure) {
    return 'الجلسة $code · فُتحت على $heure';
  }

  @override
  String get posClotureFond => 'الرصيد الافتتاحي';

  @override
  String get posClotureTheorique => 'الرصيد النظري';

  @override
  String get posClotureReel => 'الرصيد الفعلي المعدود';

  @override
  String posClotureEcart(String etat) {
    return 'فارق الصندوق · $etat';
  }

  @override
  String get posClotureJuste => 'الصندوق مضبوط';

  @override
  String get posClotureExcedent => 'فائض';

  @override
  String get posClotureManquant => 'عجز';

  @override
  String get posClotureOk => 'إقفال الجلسة';

  @override
  String get posClotureFaite => 'تم إقفال الجلسة';

  @override
  String posClotureEcartToast(String montant) {
    return 'الفارق: $montant';
  }

  @override
  String get posMvtTitre => 'حركة يدوية';

  @override
  String get posMvtDesc => 'إدخال أو إخراج خارج البيع: إيداع، سحب، مصاريف متنوعة.';

  @override
  String get posMvtType => 'النوع';

  @override
  String get posMvtEntree => 'إدخال يدوي';

  @override
  String get posMvtSortie => 'إخراج يدوي';

  @override
  String get posMvtMotif => 'السبب';

  @override
  String get posMvtFait => 'تم تسجيل الحركة';

  @override
  String posMvtFaitDesc(String montant, String sens) {
    return '$sens بمبلغ $montant';
  }

  @override
  String posVdjTitre(String caisse) {
    return 'إيراد الصندوق — $caisse';
  }

  @override
  String posVdjDesc(String date) {
    return 'مبيعات $date';
  }

  @override
  String get posVdjIndice => 'رقم السلة أو الزبون…';

  @override
  String get posVdjNombre => 'عدد المبيعات';

  @override
  String get posVdjTotal => 'مجموع المبيعات';

  @override
  String get posVdjEncaisse => 'المحصَّل';

  @override
  String get posVdjReste => 'الباقي (دين)';

  @override
  String get posVdjAucune => 'لا توجد مبيعات';

  @override
  String get posVdjHeure => 'الساعة';

  @override
  String posRecTitre(String caisse) {
    return 'الإيراد حسب المنتج — $caisse';
  }

  @override
  String posRecDesc(String date) {
    return 'الأسطر المباعة يوم $date';
  }

  @override
  String get posRecIndice => 'المنتج أو الرمز أو السلة…';

  @override
  String get posRecLignes => 'الأسطر المباعة';

  @override
  String get posRecQuantite => 'الكمية';

  @override
  String get posRecAucune => 'لا توجد أسطر مباعة';

  @override
  String get posParamDesc => 'يُطبَّق على هذا الجهاز حتى تسجيل الخروج.';

  @override
  String get posParamMagasin => 'المخزن';

  @override
  String get posParamFait => 'تم حفظ الإعدادات';

  @override
  String posFermerVenteTitre(int n) {
    return 'إغلاق البيع $n؟';
  }

  @override
  String posFermerVenteMsg(String lignes) {
    return 'ستُترك السلة ($lignes سطر). حصّلها أو احفظها أولًا للاحتفاظ بها.';
  }

  @override
  String get posFermerVenteOk => 'إغلاق دون حفظ';

  @override
  String get produitErreurUtilise => 'هذا المنتج مستخدم (مبيعات أو مشتريات أو مخزون): لا يمكن حذفه.';

  @override
  String get catalogueErreurNomPris => 'هذا الاسم مستخدم بالفعل.';

  @override
  String get prdDescription => 'الكتالوج والفئات والتخفيضات والحزم';

  @override
  String get prdOngletSousCategories => 'الفئات الفرعية';

  @override
  String get prdAchat => 'الشراء';

  @override
  String get prdVente => 'البيع دون رسوم';

  @override
  String get prdMarge => 'الهامش';

  @override
  String get prdMarque => 'العلامة التجارية';

  @override
  String get prdMarqueIndice => 'مثال: إليو';

  @override
  String get prdDescriptionChamp => 'الوصف';

  @override
  String get prdTaille => 'المقاس';

  @override
  String get prdCouleur => 'اللون';

  @override
  String get prdRemise => 'التخفيض';

  @override
  String get prdService => 'خدمة';

  @override
  String prdEmballageN(int n) {
    return 'التغليف $n';
  }

  @override
  String prdPrixEmballageN(int n) {
    return 'سعر التغليف $n';
  }

  @override
  String prdEmballagePieces(int n) {
    return '$n قطعة';
  }

  @override
  String get prdNumeroSerie => 'الرقم التسلسلي';

  @override
  String get prdMultiCodes => 'رموز شريطية متعددة';

  @override
  String get prdPhotos => 'الصور';

  @override
  String get prdTva => 'الرسم على القيمة المضافة';

  @override
  String get prdDateExpiration => 'تاريخ انتهاء الصلاحية';

  @override
  String get prdEntiteProduits => 'منتجات';

  @override
  String get prdEntiteProduit => 'منتج';

  @override
  String get prdEntiteCategories => 'فئات';

  @override
  String get prdEntiteCategorie => 'فئة';

  @override
  String get prdEntiteSousCategories => 'فئات فرعية';

  @override
  String get prdEntiteSousCategorie => 'فئة فرعية';

  @override
  String get prdEntiteRemises => 'تخفيضات';

  @override
  String get prdEntiteRemise => 'تخفيض';

  @override
  String get prdEntitePacks => 'حزم';

  @override
  String get prdEntitePack => 'حزمة';

  @override
  String get prdKpiActifs => 'المنتجات النشطة';

  @override
  String get prdKpiValeurStock => 'قيمة المخزون';

  @override
  String get prdKpiSousSeuil => 'تحت الحد';

  @override
  String get prdKpiRupture => 'نفاد المخزون';

  @override
  String get prdToutes => 'الكل';

  @override
  String get prdDisponible => 'متوفر';

  @override
  String get prdRechercheProduits => 'الاسم أو الرمز أو الرمز الشريطي…';

  @override
  String get prdRechercheCategorie => 'البحث عن فئة…';

  @override
  String get prdRechercheSousCategorie => 'البحث عن فئة فرعية…';

  @override
  String get prdRechercheRemise => 'البحث عن تخفيض…';

  @override
  String get prdRecherchePack => 'البحث عن حزمة…';

  @override
  String get prdEtiquette => 'الملصق';

  @override
  String get prdEtiquettes => 'الملصقات';

  @override
  String get prdAffecter => 'تعيين';

  @override
  String get prdImporter => 'استيراد';

  @override
  String prdAchatMontant(String montant) {
    return 'الشراء $montant';
  }

  @override
  String prdStockN(String quantite) {
    return 'المخزون $quantite';
  }

  @override
  String prdMargeN(int n) {
    return 'الهامش $n %';
  }

  @override
  String get prdStatut => 'الحالة';

  @override
  String get prdTypeTaux => 'نوع النسبة';

  @override
  String get prdSeuilMontant => 'حد السلة';

  @override
  String get prdPack => 'الحزمة';

  @override
  String get prdComposants => 'المكونات';

  @override
  String get prdComposant => 'المكون';

  @override
  String get prdValeurSeparee => 'القيمة المنفصلة';

  @override
  String get prdPrixPack => 'سعر الحزمة';

  @override
  String get prdEconomie => 'التوفير';

  @override
  String get prdDisponibles => 'المتاحة';

  @override
  String get prdModeRapide => 'سريع';

  @override
  String get prdModeDetaille => 'مفصل · 3 مراحل';

  @override
  String get prdModeIa => 'ذكاء اصطناعي';

  @override
  String get prdEtape1 => 'الصور والتعريف والأسعار';

  @override
  String get prdEtape1Desc => 'الصور، الاسم، الرموز، الهامش';

  @override
  String get prdEtape2 => 'المخزون والتغليف';

  @override
  String get prdEtape2Desc => 'المخزن، الحد، العلبة، الكرتون';

  @override
  String get prdEtape3 => 'المتغيرات والخيارات';

  @override
  String get prdEtape3Desc => 'المقاسات، الألوان، الأرقام التسلسلية';

  @override
  String prdEtapeObligatoire(int n) {
    return 'المرحلة $n / 3 · * إلزامي';
  }

  @override
  String get prdObligatoire => '* إلزامي';

  @override
  String get prdEnregistrerNouveau => 'حفظ وجديد';

  @override
  String get prdSuivant => 'التالي';

  @override
  String get prdPrincipale => 'الرئيسية';

  @override
  String get prdPhotosFormat => 'JPG أو PNG · 4 كحد أقصى';

  @override
  String get prdPhotosFin => 'الأولى هي الصورة الرئيسية';

  @override
  String get prdIdentification => 'التعريف';

  @override
  String get prdCodeAuto => 'يُسند عند الحفظ';

  @override
  String get prdDesignationIndice => 'مثال: زيت إليو 1 ل';

  @override
  String get prdEanInvalide => 'رقم التحقق EAN-13 غير صالح';

  @override
  String get prdScannerOuSaisir => 'امسح أو أدخل';

  @override
  String get prdGenererEan => 'توليد EAN-13';

  @override
  String get prdFournisseur => 'المورد';

  @override
  String get prdPrix => 'الأسعار';

  @override
  String get prdSousAchat => 'أقل من سعر الشراء';

  @override
  String prdMargeUnitaire(String montant) {
    return 'الهامش للوحدة: $montant';
  }

  @override
  String get prdStockActuel => 'المخزون الحالي';

  @override
  String get prdStockInitial => 'المخزون الأولي';

  @override
  String get prdStockAide => 'يعدل عبر المدخلات / المخرجات';

  @override
  String get prdSeuilAlerte => 'حد التنبيه';

  @override
  String get prdEmballages => 'التغليف';

  @override
  String get prdEmballagesAide => 'الطرود المقترحة في الصندوق (نافذة الكمية والطرد): عدد القطع في الطرد وسعره.';

  @override
  String get prdBoite => 'علبة';

  @override
  String get prdCarton => 'كرتون';

  @override
  String get prdPcs => 'قطعة';

  @override
  String get prdVariantes => 'المتغيرات';

  @override
  String get prdTypeTaille => 'نوع المقاس';

  @override
  String get prdTailles => 'المقاسات';

  @override
  String get prdTaillesAide => 'اختر المقاسات المتوفرة';

  @override
  String prdTaillesN(int n) {
    return '$n مقاس(ات) محدد(ة)';
  }

  @override
  String get prdCouleurs => 'الألوان';

  @override
  String get prdCouleursAide => '16 لونا · يمكن اختيار عدة ألوان';

  @override
  String get prdOptions => 'الخيارات';

  @override
  String get prdCodesMultiples => 'رموز متعددة';

  @override
  String get prdCodesMultiplesAide => 'رموز شريطية أخرى يتعرف عليها الصندوق لهذا المنتج';

  @override
  String get prdAjouterCode => 'إضافة رمز';

  @override
  String get prdSuiviSerie => 'التتبع بالرقم التسلسلي';

  @override
  String get prdSuiviSerieAide => 'إدخال إلزامي عند البيع';

  @override
  String get prdServiceSansStock => 'خدمة (بدون مخزون)';

  @override
  String get prdServiceAide => 'تصليح، توصيل، يد عاملة';

  @override
  String get prdExpirationAide => 'تنبيه قبل انتهاء الصلاحية';

  @override
  String get prdNoteInterne => 'ملاحظة داخلية';

  @override
  String get prdToastEnregistre => 'تم حفظ المنتج';

  @override
  String get prdToastModifie => 'تم تعديل المنتج';

  @override
  String prdToastAjoute(String code) {
    return '$code · أضيف إلى الكتالوج';
  }

  @override
  String get prdModifierCategorie => 'تعديل الفئة';

  @override
  String get prdModifierSousCategorie => 'تعديل الفئة الفرعية';

  @override
  String get prdCategorieParente => 'الفئة الأم';

  @override
  String get prdCategorieExiste => 'هذه الفئة موجودة مسبقا';

  @override
  String get prdSousCategorieExiste => 'هذه الفئة الفرعية موجودة مسبقا';

  @override
  String get prdCategorieIndice => 'مثال: بقالة';

  @override
  String get prdSousCategorieIndice => 'مثال: زيوت';

  @override
  String get prdVisibleCaisse => 'ظاهر في الصندوق';

  @override
  String get prdToastCategorie => 'تم حفظ الفئة';

  @override
  String get prdToastSousCategorie => 'تم حفظ الفئة الفرعية';

  @override
  String get prdInformations => 'المعلومات';

  @override
  String prdNProduits(int n) {
    return '$n منتج(ات)';
  }

  @override
  String prdNComposants(int n) {
    return '$n مكون(ات)';
  }

  @override
  String get prdPorteeProduit => 'حسب المنتج';

  @override
  String get prdPorteeMontant => 'حسب المبلغ (السلة)';

  @override
  String get prdProgrammee => 'مبرمج';

  @override
  String get prdModifierRemise => 'تعديل التخفيض';

  @override
  String get prdRemiseDescription => 'يطبق التخفيض تلقائيا في الصندوق خلال فترته.';

  @override
  String get prdProduitsConcernes => 'المنتجات المعنية';

  @override
  String get prdRemiseAccordee => 'التخفيض الممنوح';

  @override
  String get prdPrixNormal => 'السعر العادي';

  @override
  String get prdPrixRemise => 'السعر بعد التخفيض';

  @override
  String get prdRemiseNomIndice => 'مثال: نهاية السلسلة';

  @override
  String get prdPourcentageAide => 'مثال: −10 % من السعر';

  @override
  String get prdMontantFixe => 'مبلغ ثابت';

  @override
  String prdMontantFixeAide(String devise) {
    return 'مثال: −50 $devise لكل سلعة';
  }

  @override
  String get prdSeuilAide => 'يتفعل التخفيض عندما يبلغ المجموع الفرعي هذا المبلغ';

  @override
  String get prdToastRemise => 'تم حفظ التخفيض';

  @override
  String get prdToastRemiseDesc => 'يطبق في الصندوق خلال فترته';

  @override
  String get prdVentesRemisees => 'المبيعات المخفضة';

  @override
  String get prdModifierPack => 'تعديل الحزمة';

  @override
  String get prdPackDescription => 'تباع الحزمة كسلعة واحدة وتخصم كل مكون من المخزون.';

  @override
  String get prdEnregistrerPack => 'حفظ الحزمة';

  @override
  String get prdComposantsPack => 'مكونات الحزمة';

  @override
  String get prdQteParPack => 'الكمية / حزمة';

  @override
  String get prdPrixUnitaire => 'سعر الوحدة';

  @override
  String get prdOptionnel => 'اختياري';

  @override
  String get prdNomPack => 'اسم الحزمة';

  @override
  String get prdPackNomIndice => 'مثال: حزمة الفطور';

  @override
  String get prdPacksPossibles => 'الحزم الممكنة';

  @override
  String get prdPacksPossiblesAide => 'حسب مخزون المكون الأكثر محدودية';

  @override
  String get prdEconomieClient => 'توفير للزبون';

  @override
  String get prdPackPlusCher => 'الحزمة أغلى من مكوناتها';

  @override
  String prdValeurSepareeMontant(String montant) {
    return 'القيمة المنفصلة $montant';
  }

  @override
  String get prdToastPack => 'تم حفظ الحزمة';

  @override
  String get prdValeur => 'القيمة';

  @override
  String get prdStockTotal => 'المخزون الإجمالي';

  @override
  String get prdPrixMoyenAchat => 'متوسط سعر الشراء';

  @override
  String get prdVendus30 => 'المباع (30 يوما)';

  @override
  String get prdStockParMagasin => 'المخزون حسب المخزن';

  @override
  String get prdDerniersMouvements => 'آخر الحركات';

  @override
  String get prdReference => 'المرجع';

  @override
  String get prdCodeBarreTitre => 'الرمز الشريطي والملصقات';

  @override
  String get prdEanAide => 'معيار تجاري — البادئة 613 (الجزائر)';

  @override
  String get prdCodeInterne => 'رمز داخلي';

  @override
  String get prdCodeInterneAide => 'للمنتجات بدون رمز المصنع';

  @override
  String get prdFormat => 'الصيغة';

  @override
  String get prdFormatA4 => 'A4 · 3 × 8 (38 × 21 مم)';

  @override
  String get prdFormatRouleau40 => 'لفافة 40 × 30 مم';

  @override
  String get prdFormatRouleau58 => 'لفافة 58 مم';

  @override
  String prdImprimerEtiquettes(int n) {
    return 'طباعة $n ملصق(ات)';
  }

  @override
  String prdAffecterN(int n) {
    return 'تعيين $n منتج(ات)';
  }

  @override
  String get prdRemplacerAffectation => 'استبدال التعيين الحالي';

  @override
  String get prdRemplacerPackAide => 'وإلا يضاف المنتج إلى الحزمة بكمية 1';

  @override
  String get prdRemplacerCategorieAide => 'وإلا تعدل المنتجات بدون فئة فقط';

  @override
  String get prdRemplacerRemiseAide => 'وإلا تعدل المنتجات بدون تخفيض فقط';

  @override
  String get prdToastAffectation => 'تم حفظ التعيين';

  @override
  String prdToastAffectationDesc(int n, String nom) {
    return '$n منتج(ات) · $nom';
  }

  @override
  String get prdSuppressionBloquee => 'مخزون أو حركات مرتبطة — عطله بدلا من ذلك';

  @override
  String prdToastSupprimes(int n) {
    return 'تم حذف $n منتج(ات)';
  }

  @override
  String prdToastRefuses(int n) {
    return '$n مرفوض(ة): حركات مرتبطة';
  }

  @override
  String get prdImportFichier => 'الملف';

  @override
  String get prdImportFichierDesc => '.xlsx';

  @override
  String get prdImportColonnes => 'الأعمدة';

  @override
  String get prdImportColonnesDesc => 'المطابقة';

  @override
  String get prdImportApercuDesc => 'المراقبة';

  @override
  String prdImportInfos(int n, int total) {
    return '$n عمود(أعمدة) · $total ك.ب';
  }

  @override
  String get prdChangerFichier => 'تغيير الملف';

  @override
  String get prdTelechargerModele => 'تنزيل النموذج';

  @override
  String prdColonneN(String lettre, String nom) {
    return 'العمود $lettre · $nom';
  }

  @override
  String get prdIgnorer => '— تجاهل —';

  @override
  String get prdImportDesignationRequise => 'اربط عمودا بالتسمية.';

  @override
  String get prdGenere => '— مولد —';

  @override
  String get prdControle => 'المراقبة';

  @override
  String prdImporterN(int n) {
    return 'استيراد $n منتج(ات)';
  }

  @override
  String get prdImportTermine => 'انتهى الاستيراد';

  @override
  String get stkACommander => 'للطلب';

  @override
  String get stkAReapprovisionner => 'للتموين';

  @override
  String get stkAdresse => 'العنوان';

  @override
  String get stkArticles => 'المواد';

  @override
  String get stkAucun => 'لا أحد';

  @override
  String get stkAucunChangement => 'لا تغيير';

  @override
  String get stkAucunExpire => 'لا توجد منتجات منتهية أو قريبة من الانتهاء.';

  @override
  String get stkAucunTransfert => 'لا توجد تحويلات في هذه الفترة.';

  @override
  String get stkAucuneListe => 'لا توجد قوائم احتياجات في هذه الفترة.';

  @override
  String get stkAucuneRupture => 'لا توجد منتجات تحت الحد.';

  @override
  String get stkAucuneSortie => 'لا توجد إخراجات في هذه الفترة.';

  @override
  String get stkAudit => 'التدقيق';

  @override
  String get stkBloqueBesoinRecu => 'تم استلامها كمدخل';

  @override
  String get stkBloqueDejaAnnule => 'ملغى مسبقًا';

  @override
  String get stkBloqueDejaAnnulee => 'ملغاة مسبقًا';

  @override
  String get stkBloqueDejaInactif => 'غير نشط مسبقًا';

  @override
  String get stkBloqueMagasinPrincipal => 'المخزن الرئيسي لمستخدم';

  @override
  String get stkBloqueStockNonNul => 'المخزون غير معدوم — حوّله أولاً';

  @override
  String get stkCaisses => 'الصناديق';

  @override
  String get stkChoisirFournisseur => 'اختر موردًا';

  @override
  String get stkCreerListe => 'إنشاء قائمة احتياجات';

  @override
  String get stkDepuis => 'من';

  @override
  String get stkDesactiver => 'تعطيل';

  @override
  String get stkDescriptionBesoins => 'التموين: قوائم الموردين، النفاد والمنتجات المنتهية';

  @override
  String get stkDescriptionMagasins => 'نقاط المخزون، التحويلات والارتباطات';

  @override
  String get stkDescriptionSorties => 'إخراجات المخزون خارج البيع: كسر، منتهي، ضياع، استهلاك داخلي، هبة';

  @override
  String stkDescriptionStock(int n) {
    return 'الكميات حسب المخزن · $n مخازن نشطة';
  }

  @override
  String get stkDispoSource => 'الكمية (من)';

  @override
  String stkDisponible(String quantite) {
    return 'المتاح: $quantite';
  }

  @override
  String get stkDisponibleEtat => 'متوفر';

  @override
  String get stkDistribuer => 'توزيع';

  @override
  String stkDistribuerDescription(String nom, String quantite) {
    return '$nom · $quantite قطعة للتوزيع بين المخازن';
  }

  @override
  String get stkDistribuerTitre => 'توزيع المخزون';

  @override
  String get stkEnStock => 'في المخزون';

  @override
  String get stkEnregistrerListe => 'حفظ القائمة';

  @override
  String get stkEntiteListe => 'قائمة';

  @override
  String get stkEntiteListes => 'قوائم';

  @override
  String get stkEntiteMagasin => 'مخزن';

  @override
  String get stkEntiteMagasins => 'مخازن';

  @override
  String get stkEntiteMouvements => 'حركات';

  @override
  String get stkEntiteSortie => 'إخراج';

  @override
  String get stkEntiteSorties => 'إخراجات';

  @override
  String get stkEntiteTransfert => 'تحويل';

  @override
  String get stkEntiteTransferts => 'تحويلات';

  @override
  String get stkErreurDocumentInconnu => 'المستند غير موجود.';

  @override
  String get stkErreurFournisseur => 'اختر موردًا.';

  @override
  String get stkErreurMotifObligatoire => 'السبب إلزامي.';

  @override
  String get stkErreurNomPris => 'يوجد مخزن بهذا الاسم.';

  @override
  String get stkExpiration => 'انتهاء الصلاحية';

  @override
  String stkExpireDepuis(int jours) {
    return 'منتهي منذ $jours ي';
  }

  @override
  String stkJMoins(int jours) {
    return 'ي−$jours';
  }

  @override
  String get stkJours => 'الأيام';

  @override
  String get stkKpiArticlesSortis => 'المواد المخرجة';

  @override
  String get stkKpiCoutReassort => 'تكلفة التموين المقدرة';

  @override
  String get stkKpiEnRupture => 'نفد';

  @override
  String get stkKpiMagasinsActifs => 'المخازن النشطة';

  @override
  String get stkKpiSorties => 'إخراجات الفترة';

  @override
  String get stkKpiSousSeuil => 'تحت الحد';

  @override
  String get stkKpiUtilisateursRattaches => 'المستخدمون المرتبطون';

  @override
  String get stkKpiValeurPerdue => 'القيمة المفقودة';

  @override
  String get stkKpiValeurTotale => 'القيمة الإجمالية للمخزون';

  @override
  String get stkListeDescription => 'الكميات المقترحة = 2 × الحد − المخزون. عدّلها قبل الإرسال للمورد.';

  @override
  String stkListeTitre(String code) {
    return 'القائمة $code';
  }

  @override
  String get stkLivraison => 'التسليم المطلوب';

  @override
  String get stkMagasin => 'المخزن';

  @override
  String get stkMagasinDescription => 'لكل مخزن مخزونه؛ ترتبط به الصناديق والمستخدمون.';

  @override
  String get stkMagasinDifferent => 'اختر مخزنًا مختلفًا';

  @override
  String get stkModifierListe => 'تعديل قائمة الاحتياجات';

  @override
  String get stkModifierMagasin => 'تعديل المخزن';

  @override
  String get stkModifierSortie => 'تعديل الإخراج';

  @override
  String get stkModifierTransfert => 'تعديل التحويل';

  @override
  String get stkMontantEstime => 'المبلغ المقدر';

  @override
  String get stkMotif => 'السبب';

  @override
  String get stkMotifDistributionIndice => 'مثال: تموين المحل';

  @override
  String get stkMotifSortieIndice => 'مثال: سقوط كرتون أثناء الترتيب';

  @override
  String get stkMouvementsRecents => 'الحركات الأخيرة';

  @override
  String get stkNom => 'الاسم';

  @override
  String get stkNomMagasinIndice => 'مثال: محل حيدرة';

  @override
  String get stkNouveauMagasin => 'مخزن جديد';

  @override
  String get stkNouveauTransfert => 'تحويل جديد';

  @override
  String get stkNouvelleListe => 'قائمة جديدة';

  @override
  String get stkNouvelleSortie => 'إخراج جديد';

  @override
  String get stkObservationTransfertIndice => 'مثال: تموين أسبوعي';

  @override
  String get stkOngletExpires => 'المنتهية';

  @override
  String get stkOngletListes => 'قوائم الاحتياجات';

  @override
  String get stkOngletMagasins => 'المخازن';

  @override
  String get stkOngletMouvements => 'الحركات';

  @override
  String get stkOngletRuptures => 'النفاد والحدود';

  @override
  String get stkOngletTransferts => 'التحويلات';

  @override
  String get stkPalierAvance => 'المستوى المتقدم';

  @override
  String get stkPcs => 'قطعة';

  @override
  String get stkPdfFournisseur => 'PDF للمورد';

  @override
  String get stkPrincipal => 'رئيسي';

  @override
  String get stkPrixEstime => 'السعر المقدر';

  @override
  String get stkProduitsEnStock => 'المنتجات في المخزون';

  @override
  String get stkProduitsSortis => 'المنتجات المخرجة';

  @override
  String get stkProduitsTransferes => 'المنتجات المحولة';

  @override
  String get stkQte => 'الكمية';

  @override
  String get stkQuantiteTotale => 'الكمية الإجمالية';

  @override
  String get stkRechercheMouvement => 'المرجع أو المنتج…';

  @override
  String get stkReference => 'المرجع';

  @override
  String get stkReparti => 'موزع';

  @override
  String get stkRepartirEgalement => 'توزيع بالتساوي';

  @override
  String get stkRepartition => 'التوزيع حسب المخزن';

  @override
  String get stkResponsable => 'المسؤول';

  @override
  String get stkReste => 'الباقي';

  @override
  String get stkRestePrincipal => 'الباقي للرئيسي';

  @override
  String get stkRetourFournisseur => 'إرجاع للمورد';

  @override
  String get stkSeuilAlerte => 'حد التنبيه';

  @override
  String get stkSortieDescription => 'إخراج من المخزون خارج البيع — مقيم بسعر الشراء.';

  @override
  String get stkSortiePerime => 'إخراج «منتهي الصلاحية»';

  @override
  String stkSortieTitre(String code) {
    return 'الإخراج $code';
  }

  @override
  String get stkSousSeuilEtat => 'تحت الحد';

  @override
  String get stkStatut => 'الحالة';

  @override
  String stkStockDispo(String quantite) {
    return 'المخزون: $quantite';
  }

  @override
  String get stkStockDuMagasin => 'مخزون المخزن';

  @override
  String get stkStockTotal => 'المخزون الإجمالي';

  @override
  String get stkSuggestion => 'الاقتراح';

  @override
  String get stkTelephone => 'الهاتف';

  @override
  String get stkToastDistribue => 'تم توزيع المخزون';

  @override
  String get stkToastListe => 'تم حفظ القائمة';

  @override
  String stkToastListeDesc(String code) {
    return '$code · جاهزة للإرسال';
  }

  @override
  String get stkToastListesAnnulees => 'تم إلغاء القوائم';

  @override
  String get stkToastMagasin => 'تم حفظ المخزن';

  @override
  String get stkToastMagasinsDesactives => 'تم تعطيل المخازن';

  @override
  String get stkToastSortie => 'تم حفظ الإخراج';

  @override
  String get stkToastSortiesAnnulees => 'تم إلغاء الإخراجات';

  @override
  String get stkToastStockAJour => 'تم تحديث المخزون';

  @override
  String get stkToastStockReintegre => 'تمت إعادة المخزون';

  @override
  String get stkToastTransfert => 'تم اعتماد التحويل';

  @override
  String get stkToastTransfertsAnnules => 'تم إلغاء التحويلات';

  @override
  String get stkToutPrincipal => 'الكل للرئيسي';

  @override
  String stkTransfererPieces(String quantite) {
    return 'تحويل $quantite قطعة';
  }

  @override
  String get stkTransfertDescription => 'نقل المخزون من مخزن إلى آخر.';

  @override
  String stkTransfertTitre(String code) {
    return 'التحويل $code';
  }

  @override
  String get stkUtilisateurs => 'المستخدمون';

  @override
  String get stkUtilisateursCaisses => 'المستخدمون والصناديق';

  @override
  String get stkValeurAchat => 'قيمة الشراء';

  @override
  String get stkValeurStock => 'قيمة المخزون';

  @override
  String get stkValeurVente => 'قيمة البيع';

  @override
  String get stkValideLe => 'تاريخ الاعتماد';

  @override
  String get stkValiderTransfert => 'اعتماد التحويل';

  @override
  String get stkVers => 'إلى';

  @override
  String get stkVoirMouvements => 'عرض الحركات';

  @override
  String get stkVoirPiece => 'عرض المستند';

  @override
  String get entAucunBon => 'لا توجد وصولات مستلمة.';

  @override
  String get entAucunFournisseur => 'بدون (شراء نقدي)';

  @override
  String get entAucunProduit => 'امسح أو أضف المنتجات المستلمة.';

  @override
  String get entBloqueDejaAnnulee => 'ملغاة مسبقا';

  @override
  String get entBloqueVendus => 'تم بيع بعض المنتجات';

  @override
  String get entBonReception => 'وصل الاستلام';

  @override
  String get entChoisirProduit => 'اختر منتجا';

  @override
  String get entDescription => 'استلامات الموردين — مسح، قراءة الوصولات بالذكاء الاصطناعي، إدخال سريع';

  @override
  String get entEntite => 'إدخال';

  @override
  String get entEntiteBon => 'وصل';

  @override
  String get entEntiteBons => 'وصولات';

  @override
  String get entEntitePluriel => 'إدخالات';

  @override
  String get entEntreeLiee => 'الإدخال المرتبط';

  @override
  String get entErreurBonInconnu => 'وصل الاستلام غير موجود.';

  @override
  String get entErreurBonTraite => 'وصل معالج مسبقا';

  @override
  String get entErreurMotif => 'السبب إلزامي.';

  @override
  String get entEtapeBon => 'الوصل والمورد';

  @override
  String get entEtapeBonDetail => 'الرأسية، الدفع';

  @override
  String get entEtapeProduits => 'المنتجات المستلمة';

  @override
  String get entEtapeProduitsDetail => 'المسح والكميات';

  @override
  String get entFichier => 'الملف';

  @override
  String get entFournisseurDetecte => 'المورد المكتشف';

  @override
  String get entIaAnalyser => 'تحليل الوصل';

  @override
  String get entIaApercu => 'معاينة الوصل';

  @override
  String get entIaAucunFichier => 'لم يتم اختيار ملف';

  @override
  String get entIaBandeauDetail => 'تصل الوصولات المرسلة من الهاتف هنا بحالة « مستلم ».';

  @override
  String get entIaBandeauTitre => 'صوّر الوصل، والذكاء الاصطناعي يملأ الإدخال';

  @override
  String get entIaConfiance => 'الثقة';

  @override
  String get entIaDepuisDisque => 'من القرص';

  @override
  String get entIaDepuisTelephone => 'من الهاتف';

  @override
  String get entIaDescription => 'صورة أو PDF لفاتورة المورد: تُكتشف الأسطر ثم تُطابق مع الكتالوج.';

  @override
  String get entIaDetecte => 'مكتشف في الوصل';

  @override
  String get entIaEtapeFournisseur => 'المورد والدفع';

  @override
  String get entIaEtapeFournisseurDetail => 'تأكيد';

  @override
  String get entIaEtapeLignes => 'الأسطر المكتشفة';

  @override
  String get entIaEtapeLignesDetail => 'التحقق والمطابقة';

  @override
  String get entIaEtapePhoto => 'صورة الوصل';

  @override
  String get entIaEtapePhotoDetail => 'صورة أو PDF';

  @override
  String get entIaFormats => 'JPG أو PNG أو PDF';

  @override
  String get entIaJoindre => 'إرفاق وصل';

  @override
  String get entIaLecture => 'جارٍ قراءة الوصل…';

  @override
  String get entIaLectureDetail => 'اكتشاف الأسطر والكميات والأسعار';

  @override
  String get entIaLignes => 'الأسطر';

  @override
  String get entIaLignesLues => 'الأسطر المقروءة';

  @override
  String get entIaLu => 'مقروء في الوصل';

  @override
  String get entIaProduitCatalogue => 'منتج الكتالوج';

  @override
  String get entIaRapprocher => 'مطابقة…';

  @override
  String get entIaRecuPar => 'استلمه';

  @override
  String get entIaRemplacer => 'استبدال المنتج';

  @override
  String get entIaTelephoneAide => 'تظهر الوصولات المرسلة من تطبيق الهاتف في قائمة وضع الذكاء الاصطناعي.';

  @override
  String get entIaTitre => 'وصل ذكي · قراءة آلية للوصل';

  @override
  String get entIaTraitePar => 'عالجه';

  @override
  String get entIaTraiter => 'معالجة';

  @override
  String get entIaVideAide => 'أرفق وصلا (صورة أو PDF) ليحضّر الذكاء الاصطناعي الإدخال.';

  @override
  String get entIaVoirBon => 'عرض الوصل';

  @override
  String get entImprimer => 'طباعة';

  @override
  String get entInformations => 'معلومات';

  @override
  String get entKpiEntrees => 'إدخالات الشهر';

  @override
  String get entListe => 'القائمة';

  @override
  String get entListeBesoins => 'قائمة الاحتياجات';

  @override
  String get entMagasinAide => 'افتراضيا: متجرك الرئيسي';

  @override
  String get entMajDernier => 'آخر سعر شراء';

  @override
  String get entMajGarder => 'الإبقاء على سعر الشراء الحالي';

  @override
  String get entMajMoyen => 'السعر المتوسط المرجح';

  @override
  String get entMajPrix => 'تحديث السعر';

  @override
  String get entMode => 'الطريقة';

  @override
  String get entModifierTitre => 'تعديل الإدخال';

  @override
  String get entMontantPaye => 'المبلغ المدفوع';

  @override
  String get entNbVersements => 'عدد الدفعات';

  @override
  String get entNouvelleDescription => 'امسح المنتجات المستلمة: كل مسح يضيف 1 إلى الكمية.';

  @override
  String get entNouvelleTitre => 'إدخال جديد · Smart Scan';

  @override
  String get entNumFacture => 'رقم الفاتورة / وصل التسليم';

  @override
  String get entNumFactureIndice => 'مثال FAC-24-1187';

  @override
  String get entOffreMessage => 'أرغب في زيادة حصة Smart Scan.';

  @override
  String get entOngletIa => 'وضع الذكاء الاصطناعي';

  @override
  String get entPaiement => 'الدفع';

  @override
  String get entPaye => 'مدفوع';

  @override
  String get entPayeTotalite => 'مدفوع بالكامل';

  @override
  String get entProduitsRecus => 'المنتجات المستلمة';

  @override
  String get entQteRecue => 'الكمية المستلمة';

  @override
  String get entRapideDescription => 'استلام منتج واحد دون وصل مورد مفصل.';

  @override
  String get entRapideTitre => 'إدخال سريع';

  @override
  String get entRecherche => 'الرمز أو المورد أو رقم الفاتورة…';

  @override
  String get entRechercheBons => 'الملف أو المورد…';

  @override
  String get entRecuLe => 'تاريخ الاستلام';

  @override
  String get entRepartitionIncomplete => 'توزيع غير مكتمل';

  @override
  String get entRepartitionOption => 'التوزيع (اختياري)';

  @override
  String get entResteAide => 'يضاف إلى دين المورد';

  @override
  String get entResteCredit => 'الباقي (دين)';

  @override
  String get entRetour => 'رجوع';

  @override
  String get entScanAjoute => 'أضيف';

  @override
  String get entScanIndice => 'امسح الرمز الشريطي ثم Entrée (أو رمز المنتج)…';

  @override
  String get entSourceIa => 'وصل ذكي';

  @override
  String get entSourceRapide => 'إدخال سريع';

  @override
  String get entSuivant => 'التالي';

  @override
  String get entToastAnnulees => 'تم إلغاء الإدخالات';

  @override
  String get entToastAnnuleesDetail => 'تم تصحيح المخزون ودين المورد';

  @override
  String get entToastBonsSupprimes => 'تم حذف الوصولات';

  @override
  String get entToastDepuisBon => 'تم إنشاء الإدخال من الوصل';

  @override
  String get entToastEnregistree => 'تم تسجيل الإدخال';

  @override
  String get entToastModifiee => 'تم تعديل الإدخال';

  @override
  String get entToastRapide => 'تم تسجيل الإدخال السريع';

  @override
  String get entToastReparti => 'تم توزيع المخزون بين المتاجر';

  @override
  String get entVenteSousAchat => 'سعر البيع ≤ سعر الشراء';

  @override
  String entCreerProduit(String nom) {
    return '+ إنشاء « $nom »';
  }

  @override
  String entDepuisListe(String code) {
    return 'استلام قائمة الاحتياجات $code';
  }

  @override
  String entDetailTitre(String code) {
    return 'إدخال $code';
  }

  @override
  String entIaARapprocher(int n) {
    return '$n سطر(أسطر) للمطابقة';
  }

  @override
  String entIaCreer(String montant) {
    return 'إنشاء الإدخال · $montant';
  }

  @override
  String entValider(String montant) {
    return 'تأكيد الإدخال · $montant';
  }

  @override
  String entRapideDescriptionProduit(String code, String stock) {
    return '$code · المخزون الحالي $stock قطعة — استلام دون وصل مفصل.';
  }

  @override
  String entRapideTitreProduit(String nom) {
    return 'إدخال سريع · $nom';
  }

  @override
  String entScanInconnu(String code) {
    return 'رمز غير معروف: $code';
  }

  @override
  String entToastBonsDetail(int n) {
    return '$n ملف(ات)';
  }

  @override
  String get entCreerEntree => 'إنشاء الإدخال';

  @override
  String get statutErreur => 'خطأ';

  @override
  String get gcDescription => 'الصناديق، التحويلات، إقفالات Z، الحركات والجلسات';

  @override
  String get gcOngletCaisses => 'الصناديق';

  @override
  String get gcOngletTransferts => 'التحويلات';

  @override
  String get gcOngletClotures => 'إقفالات Z';

  @override
  String get gcOngletMouvements => 'الحركات';

  @override
  String get gcOngletSessions => 'الجلسات';

  @override
  String get gcEntiteCaisse => 'صندوق';

  @override
  String get gcEntiteCaisses => 'صناديق';

  @override
  String get gcEntiteTransfert => 'تحويل';

  @override
  String get gcEntiteTransferts => 'تحويلات';

  @override
  String get gcEntiteClotures => 'إقفالات';

  @override
  String get gcEntiteMouvements => 'حركات';

  @override
  String get gcEntiteSessions => 'جلسات';

  @override
  String get gcColCaisse => 'الصندوق';

  @override
  String get gcColSoldeInitial => 'الرصيد الأولي';

  @override
  String get gcColSoldeActuel => 'الرصيد الحالي';

  @override
  String get gcColSession => 'الجلسة';

  @override
  String get gcColEtat => 'الحالة';

  @override
  String get gcColStatut => 'الوضعية';

  @override
  String get gcColDepuis => 'من';

  @override
  String get gcColVers => 'إلى';

  @override
  String get gcColTickets => 'التذاكر';

  @override
  String get gcColAnnules => 'الملغاة';

  @override
  String get gcColTotalAnnule => 'الملغى';

  @override
  String get gcColPar => 'بواسطة';

  @override
  String get gcColEmpreinte => 'البصمة';

  @override
  String get gcColCreeLe => 'أنشئ في';

  @override
  String get gcColReference => 'المرجع';

  @override
  String get gcColEntree => 'دخول';

  @override
  String get gcColSortie => 'خروج';

  @override
  String get gcColUtilisateur => 'المستخدم';

  @override
  String get gcColMode => 'الطريقة';

  @override
  String get gcColOuverture => 'الافتتاح';

  @override
  String get gcColCloture => 'الإقفال';

  @override
  String get gcColFond => 'الرصيد الافتتاحي';

  @override
  String get gcColTheorique => 'النظري';

  @override
  String get gcColReel => 'الفعلي';

  @override
  String get gcColEcart => 'الفرق';

  @override
  String get gcColOuvertePar => 'افتتحها';

  @override
  String get gcToutesCaisses => 'كل الصناديق';

  @override
  String get gcRechercheCaisses => 'ابحث عن صندوق…';

  @override
  String get gcRechercheTransferts => 'ابحث عن تحويل…';

  @override
  String get gcRechercheClotures => 'ابحث عن إقفال…';

  @override
  String get gcRechercheMouvements => 'ابحث عن حركة…';

  @override
  String get gcRechercheSessions => 'ابحث عن جلسة…';

  @override
  String get gcAucuneSession => 'لا توجد جلسات.';

  @override
  String get gcExportFiscal => 'تصدير للمراقبة الجبائية';

  @override
  String get gcNouvelleClotureZ => 'إقفال Z جديد';

  @override
  String get gcMouvementManuel => 'حركة يدوية';

  @override
  String get gcVoirMouvements => 'عرض الحركات';

  @override
  String get gcCloturer => 'إقفال';

  @override
  String get gcOuvrirSession => 'فتح جلسة';

  @override
  String get gcFormDescription => 'لكل صندوق (درج، خزنة) رصيده وجلساته.';

  @override
  String get gcFormNomIndice => 'مثال: الصندوق 3';

  @override
  String get gcFormSoldeInitialAide => 'يُقترح كرصيد افتتاحي عند كل فتح';

  @override
  String get gcCaisseEnregistree => 'تم حفظ الصندوق';

  @override
  String get gcSessions30j => 'الجلسات (30 يوماً)';

  @override
  String get gcEcartCumule => 'الفرق التراكمي';

  @override
  String get gcDernieresSessions => 'آخر الجلسات';

  @override
  String get gcBloqueSession => 'جلسة مفتوحة — أقفلها أولاً';

  @override
  String get gcBloqueSolde => 'رصيد غير صفري — حوّله أولاً';

  @override
  String get gcBloqueSysteme => 'الصندوق الرئيسي';

  @override
  String get gcBloqueInactive => 'معطل مسبقاً';

  @override
  String get gcErreurSoldeNonNul => 'يجب أن يكون رصيد الصندوق صفراً: حوّله أولاً.';

  @override
  String get gcToastDesactivees => 'تم تعطيل الصناديق';

  @override
  String get gcTrfTitre => 'تحويل بين الصناديق';

  @override
  String get gcTrfDescription => 'مثال: إيداع مداخيل اليوم في الخزنة في نهاية اليوم.';

  @override
  String gcTrfDisponible(String montant) {
    return 'الرصيد المتاح: $montant';
  }

  @override
  String get gcTrfMemeCaisse => 'اختر صندوقاً مختلفاً';

  @override
  String gcTrfSuperieur(String caisse) {
    return 'أكبر من رصيد $caisse';
  }

  @override
  String get gcTrfMotifIndice => 'مثال: إيداع المداخيل';

  @override
  String gcTrfValider(String montant) {
    return 'تحويل $montant';
  }

  @override
  String get gcToastTransfert => 'تم تسجيل التحويل';

  @override
  String get gcToastTransfertsAnnules => 'تم إلغاء التحويلات';

  @override
  String get gcToastSoldesRetablis => 'تمت استعادة الأرصدة';

  @override
  String get gcBloqueDejaAnnule => 'ملغى مسبقاً';

  @override
  String get gcErreurDejaAnnule => 'هذا التحويل ملغى مسبقاً.';

  @override
  String get gcErreurTransfertInconnu => 'التحويل غير موجود.';

  @override
  String get gcErreurPeriodeCloturee => 'هذا التاريخ ضمن فترة مقفلة.';

  @override
  String get gcZDescription => 'تقرير ثابت للفترة: بعد إنشائه لا يمكن تعديله أو حذفه.';

  @override
  String gcZPeriodeValeur(String debut) {
    return 'من $debut إلى الآن';
  }

  @override
  String gcZDepuisDerniere(String code) {
    return 'منذ آخر إقفال ($code)';
  }

  @override
  String get gcZPremiere => 'أول إقفال لهذا الصندوق';

  @override
  String get gcZTicketsAnnules => 'التذاكر الملغاة';

  @override
  String get gcZTotalAnnule => 'مجموع الملغى';

  @override
  String get gcZMoyen => 'وسيلة الدفع';

  @override
  String get gcZPart => 'الحصة';

  @override
  String gcZChainee(String code) {
    return 'مرتبط بـ $code · البصمة السابقة';
  }

  @override
  String get gcZGenese => 'بداية سلسلة هذا الصندوق · بصمة البداية';

  @override
  String get gcZConfirmer => 'أؤكد المجاميع: سيكون الإقفال نهائياً وموقّعاً.';

  @override
  String gcZCreer(String code) {
    return 'إنشاء الإقفال $code';
  }

  @override
  String gcZCreee(String code) {
    return 'تم إنشاء الإقفال $code';
  }

  @override
  String get gcZCreeeDetail => 'تقرير موقّع ومتسلسل';

  @override
  String get gcZAucunPaiement => 'لا توجد مدفوعات في هذه الفترة.';

  @override
  String gcZDetailTitre(String code) {
    return 'الإقفال $code';
  }

  @override
  String gcZDetailDescription(String au, String caisse, String du, String par) {
    return '$caisse · من $du إلى $au · بواسطة $par';
  }

  @override
  String get gcZDefinitive => 'نهائي';

  @override
  String get gcZEmpreinteValide => 'بصمة صالحة';

  @override
  String get gcZEmpreinteAlteree => 'بصمة معدّلة';

  @override
  String get gcZRepartition => 'توزيع المدفوعات';

  @override
  String get gcZIntegrite => 'السلامة';

  @override
  String get gcZEmpreintePrecedente => 'البصمة السابقة';

  @override
  String get gcZTotaux => 'مجاميع الفترة';

  @override
  String get gcZSoldeFin => 'الرصيد في نهاية الفترة';

  @override
  String get gcFiscalTitre => 'تصدير للمراقبة الجبائية';

  @override
  String get gcFiscalDescription => 'أرشيف إقفالات Z وتذاكر الفترة مع سلسلة بصمات متحقق منها.';

  @override
  String get gcFiscalZip => 'أرشيف كامل';

  @override
  String get gcFiscalZipDesc => 'JSON المراقبة + CSV + البصمات (.zip)';

  @override
  String get gcFiscalJson => 'JSON المراقبة';

  @override
  String get gcFiscalJsonDesc => 'سلسلة قابلة للتحقق (§12.3)';

  @override
  String get gcFiscalPdf => 'تقرير PDF';

  @override
  String get gcFiscalPdfDesc => 'إقفالات Z فقط';

  @override
  String get gcFiscalCsv => 'CSV';

  @override
  String get gcFiscalCsvDesc => 'التذاكر سطراً بسطر';

  @override
  String gcFiscalChaineOk(int n) {
    return 'سلسلة البصمات سليمة · $n إقفال، دون انقطاع';
  }

  @override
  String gcFiscalChaineKo(String code) {
    return 'السلسلة منقطعة عند الإقفال $code';
  }

  @override
  String get gcFiscalGenere => 'تم إنشاء الأرشيف';

  @override
  String gcSesMvtTitre(String code) {
    return 'الحركات · $code';
  }

  @override
  String gcSesMvtOuverte(String caisse, String ouverture) {
    return '$caisse · فُتحت $ouverture';
  }

  @override
  String gcSesMvtCloturee(String caisse, String cloture, String ouverture) {
    return '$caisse · فُتحت $ouverture · أُقفلت $cloture';
  }

  @override
  String get gcEntrees => 'المداخيل';

  @override
  String get gcSorties => 'المخارج';

  @override
  String get gcSolde => 'الرصيد';

  @override
  String get permVoirMarge => 'عرض الهامش / نسبة الهامش';

  @override
  String get permModifierPrixVente => 'تعديل سعر البيع';

  @override
  String get permAnnulerOperations => 'إلغاء العمليات';

  @override
  String get permChangerCaisseMagasin => 'تغيير صندوقه / مخزنه';

  @override
  String get permGererTransfertsCaisse => 'إدارة التحويلات بين الصناديق';

  @override
  String get permVoirStockTousMagasins => 'عرض مخزون كل المخازن';

  @override
  String get usrDescription => 'الحسابات والأدوار والصلاحيات';

  @override
  String get usrOngletUtilisateurs => 'المستخدمون';

  @override
  String get usrOngletRoles => 'الأدوار';

  @override
  String get usrEntiteUtilisateurs => 'مستخدمين';

  @override
  String get usrEntiteUtilisateur => 'مستخدم';

  @override
  String get usrEntiteRoles => 'أدوار';

  @override
  String get usrEntiteRole => 'دور';

  @override
  String get usrKpiActifs => 'المستخدمون النشطون';

  @override
  String get usrKpiVentes => 'المبيعات (30 يومًا)';

  @override
  String get usrKpiTotal => 'إجمالي المبيعات';

  @override
  String get usrRole => 'الدور';

  @override
  String get usrEtat => 'الحالة';

  @override
  String get usrActif => 'نشط';

  @override
  String get usrInactif => 'غير نشط';

  @override
  String get usrRecherche => 'الاسم أو المعرّف أو الهاتف…';

  @override
  String get usrColUtilisateur => 'المستخدم';

  @override
  String get usrColCaisse => 'الصندوق';

  @override
  String get usrColMagasins => 'المخازن';

  @override
  String get usrColVentes => 'المبيعات';

  @override
  String get usrColDernierAcces => 'آخر دخول';

  @override
  String get usrTelephone => 'الهاتف';

  @override
  String get usrLibre => 'حر';

  @override
  String get usrReinitialiser => 'إعادة تعيين كلمة المرور';

  @override
  String get usrDesactiver => 'تعطيل';

  @override
  String get usrNouvel => 'مستخدم جديد';

  @override
  String get usrModifierTitre => 'تعديل المستخدم';

  @override
  String get usrFormDescription => 'يحدد الدور الوحدات الظاهرة؛ والصندوق المرتبط يقفل شاشة الصندوق.';

  @override
  String get usrSectionCompte => 'الحساب';

  @override
  String get usrSectionAcces => 'الصلاحيات';

  @override
  String get usrCode => 'الرمز';

  @override
  String get usrIdentifiant => 'المعرّف';

  @override
  String get usrIdentifiantIndice => 'مثال: amina';

  @override
  String get usrIdentifiantPris => 'المعرّف مستخدم من قبل';

  @override
  String get usrIdentifiantInvalide => 'من 3 إلى 32 حرفًا: حروف، أرقام، . _ -';

  @override
  String get usrMotDePasse => 'كلمة المرور';

  @override
  String get usrNouveauMotDePasse => 'كلمة مرور جديدة';

  @override
  String get usrMdpIndice => '8 أحرف على الأقل';

  @override
  String get usrMdpVide => 'اتركه فارغًا لعدم التغيير';

  @override
  String get usrForce0 => 'ضعيفة جدًا';

  @override
  String get usrForce1 => 'ضعيفة';

  @override
  String get usrForce2 => 'متوسطة';

  @override
  String get usrForce3 => 'جيدة';

  @override
  String get usrForce4 => 'قوية';

  @override
  String get usrPrenom => 'الاسم';

  @override
  String get usrNom => 'اللقب';

  @override
  String get usrAdminRole => 'صلاحيات كاملة، لا يمكن تقييدها';

  @override
  String usrNbPermissions(int n) {
    return '$n صلاحيات';
  }

  @override
  String get usrCaisseAttachee => 'الصندوق المرتبط';

  @override
  String get usrCaisseAdmin => 'المدير يختار صندوقه بحرية';

  @override
  String get usrCaisseIndice => 'يقفل صندوق شاشة الصندوق';

  @override
  String get usrAucune => 'لا شيء';

  @override
  String get usrMagasinsIndice => 'الأول هو المخزن الافتراضي عند الدخول';

  @override
  String get usrObservation => 'ملاحظة';

  @override
  String get usrCree => 'تم إنشاء المستخدم';

  @override
  String get usrModifie => 'تم تعديل المستخدم';

  @override
  String get usrErrTelephone => 'الهاتف إلزامي';

  @override
  String get usrErrMotDePasse => 'كلمة المرور ضعيفة جدًا';

  @override
  String get usrErrRole => 'دور غير قابل للإسناد';

  @override
  String get usrErrMagasins => 'اختر مخزنًا واحدًا على الأقل';

  @override
  String get usrErrInconnu => 'المستخدم غير موجود';

  @override
  String get usrInfos => 'معلومات عامة';

  @override
  String get usrPermissionsRole => 'صلاحيات الدور';

  @override
  String get usrAudit => 'التدقيق';

  @override
  String get usrCreePar => 'أنشأه';

  @override
  String get usrCreeLe => 'أنشئ في';

  @override
  String get usrModifiePar => 'عدّله';

  @override
  String get usrModifieLe => 'عُدّل في';

  @override
  String get usrLibreAdmin => 'حر (مدير)';

  @override
  String get usrDefaut => '(افتراضي)';

  @override
  String get usrMdpReinitTitre => 'تمت إعادة تعيين كلمة المرور';

  @override
  String usrMdpReinitMessage(String identifiant, String mdp) {
    return 'أبلغ @$identifiant بكلمة المرور المؤقتة هذه: $mdp. يمكنه تغييرها من حسابي.';
  }

  @override
  String get usrBloqueAdmin => 'حساب المدير الرئيسي';

  @override
  String get usrBloqueCourant => 'حسابك الخاص';

  @override
  String get usrBloqueInactif => 'غير نشط مسبقًا';

  @override
  String get usrDesactives => 'تم تعطيل المستخدمين';

  @override
  String get usrDesactivesDetail => 'لم يعد بإمكانهم الدخول';

  @override
  String get usrColModules => 'الوحدات';

  @override
  String get usrColSpeciales => 'خاصة';

  @override
  String get usrTous => 'الكل';

  @override
  String get usrToutes => 'الكل';

  @override
  String get usrSysteme => 'نظام';

  @override
  String get usrDupliquer => 'نسخ';

  @override
  String get usrNouveauRole => 'دور جديد';

  @override
  String get usrModifierRole => 'تعديل الدور';

  @override
  String get usrRoleDescription => 'المعلومات، الوحدات المتاحة، ثم العمليات الحساسة.';

  @override
  String usrRoleConcernes(String code, int n) {
    return '$code · $n مستخدم(ين) معنيين';
  }

  @override
  String get usrPrecedent => 'السابق';

  @override
  String get usrSuivant => 'التالي';

  @override
  String get usrEnregistrerRole => 'حفظ الدور';

  @override
  String get usrEtapeInfos => 'المعلومات';

  @override
  String get usrEtapeInfosDesc => 'الاسم، الحالة';

  @override
  String get usrEtapePermissions => 'الصلاحيات';

  @override
  String usrEtapeModules(int n) {
    return '$n وحدات';
  }

  @override
  String get usrEtapeSpeciales => 'صلاحيات خاصة';

  @override
  String get usrEtapeSpecialesDesc => 'عمليات حساسة';

  @override
  String get usrNomRole => 'اسم الدور';

  @override
  String get usrNomRoleIndice => 'مثال: أمين صندوق أول';

  @override
  String get usrNomRolePris => 'اسم الدور هذا موجود مسبقًا';

  @override
  String get usrObsRoleIndice => 'ما الغرض من هذا الدور؟';

  @override
  String get usrModulesTitre => 'الوحدات المتاحة';

  @override
  String get usrModulesDesc =>
      'لا يرى الدور في الشريط الجانبي والقائمة إلا الوحدات المحددة. تُسند الإعدادات والسجل مثل باقي الوحدات.';

  @override
  String get usrSpecialesDesc => 'عمليات شاملة تُراقَب في كل الوحدات (عرض أسعار الشراء، الإلغاءات، تغيير الصندوق…).';

  @override
  String get usrConfirmRoleTitre => 'تعديل هذا الدور؟';

  @override
  String usrConfirmRoleMessage(int n) {
    return 'سيتغير وصول $n مستخدم(ين) عند الدخول القادم.';
  }

  @override
  String get usrRoleEnregistre => 'تم حفظ الدور';

  @override
  String get usrRoleEnregistreDetail => 'تم تطبيق الصلاحيات';

  @override
  String usrRoleTitre(String nom) {
    return 'الدور $nom';
  }

  @override
  String get usrAdminBloqueTitre => 'التعديل غير ممكن';

  @override
  String get usrAdminBloqueMessage => 'دور المدير دور نظام: لا يمكن تعديل صلاحياته.';

  @override
  String get usrRoleBloqueSysteme => 'دور نظام المدير';

  @override
  String get usrRoleBloqueUtilisateurs => 'لهذا الدور مستخدمون: أعد إسنادهم';

  @override
  String get usrRolesDesactives => 'تم تعطيل الأدوار';

  @override
  String usrNbUtilisateurs(int n) {
    return '$n مستخدم(ين)';
  }

  @override
  String usrCopie(String nom) {
    return '$nom (نسخة)';
  }

  @override
  String get usrRoleErrModules => 'حدد وحدة واحدة على الأقل';

  @override
  String get usrRoleErrInconnu => 'الدور غير موجود';

  @override
  String get usrAucunUtilisateur => 'لا يوجد مستخدمون.';

  @override
  String get usrAucunRole => 'لا توجد أدوار.';

  @override
  String get zkDescription => 'حساب سنوي على المخزون والسيولة والديون المستحقة';

  @override
  String get zkEntite => 'حسابات';

  @override
  String get zkEntiteUn => 'حساب';

  @override
  String zkKpiCapital(int annee) {
    return 'رأس المال $annee (مؤقت)';
  }

  @override
  String get zkKpiNissab => 'النصاب الحالي';

  @override
  String zkKpiEstimee(int annee) {
    return 'الزكاة المقدرة $annee';
  }

  @override
  String get zkKpiEcheance => 'الاستحقاق';

  @override
  String get zkJours => 'يوم';

  @override
  String get zkColCode => 'الرمز';

  @override
  String get zkColAnnee => 'السنة';

  @override
  String get zkColCapital => 'رأس المال';

  @override
  String get zkColNissab => 'النصاب';

  @override
  String get zkColObligatoire => 'واجبة';

  @override
  String get zkOui => 'نعم';

  @override
  String get zkNon => 'لا';

  @override
  String get zkColZakat => 'الزكاة';

  @override
  String get zkColDue => 'تستحق في';

  @override
  String get zkColPayee => 'دفعت في';

  @override
  String get zkColStatut => 'الحالة';

  @override
  String get zkColStock => 'المخزون';

  @override
  String get zkColLiquidites => 'السيولة';

  @override
  String get zkColCreances => 'الديون المستحقة';

  @override
  String get zkColDettes => 'الديون';

  @override
  String get zkColTaux => 'النسبة';

  @override
  String get zkColHawl => 'بداية الحول';

  @override
  String get zkColObservation => 'ملاحظة';

  @override
  String get zkColCreePar => 'أنشأه';

  @override
  String get zkExoneree => 'معفاة';

  @override
  String get zkAnnulee => 'ملغاة';

  @override
  String get zkMarquerPayee => 'تعليم كمدفوعة';

  @override
  String get zkAnnuler => 'إلغاء';

  @override
  String get zkNouveau => 'حساب جديد';

  @override
  String get zkNouveauTitre => 'حساب زكاة جديد';

  @override
  String get zkModifierTitre => 'تعديل الزكاة';

  @override
  String get zkFormDescription => 'المبالغ معبأة مسبقًا من المخزون والصناديق والديون؛ عدّلها عند الحاجة.';

  @override
  String get zkSectionPeriode => 'الفترة (الحول)';

  @override
  String get zkSectionPatrimoine => 'الذمة المالية';

  @override
  String get zkDebutHawl => 'بداية الحول';

  @override
  String get zkDueLe => 'تستحق الزكاة في';

  @override
  String get zkDueIndice => 'البداية + 354 يومًا (سنة قمرية)';

  @override
  String get zkValeurStock => 'قيمة المخزون';

  @override
  String get zkStockIndice => 'بسعر الشراء';

  @override
  String get zkLiquiditesIndice => 'الصناديق + البنك';

  @override
  String get zkCreancesIndice => 'ديون العملاء القابلة للتحصيل';

  @override
  String get zkDettesCourt => 'الديون قصيرة الأجل';

  @override
  String get zkDettesIndice => 'ديون الموردين';

  @override
  String get zkNissabIndice => '85 غ ذهب × سعر اليوم';

  @override
  String zkReprendre(String libelle) {
    return 'استرجاع: $libelle';
  }

  @override
  String get zkRepValeurStock => 'قيمة المخزون';

  @override
  String get zkRepSoldes => 'أرصدة الصناديق';

  @override
  String get zkRepCreances => 'ديون العملاء';

  @override
  String get zkRepDettes => 'ديون الموردين';

  @override
  String get zkCapitalSoumis => 'رأس المال الخاضع';

  @override
  String get zkAuDessus => 'فوق النصاب';

  @override
  String get zkEnDessous => 'دون النصاب';

  @override
  String get zkObligatoire => 'الزكاة واجبة';

  @override
  String get zkMontant => 'مبلغ الزكاة';

  @override
  String zkFormule(String taux) {
    return 'رأس المال = المخزون + السيولة + الديون المستحقة − الديون. المبلغ = رأس المال × $taux % إذا بلغ النصاب.';
  }

  @override
  String get zkEnregistre => 'تم حفظ الحساب';

  @override
  String get zkPayeeToast => 'تم تعليم الزكاة كمدفوعة';

  @override
  String get zkAnnules => 'تم إلغاء الحسابات';

  @override
  String zkDetailTitre(int annee) {
    return 'زكاة $annee';
  }

  @override
  String zkDetailDescription(String code, String debut, String fin) {
    return '$code · الحول $debut ← $fin';
  }

  @override
  String get zkCalcul => 'الحساب';

  @override
  String get zkPoste => 'البند';

  @override
  String get zkMontantCol => 'المبلغ';

  @override
  String get zkAudit => 'التدقيق';

  @override
  String get zkMotif => 'السبب';

  @override
  String get zkBloqueePayee => 'مدفوعة مسبقًا';

  @override
  String get zkBloqueeAnnulee => 'ملغاة مسبقًا';

  @override
  String get zkErrValeur => 'قيم غير صالحة (مبالغ موجبة، الاستحقاق بعد بداية الحول)';

  @override
  String get zkErrInconnue => 'الحساب غير موجود';

  @override
  String get zkErrMotif => 'السبب إلزامي';

  @override
  String get zkAucun => 'لا يوجد حساب زكاة.';

  @override
  String get hiDescription => 'سجل جميع العمليات · الوصول حسب الدور';

  @override
  String get hiEntite => 'عمليات';

  @override
  String get hiKpiActions => 'العمليات (7 أيام)';

  @override
  String get hiKpiCreations => 'إنشاءات';

  @override
  String get hiKpiModifications => 'تعديلات';

  @override
  String get hiKpiAnnulations => 'إلغاءات';

  @override
  String get hiModule => 'الوحدة';

  @override
  String get hiAction => 'العملية';

  @override
  String get hiUtilisateur => 'المستخدم';

  @override
  String get hiPoste => 'المحطة';

  @override
  String get hiTous => 'الكل';

  @override
  String get hiToutes => 'الكل';

  @override
  String get hiRecherche => 'المرجع أو الوصف…';

  @override
  String get hiColDate => 'التاريخ';

  @override
  String get hiColRef => 'المرجع';

  @override
  String get hiColDescription => 'الوصف';

  @override
  String get hiColCode => 'الرمز';

  @override
  String get hiAucun => 'لا توجد عمليات خلال الفترة.';

  @override
  String get hiDetail => 'التفاصيل';

  @override
  String get hiSectionAction => 'العملية';

  @override
  String get hiSectionContexte => 'السياق';

  @override
  String get hiReference => 'المرجع';

  @override
  String get hiEntiteTechnique => 'الكيان';

  @override
  String get hiModuleConnexion => 'تسجيل الدخول';

  @override
  String get hiCatCreation => 'إنشاء';

  @override
  String get hiCatModification => 'تعديل';

  @override
  String get hiCatAnnulation => 'إلغاء';

  @override
  String get hiCatConnexion => 'اتصال';

  @override
  String get hiCatExport => 'تصدير';

  @override
  String get hiActCreation => 'إنشاء';

  @override
  String get hiActModification => 'تعديل';

  @override
  String get hiActAnnulation => 'إلغاء';

  @override
  String get hiActDesactivation => 'تعطيل';

  @override
  String get hiActActivation => 'تفعيل';

  @override
  String get hiActSuppression => 'حذف';

  @override
  String get hiActVersement => 'دفعة';

  @override
  String get hiActTransfert => 'تحويل';

  @override
  String get hiActReinitialisation => 'إعادة تعيين كلمة المرور';

  @override
  String get hiActRetour => 'إرجاع';

  @override
  String get hiActParametres => 'الإعدادات';

  @override
  String get hiActOuverture => 'فتح';

  @override
  String get hiActFermeture => 'إغلاق';

  @override
  String get hiActEncaissement => 'تحصيل';

  @override
  String get hiActConnexion => 'تسجيل الدخول';

  @override
  String get hiActDeconnexion => 'تسجيل الخروج';

  @override
  String get hiActConfiguration => 'الإعداد الأولي';

  @override
  String get hiActClotureZ => 'إقفال Z';

  @override
  String get hiActAffectation => 'تعيين';

  @override
  String get hiActAchat => 'شراء';

  @override
  String get hiActApport => 'إيداع';

  @override
  String get hiActDepense => 'مصروف';

  @override
  String get hiActPaiement => 'أداء';

  @override
  String get hiActExport => 'تصدير';

  @override
  String get pmDescription => 'تفضيلات المحطة والمتجر والتطبيق.';

  @override
  String get pmNonEnregistre => 'تعديلات غير محفوظة';

  @override
  String get pmEnregistrer => 'حفظ';

  @override
  String get pmEnregistre => 'تم حفظ الإعدادات';

  @override
  String get pmGrpSysteme => 'النظام';

  @override
  String get pmGrpBoutique => 'المتجر';

  @override
  String get pmGrpCaisse => 'الصندوق والمبيعات';

  @override
  String get pmGrpImpression => 'الطباعة';

  @override
  String get pmGrpAlertes => 'التنبيهات';

  @override
  String get pmGrpSauvegarde => 'النسخ الاحتياطي';

  @override
  String get pmGrpLicence => 'الترخيص';

  @override
  String get pmTheme => 'المظهر';

  @override
  String get pmThemeDesc => 'فاتح للنهار، داكن لشاشات الصندوق في الإضاءة الخافتة.';

  @override
  String get pmClair => 'فاتح';

  @override
  String get pmSombre => 'داكن';

  @override
  String get pmLangue => 'لغة الواجهة';

  @override
  String get pmLangueDesc => 'العربية تفعّل التخطيط من اليمين إلى اليسار وخط القاهرة.';

  @override
  String get pmDevise => 'العملة';

  @override
  String get pmDeviseDesc => 'تظهر على المبالغ والتذاكر والفواتير.';

  @override
  String get pmDecimales => 'الأرقام العشرية للكميات';

  @override
  String get pmDecimalesDesc => '0 للمواد بالوحدة، 3 للبيع بالوزن (كغ).';

  @override
  String get pmMargeTitre => 'الهامش الافتراضي';

  @override
  String get pmMargeInfo => 'يطبق على المنتجات الجديدة ويقترح في الإدخال';

  @override
  String get pmMargeType => 'نوع الهامش';

  @override
  String get pmMargeTypeDesc => 'مبلغ ثابت أو نسبة من سعر الشراء.';

  @override
  String get pmMontant => 'مبلغ';

  @override
  String get pmPourcentage => 'نسبة مئوية';

  @override
  String get pmMargeValeur => 'الهامش';

  @override
  String get pmMargeValeurDesc => 'سعر البيع = الشراء + الهامش.';

  @override
  String get pmSeuilsTitre => 'حدود المخزون العامة';

  @override
  String get pmSeuilsInfo => 'قيم افتراضية قابلة للتعديل لكل منتج';

  @override
  String get pmSeuilMin => 'الحد الأدنى (نفاد)';

  @override
  String get pmSeuilMinDesc => 'تنبيه عندما ينزل المخزون تحت هذا الحد.';

  @override
  String get pmSeuilMax => 'الحد الأقصى';

  @override
  String get pmSeuilMaxDesc => 'يشير إلى فائض المخزون؛ 0 بلا حد.';

  @override
  String get pmPieces => 'قطعة';

  @override
  String get pmGarde => 'حماية المخزون';

  @override
  String get pmGardeDesc => 'مفعلة دائما: لا يصبح المخزون سالبا أبدا.';

  @override
  String get pmGardeCaisseDesc => 'مفعلة دائما: لا يصبح المخزون سالبا، ولا يباع منتج رصيده 0.';

  @override
  String get pmNonDesactivable => 'غير قابلة للتعطيل';

  @override
  String get pmZakatTitre => 'الزكاة';

  @override
  String get pmNissab => 'النصاب';

  @override
  String get pmNissabDesc => 'قيمة 85 غ من الذهب؛ تقترح في كل حساب.';

  @override
  String get pmTaux => 'النسبة';

  @override
  String get pmTauxDesc => 'النسبة المطبقة على الوعاء.';

  @override
  String get pmServeursTitre => 'الخدمات عبر الإنترنت';

  @override
  String get pmServeursInfo => 'الكتالوج المشترك والبحث عن المنتجات بالرمز الشريطي';

  @override
  String get pmServeurUrl => 'رابط خادم CaisseDZ';

  @override
  String get pmServeurCle => 'مفتاح API';

  @override
  String get pmMantouj => 'رابط Mantouj';

  @override
  String get pmSynchro => 'مزامنة الكتالوج';

  @override
  String get pmSynchroDesc => 'يرسل بطاقاتك ويسترجع البطاقات المحسنة من الكتالوج المشترك.';

  @override
  String get pmSynchroBouton => 'مزامنة';

  @override
  String get pmLogo => 'الشعار';

  @override
  String get pmLogoAide => 'PNG شفاف · يطبع أعلى التذكرة';

  @override
  String get pmRaisonSociale => 'الاسم التجاري';

  @override
  String get pmTelephone => 'الهاتف';

  @override
  String get pmAdresse => 'العنوان';

  @override
  String get pmRc => 'السجل التجاري';

  @override
  String get pmNif => 'رقم التعريف الجبائي';

  @override
  String get pmNis => 'رقم التعريف الإحصائي';

  @override
  String get pmArticle => 'رقم المادة الضريبية';

  @override
  String get pmEmail => 'البريد الإلكتروني';

  @override
  String get pmMessage => 'رسالة التذكرة';

  @override
  String get pmMessageAide => 'يطبع أسفل كل تذكرة';

  @override
  String get pmModesTitre => 'وسائل الدفع';

  @override
  String get pmModesInfo => 'تقترح في نافذة التحصيل؛ النقد مقبول دائما، والنقاط فقط مع تفعيل مكافأة الوفاء وزبون معروف';

  @override
  String get pmReglesTitre => 'قواعد البيع';

  @override
  String get pmSousAchat => 'البيع بأقل من سعر الشراء';

  @override
  String get pmSousAchatDesc => 'السماح أو التنبيه أو منع سعر بيع أقل من سعر الشراء.';

  @override
  String get pmFideliteTitre => 'الوفاء';

  @override
  String get pmBonus => 'مكافأة الوفاء';

  @override
  String get pmBonusDesc => 'يكسب الزبائن المعرفون نقاطا عند كل تحصيل.';

  @override
  String get pmTauxGain => 'نسبة الكسب';

  @override
  String get pmTauxGainDesc => 'النقاط المكتسبة لكل شريحة شراء.';

  @override
  String get pmPointPar => 'نقطة /';

  @override
  String get pmImprimanteTitre => 'طابعة التذاكر';

  @override
  String get pmTypeBluetooth => 'بلوتوث';

  @override
  String get pmTypeBluetoothDesc => 'مقترنة في ويندوز';

  @override
  String get pmTypeUsb => 'USB';

  @override
  String get pmTypeUsbDesc => 'قائمة انتظار ويندوز (ESC/POS)';

  @override
  String get pmTypeReseau => 'شبكة';

  @override
  String get pmTypeReseauDesc => 'عنوان IP والمنفذ';

  @override
  String get pmTypeNormale => 'عادية';

  @override
  String get pmTypeNormaleDesc => 'طابعة ويندوز';

  @override
  String get pmAdresseIp => 'عنوان IP:المنفذ';

  @override
  String get pmAdresseBluetooth => 'قائمة انتظار البلوتوث';

  @override
  String get pmFileUsb => 'قائمة انتظار ويندوز';

  @override
  String get pmLargeur => 'العرض';

  @override
  String get pmTest => 'طباعة تجريبية';

  @override
  String pmTestOk(String cible) {
    return 'أرسلت التجربة: خرجت صفحة الاختبار على $cible.';
  }

  @override
  String get pmAlertesConnexion => 'عرض التنبيهات عند الدخول';

  @override
  String get pmAlertesConnexionDesc => 'النفاد، الديون المرتفعة، الجلسات غير المقفلة.';

  @override
  String get pmSeuilCredit => 'حد دين الزبون';

  @override
  String get pmSeuilCreditDesc => 'يشير إلى الزبائن فوق هذا المبلغ؛ 0 للجميع.';

  @override
  String get pmSauverMaintenant => 'حفظ نسخة الآن';

  @override
  String get pmSauvegardeTerminee => 'اكتمل النسخ الاحتياطي';

  @override
  String get pmRestaurerDesc => 'يستبدل جميع البيانات الحالية ببيانات ملف.';

  @override
  String get pmRestaurerBouton => 'استعادة…';

  @override
  String get pmRestaurerConfirmTitre => 'استعادة نسخة احتياطية؟';

  @override
  String get pmRestaurerConfirmMsg => 'ستستبدل جميع البيانات الحالية (المبيعات، المخزون، الزبائن…) عند التشغيل القادم.';

  @override
  String get pmRestaurerConfirmOk => 'اختيار الملف والاستعادة';

  @override
  String get pmPalierAvance => 'المستوى المتقدم';

  @override
  String get pmPalierAvanceDesc => 'متاجر وصناديق متعددة';

  @override
  String get pmPalierBasic => 'المستوى الأساسي';

  @override
  String get pmPalierBasicDesc => 'متجر واحد، جميع وظائف البيع';

  @override
  String get pmPalierDemo => 'الوضع التجريبي';

  @override
  String get pmPalierDemoDesc => 'بيانات وهمية تعاد عند الإغلاق';

  @override
  String get pmPalierAucun => 'التطبيق غير مفعل';

  @override
  String get pmPalierAucunDesc => 'أدخل مفتاحا لتفعيل CaisseDZ';

  @override
  String get pmActive => 'مفعلة';

  @override
  String get pmCle => 'مفتاح الترخيص';

  @override
  String get pmCleDesc => 'مرتبط بهذه المحطة.';

  @override
  String pmActiveeLe(String date) {
    return 'فعلت في $date.';
  }

  @override
  String get pmGererLicence => 'إدارة الترخيص';

  @override
  String get pmGererLicenceDesc => 'إدخال مفتاح جديد أو الانتقال إلى المستوى المتقدم.';

  @override
  String get posPrixSousAchatInterdit => 'سعر أقل من سعر الشراء: ممنوع في الإعدادات.';

  @override
  String alertesExpireDepuis(int n) {
    return 'منتهي منذ $n ي';
  }

  @override
  String get communSessionRequise => 'لا توجد جلسة صندوق مفتوحة: افتح جلسة قبل التسجيل.';

  @override
  String communFermeeDesc(String caisse) {
    return 'افتح جلسة لـ « $caisse » قبل تسجيل هذه العملية.';
  }

  @override
  String get posRaccourciE => 'إدخال سريع (شراء منتج واحد)';

  @override
  String get hiActSauvegarde => 'نسخ احتياطي';

  @override
  String get hiActRestauration => 'استعادة';

  @override
  String get posApercuTicket => 'معاينة التذكرة';

  @override
  String get posApercuTicketDesc => 'تحقق من التخطيط قبل إرساله إلى الطابعة.';

  @override
  String get posImprimer => 'طباعة';

  @override
  String get posGabaritLatin => 'لاتيني';

  @override
  String get pmApercuAucuneVente => 'لا توجد مبيعات: تستخدم المعاينة تذكرة نموذجية.';

  @override
  String get pmSauvegardeIncomplete => 'النسخ التلقائي: اختر مجلدًا وكلمة مرور.';

  @override
  String get pmSauvegardeDossier => 'مجلد النسخ الاحتياطي';

  @override
  String get pmSauvegardeDossierDesc => 'قرص محلي أو مفتاح USB أو مجلد متزامن (Google Drive، OneDrive).';

  @override
  String get pmSauvegardeChanger => 'تغيير';

  @override
  String get pmSauvegardeAuto => 'النسخ الاحتياطي التلقائي';

  @override
  String get pmSauvegardeAutoDesc => 'تتم عند فتح التطبيق؛ يُحتفظ بآخر 30 نسخة.';

  @override
  String get pmFrequenceDesactivee => 'معطّل';

  @override
  String get pmFrequenceDemarrage => 'عند كل تشغيل';

  @override
  String get pmFrequenceQuotidienne => 'يومي';

  @override
  String get pmSauvegardeMdp => 'كلمة مرور النسخ';

  @override
  String get pmSauvegardeMdpDesc => 'مطلوبة لاستعادة نسخة تلقائية.';

  @override
  String get pmSauvegardeMdpDefinir => 'تحديد';

  @override
  String get pmSauvegardeMdpChanger => 'تغيير';

  @override
  String pmSauvegardeDerniere(String date) {
    return 'آخر نسخة تلقائية: $date';
  }

  @override
  String get communModifiePar => 'عُدّل بواسطة';

  @override
  String get communModifieLe => 'تاريخ التعديل';

  @override
  String get communNombreObligatoire => 'عدد القطع (المخزون الثاني) إلزامي لهذا المنتج.';

  @override
  String get stkNombre => 'العدد';

  @override
  String get stkNombreObligatoire => 'العدد إلزامي';

  @override
  String get pmNombreActif => 'المخزون الثاني « العدد » لكل المنتجات';

  @override
  String get pmNombreActifDesc => 'عدد القطع يُدخل إضافة إلى الكمية (مثال: الجزارة كغ + قطع)، إلزامي في كل حركة.';

  @override
  String dsFavorisAide(int max) {
    return 'انقر على وحدة لإضافتها إلى المفضلة أو إزالتها ($max كحد أقصى).';
  }

  @override
  String dsFavorisAideComplets(int max) {
    return 'تم اختيار $max مفضلات: أزل واحدة لإضافة أخرى.';
  }

  @override
  String get shellChoisirFavoris => 'اختيار المفضلة';

  @override
  String get communTermine => 'تم';

  @override
  String get posRechMin => 'أدنى';

  @override
  String get posRechMax => 'أقصى';

  @override
  String get posRechToutesCategories => 'كل الفئات';

  @override
  String get posMontantTitre => 'بيع بالمبلغ';

  @override
  String get posMontantColis => 'مبلغ';

  @override
  String get posMontantAide => 'سلعة موزونة أو بدون رمز: يُضاف المبلغ إلى سطر واحد في السلة (200 ثم 500 = 700).';

  @override
  String get posMontantAutre => 'مبلغ آخر';

  @override
  String get posMontantModifier => 'تعديل المبلغ';

  @override
  String get posMontantModifierDesc => 'المبلغ الجديد لسطر « بيع بالمبلغ »؛ 0 يحذف السطر.';

  @override
  String get posMontantChamp => 'المبلغ';

  @override
  String get posMontantInvalide => 'أدخل مبلغًا أكبر من 0.';

  @override
  String get posMontantLigneAide => 'نقرة مزدوجة: تعديل المبلغ';

  @override
  String get ventesListeProduits => 'قائمة المنتجات';

  @override
  String ventesListeProduitsTitre(String code) {
    return 'منتجات السلة $code';
  }

  @override
  String get ventesColis => 'الطرد';

  @override
  String get selRechercherListe => 'البحث في القائمة';

  @override
  String get selProduit => 'اختيار منتج';

  @override
  String get selCategorie => 'اختيار فئة';

  @override
  String get selSousCategorie => 'اختيار فئة فرعية';

  @override
  String get selRemise => 'اختيار تخفيض';

  @override
  String get selPack => 'اختيار حزمة';

  @override
  String get selClient => 'اختيار عميل';

  @override
  String get selFournisseur => 'اختيار مورد';

  @override
  String get selMagasin => 'اختيار مخزن';

  @override
  String get selCaisse => 'اختيار صندوق';

  @override
  String get selSession => 'اختيار جلسة';

  @override
  String get selUtilisateur => 'اختيار مستخدم';

  @override
  String get selVente => 'اختيار عملية بيع';

  @override
  String get selColCode => 'الرمز';

  @override
  String get selColNom => 'الاسم';

  @override
  String get selColDesignation => 'التسمية';

  @override
  String get selColCategorie => 'الفئة';

  @override
  String get selColStock => 'المخزون';

  @override
  String get selColPrix => 'السعر';

  @override
  String get selColTelephone => 'الهاتف';

  @override
  String get selColAdresse => 'العنوان';

  @override
  String get selColType => 'النوع';

  @override
  String get selColValeur => 'القيمة';

  @override
  String get selColMagasin => 'المخزن';

  @override
  String get selColCaisse => 'الصندوق';

  @override
  String get selColUtilisateur => 'المستخدم';

  @override
  String get selColOuverture => 'الفتح';

  @override
  String get selColStatut => 'الحالة';

  @override
  String get selColDate => 'التاريخ';

  @override
  String get selColClient => 'العميل';

  @override
  String get selColTotal => 'المجموع';

  @override
  String get selColProduits => 'المنتجات';

  @override
  String get selColDescription => 'الوصف';

  @override
  String get selFiltreEtat => 'الحالة';

  @override
  String get selTous => 'الكل';

  @override
  String selPoints(int n) {
    return '$n نقطة';
  }

  @override
  String selNbProduits(int n) {
    return '$n منتجات';
  }

  @override
  String get retoursNouveauClient => 'مرتجع زبون جديد';

  @override
  String get retoursNouveauFournisseur => 'مرتجع مورد جديد';

  @override
  String get retoursFormDescriptionClient => 'إرجاع منتج مباع: يعاد إلى المخزون أو يُسترد أو يُسجل كرصيد.';

  @override
  String get retoursFormDescriptionFournisseur => 'إرجاع منتج مستلم: يُخرج من المخزون ويُخصم من دين المورد.';

  @override
  String get prdPorteeProduitAide => 'تُطبق تلقائيًا على المنتجات المختارة خلال فترتها.';

  @override
  String get prdPorteeMontantAide => 'تُختار على السلة في الصندوق عندما يبلغ المجموع الفرعي العتبة.';

  @override
  String prdMontantPanierAide(String devise) {
    return 'مثال: −500 $devise على السلة';
  }

  @override
  String get auditCreeLe => 'أُنشئ في';

  @override
  String get auditModifieLe => 'عُدّل في';

  @override
  String get auditModifiePar => 'عدّله';

  @override
  String get prdDescRapide => 'الأساسي في صفحة واحدة.';

  @override
  String get prdDescDetaille => 'في 3 خطوات: التعريف، المخزون، المتغيرات.';

  @override
  String get prdDescIa => 'بطاقة مسترجعة بالرمز الشريطي.';

  @override
  String get prdFiltreQuantite => 'الكمية';

  @override
  String get prdToastSuppression => 'تم الحذف';

  @override
  String prdVersSansCategorie(int n) {
    return '$n منتج(ات) ← بدون فئة';
  }

  @override
  String get prdPackVendu => 'مُباع سابقًا: يُحتفظ به لسجل المبيعات';

  @override
  String stkNombreDispo(String quantite) {
    return 'القطع: $quantite';
  }

  @override
  String get stkListeProduits => 'قائمة المنتجات';

  @override
  String stkListeProduitsTitre(String code) {
    return 'منتجات $code';
  }

  @override
  String get stkAjouterSousSeuil => 'المنتجات تحت الحد';

  @override
  String get stkAjouterRuptures => 'المنتجات النافدة';

  @override
  String get stkAucunProduitAjoute => 'لا توجد منتجات جديدة للإضافة.';

  @override
  String stkProduitsAjoutes(int n) {
    return 'تمت إضافة $n منتج';
  }

  @override
  String get entFiltreType => 'نوع الإدخال';

  @override
  String get entTypeNormale => 'إدخال عادي';

  @override
  String get tiersSoldeAvant => 'الرصيد قبل';

  @override
  String get tiersSoldeApres => 'الرصيد بعد';

  @override
  String get stkErreurSortieRetour => 'إخراج مرتبط بإرجاع: عدّل الإرجاع أو ألغه.';

  @override
  String get remiseSectionType => 'نوع التخفيض';

  @override
  String get remiseSectionInfos => 'معلومات عامة';

  @override
  String get remiseSectionCalcul => 'قيمة التخفيض';

  @override
  String get remiseSectionPeriode => 'فترة الصلاحية';

  @override
  String stkQteDansMagasin(String magasin) {
    return 'الكمية في $magasin';
  }

  @override
  String stkStockMagasinN(String magasin, String quantite) {
    return '$magasin: $quantite';
  }

  @override
  String get versementErreurPeriode => 'فترة مغلقة: لم يعد بالإمكان تعديل هذا الدفع. ألغِه ثم أدخل دفعًا جديدًا.';

  @override
  String get retoursDateDuJour => 'مؤرخ بتاريخ اليوم، حتى بعد إقفال Z ليوم البيع.';

  @override
  String get situationCasse => 'تالف (خسارة)';

  @override
  String get situationPiecesTheoriques => 'القطع النظرية';

  @override
  String get situationPiecesComptees => 'القطع المحسوبة';

  @override
  String get permDepasserPlafondCredit => 'تجاوز سقف الائتمان';

  @override
  String posErreurPlafondCredit(String plafond, String solde) {
    return 'تم تجاوز سقف ائتمان الزبون ($plafond، الائتمان الحالي $solde).';
  }

  @override
  String get tiersPlafondCredit => 'سقف الائتمان';

  @override
  String get tiersPlafondCreditAide => 'فارغ أو 0: بدون سقف.';

  @override
  String get mvtCoffre => 'الخزنة';

  @override
  String get mvtTimbre => 'حق الطابع';

  @override
  String get retoursAvoirEmis => 'تم إصدار فاتورة تخفيض لهذا الإرجاع (بيع مفوتر): لا يمكن تعديله أو إلغاؤه.';

  @override
  String get tiersArticleImposition => 'المادة الجبائية';

  @override
  String get pmRegimeFiscal => 'النظام الجبائي';

  @override
  String get pmRegimeFiscalDesc =>
      'الحقيقي: رسم على القيمة المضافة في المبيعات وقابل للخصم في المشتريات. الضريبة الجزافية الوحيدة: مبيعات دون رسم.';

  @override
  String get pmRegimeReel => 'الحقيقي';

  @override
  String get pmRegimeIfu => 'IFU';

  @override
  String get pmTimbre => 'حق الطابع';

  @override
  String get pmTimbreDesc => 'يضاف إلى الفواتير على الجزء المدفوع نقدا (1% إلى 2%، 5 دج كحد أدنى).';

  @override
  String get factureVenteAnnulee => 'بيع ملغى: لا يمكن إصدار فاتورة.';

  @override
  String get exportFiscalG50 => 'تصريح G50 (Excel)';

  @override
  String get exportFiscalG50Desc => 'الرسم المحصل والقابل للخصم حسب النسبة، الطابع، الرسم المستحق';

  @override
  String get typeMouvementAnnulation => 'إلغاء بيع';

  @override
  String get posErreurMonnaieSansEspeces => 'الباقي يتجاوز النقود المستلمة: البطاقة أو الصك أو النقاط لا تُرجع الباقي.';

  @override
  String get tiersSoldeInitial => 'الرصيد الافتتاحي';

  @override
  String get tiersSoldeInitialAideClient => 'رصيد سابق: المبلغ المستحق على الزبون قبل البرنامج (سالب = تسبيق).';

  @override
  String get tiersSoldeInitialAideFournisseur => 'رصيد سابق: المبلغ المستحق للمورد قبل البرنامج (سالب = تسبيق).';

  @override
  String get tvaRecapitulatif => 'ملخص الرسم على القيمة المضافة';

  @override
  String get tvaTaux => 'نسبة الرسم';

  @override
  String get tvaBaseHt => 'الأساس خارج الرسم';

  @override
  String get tvaMontant => 'الرسم';

  @override
  String get tvaTtc => 'مع الرسم';

  @override
  String get tvaCollectee => 'الرسم المحصل';

  @override
  String get tvaDeductible => 'الرسم القابل للخصم';

  @override
  String get tvaNette => 'الرسم الواجب دفعه';

  @override
  String get tvaHt => 'خارج الرسم';

  @override
  String get situationTva => 'الرسم حسب النسبة';

  @override
  String get situationGroupeFiscalite => 'الجباية';

  @override
  String get ventesOngletPaniers => 'السلات';

  @override
  String get ventesOngletFactures => 'الفواتير والفواتير العكسية';

  @override
  String get factureNumero => 'رقم الفاتورة';

  @override
  String get factureTypeFacture => 'فاتورة';

  @override
  String get factureTypeAvoir => 'فاتورة عكسية';

  @override
  String get factureVente => 'التذكرة';

  @override
  String get factureOrigine => 'الفاتورة الأصلية';

  @override
  String get factureTimbre => 'الطابع';

  @override
  String get factureNet => 'الصافي للدفع';

  @override
  String get factureEntites => 'الفواتير والفواتير العكسية';

  @override
  String get factureAucune => 'لا توجد فواتير في هذه الفترة';

  @override
  String get factureKpiFactures => 'الفواتير الصادرة';

  @override
  String get factureKpiFacture => 'إجمالي المفوتر';

  @override
  String get factureKpiAvoirs => 'إجمالي الفواتير العكسية';

  @override
  String get factureImprimer => 'طباعة (نسخة)';

  @override
  String get factureChaineOk => 'سلسلة الفواتير سليمة';

  @override
  String get achatErreurCommandeInconnue => 'لم يتم العثور على طلبية المورد لهذا المورد';

  @override
  String get achatErreurCommandeCloturee => 'طلبية المورد ملغاة أو مُسوّاة: الاستلام غير ممكن';

  @override
  String get moduleDocuments => 'العروض والطلبيات';

  @override
  String get moduleCommandesFournisseurs => 'طلبيات الموردين';

  @override
  String get docDescriptionModule => 'عروض الأسعار، الفواتير الشكلية، طلبيات الزبائن ووصولات التسليم';

  @override
  String get docOngletDevis => 'عروض الأسعار';

  @override
  String get docOngletProformas => 'الفواتير الشكلية';

  @override
  String get docOngletCommandes => 'طلبيات الزبائن';

  @override
  String get docOngletLivraisons => 'وصولات التسليم';

  @override
  String get docTypeDevis => 'عرض سعر';

  @override
  String get docTypeProforma => 'فاتورة شكلية';

  @override
  String get docTypeCommande => 'طلبية';

  @override
  String get docBonLivraison => 'وصل التسليم';

  @override
  String get docStatutEnCours => 'قيد الإنجاز';

  @override
  String get docStatutAccepte => 'مقبول';

  @override
  String get docStatutRefuse => 'مرفوض';

  @override
  String get docStatutTransforme => 'حُوّل إلى طلبية';

  @override
  String get docStatutExpire => 'منتهي الصلاحية';

  @override
  String get docStatutPartielle => 'مسلمة جزئيا';

  @override
  String get docStatutLivree => 'مسلمة';

  @override
  String get docStatutAnnule => 'ملغى';

  @override
  String get docValidite => 'صالح إلى';

  @override
  String get docOrigine => 'الأصل';

  @override
  String get docLivre => 'المسلّم';

  @override
  String get docResteALivrer => 'المتبقي للتسليم';

  @override
  String get docALivrer => 'للتسليم';

  @override
  String get docQuantiteLivree => 'الكمية المسلمة';

  @override
  String get docPuTtc => 'سعر الوحدة بالرسوم';

  @override
  String get docTotalTtc => 'المجموع بالرسوم';

  @override
  String get docAucun => 'لا توجد وثائق في هذه الفترة';

  @override
  String get docKpiNombre => 'الوثائق';

  @override
  String get docKpiMontant => 'المبلغ الإجمالي';

  @override
  String get docKpiALivrer => 'للتسليم';

  @override
  String get docKpiTransformes => 'حُوّلت إلى طلبيات';

  @override
  String get docImprimer => 'طباعة (A4)';

  @override
  String get docAccepter => 'قبول';

  @override
  String get docRefuser => 'رفض';

  @override
  String get docTransformer => 'تحويل إلى طلبية';

  @override
  String get docLivrer => 'تسليم';

  @override
  String get docNouveauDevis => 'عرض سعر جديد';

  @override
  String get docNouvelleProforma => 'فاتورة شكلية جديدة';

  @override
  String get docNouvelleCommande => 'طلبية جديدة';

  @override
  String docNouveauTitre(String type) {
    return 'وثيقة جديدة: $type';
  }

  @override
  String docModifierTitre(String type) {
    return 'تعديل: $type';
  }

  @override
  String get docFormDescription => 'الزبون، الصلاحية والمنتجات بسعر البيع بالرسوم (ر.ق.م مثبتة)';

  @override
  String get docChoisirClient => 'اختر زبونا';

  @override
  String get docToastEnregistre => 'تم حفظ الوثيقة';

  @override
  String get docToastTransforme => 'تم إنشاء الطلبية';

  @override
  String get docToastLivre => 'تم تسجيل التسليم';

  @override
  String docLivrerTitre(String code) {
    return 'تسليم الطلبية $code';
  }

  @override
  String get docLivrerDescription => 'أدخل الكميات المسلمة: يتم إنشاء البيع ووصل التسليم معا؛ والباقي دين على الزبون.';

  @override
  String get docMontantPaye => 'المبلغ المدفوع';

  @override
  String get docMontantPayeAide => 'اتركه فارغا: تسليم بالدين';

  @override
  String get docValiderLivraison => 'تأكيد التسليم';

  @override
  String get docPdfDevis => 'عرض سعر';

  @override
  String get docPdfProforma => 'فاتورة شكلية';

  @override
  String get docPdfCommande => 'وصل طلبية';

  @override
  String get docPdfLivraison => 'وصل التسليم';

  @override
  String docArretee(String type) {
    return 'أوقفت هذه الوثيقة ($type) بمبلغ';
  }

  @override
  String get docMentionProforma => 'وثيقة دون قيمة محاسبية: لا تعتبر فاتورة.';

  @override
  String get docSignatureClient => 'موافقة الزبون';

  @override
  String get docSignatureVendeur => 'الختم والإمضاء';

  @override
  String get docSignatureLivreur => 'سلّمه';

  @override
  String get docSignatureReception => 'استلمه (الاسم، الإمضاء)';

  @override
  String get docErreurClient => 'زبون غير معروف';

  @override
  String get docErreurInconnu => 'الوثيقة غير موجودة';

  @override
  String get docErreurNonModifiable => 'لا يمكن تعديل هذه الوثيقة (محولة، مرفوضة، ملغاة أو مسلمة)';

  @override
  String get docErreurDejaAnnule => 'الوثيقة ملغاة مسبقا';

  @override
  String get docErreurLivraisonLiee => 'طلبية مسلمة: ألغ أولا بيع وصل التسليم';

  @override
  String get docErreurRienALivrer => 'لا توجد كمية للتسليم';

  @override
  String get docErreurQuantiteExcessive => 'كمية تفوق المتبقي للتسليم';

  @override
  String get docErreurLivraisonExistante => 'لهذا البيع وصل تسليم مسبقا';

  @override
  String get docErreurVenteInconnue => 'البيع غير موجود';

  @override
  String get cmdfDescriptionModule => 'طلبيات الموردين المستلمة في دخول واحد أو أكثر';

  @override
  String get cmdfNouvelle => 'طلبية مورد جديدة';

  @override
  String get cmdfModifier => 'تعديل طلبية المورد';

  @override
  String get cmdfFormDescription => 'المورد، مخزن الاستلام، التسليم المتوقع والمنتجات بسعر الشراء';

  @override
  String cmdfTitre(String code) {
    return 'طلبية المورد $code';
  }

  @override
  String get cmdfCommande => 'طلبية المورد';

  @override
  String get cmdfPrix => 'سعر الشراء';

  @override
  String get cmdfRecu => 'المستلم';

  @override
  String get cmdfReste => 'المتبقي للاستلام';

  @override
  String get cmdfReceptions => 'إدخالات الاستلام';

  @override
  String get cmdfReceptionner => 'استلام';

  @override
  String get cmdfSolder => 'تسوية';

  @override
  String cmdfSolderMessage(String code) {
    return 'تسوية الطلبية $code؟ لن يُنتظر الباقي.';
  }

  @override
  String get cmdfKpiAttendues => 'في انتظار الاستلام';

  @override
  String get cmdfStatutPartielle => 'مستلمة جزئيا';

  @override
  String get cmdfStatutRecue => 'مستلمة';

  @override
  String get cmdfStatutSoldee => 'مُسوّاة';

  @override
  String get cmdfPdfTitre => 'وصل طلبية المورد';

  @override
  String get cmdfDepuisBesoin => 'إنشاء طلبية مورد';

  @override
  String get cmdfErreurReceptionLiee => 'طلبية مستلمة: ألغ أولا الإدخالات المرتبطة';

  @override
  String get cmdfErreurDejaSoldee => 'الطلبية مسواة مسبقا';

  @override
  String entDepuisCommande(String code) {
    return 'استلام الطلبية $code';
  }

  @override
  String get apercuEnregistrerPdf => 'حفظ بصيغة PDF';

  @override
  String get rechercheGlobaleTitre => 'البحث الشامل';

  @override
  String get rechercheGlobaleIndice => 'ابحث في كامل النظام…';

  @override
  String get rechercheGlobaleAide =>
      'رمز، اسم، هاتف، رمز شريطي، مرجع: المنتجات، الزبائن، الموردون، المبيعات، الفواتير، عروض الأسعار، التسليمات، المدخلات، المرتجعات، الدفعات…';

  @override
  String rechercheGlobaleAucun(String texte) {
    return 'لا توجد نتائج لـ « $texte »';
  }

  @override
  String get prdPrixTtc => 'سعر البيع بالرسوم';

  @override
  String get prdVenteTtc => 'البيع بالرسوم';

  @override
  String get posClotureNegatif =>
      'الرصيد النظري سالب: خرج من هذا الصندوق نقد أكثر مما دخل منذ الفتح (انظر التفاصيل أعلاه). لا يمكن أن يحتوي الصندوق على أقل من 0: عدّ النقد الموجود فعلاً (0 إذا كان الدرج فارغاً)، وسيُسجل الفرق كعجز.';

  @override
  String get posTransfertTitre => 'مخزون غير كاف في هذا المخزن';

  @override
  String get posTransfertConfirmer => 'تحويل وإضافة';

  @override
  String posTransfertFait(String code) {
    return 'تم إنشاء التحويل $code';
  }

  @override
  String get posTransfertQuestion => 'تحويل الكمية الناقصة لإكمال السلة؟';

  @override
  String get posTransfertDepuis => 'من';

  @override
  String get posTransfertVers => 'إلى الصندوق';

  @override
  String posTransfertStock(String stock) {
    return 'المخزون: $stock';
  }

  @override
  String posTransfertManque(String quantite) {
    return 'ناقص $quantite';
  }

  @override
  String get pmTvaCaisse => 'البيع في الصندوق مع الرسم على القيمة المضافة';

  @override
  String get pmTvaCaisseDesc => 'نعم: السعر بكل الرسوم (السعر دون رسوم + الرسم). لا: السعر دون رسوم، تذكرة بدون رسم.';

  @override
  String get pmTvaDocuments => 'عروض الأسعار والفواتير الأولية والطلبيات مع الرسم';

  @override
  String get pmTvaDocumentsDesc => 'نفس الخيار لعروض الأسعار والفواتير الأولية وطلبيات الزبائن وتسليماتها.';

  @override
  String get docPuHt => 'س.و دون رسوم';

  @override
  String get retoursMontantRetour => 'مبلغ الإرجاع';

  @override
  String get retoursMontantRetourAideClient => 'يُرد للزبون نقدًا؛ والباقي رصيد دائن في حسابه.';

  @override
  String get retoursMontantRetourAideFournisseur => 'يدفعه المورد نقدًا؛ والباقي يُخصم مما تدينون له.';

  @override
  String get retoursMontantRetourPassage => 'زبون عابر: يسترجع كامل مبلغ الإرجاع.';

  @override
  String retoursMontantRetourMax(String plafond) {
    return 'بين 0 و $plafond';
  }

  @override
  String get retoursErreurMontant => 'مبلغ الإرجاع غير صالح: يجب أن يكون بين 0 ومبلغ الإرجاع.';

  @override
  String retoursRepartition(String avoir, String versement) {
    return 'دفعة $versement · رصيد دائن $avoir';
  }

  @override
  String get retoursMontantComplet => 'المبلغ كاملاً';
}
