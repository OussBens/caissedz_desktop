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
  String get activationIntro => 'أدخل مفتاح التفعيل الخاص بهذا الجهاز، أو جرّب الوضع التجريبي.';

  @override
  String get activationIdentifiantMachine => 'معرّف هذا الجهاز';

  @override
  String get activationCopierIdentifiant => 'نسخ المعرّف';

  @override
  String get activationIdentifiantCopie => 'تم نسخ المعرّف';

  @override
  String get activationCle => 'مفتاح التفعيل (64 حرفًا)';

  @override
  String get activationCleIndice => 'مفتاح SHA-256 من 64 حرفًا سداسيًا عشريًا';

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
  String get activationErreurInconnue => 'هذا المفتاح لا يطابق هذا الجهاز. تحقق من المفتاح أو اتصل بالموزع.';

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
  String get connexionTitre => 'تسجيل الدخول';

  @override
  String get connexionIdentifiant => 'المعرّف';

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
  String get connexionDemoIndice => 'الوضع التجريبي: المعرّف demo، كلمة المرور demo';

  @override
  String get connexionDeconnecter => 'تسجيل الخروج';

  @override
  String get configTitre => 'الإعداد الأولي';

  @override
  String configEtape(int n, int total) {
    return 'الخطوة $n من $total';
  }

  @override
  String get configEtapeBoutique => 'المتجر';

  @override
  String get configEtapeAdmin => 'المدير';

  @override
  String get configEtapeVente => 'الهامش والبيع';

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
  String get configMarge => 'الهامش الافتراضي (%)';

  @override
  String get configMargeAide => 'يُطبّق لحساب سعر البيع من سعر الشراء للمنتجات الجديدة.';

  @override
  String get configSeuil => 'حد تنبيه المخزون (عام)';

  @override
  String get configFidelite => 'تفعيل الولاء (نقاط)';

  @override
  String get configPointsParDinar => 'النقاط المكتسبة لكل دينار';

  @override
  String get configDevise => 'العملة';

  @override
  String get configLangue => 'لغة التطبيق';

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
  String get posScan => 'امسح أو ابحث عن منتج (F1)';

  @override
  String posPanier(int n) {
    return 'سلة $n';
  }

  @override
  String get posNouveauPanier => 'سلة جديدة (Ctrl+N)';

  @override
  String get posMaxPaniers => '5 مبيعات متوازية كحد أقصى.';

  @override
  String get posPanierVide => 'السلة فارغة: امسح باركودًا أو انقر على منتج.';

  @override
  String get posSousTotal => 'المجموع الجزئي';

  @override
  String get posRemise => 'التخفيض';

  @override
  String get posTotal => 'المجموع';

  @override
  String get posVerse => 'المدفوع';

  @override
  String get posReste => 'المتبقي';

  @override
  String get posMonnaie => 'الباقي المسترجع';

  @override
  String get posPointsGagnes => 'النقاط المكتسبة';

  @override
  String get posClient => 'الزبون (F2)';

  @override
  String get posClientPassage => 'زبون عابر';

  @override
  String get posChoisirClient => 'اختيار زبون';

  @override
  String get posRemiseGlobale => 'تخفيض إجمالي (F3)';

  @override
  String get posRemisePct => 'التخفيض (%)';

  @override
  String get posPaiement => 'الدفع';

  @override
  String get posMontant => 'المبلغ';

  @override
  String get posEncaisser => 'تحصيل (F12)';

  @override
  String get posVider => 'إفراغ (F10)';

  @override
  String get posCalculatrice => 'الآلة الحاسبة (F9)';

  @override
  String get posAide => 'مساعدة (F11)';

  @override
  String get posSessionOuvrir => 'فتح الجلسة';

  @override
  String get posSessionFermer => 'إغلاق الجلسة';

  @override
  String get posSessionAucune => 'لا توجد جلسة صندوق مفتوحة: افتح جلسة للتحصيل.';

  @override
  String posSessionOuverte(String code, String caisse) {
    return 'الجلسة $code · $caisse';
  }

  @override
  String get posSessionCaisse => 'الصندوق';

  @override
  String get posSessionFond => 'رصيد الصندوق الأولي';

  @override
  String get posSessionMontantCompte => 'المبلغ المعدود';

  @override
  String get posSessionAttendu => 'النقد المتوقع';

  @override
  String get posSessionEcart => 'الفرق';

  @override
  String posSessionFermee(String code, String ecart) {
    return 'أُغلقت الجلسة $code. الفرق: $ecart.';
  }

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
  String get posApercuTicket => 'معاينة التذكرة';

  @override
  String get posImpressionOk => 'أُرسلت التذكرة إلى الطابعة.';

  @override
  String posImpressionErreur(String detail) {
    return 'تعذرت الطباعة: $detail';
  }

  @override
  String get posCreditAutoriser => 'البيع بالدين (متبقٍ مستحق)';

  @override
  String get posRaccourcisTitre => 'اختصارات لوحة المفاتيح';

  @override
  String get posRaccourciF1 => 'بحث / مسح';

  @override
  String get posRaccourciF2 => 'اختيار الزبون';

  @override
  String get posRaccourciF3 => 'تخفيض إجمالي';

  @override
  String get posRaccourciF4 => 'نقدًا: المبلغ بالضبط';

  @override
  String get posRaccourciF5 => 'بطاقة: المبلغ بالضبط';

  @override
  String get posRaccourciF6 => 'شيك: المبلغ بالضبط';

  @override
  String get posRaccourciF7 => 'تحويل: المبلغ بالضبط';

  @override
  String get posRaccourciF8 => 'نقاط الولاء';

  @override
  String get posRaccourciF9 => 'الآلة الحاسبة';

  @override
  String get posRaccourciF10 => 'إفراغ السلة';

  @override
  String get posRaccourciF11 => 'هذه المساعدة';

  @override
  String get posRaccourciF12 => 'تحصيل';

  @override
  String get posRaccourciCtrlN => 'سلة جديدة';

  @override
  String get posRaccourciCtrlTab => 'السلة التالية';

  @override
  String get posRaccourciSuppr => 'إزالة السطر المحدد';

  @override
  String get posRaccourciPlusMoins => 'الكمية +1 / −1 على السطر المحدد';

  @override
  String get posLigneQuantite => 'الكمية';

  @override
  String get posLignePrix => 'السعر';

  @override
  String get posLigneRemise => 'تخف.';

  @override
  String get posLigneTotal => 'المجموع';

  @override
  String get posVendreNombre => 'البيع بالقطعة';

  @override
  String get posColis => 'طرد';

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
}
