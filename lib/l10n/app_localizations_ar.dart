// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get app_name => 'نعيمن';

  @override
  String get admin_portal => 'لوحة الإدارة (وضع التحكم الكامل)';

  @override
  String get total_users => 'إجمالي المستخدمين';

  @override
  String get active_shops => 'المتاجر المفتوحة';

  @override
  String get appointments => 'المواعيد';

  @override
  String get revenue => 'الإيرادات';

  @override
  String get system_health => 'حالة النظام';

  @override
  String get view_api_logs => 'عرض سجلات API';

  @override
  String get api_status => 'واجهة برمجة التطبيقات (API)';

  @override
  String get cache_status => 'خدمة التخزين المؤقت (Redis)';

  @override
  String get db_status => 'قاعدة البيانات (PostgreSQL)';

  @override
  String get admin_modules => 'أقسام الإدارة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get insights => 'تحليلات ورؤى';

  @override
  String get analyze_trends => 'تحليل الاتجاهات';

  @override
  String get users => 'المستخدمين';

  @override
  String get finance => 'المالية';

  @override
  String get analytics => 'التحليلات';

  @override
  String get compliance => 'الامتثال';

  @override
  String get intern_portal => 'بوابة المتدربين';

  @override
  String get learning_journey => 'رحلة التعلم برعاية';

  @override
  String get explore_mentors => 'تصفح المشرفين أدناه';

  @override
  String get active_assignments => 'المهام النشطة';

  @override
  String get daily_tasks => 'المهام اليومية';

  @override
  String get add_task => 'إضافة مهمة';

  @override
  String get weekly_training => 'التدريب الأسبوعي';

  @override
  String get monthly_targets => 'الأهداف الشهرية';

  @override
  String get show_pct => 'عرض %';

  @override
  String get show_num => 'عرض #';

  @override
  String get task_completion => 'إكمال المهام';

  @override
  String tasks_done_today(int completed, int total) {
    return 'تم إكمال $completed من $total مهام اليوم';
  }

  @override
  String get show_more => 'عرض المزيد';

  @override
  String get no_employees => 'لا يوجد موظفين في هذا المتجر';

  @override
  String get shadowing => 'متابعة تدريبية';

  @override
  String get attach => 'إلحاق';

  @override
  String get finish_tasks => 'أكمل المهام أولاً';

  @override
  String get refresh => 'تحديث';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get growth_insight =>
      'نما نمو المستخدمين بنسبة 12% هذا الأسبوع مقارنة بالشهر الماضي.';

  @override
  String get top_categories_insight =>
      'الفئات الأعلى: محلات الحلاقة (65%)، السبا (20%).';

  @override
  String get admin_panel => 'لوحة الإدارة';

  @override
  String get shop_dashboard => 'لوحة المتجر';

  @override
  String get my_schedule => 'جدولي';

  @override
  String get offers => 'العروض';

  @override
  String get ads => 'الإعلانات';

  @override
  String get feedback => 'آراء العملاء';

  @override
  String get tell_others => 'أخبر الآخرين عنا';

  @override
  String get share_link => 'شارك رابط المتجر';

  @override
  String get privacy_policy => 'سياسة الخصوصية';
}
