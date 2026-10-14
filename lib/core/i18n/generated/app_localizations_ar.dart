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
}
