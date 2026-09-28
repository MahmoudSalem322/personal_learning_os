// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Learning OS';

  @override
  String get appTagline => 'مساحة التعلّم الشخصية';

  @override
  String get navDashboard => 'لوحة التحكم';

  @override
  String get navCategories => 'المجالات';

  @override
  String get navResources => 'المصادر';

  @override
  String get navNotes => 'الملاحظات';

  @override
  String get navTasks => 'المهام';

  @override
  String get navFavorites => 'المفضلة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get navOpenMenu => 'فتح قائمة التنقل';

  @override
  String get navMainLabel => 'التنقل الرئيسي';

  @override
  String get dashboardSubtitle => 'نظرة سريعة على رحلة تعلّمك.';

  @override
  String get categoriesSubtitle => 'نظّم تعلّمك في مجالات واضحة ومركّزة.';

  @override
  String get resourcesSubtitle =>
      'الدورات والفيديوهات والتوثيقات والمقالات في مكتبة واحدة.';

  @override
  String get notesSubtitle => 'دوّن ما تتعلّمه بأسلوبك الخاص.';

  @override
  String get tasksSubtitle => 'خطّط وتابع خطواتك القادمة في التعلّم.';

  @override
  String get favoritesSubtitle => 'كل ما أضفته إلى المفضلة في مكان واحد.';

  @override
  String get settingsSubtitle => 'خصّص مظهر Learning OS وطريقة عمله.';

  @override
  String comingSoonTitle(String section) {
    return 'قسم $section قادم قريبًا';
  }

  @override
  String get comingSoonMessage =>
      'هذه المساحة جزء من مرحلة قادمة. الأساس جاهز، وستظهر هنا قريبًا.';

  @override
  String get themeLabel => 'المظهر';

  @override
  String get themeLight => 'فاتح';

  @override
  String get themeDark => 'داكن';

  @override
  String get themeSystem => 'النظام';

  @override
  String get languageLabel => 'اللغة';

  @override
  String get languageSystem => 'لغة النظام';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageArabic => 'العربية';

  @override
  String get notFoundTitle => 'الصفحة غير موجودة';

  @override
  String get notFoundMessage =>
      'الصفحة التي تبحث عنها غير موجودة أو ربما تم نقلها.';

  @override
  String get notFoundAction => 'العودة إلى لوحة التحكم';

  @override
  String get errorGenericTitle => 'حدث خطأ ما';

  @override
  String get errorGenericMessage =>
      'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';

  @override
  String get actionRetry => 'إعادة المحاولة';

  @override
  String get actionDismiss => 'إغلاق';

  @override
  String get storageVolatileWarning =>
      'التخزين المحلي غير متاح في جلسة المتصفح هذه. لن يتم الاحتفاظ بتغييراتك بعد إغلاق التبويب.';

  @override
  String get settingsSaveError => 'تعذّر حفظ التفضيل. يرجى المحاولة مرة أخرى.';
}
