import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'Na3eeman'**
  String get app_name;

  /// No description provided for @admin_portal.
  ///
  /// In en, this message translates to:
  /// **'Admin (God Mode)'**
  String get admin_portal;

  /// No description provided for @total_users.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get total_users;

  /// No description provided for @active_shops.
  ///
  /// In en, this message translates to:
  /// **'Active Shops'**
  String get active_shops;

  /// No description provided for @appointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @system_health.
  ///
  /// In en, this message translates to:
  /// **'System Health'**
  String get system_health;

  /// No description provided for @view_api_logs.
  ///
  /// In en, this message translates to:
  /// **'View API Logs'**
  String get view_api_logs;

  /// No description provided for @api_status.
  ///
  /// In en, this message translates to:
  /// **'Backend API'**
  String get api_status;

  /// No description provided for @cache_status.
  ///
  /// In en, this message translates to:
  /// **'Cache Service (Redis)'**
  String get cache_status;

  /// No description provided for @db_status.
  ///
  /// In en, this message translates to:
  /// **'DB (PostgreSQL)'**
  String get db_status;

  /// No description provided for @admin_modules.
  ///
  /// In en, this message translates to:
  /// **'Admin Modules'**
  String get admin_modules;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @insights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// No description provided for @analyze_trends.
  ///
  /// In en, this message translates to:
  /// **'Analyze Trends'**
  String get analyze_trends;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @compliance.
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get compliance;

  /// No description provided for @intern_portal.
  ///
  /// In en, this message translates to:
  /// **'Intern Portal'**
  String get intern_portal;

  /// No description provided for @learning_journey.
  ///
  /// In en, this message translates to:
  /// **'Learning Journey Under'**
  String get learning_journey;

  /// No description provided for @explore_mentors.
  ///
  /// In en, this message translates to:
  /// **'Explore Mentors Below'**
  String get explore_mentors;

  /// No description provided for @active_assignments.
  ///
  /// In en, this message translates to:
  /// **'Active Assignments'**
  String get active_assignments;

  /// No description provided for @daily_tasks.
  ///
  /// In en, this message translates to:
  /// **'Daily Tasks'**
  String get daily_tasks;

  /// No description provided for @add_task.
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get add_task;

  /// No description provided for @weekly_training.
  ///
  /// In en, this message translates to:
  /// **'Weekly Training'**
  String get weekly_training;

  /// No description provided for @monthly_targets.
  ///
  /// In en, this message translates to:
  /// **'Monthly Targets'**
  String get monthly_targets;

  /// No description provided for @show_pct.
  ///
  /// In en, this message translates to:
  /// **'Show %'**
  String get show_pct;

  /// No description provided for @show_num.
  ///
  /// In en, this message translates to:
  /// **'Show #'**
  String get show_num;

  /// No description provided for @task_completion.
  ///
  /// In en, this message translates to:
  /// **'Task Completion'**
  String get task_completion;

  /// No description provided for @tasks_done_today.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} tasks done for today'**
  String tasks_done_today(int completed, int total);

  /// No description provided for @show_more.
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get show_more;

  /// No description provided for @no_employees.
  ///
  /// In en, this message translates to:
  /// **'No employees found in the shop'**
  String get no_employees;

  /// No description provided for @shadowing.
  ///
  /// In en, this message translates to:
  /// **'SHADOWING'**
  String get shadowing;

  /// No description provided for @attach.
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get attach;

  /// No description provided for @finish_tasks.
  ///
  /// In en, this message translates to:
  /// **'Finish Tasks'**
  String get finish_tasks;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @growth_insight.
  ///
  /// In en, this message translates to:
  /// **'User growth is up 12% this week compared to last month.'**
  String get growth_insight;

  /// No description provided for @top_categories_insight.
  ///
  /// In en, this message translates to:
  /// **'Top categories: Barbershops (65%), Spas (20%).'**
  String get top_categories_insight;

  /// No description provided for @admin_panel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get admin_panel;

  /// No description provided for @shop_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Shop Dashboard'**
  String get shop_dashboard;

  /// No description provided for @my_schedule.
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get my_schedule;

  /// No description provided for @offers.
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// No description provided for @ads.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get ads;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @tell_others.
  ///
  /// In en, this message translates to:
  /// **'Tell others about us'**
  String get tell_others;

  /// No description provided for @share_link.
  ///
  /// In en, this message translates to:
  /// **'Share Shop Link'**
  String get share_link;

  /// No description provided for @privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacy_policy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
