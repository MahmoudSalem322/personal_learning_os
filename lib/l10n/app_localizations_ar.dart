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

  @override
  String get actionCancel => 'إلغاء';

  @override
  String get actionSave => 'حفظ التغييرات';

  @override
  String get actionEdit => 'تعديل';

  @override
  String get actionDelete => 'حذف';

  @override
  String get actionUndo => 'تراجع';

  @override
  String get actionClose => 'إغلاق';

  @override
  String get actionMore => 'إجراءات أخرى';

  @override
  String get actionClearSearch => 'مسح البحث';

  @override
  String validationTooLong(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'استخدم $max حرفًا كحد أقصى',
      few: 'استخدم $max أحرف كحد أقصى',
      two: 'استخدم حرفين كحد أقصى',
      one: 'استخدم حرفًا واحدًا كحد أقصى',
    );
    return '$_temp0';
  }

  @override
  String dateCreatedOn(String date) {
    return 'أُنشئ في $date';
  }

  @override
  String dateUpdatedOn(String date) {
    return 'حُدّث في $date';
  }

  @override
  String get categoriesNew => 'مجال جديد';

  @override
  String categoriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مجال',
      many: '$count مجالًا',
      few: '$count مجالات',
      two: 'مجالان',
      one: 'مجال واحد',
      zero: 'لا توجد مجالات',
    );
    return '$_temp0';
  }

  @override
  String get categoriesSearchHint => 'ابحث في المجالات';

  @override
  String get categoriesEmptyTitle => 'نظّم رحلة تعلّمك';

  @override
  String get categoriesEmptyMessage =>
      'المجالات هي المواضيع التي تتعلّمها، مثل Flutter أو Dart أو UI/UX. أنشئ أول مجال لتبدأ.';

  @override
  String get categoriesNoResultsTitle => 'لا توجد مجالات مطابقة';

  @override
  String categoriesNoResultsMessage(String query) {
    return 'لا يوجد ما يطابق «$query». جرّب اسمًا آخر.';
  }

  @override
  String get categoryFormCreateTitle => 'مجال جديد';

  @override
  String get categoryFormEditTitle => 'تعديل المجال';

  @override
  String get categoryFormName => 'الاسم';

  @override
  String get categoryFormNameHint => 'مثال: Flutter';

  @override
  String get categoryFormDescription => 'الوصف';

  @override
  String get categoryFormDescriptionHint => 'ما الذي تتعلّمه في هذا المجال؟';

  @override
  String get categoryFormIcon => 'الأيقونة';

  @override
  String get categoryFormColor => 'اللون';

  @override
  String get categoryFormPreviewName => 'اسم المجال';

  @override
  String get categoryFormCreate => 'إنشاء المجال';

  @override
  String get categoryNameRequired => 'أدخل اسمًا';

  @override
  String get categoryNameTaken => 'يوجد مجال بهذا الاسم بالفعل';

  @override
  String get categoryNoDescription => 'بدون وصف';

  @override
  String get categoryCreated => 'تم إنشاء المجال';

  @override
  String get categoryUpdated => 'تم تحديث المجال';

  @override
  String get categoryDeleted => 'تم حذف المجال';

  @override
  String get categorySaveError => 'تعذّر حفظ المجال. يرجى المحاولة مرة أخرى.';

  @override
  String get categoryDeleteError => 'تعذّر حذف المجال. يرجى المحاولة مرة أخرى.';

  @override
  String categoryDeleteTitle(String name) {
    return 'حذف «$name»؟';
  }

  @override
  String get categoryDeleteMessage =>
      'سيتم حذف هذا المجال. يمكنك التراجع مباشرةً بعد الحذف.';

  @override
  String get categoryNotFoundTitle => 'المجال غير موجود';

  @override
  String get categoryNotFoundMessage => 'ربما تم حذفه، أو أن الرابط غير صحيح.';

  @override
  String get categoryBackToList => 'كل المجالات';

  @override
  String get categoryDetailEmptyTitle => 'لا يوجد شيء هنا بعد';

  @override
  String categoryDetailEmptyMessage(String name) {
    return 'ستظهر هنا المصادر والملاحظات والمهام التي تضيفها إلى $name.';
  }

  @override
  String get categoryIconFolder => 'مجلد';

  @override
  String get categoryIconCode => 'برمجة';

  @override
  String get categoryIconMobile => 'الجوال';

  @override
  String get categoryIconWeb => 'الويب';

  @override
  String get categoryIconDesign => 'التصميم';

  @override
  String get categoryIconTerminal => 'الطرفية';

  @override
  String get categoryIconDatabase => 'قواعد البيانات';

  @override
  String get categoryIconCloud => 'السحابة';

  @override
  String get categoryIconVersionControl => 'إدارة الإصدارات';

  @override
  String get categoryIconData => 'البيانات';

  @override
  String get categoryIconMath => 'الرياضيات';

  @override
  String get categoryIconAi => 'الذكاء الاصطناعي';

  @override
  String get categoryIconLanguages => 'اللغات';

  @override
  String get categoryIconReading => 'القراءة';

  @override
  String get categoryIconCourse => 'دورة';

  @override
  String get categoryIconScience => 'العلوم';

  @override
  String get categoryIconIdeas => 'أفكار';

  @override
  String get categoryIconProjects => 'مشاريع';

  @override
  String get categoryIconDebugging => 'تصحيح الأخطاء';

  @override
  String get categoryIconSecurity => 'الأمان';

  @override
  String get categoryIconAnalytics => 'التحليلات';

  @override
  String get categoryIconMusic => 'الموسيقى';

  @override
  String get colorBlue => 'أزرق';

  @override
  String get colorIndigo => 'نيلي';

  @override
  String get colorPurple => 'بنفسجي';

  @override
  String get colorPink => 'وردي';

  @override
  String get colorRed => 'أحمر';

  @override
  String get colorOrange => 'برتقالي';

  @override
  String get colorAmber => 'كهرماني';

  @override
  String get colorGreen => 'أخضر';

  @override
  String get colorTeal => 'فيروزي';

  @override
  String get colorSlate => 'رمادي';

  @override
  String get sampleDataLoad => 'تحميل بيانات تجريبية';

  @override
  String get sampleDataLoaded => 'تمت إضافة البيانات التجريبية';

  @override
  String get sampleDataRemove => 'حذف البيانات التجريبية';

  @override
  String get sampleDataRemoved => 'تم حذف البيانات التجريبية';

  @override
  String get sampleDataError =>
      'تعذّر تحديث البيانات التجريبية. يرجى المحاولة مرة أخرى.';

  @override
  String get sampleDataBannerTitle => 'أنت تستعرض بيانات تجريبية';

  @override
  String get sampleDataBannerMessage =>
      'توضّح المجالات التجريبية طريقة عمل Learning OS. احذفها متى شئت.';

  @override
  String get sampleDataRemoveTitle => 'حذف البيانات التجريبية؟';

  @override
  String get sampleDataRemoveMessage =>
      'سيتم حذف جميع المجالات التجريبية. المجالات التي أنشأتها بنفسك لن تتأثر.';

  @override
  String get sampleFlutterDescription =>
      'تطبيقات متعددة المنصات باستخدام الـ Widgets والتخطيطات وإدارة الحالة.';

  @override
  String get sampleDartDescription =>
      'اللغة التي يقوم عليها Flutter: الأنواع والبرمجة غير المتزامنة و Null Safety.';

  @override
  String get sampleUiUxDescription =>
      'تصميم الواجهات وقابلية الاستخدام وبناء أنظمة التصميم.';

  @override
  String get sampleGitDescription =>
      'إدارة الإصدارات والفروع والتعاون عبر GitHub.';
}
