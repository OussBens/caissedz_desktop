// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'CaisseDZ';

  @override
  String get shellNavGeneral => 'عام';

  @override
  String get shellNavStock => 'المخزون';

  @override
  String get shellNavTiers => 'الأطراف';

  @override
  String get shellNavGestion => 'الإدارة';

  @override
  String get shellFavoris => 'المفضلة';

  @override
  String get shellFavorisVide => 'لا توجد مفضلة. انقر بالزر الأيمن على وحدة لإضافتها.';

  @override
  String get shellFavorisMax => '7 مفضلات كحد أقصى';

  @override
  String get shellFavorisAjouter => 'إضافة إلى المفضلة';

  @override
  String get shellFavorisRetirer => 'إزالة من المفضلة';

  @override
  String get shellMenuModules => 'الوحدات';

  @override
  String get shellMenuModulesRaccourci => 'Ctrl+M';

  @override
  String get shellMenuModulesRecherche => 'البحث عن وحدة…';

  @override
  String get shellMenuModulesAucun => 'لا توجد وحدة مطابقة.';

  @override
  String get shellAlertes => 'التنبيهات';

  @override
  String get shellAlertesAucune => 'لا توجد تنبيهات';

  @override
  String get shellInternetConnecte => 'الإنترنت: متصل';

  @override
  String get shellInternetDeconnecte => 'الإنترنت: غير متصل';

  @override
  String get shellFenetreReduire => 'تصغير';

  @override
  String get shellFenetreAgrandir => 'تكبير';

  @override
  String get shellFenetreRestaurer => 'استعادة';

  @override
  String get shellFenetreFermer => 'إغلاق';

  @override
  String get shellReduireSidebar => 'طي القائمة';

  @override
  String get shellEtendreSidebar => 'توسيع القائمة';

  @override
  String get shellGalerie => 'معرض نظام التصميم';

  @override
  String modulePlaceholder(String nom) {
    return 'الوحدة « $nom » : متاحة في دفعة قادمة.';
  }

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
  String get moduleMonCompte => 'حسابي';

  @override
  String get communOk => 'موافق';

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
  String get communChargement => 'جارٍ التحميل…';

  @override
  String get communAucunResultat => 'لا توجد نتائج';

  @override
  String get communSelectionner => 'اختيار';

  @override
  String get communTotal => 'المجموع';

  @override
  String get communColonnes => 'الأعمدة';

  @override
  String get communToutSelectionner => 'تحديد الكل';

  @override
  String get communLignesParPage => 'أسطر في الصفحة';

  @override
  String communPagination(int debut, int fin, int total) {
    return '$debut–$fin من $total';
  }

  @override
  String get communPagePrecedente => 'الصفحة السابقة';

  @override
  String get communPageSuivante => 'الصفحة التالية';

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
  String get activationDemo => 'تجربة الوضع التجريبي';

  @override
  String get activationDemoAide =>
      'يفتح الوضع التجريبي كل الوظائف (رخصة متقدم) بالحساب demo / demo. البيانات المدخلة ليست للاستعمال الفعلي.';

  @override
  String get activationErreurFormat => 'يجب أن يحتوي المفتاح على 64 حرفًا سداسيًا عشريًا بالضبط (0-9، a-f).';

  @override
  String get activationErreurInconnue => 'مفتاح غير صالح لهذا الجهاز — تحقق من المعرّف المرسل.';

  @override
  String activationReussie(String niveau) {
    return 'تم تفعيل رخصة $niveau.';
  }

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
  String get licenceRequise => 'وظيفة متاحة مع الرخصة المتقدمة';

  @override
  String get licenceRequiseDetail => 'رخصتك الحالية أساسية. فعّل رخصة متقدمة للوصول إلى هذه الوحدة.';

  @override
  String get licenceGererCle => 'تفعيل مفتاح آخر';

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
  String configEtape(int n, int total) {
    return 'الخطوة $n من $total';
  }

  @override
  String get configEtapeBoutique => 'المتجر';

  @override
  String get configEtapeAdmin => 'المدير';

  @override
  String get configEtapeVente => 'الهامش والمخزون';

  @override
  String get configEtapeRecap => 'الملخص';

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
  String get configAdminIntro => 'سيملك حساب المدير هذا كل الصلاحيات. اختر معرّفًا وكلمة مرور.';

  @override
  String get configAdminNom => 'الاسم المعروض';

  @override
  String get configAdminMotDePasseConfirmation => 'تأكيد كلمة المرور';

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
  String get configRecapIntro => 'تحقق من المعلومات قبل الإنهاء. يمكنك تعديلها لاحقًا في الإعدادات.';

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
  String get configReussie => 'اكتمل الإعداد. سجّل الدخول بحساب المدير.';

  @override
  String get compteTitre => 'حسابي';

  @override
  String get compteRole => 'الدور';

  @override
  String get compteIdentifiantActuel => 'المعرّف الحالي';

  @override
  String get compteNouvelIdentifiant => 'المعرّف الجديد';

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
  String get accesRefuseTitre => 'الوصول مرفوض';

  @override
  String accesRefuseMessage(String role, String module) {
    return 'دورك « $role » لا يملك صلاحية الوصول إلى الوحدة « $module ». اطلب من مدير.';
  }

  @override
  String get accesRefuseRetour => 'العودة إلى لوحة القيادة';

  @override
  String get rolesTitre => 'الأدوار والصلاحيات';

  @override
  String get rolesIntro => 'حدد صلاحيات الإجراءات والوحدات المتاحة لكل دور. يحتفظ المدير دائمًا بكل الصلاحيات.';

  @override
  String get rolesPermissions => 'صلاحيات الإجراءات';

  @override
  String get rolesModules => 'الوحدات المتاحة';

  @override
  String get rolesEnregistre => 'تم حفظ شبكة الأدوار.';

  @override
  String get rolesAdminTotal => 'كل الصلاحيات';

  @override
  String get permVoirPrixAchat => 'عرض سعر الشراء';

  @override
  String get permModifierPrix => 'تعديل السعر في الصندوق';

  @override
  String get permAppliquerRemise => 'تطبيق تخفيض';

  @override
  String get permAnnulerVente => 'إلغاء بيع';

  @override
  String get permSupprimerDocument => 'حذف مستند';

  @override
  String get permExporterDonnees => 'تصدير البيانات';

  @override
  String get permGererUtilisateurs => 'إدارة المستخدمين';

  @override
  String get roleAdmin => 'مدير';

  @override
  String get roleCaissier => 'أمين الصندوق';

  @override
  String get roleMagasinier => 'أمين المخزن';

  @override
  String get parametresRolesCarte => 'الأدوار والصلاحيات';

  @override
  String get parametresRolesCarteDetail => 'صلاحيات الإجراءات والوحدات المتاحة حسب الدور.';

  @override
  String get parametresLicenceCarte => 'الرخصة';

  @override
  String get shellBandeauDemo => 'وضع تجريبي — البيانات ليست للاستعمال الفعلي';

  @override
  String get shellMenuUtilisateur => 'قائمة المستخدم';

  @override
  String get shellVerrouille => 'مخصص للرخصة المتقدمة';

  @override
  String get shellAccesRestreint => 'وصول غير مسموح لدورك';

  @override
  String get produitsTitre => 'المنتجات';

  @override
  String get produitsOngletProduits => 'المنتجات';

  @override
  String get produitsOngletCategories => 'الفئات';

  @override
  String get produitsOngletColis => 'الطرود';

  @override
  String get produitsOngletPacks => 'الحزم';

  @override
  String get produitsOngletRemises => 'التخفيضات';

  @override
  String get produitsNouveau => 'منتج جديد';

  @override
  String get produitsModeIa => 'وضع الذكاء الاصطناعي';

  @override
  String get produitsImporter => 'استيراد Excel';

  @override
  String get produitsEtiquettes => 'الملصقات';

  @override
  String get produitsSynchro => 'مزامنة الكتالوج';

  @override
  String get produitsRecherche => 'البحث بالاسم أو الرمز أو الباركود…';

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
  String get produitsColPrixVente => 'سعر البيع';

  @override
  String get produitsColMarge => 'الهامش %';

  @override
  String get produitsColActif => 'نشط';

  @override
  String get produitsColStock => 'المخزون';

  @override
  String get produitsAucun => 'لا توجد منتجات. أنشئ منتجًا أو استورد ملف Excel.';

  @override
  String get produitModifier => 'تعديل المنتج';

  @override
  String get produitDesactiver => 'تعطيل';

  @override
  String get produitActiver => 'تفعيل';

  @override
  String get produitGenererCodeBarres => 'توليد باركود داخلي';

  @override
  String get produitChampDesignation => 'التسمية';

  @override
  String get produitChampCodeBarres => 'الباركود (EAN-13 أو داخلي)';

  @override
  String get produitChampCategorie => 'الفئة';

  @override
  String get produitChampSousCategorie => 'الفئة الفرعية';

  @override
  String get produitChampPrixAchat => 'سعر الشراء';

  @override
  String get produitChampPrixVente => 'سعر البيع';

  @override
  String get produitChampMarge => 'الهامش (%)';

  @override
  String get produitChampUnite => 'الوحدة';

  @override
  String get produitChampTva => 'الضريبة (%)';

  @override
  String get produitChampSeuil => 'حد التنبيه (فارغ = الحد العام)';

  @override
  String get produitChampSuiviNombre => 'تتبع مخزون ثانٍ « بالعدد » (قطع)';

  @override
  String get produitChampSuiviNombreAide => 'يُباع المنتج بالوحدة أو بالقطعة؛ يُحفظ المخزون في الاثنين.';

  @override
  String get produitChampNombreParUnite => 'قطع لكل وحدة';

  @override
  String get produitPrixAuto => 'يُحسب سعر البيع من الهامش إذا تركته فارغًا.';

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
  String produitCree(String nom, String code) {
    return 'تم إنشاء المنتج « $nom » ($code).';
  }

  @override
  String get iaTitre => 'منتج جديد بالذكاء الاصطناعي';

  @override
  String get iaIntro =>
      'امسح أو أدخل باركودًا: يُبحث عن البطاقة في CaisseDZ ثم Mantouj ثم Open Food Facts ثم Open Beauty Facts.';

  @override
  String get iaRechercher => 'بحث';

  @override
  String get iaRechercheEnCours => 'جارٍ البحث…';

  @override
  String get iaAucun => 'لم يُعثر على بطاقة لهذا الباركود: انتقل إلى الإدخال التفصيلي.';

  @override
  String iaTrouve(String source) {
    return 'بطاقة موجودة عبر $source';
  }

  @override
  String get iaMarque => 'العلامة';

  @override
  String get iaCreer => 'إنشاء المنتج';

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
  String get importTelechargerModele => 'حفظ النموذج';

  @override
  String importLignesValides(int n) {
    return '$n سطر صالح';
  }

  @override
  String importLignesInvalides(int n) {
    return '$n سطر متجاهل';
  }

  @override
  String get importColLigne => 'السطر';

  @override
  String get importColErreur => 'الخطأ';

  @override
  String get importLancer => 'استيراد';

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
  String get etiquettesTitre => 'طباعة الملصقات';

  @override
  String get etiquettesQuantite => 'الكمية';

  @override
  String get etiquettesFormatA4 => 'ورقة A4';

  @override
  String get etiquettesFormatRouleau => 'لفافة';

  @override
  String get etiquettesAfficherPrix => 'إظهار السعر';

  @override
  String get etiquettesQr => 'رمز QR بدل الباركود';

  @override
  String get etiquettesGenerer => 'توليد PDF';

  @override
  String get etiquettesAucuneSelection => 'اختر منتجًا واحدًا على الأقل من القائمة.';

  @override
  String synchroResultat(int envoyes, int recus) {
    return 'المزامنة: $envoyes مرسل، $recus محدّث.';
  }

  @override
  String get synchroNonConfiguree => 'أدخل عنوان خادم CaisseDZ في الإعدادات لمزامنة الكتالوج.';

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
  String get categorieRenommer => 'إعادة التسمية';

  @override
  String get categorieSupprimer => 'حذف';

  @override
  String get categorieSousCategories => 'الفئات الفرعية';

  @override
  String get categorieErreurSysteme => 'لا يمكن تعديل فئة النظام.';

  @override
  String get categorieErreurUtilisee => 'توجد منتجات مرتبطة بهذه الفئة.';

  @override
  String categorieConfirmerSuppression(String nom) {
    return 'حذف الفئة « $nom » وفئاتها الفرعية؟';
  }

  @override
  String get colisNouveau => 'طرد جديد';

  @override
  String get colisProduit => 'المنتج';

  @override
  String get colisQuantite => 'وحدات لكل طرد';

  @override
  String get colisAucun => 'لا توجد طرود.';

  @override
  String get packNouveau => 'حزمة جديدة';

  @override
  String get packLignes => 'التركيبة';

  @override
  String get packAjouterProduit => 'إضافة منتج';

  @override
  String get packAucun => 'لا توجد حزم.';

  @override
  String get packErreurLignes => 'أضف منتجًا واحدًا على الأقل إلى الحزمة.';

  @override
  String get remiseNouvelle => 'تخفيض جديد';

  @override
  String get remiseType => 'النوع';

  @override
  String get remiseTypePourcentage => 'نسبة مئوية';

  @override
  String get remiseTypeMontant => 'مبلغ';

  @override
  String get remiseValeur => 'القيمة';

  @override
  String get remisePortee => 'النطاق';

  @override
  String get remisePorteeGlobale => 'كل المنتجات';

  @override
  String get remisePorteeCategorie => 'فئة';

  @override
  String get remisePorteeProduit => 'منتج';

  @override
  String get remiseDebut => 'البداية';

  @override
  String get remiseFin => 'النهاية';

  @override
  String get remiseAucune => 'لا توجد تخفيضات.';

  @override
  String get communNouveau => 'جديد';

  @override
  String get communModifier => 'تعديل';

  @override
  String get communActif => 'نشط';

  @override
  String get communInactif => 'غير نشط';

  @override
  String get communOui => 'نعم';

  @override
  String get communNon => 'لا';

  @override
  String get communValider => 'تأكيد';

  @override
  String get communApercu => 'معاينة';

  @override
  String get communImprimer => 'طباعة';

  @override
  String get communAucune => 'لا شيء';

  @override
  String get stockTitre => 'المخزون';

  @override
  String get stockOngletNiveaux => 'المستويات';

  @override
  String get stockOngletJournal => 'سجل الحركات';

  @override
  String get stockColProduit => 'المنتج';

  @override
  String get stockColMagasin => 'المخزن';

  @override
  String get stockColQuantite => 'الكمية';

  @override
  String get stockColNombre => 'العدد (قطع)';

  @override
  String get stockColSeuil => 'الحد';

  @override
  String get stockColDate => 'التاريخ';

  @override
  String get stockColType => 'النوع';

  @override
  String get stockColMotif => 'السبب';

  @override
  String get stockColReference => 'المرجع';

  @override
  String get stockColUtilisateur => 'المستخدم';

  @override
  String get stockColCommentaire => 'تعليق';

  @override
  String get stockColValeur => 'القيمة (سعر الشراء)';

  @override
  String get stockTousMagasins => 'كل المخازن';

  @override
  String get stockSousSeuil => 'تحت الحد';

  @override
  String get stockEntreeManuelle => 'إدخال يدوي';

  @override
  String get stockInventaire => 'جرد';

  @override
  String get stockQuantiteConstatee => 'الكمية المعاينة';

  @override
  String get stockNombreConstate => 'العدد المعاين';

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
  String get magasinsTitre => 'المخازن';

  @override
  String get magasinNouveau => 'مخزن جديد';

  @override
  String get magasinNom => 'الاسم';

  @override
  String get magasinAdresse => 'العنوان';

  @override
  String get magasinPrincipal => 'رئيسي';

  @override
  String get magasinMesMagasins => 'مخازني (الأول هو الرئيسي)';

  @override
  String get magasinAjouterAuxMiens => 'إضافة إلى مخازني';

  @override
  String get magasinRetirerDesMiens => 'إزالة من مخازني';

  @override
  String get magasinDefinirPrincipal => 'تعيين كرئيسي';

  @override
  String get transfertsTitre => 'التحويلات';

  @override
  String get transfertNouveau => 'تحويل جديد';

  @override
  String get transfertSource => 'المخزن المصدر';

  @override
  String get transfertDestination => 'مخزن الوجهة';

  @override
  String get transfertLignes => 'الأسطر';

  @override
  String get transfertAjouterLigne => 'إضافة منتج';

  @override
  String get transfertAucun => 'لا توجد تحويلات.';

  @override
  String transfertCree(String code) {
    return 'تم تسجيل التحويل $code: حركتان لكل سطر.';
  }

  @override
  String get besoinsTitre => 'الاحتياجات';

  @override
  String get besoinNouveau => 'احتياج جديد';

  @override
  String get besoinGenerer => 'توليد تحت الحد';

  @override
  String besoinGeneres(int n) {
    return 'تم توليد $n احتياج.';
  }

  @override
  String get besoinStatut => 'الحالة';

  @override
  String get besoinPasserCommande => 'تحويل إلى طلبية';

  @override
  String get besoinPasserDisponible => 'تحويل إلى متوفر';

  @override
  String get besoinRemettreAttente => 'إعادة إلى قيد الانتظار';

  @override
  String get besoinAucun => 'لا توجد احتياجات.';

  @override
  String get statutBesoinEnAttente => 'قيد الانتظار';

  @override
  String get statutBesoinCommande => 'طلبية';

  @override
  String get statutBesoinDisponible => 'متوفر';

  @override
  String get sortiesTitre => 'الإخراجات';

  @override
  String get sortiesOngletSorties => 'الإخراجات';

  @override
  String get sortiesOngletVentes => 'المبيعات';

  @override
  String get sortieNouvelle => 'إخراج جديد';

  @override
  String get sortieMotif => 'السبب';

  @override
  String get sortieAucune => 'لا توجد إخراجات.';

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
  String communLignes(int n) {
    return '$n سطر';
  }

  @override
  String get communCommentaire => 'تعليق';

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
  String get posRaccourciF5 => 'تحصيل وصل التسليم';

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
  String get ventesTitre => 'المبيعات';

  @override
  String get ventesColTicket => 'التذكرة';

  @override
  String get ventesColClient => 'الزبون';

  @override
  String get ventesColNet => 'الصافي';

  @override
  String get ventesColVerse => 'المدفوع';

  @override
  String get ventesColReste => 'المتبقي';

  @override
  String get ventesColStatut => 'الحالة';

  @override
  String get ventesColCaisse => 'الصندوق';

  @override
  String get ventesColVendeur => 'البائع';

  @override
  String get ventesAucune => 'لا توجد مبيعات.';

  @override
  String get ventesVoirTicket => 'عرض التذكرة';

  @override
  String get ventesAnnuler => 'إلغاء البيع';

  @override
  String ventesConfirmerAnnulation(String code) {
    return 'إلغاء البيع $code؟ سيُعاد المخزون والنقاط؛ تبقى التذكرة المختومة محفوظة.';
  }

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
  String get ventesFiltreToutes => 'الكل';

  @override
  String get ventesFiltreValidees => 'مؤكدة';

  @override
  String get ventesFiltreAnnulees => 'ملغاة';

  @override
  String get ventesFiltreCredit => 'بالدين';

  @override
  String get statutVenteValidee => 'مؤكدة';

  @override
  String get statutVenteAnnulee => 'ملغاة';

  @override
  String ticketDetail(String code) {
    return 'التذكرة $code';
  }

  @override
  String get retoursTitre => 'المرتجعات';

  @override
  String get retourNouveau => 'مرتجع جديد';

  @override
  String get retourVente => 'البيع الأصلي';

  @override
  String get retourMotif => 'السبب';

  @override
  String get retourRembourser => 'المبلغ المسترجع';

  @override
  String get retourModeRemboursement => 'طريقة الاسترجاع';

  @override
  String get retourAvoir => 'يُسجل الباقي كرصيد في حساب الزبون.';

  @override
  String get retourAucun => 'لا توجد مرتجعات.';

  @override
  String get retourColTotal => 'إجمالي المرتجع';

  @override
  String get retourColRembourse => 'المسترجع';

  @override
  String retourQuantiteMax(String max) {
    return 'الكمية المرتجعة (الحد $max)';
  }

  @override
  String get retourErreurVenteInconnue => 'البيع غير موجود.';

  @override
  String get retourErreurVenteAnnulee => 'هذا البيع ملغى.';

  @override
  String get retourErreurLignes => 'حدد كمية واحدة على الأقل للإرجاع.';

  @override
  String get retourErreurQuantite => 'كمية غير صالحة.';

  @override
  String get retourErreurDepasse => 'الكمية أكبر من الكمية المباعة (بما فيها المرتجع سابقًا).';

  @override
  String get retourErreurPeriode => 'فترة مقفلة: الإرجاع غير ممكن.';

  @override
  String retourCree(String code, String total, String rembourse) {
    return 'تم تسجيل المرتجع $code: $total (مسترجع $rembourse).';
  }

  @override
  String get clientsTitre => 'العملاء';

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
  String get clientPlafond => 'سقف الدين';

  @override
  String get clientSolde => 'الرصيد المستحق';

  @override
  String get clientAucun => 'لا يوجد عملاء.';

  @override
  String get clientFiche => 'بطاقة العميل';

  @override
  String get clientDocumentsOuverts => 'المستندات المفتوحة';

  @override
  String get clientVersements => 'الدفعات';

  @override
  String get clientNouveauVersement => 'تحصيل دفعة';

  @override
  String get fournisseursTitre => 'الموردون';

  @override
  String get fournisseurNouveau => 'مورد جديد';

  @override
  String get fournisseurAucun => 'لا يوجد موردون.';

  @override
  String get fournisseurFiche => 'بطاقة المورد';

  @override
  String get fournisseurNouveauVersement => 'تسديد دفعة';

  @override
  String get versementsTitre => 'الدفعات';

  @override
  String get versementNouveau => 'دفعة جديدة';

  @override
  String get versementTiers => 'الطرف';

  @override
  String get versementTiersClient => 'عميل';

  @override
  String get versementTiersFournisseur => 'مورد';

  @override
  String get versementMontant => 'المبلغ';

  @override
  String get versementMode => 'الطريقة';

  @override
  String get versementReference => 'المرجع';

  @override
  String get versementAucun => 'لا توجد دفعات.';

  @override
  String get versementColSens => 'الاتجاه';

  @override
  String get versementColImpute => 'المخصص';

  @override
  String get versementColNonImpute => 'غير المخصص';

  @override
  String versementVerrouille(String retour) {
    return 'مقفل (مرتبط بالمرتجع $retour)';
  }

  @override
  String get versementImputations => 'التخصيصات (الأقدم أولاً)';

  @override
  String get versementSupprimer => 'حذف الدفعة';

  @override
  String versementConfirmerSuppression(String code) {
    return 'حذف الدفعة $code؟ ستُلغى التخصيصات.';
  }

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
  String versementEnregistre(String code, String impute, String reste) {
    return 'تم تسجيل الدفعة $code: $impute مخصص، $reste كسلفة.';
  }

  @override
  String get sensEncaissement => 'تحصيل';

  @override
  String get sensDecaissement => 'صرف';

  @override
  String get tiersErreurNom => 'الاسم إلزامي.';

  @override
  String get tiersErreurSysteme => 'لا يمكن تعديل الطرف النظامي.';

  @override
  String get achatsTitre => 'الإدخالات / المشتريات';

  @override
  String get achatNouveau => 'إدخال جديد';

  @override
  String get achatSmartScan => 'Smart Scan IA';

  @override
  String get achatFournisseur => 'المورد';

  @override
  String get achatReference => 'مرجع الفاتورة';

  @override
  String get achatMagasin => 'المخزن';

  @override
  String get achatLignes => 'الأسطر';

  @override
  String get achatPrixAchat => 'سعر الشراء';

  @override
  String get achatNouveauPrixVente => 'سعر البيع الجديد';

  @override
  String get achatVerse => 'المدفوع';

  @override
  String get achatModePaiement => 'طريقة الدفع';

  @override
  String get achatMettreAJourPrix => 'تحديث سعر شراء المنتجات';

  @override
  String get achatAucun => 'لا توجد إدخالات.';

  @override
  String get achatColTotal => 'المجموع';

  @override
  String get achatColVerse => 'المدفوع';

  @override
  String get achatColReste => 'المتبقي';

  @override
  String get achatColSource => 'المصدر';

  @override
  String get achatColStatut => 'الحالة';

  @override
  String get achatAnnuler => 'إلغاء الإدخال';

  @override
  String achatConfirmerAnnulation(String code) {
    return 'إلغاء الإدخال $code؟ سيُخرج المخزون.';
  }

  @override
  String achatEnregistre(String code, String total, String reste) {
    return 'تم تسجيل الإدخال $code: $total، المتبقي $reste.';
  }

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
  String get statutAchatValide => 'مؤكد';

  @override
  String get statutAchatAnnule => 'ملغى';

  @override
  String get sourceManuel => 'يدوي';

  @override
  String get sourceSmartScan => 'Smart Scan';

  @override
  String get smartScanTitre => 'Smart Scan IA — فاتورة المورد';

  @override
  String get smartScanIntro =>
      'صوّر الفاتورة أو اخترها (صورة أو PDF): يتعرف خادم CaisseDZ على الأسطر ويقارنها بالكتالوج.';

  @override
  String smartScanQuota(int restant, int total) {
    return 'الحصة: $restant تحليل متبقٍ من $total';
  }

  @override
  String get smartScanChoisir => 'اختيار فاتورة';

  @override
  String get smartScanAnalyser => 'تحليل';

  @override
  String get smartScanAnalyse => 'جارٍ التحليل…';

  @override
  String get smartScanAucuneLigne => 'لم يُتعرف على أي سطر.';

  @override
  String get smartScanLigneNonRapprochee => 'غير مطابق';

  @override
  String get smartScanRapprocher => 'ربط بمنتج';

  @override
  String get smartScanCreerEntree => 'إنشاء الإدخال';

  @override
  String get smartScanQuotaAtteint => 'تم بلوغ حصة Smart Scan';

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
  String get gestionCaisseTitre => 'إدارة الصندوق';

  @override
  String get gestionCaisseOngletCaisses => 'الصناديق';

  @override
  String get gestionCaisseOngletMouvements => 'الحركات';

  @override
  String get gestionCaisseOngletTransferts => 'التحويلات بين الصناديق';

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
  String get caisseSansMagasin => 'بدون مخزن';

  @override
  String get caisseActive => 'نشط';

  @override
  String get caisseInactive => 'غير نشط';

  @override
  String get caisseSoldeEspeces => 'رصيد نقدي';

  @override
  String get caisseSoldeTotal => 'الرصيد الإجمالي';

  @override
  String get caisseTypePhysique => 'مادي';

  @override
  String get caisseTypeCompte => 'حساب';

  @override
  String get caisseAucune => 'لا يوجد صندوق.';

  @override
  String get caisseDesactiver => 'تعطيل';

  @override
  String get caisseActiver => 'تفعيل';

  @override
  String get mouvementApport => 'إيداع';

  @override
  String get mouvementDepense => 'مصروف';

  @override
  String get mouvementColType => 'النوع';

  @override
  String get mouvementColSens => 'الاتجاه';

  @override
  String get mouvementColMontant => 'المبلغ';

  @override
  String get mouvementColMode => 'الوسيلة';

  @override
  String get mouvementColReference => 'المرجع';

  @override
  String get mouvementAucun => 'لا توجد حركات.';

  @override
  String get mouvementToutesCaisses => 'كل الصناديق';

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
  String get sensEntree => 'دخول';

  @override
  String get sensSortie => 'خروج';

  @override
  String get transfertCaisseNouveau => 'تحويل جديد';

  @override
  String get transfertCaisseSource => 'الصندوق المصدر';

  @override
  String get transfertCaisseDestination => 'الصندوق الوجهة';

  @override
  String get transfertCaisseAucun => 'لا توجد تحويلات.';

  @override
  String transfertCaisseCree(String code) {
    return 'تم تسجيل التحويل $code (حركتان).';
  }

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
  String get cloturesTitre => 'إقفالات Z';

  @override
  String get clotureNouvelle => 'إقفال (Z)';

  @override
  String get clotureApercuTitre => 'إقفال Z — معاينة الفترة';

  @override
  String get cloturePeriode => 'الفترة';

  @override
  String get clotureDebut => 'البداية';

  @override
  String get clotureFin => 'النهاية';

  @override
  String get clotureColVentes => 'المبيعات';

  @override
  String get clotureColAnnulations => 'الإلغاءات';

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
  String get clotureColHash => 'الختم';

  @override
  String get clotureColUtilisateur => 'المستخدم';

  @override
  String get clotureAucune => 'لا يوجد إقفال.';

  @override
  String get clotureConfirmer => 'ختم الإقفال';

  @override
  String clotureCreee(String code, String hash) {
    return 'تم ختم الإقفال $code. البصمة: $hash';
  }

  @override
  String get clotureDetail => 'تفاصيل الإقفال';

  @override
  String get clotureParMode => 'التحصيلات حسب الوسيلة';

  @override
  String get clotureSoldes => 'أرصدة الصناديق';

  @override
  String get clotureDerniereVente => 'آخر تذكرة';

  @override
  String get clotureHashPrecedent => 'البصمة السابقة';

  @override
  String get clotureHash => 'البصمة';

  @override
  String get clotureVerifier => 'التحقق من السلسلة';

  @override
  String get clotureChaineOk => 'سلسلة الإقفالات سليمة.';

  @override
  String clotureChaineKo(String code) {
    return 'سلسلة معدّلة ابتداءً من الإقفال $code.';
  }

  @override
  String get clotureErreurSession => 'أغلق جميع جلسات الصندوق قبل الإقفال.';

  @override
  String get clotureErreurRien => 'لا شيء للإقفال منذ آخر إقفال.';

  @override
  String get clotureAvertissementImmuable =>
      'الإقفال نهائي: لا يمكن تعديله أو حذفه، ولن يمكن إلغاء مستندات الفترة بعد ذلك.';

  @override
  String get exportFiscalTitre => 'التصدير الجبائي';

  @override
  String get exportFiscalDebut => 'من (يوم/شهر/سنة)';

  @override
  String get exportFiscalFin => 'إلى (يوم/شهر/سنة)';

  @override
  String get exportFiscalGenerer => 'إنشاء الأرشيف';

  @override
  String exportFiscalOk(String chemin, int ventes, int clotures) {
    return 'تم حفظ الأرشيف: $chemin ($ventes مبيعات، $clotures إقفالات، تم التحقق من البصمة).';
  }

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
  String get exportFiscalPermission => 'مطلوب إذن « تصدير البيانات ».';

  @override
  String get tableauBordTitre => 'لوحة القيادة';

  @override
  String get tableauBordCaJour => 'رقم أعمال اليوم';

  @override
  String get tableauBordTicketsJour => 'تذاكر اليوم';

  @override
  String get tableauBordPanierMoyen => 'متوسط السلة';

  @override
  String get tableauBordCaMois => 'رقم أعمال الشهر';

  @override
  String get tableauBordSousSeuil => 'منتجات تحت الحد';

  @override
  String get tableauBordCreances => 'ديون الزبائن';

  @override
  String get tableauBordCa30Jours => 'رقم الأعمال خلال 30 يومًا';

  @override
  String get tableauBordPaiements => 'التحصيلات حسب الوسيلة (30 يومًا)';

  @override
  String get tableauBordTopProduits => 'أفضل 5 منتجات (30 يومًا)';

  @override
  String get tableauBordCategories => 'المبيعات حسب الفئة (30 يومًا)';

  @override
  String get tableauBordCaMensuel => 'رقم الأعمال الشهري (12 شهرًا)';

  @override
  String get tableauBordActualiser => 'تحديث';

  @override
  String get situationTitre => 'الوضعية';

  @override
  String get situationRapport => 'التقرير';

  @override
  String get situationDu => 'من (يوم/شهر/سنة)';

  @override
  String get situationAu => 'إلى (يوم/شهر/سنة)';

  @override
  String get situationAfficher => 'عرض';

  @override
  String get situationExportExcel => 'تصدير Excel';

  @override
  String get situationApercuPdf => 'معاينة PDF';

  @override
  String get situationAucuneLigne => 'لا توجد بيانات في هذه الفترة.';

  @override
  String get situationDatesInvalides => 'تواريخ غير صالحة.';

  @override
  String situationExportOk(String chemin) {
    return 'تم حفظ الملف: $chemin';
  }

  @override
  String situationPeriode(String debut, String fin) {
    return 'الفترة من $debut إلى $fin';
  }

  @override
  String get rapportVentesJour => 'المبيعات حسب اليوم';

  @override
  String get rapportVentesProduit => 'المبيعات حسب المنتج';

  @override
  String get rapportVentesCategorie => 'المبيعات حسب الفئة';

  @override
  String get rapportVentesClient => 'المبيعات حسب الزبون';

  @override
  String get rapportVentesVendeur => 'المبيعات حسب البائع والصندوق';

  @override
  String get rapportEncaissementsMode => 'التحصيلات حسب الوسيلة';

  @override
  String get rapportAchatsFournisseur => 'المشتريات حسب المورد';

  @override
  String get rapportRetours => 'مرتجعات الزبائن';

  @override
  String get rapportEtatStock => 'حالة المخزون المقيّم';

  @override
  String get rapportCreancesDettes => 'الديون والمستحقات';

  @override
  String get zakatTitre => 'الزكاة';

  @override
  String get zakatIntro => 'زكاة عروض التجارة: 2.5٪ من الوعاء إذا بلغ النصاب (85 غ ذهب).';

  @override
  String zakatPrixOr(String devise) {
    return 'سعر غرام الذهب ($devise)';
  }

  @override
  String get zakatEnregistrerPrix => 'حفظ السعر';

  @override
  String get zakatStock => 'المخزون (سعر الشراء)';

  @override
  String get zakatCaisses => 'الصناديق';

  @override
  String get zakatCreances => 'ديون الزبائن';

  @override
  String get zakatDettes => 'مستحقات الموردين';

  @override
  String get zakatAssiette => 'الوعاء';

  @override
  String get zakatNissab => 'النصاب (85 غ)';

  @override
  String get zakatMontant => 'الزكاة الواجبة (2.5٪)';

  @override
  String get zakatAssujetti => 'واجبة: الوعاء بلغ النصاب.';

  @override
  String get zakatNonAssujetti => 'غير واجبة: الوعاء أقل من النصاب.';

  @override
  String get zakatPrixManquant => 'أدخل سعر الذهب لحساب النصاب.';

  @override
  String get historiqueTitre => 'السجل';

  @override
  String get historiqueColUtilisateur => 'المستخدم';

  @override
  String get historiqueColAction => 'الإجراء';

  @override
  String get historiqueColEntite => 'الكيان';

  @override
  String get historiqueColDetail => 'التفاصيل';

  @override
  String get historiqueToutesEntites => 'كل الكيانات';

  @override
  String get historiqueAucun => 'لا توجد عمليات.';

  @override
  String get parametresTitre => 'الإعدادات';

  @override
  String get parametresOngletGeneral => 'عام';

  @override
  String get parametresOngletBoutique => 'المتجر';

  @override
  String get parametresOngletVente => 'البيع';

  @override
  String get parametresOngletImpression => 'الطباعة';

  @override
  String get parametresOngletServeur => 'الخوادم';

  @override
  String get parametresOngletSauvegarde => 'النسخ الاحتياطي';

  @override
  String get parametresEnregistre => 'تم حفظ الإعدادات.';

  @override
  String get parametresBoutiqueNom => 'اسم المتجر';

  @override
  String get parametresBoutiqueRc => 'السجل التجاري';

  @override
  String get parametresBoutiqueNif => 'الرقم الجبائي';

  @override
  String get parametresBoutiqueAdresse => 'العنوان';

  @override
  String get parametresBoutiqueTelephone => 'الهاتف';

  @override
  String get parametresBoutiqueEmail => 'البريد الإلكتروني';

  @override
  String get parametresMarge => 'الهامش الافتراضي (٪)';

  @override
  String get parametresDevise => 'العملة';

  @override
  String get parametresSeuil => 'حد المخزون العام';

  @override
  String get parametresFidelite => 'برنامج الولاء';

  @override
  String get parametresPoints => 'نقاط لكل دينار';

  @override
  String get parametresGardeStock => 'حماية المخزون: مفعّلة دائمًا (لا بيع بدون مخزون).';

  @override
  String get parametresImprimanteType => 'نوع الطابعة';

  @override
  String get parametresImprimanteAdresse => 'طابور Windows أو عنوان IP:port';

  @override
  String get parametresImprimanteLargeur => 'عرض التذكرة';

  @override
  String get parametresImprimanteNormale => 'عادية (نافذة الطباعة)';

  @override
  String get parametresImprimanteUsb => 'USB (طابور Windows)';

  @override
  String get parametresImprimanteReseau => 'شبكة (IP:port)';

  @override
  String get parametresImprimanteBluetooth => 'بلوتوث';

  @override
  String get parametresServeurUrl => 'عنوان خادم CaisseDZ';

  @override
  String get parametresServeurCle => 'مفتاح API';

  @override
  String get parametresMantoujUrl => 'عنوان كتالوج Mantouj';

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
  String get sauvegardeCreer => 'إنشاء نسخة احتياطية';

  @override
  String get sauvegardeRestaurer => 'استعادة نسخة احتياطية';

  @override
  String get sauvegardeMotDePasse => 'كلمة مرور النسخة';

  @override
  String get sauvegardeFichier => 'ملف النسخة الاحتياطية';

  @override
  String get sauvegardeChoisirFichier => 'اختيار الملف…';

  @override
  String sauvegardeOk(String chemin) {
    return 'تم حفظ النسخة: $chemin';
  }

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
  String get dsFavori => 'مفضّل';

  @override
  String get dsAjouterFavoris => 'إضافة إلى المفضلة';

  @override
  String get dsRetirerFavoris => 'إزالة من المفضلة';

  @override
  String get dsFavorisComplets => 'المفضلة ممتلئة';

  @override
  String get dsAucunModule => 'لا توجد وحدة';

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
  String get dsChoisirListe => 'اختيار من القائمة';

  @override
  String get dsRechercher => 'بحث';

  @override
  String get dsSelectionner => 'تحديد';

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
  String get dsBarcodeFormatLibre => 'تنسيق حر (ليس EAN-13)';

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
  String get tiersSolde => 'الرصيد';

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
  String get tableauBordVsPrecedente => 'مقارنة بالفترة السابقة';

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
  String get statutTicket => 'تذكرة';

  @override
  String get statutFacture => 'BL / SC';

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
  String get retoursNouveau => 'مرتجع جديد';

  @override
  String get retoursModifierTitre => 'تعديل المرتجع';

  @override
  String get retoursFormDescription => 'إرجاع منتج مباع (زبون) أو مستلم (مورد). يُعاد المخزون أو يُخصم.';

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
  String get posBlSc => 'وصل / بدون ختم';

  @override
  String get posEncaisserBouton => 'تحصيل';

  @override
  String get posEncTicketTitre => 'تحصيل التذكرة';

  @override
  String get posEncBlscTitre => 'تحصيل وصل التسليم';

  @override
  String get posEncSaveTitre => 'حفظ التذكرة';

  @override
  String get posEncTicketDesc => 'تحقق من المبلغ المستلم ثم أكّد: تُطبع التذكرة.';

  @override
  String get posEncBlscDesc => 'وصل تسليم بدون ختم، مع البيانات القانونية.';

  @override
  String get posEncSaveDesc => 'تُحفظ التذكرة: يُسجَّل الباقي دينًا على الزبون.';

  @override
  String get posEncTicketOk => 'تحصيل وطباعة';

  @override
  String get posEncBlscOk => 'تحصيل الوصل';

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
  String get posSortieImprimer => 'طباعة';

  @override
  String get posSortieImprimerDesc => 'طابعة A4 الافتراضية';

  @override
  String get posSortiePdf => 'حفظ بصيغة PDF';

  @override
  String get posSortiePdfDesc => 'حفظ المستند أو مشاركته';

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
  String get posClotureVentesEspeces => 'المبيعات نقدًا (بعد خصم الباقي)';

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
  String get posEntreeTitre => 'إدخال سريع';

  @override
  String posEntreeDesc(String magasin, String nom) {
    return '$nom · $magasin';
  }

  @override
  String get posEntreeFaite => 'تم تسجيل الإدخال السريع';

  @override
  String posEntreeFaiteDesc(String nom) {
    return '$nom · تم تحديث المخزون';
  }

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
  String get prdVente => 'البيع';

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
  String get prdFormDescription =>
      'سريع: صفحة واحدة للأساسيات. مفصل: 3 مراحل (الصور والتعريف والأسعار · المخزون والتغليف · المتغيرات والخيارات). الذكاء الاصطناعي: بطاقة يعثر عليها بالرمز الشريطي.';

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
  String get prdPhotosAide =>
      'تظهر الصورة الأولى في الصندوق (بطاقة المنتج ونافذة الكمية والطرد). JPG أو PNG، 4 كحد أقصى.';

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
  String get prdContientProduits => 'تحتوي على منتجات — أعد تعيينها أولا';

  @override
  String get prdDejaInactif => 'غير نشط مسبقا';

  @override
  String get prdToastAnnulation => 'تم الإلغاء';

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
  String get prdCumulable => 'قابل للجمع';

  @override
  String get prdAvecRemiseTicket => 'مع تخفيض التذكرة';

  @override
  String get prdSeuilAide => 'يتفعل التخفيض عندما يبلغ المجموع الفرعي هذا المبلغ';

  @override
  String get prdParMontantAide => 'تخفيض «حسب المبلغ»: يختار على السلة في الصندوق (Ctrl+R / F8)، دون قائمة منتجات.';

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
  String get stkDispoSource => 'المتاح بالمصدر';

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
}
