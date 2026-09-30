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
      'توضّح المجالات والمصادر والملاحظات والمهام التجريبية طريقة عمل Learning OS. احذفها متى شئت.';

  @override
  String get sampleDataRemoveTitle => 'حذف البيانات التجريبية؟';

  @override
  String get sampleDataRemoveMessage =>
      'سيتم حذف جميع المجالات والمصادر والملاحظات والمهام التجريبية. ما أنشأته بنفسك سيبقى كما هو.';

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

  @override
  String get sampleResourceFlutterDocs =>
      'الأدلة الرسمية ووصفات الـ Cookbook ومرجع الـ API الخاص بـ Flutter.';

  @override
  String get sampleResourceRiverpod =>
      'إدارة الحالة والتخزين المؤقت التفاعلي لـ Flutter و Dart.';

  @override
  String get sampleResourceFlutterYoutube =>
      'محاضرات و Widget of the Week وأخبار الإصدارات من فريق Flutter.';

  @override
  String get sampleResourceFlutterRepo =>
      'الكود المصدري والمشكلات وخارطة الطريق لإطار Flutter.';

  @override
  String get sampleResourceDartLanguage =>
      'جولة في صياغة Dart والأنواع والكلاسات والبرمجة غير المتزامنة.';

  @override
  String get sampleResourceEffectiveDart =>
      'إرشادات لكتابة كود Dart متّسق وواضح وبالأسلوب الصحيح.';

  @override
  String get sampleResourceMaterial =>
      'نظام تصميم Google: المكوّنات والألوان والخطوط والحركة.';

  @override
  String get sampleResourceProGit =>
      'الكتاب المجاني عن Git: الأساسيات والفروع وأساليب العمل وما خلف الكواليس.';

  @override
  String get resourceTypeWebsite => 'موقع';

  @override
  String get resourceTypeYoutube => 'يوتيوب';

  @override
  String get resourceTypeCourse => 'دورة';

  @override
  String get resourceTypeBook => 'كتاب';

  @override
  String get resourceTypePdf => 'PDF';

  @override
  String get resourceTypeArticle => 'مقال';

  @override
  String get resourceTypeGithub => 'GitHub';

  @override
  String get resourceTypeDocumentation => 'توثيق';

  @override
  String get resourceTypeOther => 'أخرى';

  @override
  String get resourcesNew => 'إضافة مصدر';

  @override
  String resourcesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصدر',
      many: '$count مصدرًا',
      few: '$count مصادر',
      two: 'مصدران',
      one: 'مصدر واحد',
      zero: 'لا توجد مصادر',
    );
    return '$_temp0';
  }

  @override
  String get resourcesSearchHint => 'ابحث بالعنوان أو الرابط أو #الوسم';

  @override
  String get resourcesEmptyTitle => 'مكتبتك التعليمية فارغة';

  @override
  String get resourcesEmptyMessage =>
      'ابدأ ببناء قاعدة معرفتك بإضافة أول مصدر.';

  @override
  String get resourcesNoResultsTitle => 'لا توجد مصادر مطابقة';

  @override
  String get resourcesNoResultsMessage => 'جرّب بحثًا مختلفًا أو امسح الفلاتر.';

  @override
  String get resourcesClearFilters => 'مسح الفلاتر';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterType => 'النوع';

  @override
  String get filterCategory => 'المجال';

  @override
  String get filterProgress => 'التقدّم';

  @override
  String get filterTag => 'الوسم';

  @override
  String get filterFavorites => 'المفضلة';

  @override
  String get filterUncategorized => 'بدون مجال';

  @override
  String get progressNotStarted => 'لم يبدأ';

  @override
  String get progressInProgress => 'قيد التقدّم';

  @override
  String get progressCompleted => 'مكتمل';

  @override
  String get sortLabel => 'الترتيب';

  @override
  String get sortRecentlyAdded => 'المُضاف حديثًا';

  @override
  String get sortRecentlyOpened => 'المفتوح مؤخرًا';

  @override
  String get sortTitle => 'العنوان (أ–ي)';

  @override
  String get sortProgress => 'التقدّم';

  @override
  String get resourceFormCreateTitle => 'إضافة مصدر';

  @override
  String get resourceFormEditTitle => 'تعديل المصدر';

  @override
  String get resourceFormUrl => 'الرابط';

  @override
  String get resourceFormUrlHint => 'https://…';

  @override
  String get resourceFormTitle => 'العنوان';

  @override
  String get resourceFormTitleHint => 'اتركه فارغًا لاستخدام اسم الموقع';

  @override
  String get resourceFormDescription => 'الوصف';

  @override
  String get resourceFormDescriptionHint => 'ما هو، ولماذا هو مفيد؟';

  @override
  String get resourceFormType => 'النوع';

  @override
  String get resourceFormCategory => 'المجال';

  @override
  String get resourceFormNoCategory => 'بدون مجال';

  @override
  String get resourceFormTags => 'الوسوم';

  @override
  String get resourceFormTagsHint => 'اكتب وسمًا واضغط Enter';

  @override
  String resourceFormRemoveTag(String tag) {
    return 'إزالة الوسم $tag';
  }

  @override
  String get resourceFormProgress => 'التقدّم';

  @override
  String get resourceFormFavorite => 'إضافة إلى المفضلة';

  @override
  String get resourceFormCreate => 'إضافة المصدر';

  @override
  String get resourceTitleRequired => 'أدخل عنوانًا أو رابطًا';

  @override
  String get resourceUrlInvalid =>
      'أدخل عنوان ويب صحيحًا، مثل https://example.com';

  @override
  String resourceTooManyTags(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'استخدم $max وسمًا كحد أقصى',
      few: 'استخدم $max وسوم كحد أقصى',
      two: 'استخدم وسمين كحد أقصى',
      one: 'استخدم وسمًا واحدًا كحد أقصى',
    );
    return '$_temp0';
  }

  @override
  String get resourceCreated => 'تمت إضافة المصدر';

  @override
  String get resourceUpdated => 'تم تحديث المصدر';

  @override
  String get resourceDeleted => 'تم حذف المصدر';

  @override
  String get resourceSaveError => 'تعذّر حفظ المصدر. يرجى المحاولة مرة أخرى.';

  @override
  String get resourceDeleteError => 'تعذّر حذف المصدر. يرجى المحاولة مرة أخرى.';

  @override
  String resourceDeleteTitle(String title) {
    return 'حذف «$title»؟';
  }

  @override
  String get resourceDeleteMessage =>
      'سيتم حذف هذا المصدر. يمكنك التراجع مباشرةً بعد الحذف.';

  @override
  String get resourceOpen => 'فتح';

  @override
  String get resourceOpenLink => 'فتح الرابط في تبويب جديد';

  @override
  String get resourceOpenBlocked =>
      'منع المتصفح فتح تبويب جديد. اسمح بالنوافذ المنبثقة لهذا الموقع ثم حاول مرة أخرى.';

  @override
  String get resourceNoLink => 'بدون رابط';

  @override
  String get resourceFavoriteAdd => 'إضافة إلى المفضلة';

  @override
  String get resourceFavoriteRemove => 'إزالة من المفضلة';

  @override
  String get resourceUpdateError =>
      'تعذّر تحديث المصدر. يرجى المحاولة مرة أخرى.';

  @override
  String progressPercent(int value) {
    return '$value٪';
  }

  @override
  String progressComplete(int value) {
    return 'مكتمل بنسبة $value٪';
  }

  @override
  String resourceLastOpened(String date) {
    return 'آخر فتح $date';
  }

  @override
  String get resourceNeverOpened => 'لم يُفتح بعد';

  @override
  String get resourceNoDescription => 'بدون وصف';

  @override
  String get resourceNotFoundTitle => 'المصدر غير موجود';

  @override
  String get resourceNotFoundMessage => 'ربما تم حذفه، أو أن الرابط غير صحيح.';

  @override
  String get resourceBackToList => 'كل المصادر';

  @override
  String get resourceDetails => 'التفاصيل';

  @override
  String get resourceAbout => 'نبذة';

  @override
  String get detailCreated => 'تاريخ الإنشاء';

  @override
  String get detailUpdated => 'آخر تحديث';

  @override
  String get detailLastOpened => 'آخر فتح';

  @override
  String resourceMoreTags(int count) {
    return '+$count';
  }

  @override
  String categoryResourcesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مصدر',
      many: '$count مصدرًا',
      few: '$count مصادر',
      two: 'مصدران',
      one: 'مصدر واحد',
      zero: 'لا توجد مصادر بعد',
    );
    return '$_temp0';
  }

  @override
  String categoryDeleteKeepsResources(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ستبقى مصادره الـ $count في مكتبتك بدون مجال.',
      few: 'ستبقى مصادره الـ $count في مكتبتك بدون مجال.',
      two: 'سيبقى مصدراه في مكتبتك بدون مجال.',
      one: 'سيبقى مصدره في مكتبتك بدون مجال.',
    );
    return '$_temp0';
  }

  @override
  String get categoryStatResources => 'المصادر';

  @override
  String get categoryStatCompleted => 'المكتملة';

  @override
  String get categoryStatProgress => 'التقدّم';

  @override
  String get categoryResourcesSection => 'المصادر';

  @override
  String categoryNoResourcesTitle(String name) {
    return 'لا توجد مصادر في $name بعد';
  }

  @override
  String get categoryNoResourcesMessage =>
      'أضف الدورات والفيديوهات والتوثيقات والمقالات التي تتعلّم منها.';

  @override
  String get notesNew => 'ملاحظة جديدة';

  @override
  String notesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ملاحظة',
      many: '$count ملاحظة',
      few: '$count ملاحظات',
      two: 'ملاحظتان',
      one: 'ملاحظة واحدة',
      zero: 'لا توجد ملاحظات',
    );
    return '$_temp0';
  }

  @override
  String get notesSearchHint => 'ابحث في الملاحظات أو #الوسم';

  @override
  String get notesEmptyTitle => 'لا توجد ملاحظات بعد';

  @override
  String get notesEmptyMessage =>
      'دوّن الأفكار والملخصات ومقتطفات الكود أثناء تعلّمك. الملاحظات تدعم Markdown.';

  @override
  String get notesNoResultsTitle => 'لا توجد ملاحظات مطابقة';

  @override
  String get notesNoResultsMessage => 'جرّب بحثًا مختلفًا أو امسح الفلاتر.';

  @override
  String get notesSection => 'الملاحظات';

  @override
  String get notesNoneForResource => 'لا توجد ملاحظات لهذا المصدر بعد';

  @override
  String notesNoneForCategory(String name) {
    return 'لا توجد ملاحظات في $name بعد';
  }

  @override
  String get notesNoneMessage => 'دوّن ما تتعلّمه وهو ما زال حاضرًا في ذهنك.';

  @override
  String get sortRecentlyUpdated => 'المُحدّث مؤخرًا';

  @override
  String get sortRecentlyCreated => 'المُنشأ مؤخرًا';

  @override
  String get noteUntitled => 'بدون عنوان';

  @override
  String get noteTitleLabel => 'العنوان';

  @override
  String get noteContentLabel => 'محتوى الملاحظة';

  @override
  String get noteContentHint => 'ابدأ الكتابة… يدعم Markdown.';

  @override
  String get noteBackToList => 'كل الملاحظات';

  @override
  String get noteModeWrite => 'كتابة';

  @override
  String get noteModePreview => 'معاينة';

  @override
  String get noteSaving => 'جارٍ الحفظ…';

  @override
  String get noteSaved => 'تم الحفظ';

  @override
  String get noteSaveFailed =>
      'لم يتم الحفظ. ستتم إعادة المحاولة عند تعديلك التالي.';

  @override
  String get noteEmptyPreview => 'لا يوجد ما يُعرض بعد.';

  @override
  String get noteResource => 'المصدر';

  @override
  String get noteNoResource => 'بدون مصدر';

  @override
  String noteTasks(int done, int total) {
    return '$done من $total مكتملة';
  }

  @override
  String get noteCreateError => 'تعذّر إنشاء الملاحظة. يرجى المحاولة مرة أخرى.';

  @override
  String get noteUpdateError => 'تعذّر تحديث الملاحظة. يرجى المحاولة مرة أخرى.';

  @override
  String get noteDeleted => 'تم حذف الملاحظة';

  @override
  String get noteDeleteError => 'تعذّر حذف الملاحظة. يرجى المحاولة مرة أخرى.';

  @override
  String noteDeleteTitle(String title) {
    return 'حذف «$title»؟';
  }

  @override
  String get noteDeleteMessage =>
      'سيتم حذف هذه الملاحظة. يمكنك التراجع مباشرةً بعد الحذف.';

  @override
  String get noteNotFoundTitle => 'الملاحظة غير موجودة';

  @override
  String get noteNotFoundMessage => 'ربما تم حذفها، أو أن الرابط غير صحيح.';

  @override
  String get noteTooLong =>
      'الملاحظة أطول من أن تُحفظ. قسّمها إلى ملاحظات أصغر.';

  @override
  String get tasksNew => 'إضافة مهمة';

  @override
  String tasksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مهمة',
      many: '$count مهمة',
      few: '$count مهام',
      two: 'مهمتان',
      one: 'مهمة واحدة',
      zero: 'لا مهام',
    );
    return '$_temp0';
  }

  @override
  String get tasksSearchHint => 'ابحث في المهام أو #وسم';

  @override
  String get tasksEmptyTitle => 'خطّط خطواتك القادمة';

  @override
  String get tasksEmptyMessage =>
      'قسّم تعلّمك إلى مهام، حدّد الأولويات وتابع ما أتممته.';

  @override
  String get tasksNoResultsTitle => 'لا مهام مطابقة';

  @override
  String get tasksNoResultsMessage =>
      'جرّب بحثًا مختلفًا أو أزل عوامل التصفية.';

  @override
  String get tasksSection => 'المهام';

  @override
  String get tasksNoneForResource => 'لا مهام لهذا المصدر بعد';

  @override
  String tasksNoneForCategory(String name) {
    return 'لا مهام في $name بعد';
  }

  @override
  String get tasksNoneMessage => 'حوّل ما تتعلمه إلى خطوات قابلة للتنفيذ.';

  @override
  String get taskViewAll => 'الكل';

  @override
  String get taskViewToday => 'اليوم';

  @override
  String get taskViewUpcoming => 'القادمة';

  @override
  String get taskViewOverdue => 'متأخرة';

  @override
  String get taskViewCompleted => 'المكتملة';

  @override
  String get taskPriorityLow => 'منخفضة';

  @override
  String get taskPriorityMedium => 'متوسطة';

  @override
  String get taskPriorityHigh => 'عالية';

  @override
  String get taskStatusTodo => 'للتنفيذ';

  @override
  String get taskStatusInProgress => 'قيد التنفيذ';

  @override
  String get taskStatusCompleted => 'مكتملة';

  @override
  String get taskComplete => 'تحديد كمكتملة';

  @override
  String get taskReopen => 'إعادة فتح المهمة';

  @override
  String get filterStatus => 'الحالة';

  @override
  String get filterPriority => 'الأولوية';

  @override
  String get sortDueDate => 'تاريخ الاستحقاق';

  @override
  String get sortPriority => 'الأولوية';

  @override
  String get taskFormCreateTitle => 'إضافة مهمة';

  @override
  String get taskFormEditTitle => 'تعديل المهمة';

  @override
  String get taskFormTitle => 'العنوان';

  @override
  String get taskFormTitleHint => 'ما المطلوب تنفيذه؟';

  @override
  String get taskFormDescription => 'الوصف';

  @override
  String get taskFormDescriptionHint => 'أي تفاصيل أو خطوات أو روابط (اختياري)';

  @override
  String get taskFormDueDate => 'تاريخ الاستحقاق';

  @override
  String get taskFormNoDueDate => 'بدون تاريخ استحقاق';

  @override
  String get taskFormClearDueDate => 'إزالة تاريخ الاستحقاق';

  @override
  String get taskFormCreate => 'إضافة مهمة';

  @override
  String get taskTitleRequired => 'أدخل عنوانًا';

  @override
  String taskTooManyTags(int max) {
    return 'استخدم حتى $max وسوم';
  }

  @override
  String get taskCreated => 'تمت إضافة المهمة';

  @override
  String get taskUpdated => 'تم تحديث المهمة';

  @override
  String get taskDeleted => 'تم حذف المهمة';

  @override
  String get taskSaveError => 'تعذّر حفظ المهمة. حاول مجددًا.';

  @override
  String get taskDeleteError => 'تعذّر حذف المهمة. حاول مجددًا.';

  @override
  String taskDeleteTitle(String title) {
    return 'حذف \"$title\"؟';
  }

  @override
  String get taskDeleteMessage =>
      'ستُحذف هذه المهمة. يمكنك التراجع فورًا بعد ذلك.';

  @override
  String get taskUpdateError => 'تعذّر تحديث المهمة. حاول مجددًا.';

  @override
  String get taskNotFoundTitle => 'المهمة غير موجودة';

  @override
  String get taskNotFoundMessage => 'ربما حُذفت، أو أن الرابط غير صحيح.';

  @override
  String get taskBackToList => 'كل المهام';

  @override
  String get taskCompletedOn => 'اكتملت';

  @override
  String get taskDueToday => 'تستحق اليوم';

  @override
  String get taskDueOverdue => 'متأخرة';

  @override
  String taskDueOn(String date) {
    return 'تستحق في $date';
  }

  @override
  String get sampleTaskRiverpod => 'تعلّم الـ Providers في Riverpod';

  @override
  String get sampleTaskDartTour => 'إكمال جولة لغة Dart';

  @override
  String get sampleTaskBuildProject => 'بناء أول مشروع Flutter';

  @override
  String get sampleTaskGit => 'تجهيز Git و GitHub';

  @override
  String get mdHeading => 'عنوان';

  @override
  String get mdHeading1 => 'عنوان 1';

  @override
  String get mdHeading2 => 'عنوان 2';

  @override
  String get mdHeading3 => 'عنوان 3';

  @override
  String get mdBold => 'عريض (Ctrl+B)';

  @override
  String get mdItalic => 'مائل (Ctrl+I)';

  @override
  String get mdInlineCode => 'كود داخل السطر';

  @override
  String get mdBulletList => 'قائمة نقطية';

  @override
  String get mdNumberedList => 'قائمة مرقّمة';

  @override
  String get mdChecklist => 'قائمة مهام';

  @override
  String get mdQuote => 'اقتباس';

  @override
  String get mdCodeBlock => 'كتلة كود';

  @override
  String get mdLink => 'رابط';

  @override
  String get mdCopyCode => 'نسخ الكود';

  @override
  String get mdCodeCopied => 'تم نسخ الكود';

  @override
  String get sampleNoteLayoutTitle => 'ملخص تخطيطات Flutter';

  @override
  String get sampleNoteLayoutContent =>
      '## أهم Widgets التخطيط\n\n- **Row** / **Column**: ترتيب العناصر على محور واحد\n- **Expanded**: ملء المساحة المتبقية داخل Row أو Column\n- **Stack**: تراكب العناصر فوق بعضها\n\n> القيود تنزل للأسفل، والأحجام تصعد للأعلى، والأب يحدد الموضع.\n\n```dart\nRow(\n  children: [\n    const Icon(Icons.star),\n    Expanded(child: Text(title)),\n  ],\n)\n```\n\n## للتدريب\n\n- [x] بناء بطاقة ملف شخصي باستخدام Row و Column\n- [ ] إعادة بنائها بشكل متجاوب باستخدام LayoutBuilder\n- [ ] القراءة عن [القيود](https://docs.flutter.dev/ui/layout/constraints)';

  @override
  String get sampleNoteRiverpodTitle => 'Riverpod في صفحة واحدة';

  @override
  String get sampleNoteRiverpodContent =>
      '## الـ Providers\n\n1. `Provider` للقيم التي لا تتغير\n2. `NotifierProvider` للحالة التي لها دوال\n3. `StreamProvider` للبيانات الحية مثل استعلامات قاعدة البيانات\n\nاستخدم `ref.watch` داخل `build`، و `ref.read` داخل الـ callbacks.\n\n- [ ] تجربة `select` لتقليل إعادة البناء';

  @override
  String get sampleNoteGitTitle => 'أوامر Git التي أستخدمها يوميًا';

  @override
  String get sampleNoteGitContent =>
      '## يوميًا\n\n```bash\ngit status\ngit add -p\ngit commit -m \"message\"\ngit push\n```\n\n## الفروع\n\n- `git switch -c feature/x` ينشئ فرعًا وينتقل إليه\n- `git rebase main` يحدّث الفرع\n\n- [x] ضبط الاسم والبريد\n- [ ] تعلّم الـ rebase التفاعلي';
}
