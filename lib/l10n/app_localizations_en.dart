// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Na3eeman';

  @override
  String get admin_portal => 'Admin (God Mode)';

  @override
  String get total_users => 'Total Users';

  @override
  String get active_shops => 'Active Shops';

  @override
  String get appointments => 'Appointments';

  @override
  String get revenue => 'Revenue';

  @override
  String get system_health => 'System Health';

  @override
  String get view_api_logs => 'View API Logs';

  @override
  String get api_status => 'Backend API';

  @override
  String get cache_status => 'Cache Service (Redis)';

  @override
  String get db_status => 'DB (PostgreSQL)';

  @override
  String get admin_modules => 'Admin Modules';

  @override
  String get settings => 'Settings';

  @override
  String get insights => 'Insights';

  @override
  String get analyze_trends => 'Analyze Trends';

  @override
  String get users => 'Users';

  @override
  String get finance => 'Finance';

  @override
  String get analytics => 'Analytics';

  @override
  String get compliance => 'Compliance';

  @override
  String get intern_portal => 'Intern Portal';

  @override
  String get learning_journey => 'Learning Journey Under';

  @override
  String get explore_mentors => 'Explore Mentors Below';

  @override
  String get active_assignments => 'Active Assignments';

  @override
  String get daily_tasks => 'Daily Tasks';

  @override
  String get add_task => 'Add Task';

  @override
  String get weekly_training => 'Weekly Training';

  @override
  String get monthly_targets => 'Monthly Targets';

  @override
  String get show_pct => 'Show %';

  @override
  String get show_num => 'Show #';

  @override
  String get task_completion => 'Task Completion';

  @override
  String tasks_done_today(int completed, int total) {
    return '$completed of $total tasks done for today';
  }

  @override
  String get show_more => 'Show more';

  @override
  String get no_employees => 'No employees found in the shop';

  @override
  String get shadowing => 'SHADOWING';

  @override
  String get attach => 'Attach';

  @override
  String get finish_tasks => 'Finish Tasks';

  @override
  String get refresh => 'Refresh';

  @override
  String get loading => 'Loading...';

  @override
  String get growth_insight =>
      'User growth is up 12% this week compared to last month.';

  @override
  String get top_categories_insight =>
      'Top categories: Barbershops (65%), Spas (20%).';

  @override
  String get admin_panel => 'Admin Panel';

  @override
  String get shop_dashboard => 'Shop Dashboard';

  @override
  String get my_schedule => 'My Schedule';

  @override
  String get offers => 'Offers';

  @override
  String get ads => 'Ads';

  @override
  String get feedback => 'Feedback';

  @override
  String get tell_others => 'Tell others about us';

  @override
  String get share_link => 'Share Shop Link';

  @override
  String get privacy_policy => 'Privacy Policy';
}
