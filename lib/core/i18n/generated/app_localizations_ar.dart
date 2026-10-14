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
  String get shellFavorisVide =>
      'لا توجد مفضلة. انقر بالزر الأيمن على وحدة لإضافتها.';

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
  String get activationIntro =>
      'أدخل مفتاح التفعيل الخاص بهذا الجهاز، أو جرّب الوضع التجريبي.';

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
  String get activationErreurFormat =>
      'يجب أن يحتوي المفتاح على 64 حرفًا سداسيًا عشريًا بالضبط (0-9، a-f).';

  @override
  String get activationErreurInconnue =>
      'هذا المفتاح لا يطابق هذا الجهاز. تحقق من المفتاح أو اتصل بالموزع.';

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
  String get licenceRequiseDetail =>
      'رخصتك الحالية أساسية. فعّل رخصة متقدمة للوصول إلى هذه الوحدة.';

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
  String get connexionErreurNonConfigure =>
      'ليس لهذا الحساب كلمة مرور بعد: أكمل الإعداد الأولي.';

  @override
  String get connexionErreurDemo =>
      'الحساب demo/demo متاح فقط في الوضع التجريبي.';

  @override
  String get connexionDemoIndice =>
      'الوضع التجريبي: المعرّف demo، كلمة المرور demo';

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
  String get configAdminIntro =>
      'سيملك حساب المدير هذا كل الصلاحيات. اختر معرّفًا وكلمة مرور.';

  @override
  String get configAdminNom => 'الاسم المعروض';

  @override
  String get configAdminMotDePasseConfirmation => 'تأكيد كلمة المرور';

  @override
  String get configMarge => 'الهامش الافتراضي (%)';

  @override
  String get configMargeAide =>
      'يُطبّق لحساب سعر البيع من سعر الشراء للمنتجات الجديدة.';

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
  String get configRecapIntro =>
      'تحقق من المعلومات قبل الإنهاء. يمكنك تعديلها لاحقًا في الإعدادات.';

  @override
  String get configPrecedent => 'السابق';

  @override
  String get configSuivant => 'التالي';

  @override
  String get configTerminer => 'إنهاء';

  @override
  String get configErreurObligatoire => 'حقل إلزامي';

  @override
  String get configErreurIdentifiant =>
      'من 3 إلى 32 حرفًا: أحرف، أرقام، نقطة، شرطة، شرطة سفلية.';

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
  String get rolesIntro =>
      'حدد صلاحيات الإجراءات والوحدات المتاحة لكل دور. يحتفظ المدير دائمًا بكل الصلاحيات.';

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
  String get parametresRolesCarteDetail =>
      'صلاحيات الإجراءات والوحدات المتاحة حسب الدور.';

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
}
