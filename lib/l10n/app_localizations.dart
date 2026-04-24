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

  /// Translation for service_requests
  ///
  /// In en, this message translates to:
  /// **'Service Requests'**
  String get serviceRequests;

  /// Translation for app_name
  ///
  /// In en, this message translates to:
  /// **'Na3eeman'**
  String get appName;

  /// Translation for user_name
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// Translation for password
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Translation for login
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Translation for logout
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Translation for profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Translation for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Translation for search
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Translation for refresh
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Translation for loading
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Translation for catigories
  ///
  /// In en, this message translates to:
  /// **'Catigories'**
  String get catigories;

  /// Translation for special_offers
  ///
  /// In en, this message translates to:
  /// **'Special Offers'**
  String get specialOffers;

  /// Translation for service_hair
  ///
  /// In en, this message translates to:
  /// **'Hair'**
  String get serviceHair;

  /// Translation for service_beauty
  ///
  /// In en, this message translates to:
  /// **'Beauty'**
  String get serviceBeauty;

  /// Translation for service_brides
  ///
  /// In en, this message translates to:
  /// **'Brides'**
  String get serviceBrides;

  /// Translation for service_nails
  ///
  /// In en, this message translates to:
  /// **'Nails'**
  String get serviceNails;

  /// Translation for service_spa
  ///
  /// In en, this message translates to:
  /// **'Spa'**
  String get serviceSpa;

  /// Translation for service_laser
  ///
  /// In en, this message translates to:
  /// **'Laser'**
  String get serviceLaser;

  /// Translation for service_skin_care
  ///
  /// In en, this message translates to:
  /// **'Skin Care'**
  String get serviceSkinCare;

  /// Translation for service_grooming
  ///
  /// In en, this message translates to:
  /// **'Grooming'**
  String get serviceGrooming;

  /// Translation for admin_portal
  ///
  /// In en, this message translates to:
  /// **'Admin (God Mode)'**
  String get adminPortal;

  /// Translation for total_users
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// Translation for active_salons
  ///
  /// In en, this message translates to:
  /// **'Active Salons'**
  String get activeSalons;

  /// Translation for appointments
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// Translation for revenue
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// Translation for system_health
  ///
  /// In en, this message translates to:
  /// **'System Health'**
  String get systemHealth;

  /// Translation for view_api_logs
  ///
  /// In en, this message translates to:
  /// **'View API Logs'**
  String get viewApiLogs;

  /// Translation for api_status
  ///
  /// In en, this message translates to:
  /// **'Backend API'**
  String get apiStatus;

  /// Translation for cache_status
  ///
  /// In en, this message translates to:
  /// **'Cache Service (Redis)'**
  String get cacheStatus;

  /// Translation for db_status
  ///
  /// In en, this message translates to:
  /// **'DB (PostgreSQL)'**
  String get dbStatus;

  /// Translation for admin_modules
  ///
  /// In en, this message translates to:
  /// **'Admin Modules'**
  String get adminModules;

  /// Translation for insights
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// Translation for analyze_trends
  ///
  /// In en, this message translates to:
  /// **'Analyze Trends'**
  String get analyzeTrends;

  /// Translation for intern_portal
  ///
  /// In en, this message translates to:
  /// **'Intern Portal'**
  String get internPortal;

  /// Translation for learning_journey
  ///
  /// In en, this message translates to:
  /// **'Learning Journey Under'**
  String get learningJourney;

  /// Translation for explore_mentors
  ///
  /// In en, this message translates to:
  /// **'Explore Mentors Below'**
  String get exploreMentors;

  /// Translation for active_assignments
  ///
  /// In en, this message translates to:
  /// **'Active Assignments'**
  String get activeAssignments;

  /// Translation for daily_tasks
  ///
  /// In en, this message translates to:
  /// **'Daily Tasks'**
  String get dailyTasks;

  /// Translation for add_task
  ///
  /// In en, this message translates to:
  /// **'Add Task'**
  String get addTask;

  /// Translation for weekly_training
  ///
  /// In en, this message translates to:
  /// **'Weekly Training'**
  String get weeklyTraining;

  /// Translation for monthly_targets
  ///
  /// In en, this message translates to:
  /// **'Monthly Targets'**
  String get monthlyTargets;

  /// Translation for show_pct
  ///
  /// In en, this message translates to:
  /// **'Show %'**
  String get showPct;

  /// Translation for show_num
  ///
  /// In en, this message translates to:
  /// **'Show #'**
  String get showNum;

  /// Translation for task_completion
  ///
  /// In en, this message translates to:
  /// **'Task Completion'**
  String get taskCompletion;

  /// Translation for tasks_done_today
  ///
  /// In en, this message translates to:
  /// **'{value} of {value} tasks done for today'**
  String tasksDoneToday(Object value);

  /// Translation for show_more
  ///
  /// In en, this message translates to:
  /// **'Show more'**
  String get showMore;

  /// Translation for no_employees
  ///
  /// In en, this message translates to:
  /// **'No employees found in the salon'**
  String get noEmployees;

  /// Translation for no_targets
  ///
  /// In en, this message translates to:
  /// **'No targets set for this month'**
  String get noTargets;

  /// Translation for shadowing
  ///
  /// In en, this message translates to:
  /// **'SHADOWING'**
  String get shadowing;

  /// Translation for attach
  ///
  /// In en, this message translates to:
  /// **'Attach'**
  String get attach;

  /// Translation for finish_tasks
  ///
  /// In en, this message translates to:
  /// **'Finish Tasks'**
  String get finishTasks;

  /// Translation for attach_success
  ///
  /// In en, this message translates to:
  /// **'Successfully attached to {value}'**
  String attachSuccess(Object value);

  /// Translation for attach_error
  ///
  /// In en, this message translates to:
  /// **'Failed to update mentor: {value}'**
  String attachError(Object value);

  /// Translation for finance
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// Translation for analytics
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// Translation for compliance
  ///
  /// In en, this message translates to:
  /// **'Compliance'**
  String get compliance;

  /// Translation for users
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// Translation for growth_insight
  ///
  /// In en, this message translates to:
  /// **'User growth is up 12% this week compared to last month.'**
  String get growthInsight;

  /// Translation for top_categories_insight
  ///
  /// In en, this message translates to:
  /// **'Top categories: Barbersalons (65%), Spas (20%).'**
  String get topCategoriesInsight;

  /// Translation for admin_panel
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// Translation for salon_dashboard
  ///
  /// In en, this message translates to:
  /// **'Salon Dashboard'**
  String get salonDashboard;

  /// Translation for my_schedule
  ///
  /// In en, this message translates to:
  /// **'My Schedule'**
  String get mySchedule;

  /// Translation for offers
  ///
  /// In en, this message translates to:
  /// **'Offers'**
  String get offers;

  /// Translation for ads
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get ads;

  /// Translation for feedback
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Translation for tell_others
  ///
  /// In en, this message translates to:
  /// **'Tell others about us'**
  String get tellOthers;

  /// Translation for share_link
  ///
  /// In en, this message translates to:
  /// **'Share Salon Link'**
  String get shareLink;

  /// Translation for privacy_policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Translation for salon_link_copied
  ///
  /// In en, this message translates to:
  /// **'Salon Link Copied to Clipboard!'**
  String get salonLinkCopied;

  /// Translation for feedback_display
  ///
  /// In en, this message translates to:
  /// **'Feedback display...'**
  String get feedbackDisplay;

  /// Translation for cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Translation for try_again
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// Translation for confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Translation for close
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Translation for create
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// Translation for change_profile_picture
  ///
  /// In en, this message translates to:
  /// **'Change Profile Picture'**
  String get changeProfilePicture;

  /// Translation for view_all
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Translation for see_all
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Translation for system_health_title
  ///
  /// In en, this message translates to:
  /// **'System Health'**
  String get systemHealthTitle;

  /// Translation for send_feedback
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// Translation for retry
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Translation for delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Translation for gallery
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// Translation for camera
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Translation for redeem
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get redeem;

  /// Translation for history
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Translation for complete_payment
  ///
  /// In en, this message translates to:
  /// **'Complete Payment'**
  String get completePayment;

  /// Translation for change_password
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Translation for report_success
  ///
  /// In en, this message translates to:
  /// **'Report generated successfully!'**
  String get reportSuccess;

  /// Translation for offer_success
  ///
  /// In en, this message translates to:
  /// **'Offer created successfully!'**
  String get offerSuccess;

  /// Translation for manage_salon
  ///
  /// In en, this message translates to:
  /// **'Manage Salon Profile'**
  String get manageSalon;

  /// Translation for launch
  ///
  /// In en, this message translates to:
  /// **'Launch'**
  String get launch;

  /// Translation for include_options
  ///
  /// In en, this message translates to:
  /// **'Include Options:'**
  String get includeOptions;

  /// Translation for create_promotion
  ///
  /// In en, this message translates to:
  /// **'Create Promotion'**
  String get createPromotion;

  /// Translation for create_offer
  ///
  /// In en, this message translates to:
  /// **'Create New Offer'**
  String get createOffer;

  /// Translation for create_ad
  ///
  /// In en, this message translates to:
  /// **'Create Ad Campaign'**
  String get createAd;

  /// Translation for explore_salons
  ///
  /// In en, this message translates to:
  /// **'Explore Salons'**
  String get exploreSalons;

  /// Translation for book_appointment
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointment;

  /// Translation for subscription_plans
  ///
  /// In en, this message translates to:
  /// **'Subscription Plans'**
  String get subscriptionPlans;

  /// Translation for select_plan
  ///
  /// In en, this message translates to:
  /// **'Select Plan'**
  String get selectPlan;

  /// Translation for recommended
  ///
  /// In en, this message translates to:
  /// **'RECOMMENDED'**
  String get recommended;

  /// Translation for appointment_history
  ///
  /// In en, this message translates to:
  /// **'Appointment History'**
  String get appointmentHistory;

  /// Translation for report_options
  ///
  /// In en, this message translates to:
  /// **'Report Options'**
  String get reportOptions;

  /// Translation for generate
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// Translation for share
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Translation for report_problem
  ///
  /// In en, this message translates to:
  /// **'Report a Problem'**
  String get reportProblem;

  /// Translation for bug_report
  ///
  /// In en, this message translates to:
  /// **'Bug Report'**
  String get bugReport;

  /// Translation for usage_abuse
  ///
  /// In en, this message translates to:
  /// **'Usage Abuse'**
  String get usageAbuse;

  /// Translation for feature_request
  ///
  /// In en, this message translates to:
  /// **'Feature Request'**
  String get featureRequest;

  /// Translation for other
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// Translation for email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Translation for sign_up
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Translation for full_name
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Translation for phone_number
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Translation for forgot_password
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Translation for welcome_back
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// Translation for sign_in_to_continue
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// Translation for sign_in
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Translation for create_an_account
  ///
  /// In en, this message translates to:
  /// **'Create an Account'**
  String get createAnAccount;

  /// Translation for male
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Translation for female
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Translation for gender
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Translation for email_is_required
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailIsRequired;

  /// Translation for password_is_required
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordIsRequired;

  /// Translation for error
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Translation for success
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// Translation for ok
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Translation for yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Translation for no
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Translation for done
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Translation for next
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Translation for back
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Translation for save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Translation for update
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// Translation for continue
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueKey;

  /// Translation for favorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// Translation for home
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Translation for notifications
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Translation for messages
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get messages;

  /// Translation for date
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Translation for time
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// Translation for price
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Translation for status
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// Translation for available
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// Translation for busy
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get busy;

  /// Translation for book_now
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// Translation for booking
  ///
  /// In en, this message translates to:
  /// **'Booking'**
  String get booking;

  /// Translation for select
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// Translation for selected
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// Translation for submit
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Translation for total
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Translation for dashboard
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Translation for receptionist_desk
  ///
  /// In en, this message translates to:
  /// **'Receptionist Desk'**
  String get receptionistDesk;

  /// Translation for staff_actions
  ///
  /// In en, this message translates to:
  /// **'Staff Actions'**
  String get staffActions;

  /// Translation for pending_payments
  ///
  /// In en, this message translates to:
  /// **'Pending Payments'**
  String get pendingPayments;

  /// Translation for salon_management
  ///
  /// In en, this message translates to:
  /// **'Salon Management'**
  String get salonManagement;

  /// Translation for support
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// Translation for active
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// Translation for inactive
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// Translation for no_data_found
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// Translation for please_wait
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// Translation for payment_successful
  ///
  /// In en, this message translates to:
  /// **'Payment successful'**
  String get paymentSuccessful;

  /// Translation for payment_failed
  ///
  /// In en, this message translates to:
  /// **'Payment failed'**
  String get paymentFailed;

  /// Translation for welcome
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Translation for don_t_have_an_account_sign_up
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get donTHaveAnAccountSignUp;

  /// Translation for already_have_an_account_login
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAnAccountLogin;

  /// Translation for logout_page_coming_soon
  ///
  /// In en, this message translates to:
  /// **'Logout Page - Coming Soon'**
  String get logoutPageComingSoon;

  /// Translation for system_alerts
  ///
  /// In en, this message translates to:
  /// **'System Alerts'**
  String get systemAlerts;

  /// Translation for completed
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// Translation for branch_management
  ///
  /// In en, this message translates to:
  /// **'Branch Management'**
  String get branchManagement;

  /// Translation for inventory_management
  ///
  /// In en, this message translates to:
  /// **'Inventory Management'**
  String get inventoryManagement;

  /// Translation for services_prices
  ///
  /// In en, this message translates to:
  /// **'Services & Prices'**
  String get servicesPrices;

  /// Translation for email_address
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// Translation for subject
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// Translation for no_subscriptions_available
  ///
  /// In en, this message translates to:
  /// **'No Subscriptions Available'**
  String get noSubscriptionsAvailable;

  /// Translation for pending
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// Translation for generating_report
  ///
  /// In en, this message translates to:
  /// **'Generating report...'**
  String get generatingReport;

  /// Translation for low_stock_alerts
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alerts'**
  String get lowStockAlerts;

  /// Translation for quick_actions
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Translation for active_campaigns
  ///
  /// In en, this message translates to:
  /// **'Active Campaigns'**
  String get activeCampaigns;

  /// Translation for tools_inventory
  ///
  /// In en, this message translates to:
  /// **'Tools & Inventory'**
  String get toolsInventory;

  /// Translation for validity_period
  ///
  /// In en, this message translates to:
  /// **'Validity Period:'**
  String get validityPeriod;

  /// Translation for ad_campaign_launched
  ///
  /// In en, this message translates to:
  /// **'Ad Campaign launched!'**
  String get adCampaignLaunched;

  /// Translation for assign_manager
  ///
  /// In en, this message translates to:
  /// **'Assign Manager'**
  String get assignManager;

  /// Translation for edit
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Translation for working_hours
  ///
  /// In en, this message translates to:
  /// **'Working Hours'**
  String get workingHours;

  /// Translation for low_stock_alert
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlert;

  /// Translation for role
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// Translation for barber
  ///
  /// In en, this message translates to:
  /// **'Barber'**
  String get barber;

  /// Translation for monthly
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// Translation for add_first_branch
  ///
  /// In en, this message translates to:
  /// **'Add First Branch'**
  String get addFirstBranch;

  /// Translation for additional_services
  ///
  /// In en, this message translates to:
  /// **'Additional Services:'**
  String get additionalServices;

  /// Translation for add_item
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// Translation for new_password
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// Translation for confirm_password
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Translation for issue_type
  ///
  /// In en, this message translates to:
  /// **'Issue Type'**
  String get issueType;

  /// Translation for app_feedback
  ///
  /// In en, this message translates to:
  /// **'App Feedback'**
  String get appFeedback;

  /// Translation for rating
  ///
  /// In en, this message translates to:
  /// **'Rating:'**
  String get rating;

  /// Translation for today
  ///
  /// In en, this message translates to:
  /// **'Today\\'**
  String get today;

  /// Translation for report_issue
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// Translation for error_details
  ///
  /// In en, this message translates to:
  /// **'Error Details'**
  String get errorDetails;

  /// Translation for stack_trace
  ///
  /// In en, this message translates to:
  /// **'Stack Trace:'**
  String get stackTrace;

  /// Translation for builder_error
  ///
  /// In en, this message translates to:
  /// **'Builder Error'**
  String get builderError;

  /// Translation for oops_something_went_wrong
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsSomethingWentWrong;

  /// Translation for log_out
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logOut;

  /// Translation for god_mode
  ///
  /// In en, this message translates to:
  /// **'God Mode'**
  String get godMode;

  /// Translation for account
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Translation for failed_to_load_subscriptions
  ///
  /// In en, this message translates to:
  /// **'Failed to load subscriptions'**
  String get failedToLoadSubscriptions;

  /// Translation for there_are_no_subscription_plans_available_at_the_m
  ///
  /// In en, this message translates to:
  /// **'There are no subscription plans available at the moment.'**
  String get thereAreNoSubscriptionPlansAvailableAtTheM;

  /// Translation for subscribe_to_the_salon
  ///
  /// In en, this message translates to:
  /// **'Subscribe to the Salon'**
  String get subscribeToTheSalon;

  /// Translation for item_restocked_to_10_units
  ///
  /// In en, this message translates to:
  /// **'Item restocked to 10 units'**
  String get itemRestockedTo10Units;

  /// Translation for popular
  ///
  /// In en, this message translates to:
  /// **'Popular'**
  String get popular;

  /// Translation for no_favorites_yet
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get noFavoritesYet;

  /// Translation for items_you_add_to_your_favorites_will_appear_here
  ///
  /// In en, this message translates to:
  /// **'Items you add to your favorites will appear here'**
  String get itemsYouAddToYourFavoritesWillAppearHere;

  /// Translation for browse_products
  ///
  /// In en, this message translates to:
  /// **'Browse Products'**
  String get browseProducts;

  /// Translation for download_report
  ///
  /// In en, this message translates to:
  /// **'Download Report'**
  String get downloadReport;

  /// Translation for file_format_pdf
  ///
  /// In en, this message translates to:
  /// **'File Format: PDF'**
  String get fileFormatPdf;

  /// Translation for report_details
  ///
  /// In en, this message translates to:
  /// **'Report Details'**
  String get reportDetails;

  /// Translation for download
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// Translation for report_type
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get reportType;

  /// Translation for time_period
  ///
  /// In en, this message translates to:
  /// **'Time Period'**
  String get timePeriod;

  /// Translation for file_name
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// Translation for enter_file_name
  ///
  /// In en, this message translates to:
  /// **'Enter file name'**
  String get enterFileName;

  /// Translation for hello
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Translation for gold
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// Translation for select_date
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Translation for available_times
  ///
  /// In en, this message translates to:
  /// **'Available Times'**
  String get availableTimes;

  /// Translation for select_a_date_first_to_see_available_times
  ///
  /// In en, this message translates to:
  /// **'Select a date first to see available times'**
  String get selectADateFirstToSeeAvailableTimes;

  /// Translation for pending_confirmations
  ///
  /// In en, this message translates to:
  /// **'Pending Confirmations'**
  String get pendingConfirmations;

  /// Translation for weekly_earnings_trend
  ///
  /// In en, this message translates to:
  /// **'Weekly Earnings Trend'**
  String get weeklyEarningsTrend;

  /// Translation for no_earnings_data_available
  ///
  /// In en, this message translates to:
  /// **'No earnings data available'**
  String get noEarningsDataAvailable;

  /// Translation for upgrade_to_unlock
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock'**
  String get upgradeToUnlock;

  /// Translation for upgrade_now
  ///
  /// In en, this message translates to:
  /// **'Upgrade Now'**
  String get upgradeNow;

  /// Translation for view_plans
  ///
  /// In en, this message translates to:
  /// **'View Plans'**
  String get viewPlans;

  /// Translation for subscription
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// Translation for no_features_available
  ///
  /// In en, this message translates to:
  /// **'No features available'**
  String get noFeaturesAvailable;

  /// Translation for unable_to_load_subscription
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Subscription'**
  String get unableToLoadSubscription;

  /// Translation for no_active_subscription
  ///
  /// In en, this message translates to:
  /// **'No Active Subscription'**
  String get noActiveSubscription;

  /// Translation for connection_error
  ///
  /// In en, this message translates to:
  /// **'Connection Error'**
  String get connectionError;

  /// Translation for pull_down_to_refresh
  ///
  /// In en, this message translates to:
  /// **'Pull down to refresh'**
  String get pullDownToRefresh;

  /// Translation for refresh_failed
  ///
  /// In en, this message translates to:
  /// **'Refresh failed!'**
  String get refreshFailed;

  /// Translation for release_to_refresh
  ///
  /// In en, this message translates to:
  /// **'Release to refresh'**
  String get releaseToRefresh;

  /// Translation for refresh_completed
  ///
  /// In en, this message translates to:
  /// **'Refresh completed'**
  String get refreshCompleted;

  /// Translation for pull_up_to_load_more
  ///
  /// In en, this message translates to:
  /// **'Pull up to load more'**
  String get pullUpToLoadMore;

  /// Translation for load_failed
  ///
  /// In en, this message translates to:
  /// **'Load failed!'**
  String get loadFailed;

  /// Translation for release_to_load_more
  ///
  /// In en, this message translates to:
  /// **'Release to load more'**
  String get releaseToLoadMore;

  /// Translation for no_more_data
  ///
  /// In en, this message translates to:
  /// **'No more data'**
  String get noMoreData;

  /// Translation for delete_profile
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get deleteProfile;

  /// Translation for are_you_sure_you_want_to_delete_your_profile_this_
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your profile? This action cannot be undone.'**
  String get areYouSureYouWantToDeleteYourProfileThis;

  /// Translation for profile_deleted
  ///
  /// In en, this message translates to:
  /// **'Profile deleted'**
  String get profileDeleted;

  /// Translation for choose_an_option
  ///
  /// In en, this message translates to:
  /// **'Choose an option'**
  String get chooseAnOption;

  /// Translation for already_have_an_account_log_in
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAnAccountLogIn;

  /// Translation for welcome_to_na3eeman
  ///
  /// In en, this message translates to:
  /// **'Welcome to Na3eeman'**
  String get welcomeToNa3Eeman;

  /// Translation for your_premium_barber_booking_experience_book_manage
  ///
  /// In en, this message translates to:
  /// **'Your premium barber booking experience.\nBook, manage, and discover the best barbers near you.'**
  String get yourPremiumBarberBookingExperienceBookManage;

  /// Translation for personalise_your_theme
  ///
  /// In en, this message translates to:
  /// **'Personalise Your Theme'**
  String get personaliseYourTheme;

  /// Translation for we_ll_tailor_the_app_colours_to_your_preference
  ///
  /// In en, this message translates to:
  /// **'We\'ll tailor the app colours to your preference.'**
  String get weLlTailorTheAppColoursToYourPreference;

  /// Translation for prefer_not_to_say
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotToSay;

  /// Translation for how_will_you_use_na3eeman
  ///
  /// In en, this message translates to:
  /// **'How will you use Na3eeman?'**
  String get howWillYouUseNa3Eeman;

  /// Translation for dev_account_switcher
  ///
  /// In en, this message translates to:
  /// **'Dev Account Switcher'**
  String get devAccountSwitcher;

  /// Translation for retail_snapshot
  ///
  /// In en, this message translates to:
  /// **'Retail Snapshot'**
  String get retailSnapshot;

  /// Translation for team_leaderboard
  ///
  /// In en, this message translates to:
  /// **'Team Leaderboard'**
  String get teamLeaderboard;

  /// Translation for reorder_now
  ///
  /// In en, this message translates to:
  /// **'Reorder Now'**
  String get reorderNow;

  /// Translation for view_mode
  ///
  /// In en, this message translates to:
  /// **'View Mode'**
  String get viewMode;

  /// Translation for unified_p_l
  ///
  /// In en, this message translates to:
  /// **'Unified P&L'**
  String get unifiedPL;

  /// Translation for global_stock_value
  ///
  /// In en, this message translates to:
  /// **'Global Stock Value'**
  String get globalStockValue;

  /// Translation for 8_3_vs_last_month
  ///
  /// In en, this message translates to:
  /// **'+8.3% vs last month'**
  String get key83VsLastMonth;

  /// Translation for branch_comparison
  ///
  /// In en, this message translates to:
  /// **'Branch Comparison'**
  String get branchComparison;

  /// Translation for inter_branch_transfers
  ///
  /// In en, this message translates to:
  /// **'Inter-Branch Transfers'**
  String get interBranchTransfers;

  /// Translation for new_transfer
  ///
  /// In en, this message translates to:
  /// **'New Transfer'**
  String get newTransfer;

  /// Translation for commission_calculator
  ///
  /// In en, this message translates to:
  /// **'Commission Calculator'**
  String get commissionCalculator;

  /// Translation for resource_occupancy
  ///
  /// In en, this message translates to:
  /// **'Resource Occupancy'**
  String get resourceOccupancy;

  /// Translation for compliance_tracker
  ///
  /// In en, this message translates to:
  /// **'Compliance Tracker'**
  String get complianceTracker;

  /// Translation for consumable_waste
  ///
  /// In en, this message translates to:
  /// **'Consumable Waste'**
  String get consumableWaste;

  /// Translation for upgrade_plan
  ///
  /// In en, this message translates to:
  /// **'Upgrade Plan'**
  String get upgradePlan;

  /// Translation for kit_maintenance
  ///
  /// In en, this message translates to:
  /// **'Kit Maintenance'**
  String get kitMaintenance;

  /// Translation for quick_book
  ///
  /// In en, this message translates to:
  /// **'Quick Book'**
  String get quickBook;

  /// Translation for add_a_new_appointment
  ///
  /// In en, this message translates to:
  /// **'Add a new appointment'**
  String get addANewAppointment;

  /// Translation for now
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get now;

  /// Translation for today_s_earnings
  ///
  /// In en, this message translates to:
  /// **'Today\'s Earnings'**
  String get todaySEarnings;

  /// Translation for on_your_plan
  ///
  /// In en, this message translates to:
  /// **'on your plan'**
  String get onYourPlan;

  /// Translation for trial
  ///
  /// In en, this message translates to:
  /// **'Trial'**
  String get trial;

  /// Translation for intern_activity
  ///
  /// In en, this message translates to:
  /// **'Intern Activity'**
  String get internActivity;

  /// Translation for assign_daily_tip
  ///
  /// In en, this message translates to:
  /// **'Assign Daily Tip'**
  String get assignDailyTip;

  /// Translation for select_intern
  ///
  /// In en, this message translates to:
  /// **'Select Intern'**
  String get selectIntern;

  /// Translation for optional_note
  ///
  /// In en, this message translates to:
  /// **'Optional Note'**
  String get optionalNote;

  /// Translation for subscription_details
  ///
  /// In en, this message translates to:
  /// **'Subscription Details'**
  String get subscriptionDetails;

  /// Translation for plan_features
  ///
  /// In en, this message translates to:
  /// **'Plan Features'**
  String get planFeatures;

  /// Translation for review_plan
  ///
  /// In en, this message translates to:
  /// **'Review Plan'**
  String get reviewPlan;

  /// Translation for plan_confirmed_selection
  ///
  /// In en, this message translates to:
  /// **'Plan Confirmed Selection'**
  String get planConfirmedSelection;

  /// Translation for total_charges
  ///
  /// In en, this message translates to:
  /// **'Total Charges'**
  String get totalCharges;

  /// Translation for payment_instructions
  ///
  /// In en, this message translates to:
  /// **'Payment Instructions'**
  String get paymentInstructions;

  /// Translation for please_proceed_with_your_primary_linked_account_ba
  ///
  /// In en, this message translates to:
  /// **'Please proceed with your primary linked account balance, or choose a backup credit card setup configured inside configuration panels to finalize invoice sync.'**
  String get pleaseProceedWithYourPrimaryLinkedAccountBa;

  /// Translation for multi_branch_support_setup_required_admin_action_a
  ///
  /// In en, this message translates to:
  /// **'Multi-Branch support setup required admin action approval configuration setup.'**
  String get multiBranchSupportSetupRequiredAdminActionA;

  /// Translation for processing_payment_mock_step
  ///
  /// In en, this message translates to:
  /// **'Processing payment mock step...'**
  String get processingPaymentMockStep;

  /// Translation for proceed_to_pay
  ///
  /// In en, this message translates to:
  /// **'Proceed to Pay'**
  String get proceedToPay;

  /// Translation for admin_alerted_regarding_multi_branch_access
  ///
  /// In en, this message translates to:
  /// **'Admin alerted regarding multi-branch access...'**
  String get adminAlertedRegardingMultiBranchAccess;

  /// Translation for contact_admin
  ///
  /// In en, this message translates to:
  /// **'Contact Admin'**
  String get contactAdmin;

  /// Translation for active_offers
  ///
  /// In en, this message translates to:
  /// **'Active Offers'**
  String get activeOffers;

  /// Translation for no_offers_available_at_this_moment
  ///
  /// In en, this message translates to:
  /// **'No offers available at this moment'**
  String get noOffersAvailableAtThisMoment;

  /// Translation for products_prices
  ///
  /// In en, this message translates to:
  /// **'Products & Prices'**
  String get productsPrices;

  /// Translation for showcase
  ///
  /// In en, this message translates to:
  /// **'Showcase'**
  String get showcase;

  /// Translation for manage_all_your_branches_view_performance_metrics_
  ///
  /// In en, this message translates to:
  /// **'Manage all your branches, view performance metrics, and handle branch-specific settings from this page.'**
  String get manageAllYourBranchesViewPerformanceMetrics;

  /// Translation for salon_details
  ///
  /// In en, this message translates to:
  /// **'Salon Details'**
  String get salonDetails;

  /// Translation for location
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Translation for phone
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Translation for employee_details
  ///
  /// In en, this message translates to:
  /// **'Employee Details'**
  String get employeeDetails;

  /// Translation for performance_rating
  ///
  /// In en, this message translates to:
  /// **'Performance & Rating'**
  String get performanceRating;

  /// Translation for remove_from_salon
  ///
  /// In en, this message translates to:
  /// **'Remove from Salon'**
  String get removeFromSalon;

  /// Translation for employee_detached_successfully
  ///
  /// In en, this message translates to:
  /// **'Employee detached successfully.'**
  String get employeeDetachedSuccessfully;

  /// Translation for add_employee
  ///
  /// In en, this message translates to:
  /// **'Add Employee'**
  String get addEmployee;

  /// Translation for add
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Translation for employee_management
  ///
  /// In en, this message translates to:
  /// **'Employee Management'**
  String get employeeManagement;

  /// Translation for na3eeman
  ///
  /// In en, this message translates to:
  /// **'NA3EEMAN'**
  String get na3eeman;

  /// Translation for upgrade
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// Translation for staff_performance_report
  ///
  /// In en, this message translates to:
  /// **'Staff Performance Report'**
  String get staffPerformanceReport;

  /// Translation for are_you_sure_you_want_to_logout
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get areYouSureYouWantToLogout;

  /// Translation for confirm_booking
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// Translation for security_policy
  ///
  /// In en, this message translates to:
  /// **'Security Policy'**
  String get securityPolicy;

  /// Translation for application_rules
  ///
  /// In en, this message translates to:
  /// **'Application Rules'**
  String get applicationRules;

  /// Translation for invite_friends
  ///
  /// In en, this message translates to:
  /// **'Invite Friends'**
  String get inviteFriends;

  /// Translation for contact_us
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Translation for report_salon
  ///
  /// In en, this message translates to:
  /// **'Report Salon'**
  String get reportSalon;

  /// Translation for report_a_problem
  ///
  /// In en, this message translates to:
  /// **'Report A Problem'**
  String get reportAProblem;

  /// Translation for user_reports
  ///
  /// In en, this message translates to:
  /// **'User Reports'**
  String get userReports;

  /// Translation for user_management
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// Translation for staff
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// Translation for reports
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// Translation for bookings
  ///
  /// In en, this message translates to:
  /// **'Bookings'**
  String get bookings;

  /// Translation for i
  ///
  /// In en, this message translates to:
  /// **'I\\'**
  String get i;

  /// Translation for cash
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// Translation for employee
  ///
  /// In en, this message translates to:
  /// **'Employee'**
  String get employee;

  /// Translation for customer_feedback
  ///
  /// In en, this message translates to:
  /// **'Customer Feedback'**
  String get customerFeedback;

  /// Translation for back_to_login
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// Translation for admin
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// Translation for verify_otp
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOtp;

  /// Translation for submit_report
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// Translation for confirm_pay
  ///
  /// In en, this message translates to:
  /// **'Confirm & Pay'**
  String get confirmPay;

  /// Translation for salon_name
  ///
  /// In en, this message translates to:
  /// **'Salon Name'**
  String get salonName;

  /// Translation for description
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Translation for this_is_a_notification_message_mockup_details
  ///
  /// In en, this message translates to:
  /// **'This is a notification message mockup details.'**
  String get thisIsANotificationMessageMockupDetails;

  /// Translation for 2h_ago
  ///
  /// In en, this message translates to:
  /// **'2h ago'**
  String get key2HAgo;

  /// Translation for upgrade_subscription
  ///
  /// In en, this message translates to:
  /// **'Upgrade Subscription'**
  String get upgradeSubscription;

  /// Translation for enterprise_plan
  ///
  /// In en, this message translates to:
  /// **'Enterprise Plan'**
  String get enterprisePlan;

  /// Translation for premium_plan
  ///
  /// In en, this message translates to:
  /// **'Premium Plan'**
  String get premiumPlan;

  /// Translation for debug_menu
  ///
  /// In en, this message translates to:
  /// **'Debug Menu'**
  String get debugMenu;

  /// Translation for debug
  ///
  /// In en, this message translates to:
  /// **'DEBUG'**
  String get debug;

  /// Translation for debug_banner
  ///
  /// In en, this message translates to:
  /// **'Debug Banner'**
  String get debugBanner;

  /// Translation for performance_overlay
  ///
  /// In en, this message translates to:
  /// **'Performance Overlay'**
  String get performanceOverlay;

  /// Translation for slow_animations
  ///
  /// In en, this message translates to:
  /// **'Slow Animations'**
  String get slowAnimations;

  /// Translation for debug_logging
  ///
  /// In en, this message translates to:
  /// **'Debug Logging'**
  String get debugLogging;

  /// Translation for profile_updated_successfully
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// Translation for profile_deleted_successfully
  ///
  /// In en, this message translates to:
  /// **'Profile deleted successfully'**
  String get profileDeletedSuccessfully;

  /// Translation for choose_from_gallery
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// Translation for take_a_photo
  ///
  /// In en, this message translates to:
  /// **'Take a Photo'**
  String get takeAPhoto;

  /// Translation for select_language
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// Translation for english
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Translation for select_theme
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// Translation for light_mode
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Translation for dark_mode
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Translation for summer_glow_package
  ///
  /// In en, this message translates to:
  /// **'Summer Glow Package ☀️'**
  String get summerGlowPackage;

  /// Translation for complete_bridal_glow
  ///
  /// In en, this message translates to:
  /// **'Complete Bridal Glow 💅'**
  String get completeBridalGlow;

  /// Translation for home_page
  ///
  /// In en, this message translates to:
  /// **'Home Page'**
  String get homePage;

  /// Translation for home_page_content
  ///
  /// In en, this message translates to:
  /// **'Home Page Content'**
  String get homePageContent;

  /// Translation for appointment_reminder
  ///
  /// In en, this message translates to:
  /// **'Appointment Reminder'**
  String get appointmentReminder;

  /// Translation for pay_now
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// Translation for awesome
  ///
  /// In en, this message translates to:
  /// **'Awesome!'**
  String get awesome;

  /// Translation for your_feedback_matters
  ///
  /// In en, this message translates to:
  /// **'your Feedback matters'**
  String get yourFeedbackMatters;

  /// Translation for loyalty_points_earned
  ///
  /// In en, this message translates to:
  /// **'Loyalty Points Earned!'**
  String get loyaltyPointsEarned;

  /// Translation for test_example_com
  ///
  /// In en, this message translates to:
  /// **'test@example.com'**
  String get testExampleCom;

  /// Translation for test123
  ///
  /// In en, this message translates to:
  /// **'Test123!'**
  String get test123;

  /// Translation for overview
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Translation for financial_reports
  ///
  /// In en, this message translates to:
  /// **'Financial Reports'**
  String get financialReports;

  /// Translation for my_salon
  ///
  /// In en, this message translates to:
  /// **'My Salon'**
  String get mySalon;

  /// Translation for salons
  ///
  /// In en, this message translates to:
  /// **'Salons'**
  String get salons;

  /// Translation for favourites
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get favourites;

  /// Translation for average
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// Translation for card
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// Translation for assign_tip
  ///
  /// In en, this message translates to:
  /// **'Assign Tip'**
  String get assignTip;

  /// Translation for name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Translation for john_doe
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get johnDoe;

  /// Translation for financial_performance
  ///
  /// In en, this message translates to:
  /// **'Financial Performance'**
  String get financialPerformance;

  /// Translation for salon_branches
  ///
  /// In en, this message translates to:
  /// **'Salon Branches'**
  String get salonBranches;

  /// Translation for no_branches_available
  ///
  /// In en, this message translates to:
  /// **'No Branches Available'**
  String get noBranchesAvailable;

  /// Translation for add_your_first_branch_to_get_started
  ///
  /// In en, this message translates to:
  /// **'Add your first branch to get started'**
  String get addYourFirstBranchToGetStarted;

  /// Translation for delete_item
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// Translation for inventory_management_is_only_available_for_owners
  ///
  /// In en, this message translates to:
  /// **'Inventory management is only available for owners'**
  String get inventoryManagementIsOnlyAvailableForOwners;

  /// Translation for initializing_salon_details
  ///
  /// In en, this message translates to:
  /// **'Initializing salon details...'**
  String get initializingSalonDetails;

  /// Translation for failed_to_load_inventory
  ///
  /// In en, this message translates to:
  /// **'Failed to load inventory'**
  String get failedToLoadInventory;

  /// Translation for no_items_in_inventory
  ///
  /// In en, this message translates to:
  /// **'No items in inventory'**
  String get noItemsInInventory;

  /// Translation for unable_to_load_services_please_try_again
  ///
  /// In en, this message translates to:
  /// **'Unable to load services. Please try again.'**
  String get unableToLoadServicesPleaseTryAgain;

  /// Translation for no_services_available
  ///
  /// In en, this message translates to:
  /// **'No services available'**
  String get noServicesAvailable;

  /// Translation for manage_inventory
  ///
  /// In en, this message translates to:
  /// **'Manage Inventory'**
  String get manageInventory;

  /// Translation for customer_reviews
  ///
  /// In en, this message translates to:
  /// **'Customer Reviews'**
  String get customerReviews;

  /// Translation for add_your_review
  ///
  /// In en, this message translates to:
  /// **'Add Your Review'**
  String get addYourReview;

  /// Translation for submit_review
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get submitReview;

  /// Translation for write_your_review_here
  ///
  /// In en, this message translates to:
  /// **'Write your review here...'**
  String get writeYourReviewHere;

  /// Translation for our_barbers
  ///
  /// In en, this message translates to:
  /// **'Our Barbers'**
  String get ourBarbers;

  /// Translation for could_not_launch_maps
  ///
  /// In en, this message translates to:
  /// **'Could not launch maps'**
  String get couldNotLaunchMaps;

  /// Translation for add_additional_services
  ///
  /// In en, this message translates to:
  /// **'Add Additional Services'**
  String get addAdditionalServices;

  /// Translation for service_details
  ///
  /// In en, this message translates to:
  /// **'Service Details'**
  String get serviceDetails;

  /// Translation for main_service
  ///
  /// In en, this message translates to:
  /// **'Main Service'**
  String get mainService;

  /// Translation for total_duration
  ///
  /// In en, this message translates to:
  /// **'Total Duration:'**
  String get totalDuration;

  /// Translation for total_price
  ///
  /// In en, this message translates to:
  /// **'Total Price:'**
  String get totalPrice;

  /// Translation for add_more_services
  ///
  /// In en, this message translates to:
  /// **'Add More Services'**
  String get addMoreServices;

  /// Translation for no_service_selected
  ///
  /// In en, this message translates to:
  /// **'No Service Selected'**
  String get noServiceSelected;

  /// Translation for please_select_a_main_service_to_continue
  ///
  /// In en, this message translates to:
  /// **'Please select a main service to continue'**
  String get pleaseSelectAMainServiceToContinue;

  /// Translation for add_new_item
  ///
  /// In en, this message translates to:
  /// **'Add New Item'**
  String get addNewItem;

  /// Translation for item_name
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// Translation for initial_count
  ///
  /// In en, this message translates to:
  /// **'Initial Count'**
  String get initialCount;

  /// Translation for description_optional
  ///
  /// In en, this message translates to:
  /// **'Description (Optional)'**
  String get descriptionOptional;

  /// Translation for added_to_favorites
  ///
  /// In en, this message translates to:
  /// **'Added to Favorites'**
  String get addedToFavorites;

  /// Translation for share_dialog_opened
  ///
  /// In en, this message translates to:
  /// **'Share Dialog Opened'**
  String get shareDialogOpened;

  /// Translation for packages
  ///
  /// In en, this message translates to:
  /// **'Packages'**
  String get packages;

  /// Translation for packages_and_bundles_coming_soon
  ///
  /// In en, this message translates to:
  /// **'Packages and bundles coming soon!'**
  String get packagesAndBundlesComingSoon;

  /// Translation for products
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// Translation for salon_products_catalog_coming_soon
  ///
  /// In en, this message translates to:
  /// **'Salon products catalog coming soon!'**
  String get salonProductsCatalogComingSoon;

  /// Translation for offers_groups
  ///
  /// In en, this message translates to:
  /// **'Offers & Groups'**
  String get offersGroups;

  /// Translation for exclusive_offers_coming_soon
  ///
  /// In en, this message translates to:
  /// **'Exclusive offers coming soon!'**
  String get exclusiveOffersComingSoon;

  /// Translation for salon_feedback
  ///
  /// In en, this message translates to:
  /// **'Salon Feedback'**
  String get salonFeedback;

  /// Translation for 4_8_5
  ///
  /// In en, this message translates to:
  /// **'4.8 / 5'**
  String get key485;

  /// Translation for 120_reviews
  ///
  /// In en, this message translates to:
  /// **'(120 reviews)'**
  String get key120Reviews;

  /// Translation for ahmed_m
  ///
  /// In en, this message translates to:
  /// **'Ahmed M.'**
  String get ahmedM;

  /// Translation for great_service_completely_transformed_my_look_highl
  ///
  /// In en, this message translates to:
  /// **'Great service! Completely transformed my look. Highly recommended!'**
  String get greatServiceCompletelyTransformedMyLookHighl;

  /// Translation for feedback_entry_dialog
  ///
  /// In en, this message translates to:
  /// **'Feedback Entry Dialog'**
  String get feedbackEntryDialog;

  /// Translation for add_your_feedback
  ///
  /// In en, this message translates to:
  /// **'Add your feedback'**
  String get addYourFeedback;

  /// Translation for about_this_offer
  ///
  /// In en, this message translates to:
  /// **'About This Offer'**
  String get aboutThisOffer;

  /// Translation for included_services
  ///
  /// In en, this message translates to:
  /// **'Included Services'**
  String get includedServices;

  /// Translation for book_this_offer
  ///
  /// In en, this message translates to:
  /// **'Book This Offer'**
  String get bookThisOffer;

  /// Translation for select_date_time
  ///
  /// In en, this message translates to:
  /// **'Select Date & Time'**
  String get selectDateTime;

  /// Translation for available_slots
  ///
  /// In en, this message translates to:
  /// **'Available Slots'**
  String get availableSlots;

  /// Translation for booking_request_sent_successfully
  ///
  /// In en, this message translates to:
  /// **'Booking request sent successfully!'**
  String get bookingRequestSentSuccessfully;

  /// Translation for schedule_type
  ///
  /// In en, this message translates to:
  /// **'Schedule Type'**
  String get scheduleType;

  /// Translation for please_select_both_date_and_time
  ///
  /// In en, this message translates to:
  /// **'Please select both date and time'**
  String get pleaseSelectBothDateAndTime;

  /// Translation for confirm_schedule
  ///
  /// In en, this message translates to:
  /// **'Confirm Schedule'**
  String get confirmSchedule;

  /// Translation for selected_services
  ///
  /// In en, this message translates to:
  /// **'Selected Services'**
  String get selectedServices;

  /// Translation for one_time_only
  ///
  /// In en, this message translates to:
  /// **'One Time Only'**
  String get oneTimeOnly;

  /// Translation for schedule_this_appointment_once
  ///
  /// In en, this message translates to:
  /// **'Schedule this appointment once'**
  String get scheduleThisAppointmentOnce;

  /// Translation for bi_weekly
  ///
  /// In en, this message translates to:
  /// **'Bi-Weekly'**
  String get biWeekly;

  /// Translation for repeat_every_2_weeks
  ///
  /// In en, this message translates to:
  /// **'Repeat every 2 weeks'**
  String get repeatEvery2Weeks;

  /// Translation for repeat_every_month
  ///
  /// In en, this message translates to:
  /// **'Repeat every month'**
  String get repeatEveryMonth;

  /// Translation for book_a_haircut
  ///
  /// In en, this message translates to:
  /// **'Book a haircut'**
  String get bookAHaircut;

  /// Translation for owner_dashboard
  ///
  /// In en, this message translates to:
  /// **'Owner Dashboard'**
  String get ownerDashboard;

  /// Translation for new_action
  ///
  /// In en, this message translates to:
  /// **'New Action'**
  String get newAction;

  /// Translation for no_reviews_found
  ///
  /// In en, this message translates to:
  /// **'No reviews found.'**
  String get noReviewsFound;

  /// Translation for feedback_reviews
  ///
  /// In en, this message translates to:
  /// **'Feedback Reviews'**
  String get feedbackReviews;

  /// Translation for you_do_not_have_permission_to_add_branches
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to add branches'**
  String get youDoNotHavePermissionToAddBranches;

  /// Translation for add_new_branch_functionality_coming_soon
  ///
  /// In en, this message translates to:
  /// **'Add new branch functionality - Coming soon'**
  String get addNewBranchFunctionalityComingSoon;

  /// Translation for you_do_not_have_permission_to_assign_managers
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to assign managers'**
  String get youDoNotHavePermissionToAssignManagers;

  /// Translation for assign
  ///
  /// In en, this message translates to:
  /// **'Assign'**
  String get assign;

  /// Translation for branches
  ///
  /// In en, this message translates to:
  /// **'Branches'**
  String get branches;

  /// Translation for failed_to_load_branches
  ///
  /// In en, this message translates to:
  /// **'Failed to load branches'**
  String get failedToLoadBranches;

  /// Translation for no_branches_found
  ///
  /// In en, this message translates to:
  /// **'No branches found'**
  String get noBranchesFound;

  /// Translation for loading_branches
  ///
  /// In en, this message translates to:
  /// **'Loading branches...'**
  String get loadingBranches;

  /// Translation for discover_salons
  ///
  /// In en, this message translates to:
  /// **'Discover Salons'**
  String get discoverSalons;

  /// Translation for no_salons_found_nearby
  ///
  /// In en, this message translates to:
  /// **'No salons found nearby'**
  String get noSalonsFoundNearby;

  /// Translation for search_by_name_or_location
  ///
  /// In en, this message translates to:
  /// **'Search by name or location...'**
  String get searchByNameOrLocation;

  /// Translation for password_changed_successfully
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// Translation for current_password
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// Translation for confirm_new_password
  ///
  /// In en, this message translates to:
  /// **'Confirm New Password'**
  String get confirmNewPassword;

  /// Translation for check_your_spam_or_junk_folder_if_you_don_t_see_th
  ///
  /// In en, this message translates to:
  /// **'Check your spam or junk folder if you don\'t see the email.'**
  String get checkYourSpamOrJunkFolderIfYouDonTSeeTh;

  /// Translation for enter_your_email_address_and_we_ll_send_you_a_one_
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a One-Time Password (OTP) to reset your password.'**
  String get enterYourEmailAddressAndWeLlSendYouAOne;

  /// Translation for send_otp
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// Translation for professional_grooming_services
  ///
  /// In en, this message translates to:
  /// **'Professional Grooming Services'**
  String get professionalGroomingServices;

  /// Translation for remember_me
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// Translation for or
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get or;

  /// Translation for don_t_have_an_account
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get donTHaveAnAccount;

  /// Translation for quick_access_fast_login
  ///
  /// In en, this message translates to:
  /// **'Quick Access (Fast Login)'**
  String get quickAccessFastLogin;

  /// Translation for fast_login_as
  ///
  /// In en, this message translates to:
  /// **'Fast Login as'**
  String get fastLoginAs;

  /// Translation for mock_owner_variants_local_state
  ///
  /// In en, this message translates to:
  /// **'Mock Owner Variants (Local State)'**
  String get mockOwnerVariantsLocalState;

  /// Manually added: noPermissionMessage
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to view this page.'**
  String get noPermissionMessage;

  /// Manually added: backToHome
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// Manually added: noDataAvailable
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// Manually added: reorderItem
  ///
  /// In en, this message translates to:
  /// **'Reorder {name}'**
  String reorderItem(Object name);

  /// Manually added: currentStock
  ///
  /// In en, this message translates to:
  /// **'Current stock: {qty}'**
  String currentStock(Object qty);

  /// Manually added: removePermanently
  ///
  /// In en, this message translates to:
  /// **'Remove Permanently'**
  String get removePermanently;

  /// Manually added: addStock
  ///
  /// In en, this message translates to:
  /// **'Add Stock'**
  String get addStock;

  /// Manually added: allStockNominal
  ///
  /// In en, this message translates to:
  /// **'All stock levels are nominal.'**
  String get allStockNominal;

  /// Manually added: itemsCount
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemsCount(Object count);

  /// Manually added: unitsInStock
  ///
  /// In en, this message translates to:
  /// **'{qty} units in stock'**
  String unitsInStock(Object qty);

  /// Manually added: switchedTo
  ///
  /// In en, this message translates to:
  /// **'Switched to {label}'**
  String switchedTo(Object label);

  /// Button text for biometric login
  ///
  /// In en, this message translates to:
  /// **'Login with Biometrics'**
  String get loginWithBiometrics;

  /// Title for the feedback section
  ///
  /// In en, this message translates to:
  /// **'Help us improve'**
  String get helpUsImprove;

  /// Subtitle for the feedback section
  ///
  /// In en, this message translates to:
  /// **'Request a new service'**
  String get requestNewService;

  /// Button text for submitting feedback
  ///
  /// In en, this message translates to:
  /// **'Submit Suggestion'**
  String get submitSuggestion;

  /// Placeholder for the search bar
  ///
  /// In en, this message translates to:
  /// **'Search in services and salons'**
  String get searchServicesSalons;

  /// Manually added: noAppointmentsScheduled
  ///
  /// In en, this message translates to:
  /// **'No appointments scheduled for today.'**
  String get noAppointmentsScheduled;

  /// Manually added: noSalesToday
  ///
  /// In en, this message translates to:
  /// **'No sales\ntoday'**
  String get noSalesToday;

  /// Manually added: failedToUpdateProfile
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String failedToUpdateProfile(Object error);

  /// Manually added: failedToDeleteProfile
  ///
  /// In en, this message translates to:
  /// **'Failed to delete profile: {error}'**
  String failedToDeleteProfile(Object error);

  /// Manually added: navigationError
  ///
  /// In en, this message translates to:
  /// **'Navigation error: {error}'**
  String navigationError(Object error);

  /// Manually added: reportGenerationFailed
  ///
  /// In en, this message translates to:
  /// **'Failed to generate report: {error}'**
  String reportGenerationFailed(Object error);

  /// Manually added: subscriptionSuccess
  ///
  /// In en, this message translates to:
  /// **'Successfully subscribed to {name}!'**
  String subscriptionSuccess(Object name);

  /// Manually added: itemRestocked
  ///
  /// In en, this message translates to:
  /// **'Restocked to {count} units'**
  String itemRestocked(Object count);

  /// Manually added: selectedItem
  ///
  /// In en, this message translates to:
  /// **'Selected: {name}'**
  String selectedItem(Object name);

  /// No description provided for @staffCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Staff created successfully!'**
  String get staffCreatedSuccessfully;

  /// No description provided for @createStaff.
  ///
  /// In en, this message translates to:
  /// **'Create Staff'**
  String get createStaff;

  /// No description provided for @salon.
  ///
  /// In en, this message translates to:
  /// **'Salon'**
  String get salon;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @temporaryPassword.
  ///
  /// In en, this message translates to:
  /// **'Temporary Password'**
  String get temporaryPassword;

  /// No description provided for @createStaffMember.
  ///
  /// In en, this message translates to:
  /// **'Create Staff Member'**
  String get createStaffMember;

  /// Create staff members menu item
  ///
  /// In en, this message translates to:
  /// **'Create Staff Members'**
  String get createStaffMembers;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @shareSalonLink.
  ///
  /// In en, this message translates to:
  /// **'Share Salon Link'**
  String get shareSalonLink;

  /// No description provided for @appRules.
  ///
  /// In en, this message translates to:
  /// **'App Rules'**
  String get appRules;

  /// No description provided for @faqs.
  ///
  /// In en, this message translates to:
  /// **'FAQs'**
  String get faqs;

  /// No description provided for @userGuides.
  ///
  /// In en, this message translates to:
  /// **'User Guides'**
  String get userGuides;

  /// No description provided for @noActiveCampaigns.
  ///
  /// In en, this message translates to:
  /// **'No active campaigns'**
  String get noActiveCampaigns;

  /// Management dashboard title
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get managementDashboard;

  /// No description provided for @editSalon.
  ///
  /// In en, this message translates to:
  /// **'Edit Salon'**
  String get editSalon;

  /// No description provided for @bookForCustomer.
  ///
  /// In en, this message translates to:
  /// **'Book for Customer'**
  String get bookForCustomer;

  /// No description provided for @searchAppointments.
  ///
  /// In en, this message translates to:
  /// **'Search Appointments'**
  String get searchAppointments;

  /// No description provided for @performanceAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Performance Analytics'**
  String get performanceAnalytics;

  /// No description provided for @bookingsSummary.
  ///
  /// In en, this message translates to:
  /// **'Bookings Summary'**
  String get bookingsSummary;

  /// Requests from this week
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// Requests from this month
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @todaySchedule.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Schedule'**
  String get todaySchedule;

  /// No description provided for @specialization.
  ///
  /// In en, this message translates to:
  /// **'Specialization'**
  String get specialization;

  /// No description provided for @bio.
  ///
  /// In en, this message translates to:
  /// **'Bio'**
  String get bio;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllRead;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @thereAreNoItemsToDisplayAtTheMoment.
  ///
  /// In en, this message translates to:
  /// **'There are no items to display at the moment.'**
  String get thereAreNoItemsToDisplayAtTheMoment;

  /// No description provided for @yourFavoriteItemsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your favorite items will appear here.'**
  String get yourFavoriteItemsWillAppearHere;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// No description provided for @tryAdjustingYourSearchTerms.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search terms.'**
  String get tryAdjustingYourSearchTerms;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @pleaseTryAgainLater.
  ///
  /// In en, this message translates to:
  /// **'Please try again later.'**
  String get pleaseTryAgainLater;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @pleaseCheckYourConnectionAndTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Please check your connection and try again.'**
  String get pleaseCheckYourConnectionAndTryAgain;

  /// No description provided for @pleaseWaitWhileWeLoadYourContent.
  ///
  /// In en, this message translates to:
  /// **'Please wait while we load your content.'**
  String get pleaseWaitWhileWeLoadYourContent;

  /// Option for choosing any staff member
  ///
  /// In en, this message translates to:
  /// **'No Preferences'**
  String get noPreferences;

  /// Option for granular staff selection
  ///
  /// In en, this message translates to:
  /// **'Select Professional per Service'**
  String get selectProfessionalPerService;

  /// Option for choosing one staff for all
  ///
  /// In en, this message translates to:
  /// **'Individual Selection'**
  String get individualSelection;

  /// Header for dates selection
  ///
  /// In en, this message translates to:
  /// **'Available Dates'**
  String get availableDates;

  /// Header for hours selection
  ///
  /// In en, this message translates to:
  /// **'Available Hours'**
  String get availableHours;

  /// Title in staff selection page for a specific service
  ///
  /// In en, this message translates to:
  /// **'Select staff for {service}'**
  String selectForService(String service);

  /// Placeholder for salon search box
  ///
  /// In en, this message translates to:
  /// **'Search for a salon...'**
  String get searchSalon;

  /// Title for the previous salon card
  ///
  /// In en, this message translates to:
  /// **'Your Last Visit'**
  String get yourLastVisit;

  /// Button to open maps
  ///
  /// In en, this message translates to:
  /// **'Show on Map'**
  String get showOnMap;

  /// Data export and import section title
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// Export data action
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Import data action
  ///
  /// In en, this message translates to:
  /// **'Import Data'**
  String get importData;

  /// Format selector label
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// Dataset selector label
  ///
  /// In en, this message translates to:
  /// **'Dataset'**
  String get exportDataset;

  /// Date range filter label
  ///
  /// In en, this message translates to:
  /// **'Date Range (optional)'**
  String get dateRange;

  /// No date filter applied
  ///
  /// In en, this message translates to:
  /// **'All time (no filter)'**
  String get allTime;

  /// How to handle import conflicts
  ///
  /// In en, this message translates to:
  /// **'Conflict Mode'**
  String get conflictMode;

  /// Import skips existing records
  ///
  /// In en, this message translates to:
  /// **'Skip existing records'**
  String get skipExisting;

  /// Skip mode description
  ///
  /// In en, this message translates to:
  /// **'New data only — keeps existing records unchanged'**
  String get skipExistingDesc;

  /// Import overwrites existing records
  ///
  /// In en, this message translates to:
  /// **'Overwrite existing records'**
  String get overwriteExisting;

  /// Overwrite mode description
  ///
  /// In en, this message translates to:
  /// **'Updates fields in existing records with imported values'**
  String get overwriteExistingDesc;

  /// File picker prompt
  ///
  /// In en, this message translates to:
  /// **'Tap to select Na3eeman JSON export'**
  String get selectJsonFile;

  /// File type restriction note
  ///
  /// In en, this message translates to:
  /// **'Only .json exports from Na3eeman are supported'**
  String get jsonOnlySupported;

  /// Import safety warning
  ///
  /// In en, this message translates to:
  /// **'Only import files that were previously exported from Na3eeman. Importing files from other sources may cause errors.'**
  String get importWarning;

  /// Import result section header
  ///
  /// In en, this message translates to:
  /// **'Import Result'**
  String get importResult;

  /// Export success message
  ///
  /// In en, this message translates to:
  /// **'Export ready'**
  String get exportReady;

  /// Export in progress
  ///
  /// In en, this message translates to:
  /// **'Exporting…'**
  String get exporting;

  /// Import in progress
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importing;

  /// Co-founder role name
  ///
  /// In en, this message translates to:
  /// **'Co-Founder'**
  String get cofounder;

  /// Co-founder role description
  ///
  /// In en, this message translates to:
  /// **'Co-Founder — Full owner access & data management'**
  String get cofounderRole;

  /// App rules popup title
  ///
  /// In en, this message translates to:
  /// **'App Rules & Policies'**
  String get appRulesTitle;

  /// User guide popup title
  ///
  /// In en, this message translates to:
  /// **'User Guide'**
  String get userGuideTitle;

  /// Role-specific rules subtitle
  ///
  /// In en, this message translates to:
  /// **'Rules for your role'**
  String get rulesForYourRole;

  /// Rules for customers
  ///
  /// In en, this message translates to:
  /// **'1. Book appointments only during salon operating hours.\n2. Cancel at least 2 hours before your appointment to avoid a no-show flag.\n3. Respect stylists and staff — harassment results in account suspension.\n4. Reviews must be honest and based on your personal experience.\n5. Do not share your account credentials with others.\n6. Loyalty points are non-transferable and expire after 12 months of inactivity.'**
  String get rulesCustomer;

  /// Rules for employees/barbers
  ///
  /// In en, this message translates to:
  /// **'1. Arrive at least 15 minutes before your first appointment.\n2. Mark yourself unavailable in the app if you cannot serve clients that day.\n3. All appointment updates must be done through the app — not phone calls.\n4. Keep your tools & inventory updated after every service.\n5. Earnings and commissions are calculated automatically; disputes go through your owner.\n6. Do not accept cash outside the app payment flow.'**
  String get rulesEmployee;

  /// Rules for salon owners
  ///
  /// In en, this message translates to:
  /// **'1. Keep your salon profile, services and prices up to date.\n2. Respond to disputes within 48 hours or the system will auto-resolve in the customer\'s favour.\n3. Data exports are for business use only — do not share exported files.\n4. Staff accounts you create are your responsibility.\n5. Subscriptions auto-renew; cancel at least 7 days before renewal to avoid charges.\n6. Marketing campaigns must comply with Jordanian advertising regulations.'**
  String get rulesOwner;

  /// Rules for receptionists
  ///
  /// In en, this message translates to:
  /// **'1. You may create, reschedule or cancel appointments on behalf of customers.\n2. Never access financial reports — that is an owner-only function.\n3. Data exports you initiate are logged and visible to the salon owner.\n4. Do not modify staff commissions or payroll settings.\n5. Report any system issues to the salon owner immediately.\n6. Customer data accessed must remain strictly confidential.'**
  String get rulesReceptionist;

  /// Rules for interns
  ///
  /// In en, this message translates to:
  /// **'1. Attend all scheduled shifts and training sessions.\n2. Complete your daily tasks before the end of your shift.\n3. You may shadow senior staff but must not perform services unsupervised.\n4. Report progress and any difficulties to your assigned mentor.\n5. Do not access customer financial data or payment records.\n6. Treat all customer information with the utmost confidentiality.'**
  String get rulesIntern;

  /// Rules for co-founders
  ///
  /// In en, this message translates to:
  /// **'1. Co-Founders have identical access rights to the primary Owner.\n2. All Owner rules apply — data exports are for business use only.\n3. Disputes between Co-Founders and Owners are handled outside the app.\n4. Co-Founder accounts can be revoked by the primary Owner at any time.\n5. Financial decisions (subscription changes, payroll) should be coordinated with the Owner.\n6. Co-Founders are equally responsible for salon compliance and staff conduct.'**
  String get rulesCofounder;

  /// User guide for customers
  ///
  /// In en, this message translates to:
  /// **'Getting started:\n• Find salons by category or location on the Home screen.\n• Tap a salon to view services, staff, and available time slots.\n• Select a service, choose a staff member (optional), then pick a date & time.\n• Pay cash at the salon or via the in-app payment flow.\n• Earn loyalty points with every completed appointment — redeem for free services.\n• Rate your experience after every visit to help others.'**
  String get guideCustomer;

  /// User guide for employees
  ///
  /// In en, this message translates to:
  /// **'Getting started:\n• Your dashboard shows today\'s appointments and your daily schedule.\n• Tap an appointment to see customer details and service requirements.\n• Mark appointments as In-Progress or Completed when done.\n• Update your tools & inventory after each service.\n• Check your earnings and commission breakdown in the Stats section.\n• Contact your salon owner for payroll or schedule changes.'**
  String get guideEmployee;

  /// User guide for owners
  ///
  /// In en, this message translates to:
  /// **'Getting started:\n• Set up your salon profile: name, photos, location and opening hours.\n• Add your services with prices and durations.\n• Invite staff by creating employee accounts from the Staff section.\n• Activate your subscription plan to unlock all features.\n• Monitor revenue, appointments and staff performance from the Dashboard.\n• Create offers and campaigns from the Marketing section.\n• Export your data from the Data Management page at any time.'**
  String get guideOwner;

  /// User guide for receptionists
  ///
  /// In en, this message translates to:
  /// **'Getting started:\n• Use the Receptionist Desk to view and manage all today\'s appointments.\n• Create walk-in appointments for customers directly from the calendar.\n• Search for customers by name or phone to pull up their booking history.\n• Process payments and mark appointments as complete.\n• Use the Data Management page to export appointment or customer reports.\n• Escalate any issues to the salon owner.'**
  String get guideReceptionist;

  /// User guide for interns
  ///
  /// In en, this message translates to:
  /// **'Getting started:\n• Check your Daily Tasks section every morning before your shift.\n• Shadow your assigned mentor and take notes in the Activity section.\n• Mark tasks as complete when done — your owner tracks your progress.\n• Ask your mentor before attempting any customer service independently.\n• Your schedule is set by the salon owner — check it the night before.\n• Complete your monthly training targets to unlock higher responsibilities.'**
  String get guideIntern;

  /// User guide for co-founders
  ///
  /// In en, this message translates to:
  /// **'Getting started:\n• You have access to everything the Owner can do — use it responsibly.\n• The Dashboard shows real-time revenue, appointments and staff activity.\n• Use the Data Management page to export or restore salon data.\n• Coordinate with the primary Owner before making subscription or billing changes.\n• Staff management: you can create, edit or deactivate staff accounts.\n• Marketing: launch campaigns and offers from the Marketing section.'**
  String get guideCofounder;

  /// Admin monitoring section title
  ///
  /// In en, this message translates to:
  /// **'Platform Monitoring'**
  String get platformMonitoring;

  /// Real-time metrics section
  ///
  /// In en, this message translates to:
  /// **'Real-Time Metrics'**
  String get realtimeMetrics;

  /// Currently active users count
  ///
  /// In en, this message translates to:
  /// **'Active Users'**
  String get activeUsers;

  /// Booking conversion rate
  ///
  /// In en, this message translates to:
  /// **'Conversion Rate'**
  String get conversionRate;

  /// User churn rate
  ///
  /// In en, this message translates to:
  /// **'Churn Rate'**
  String get churnRate;

  /// Average session duration
  ///
  /// In en, this message translates to:
  /// **'Avg. Session'**
  String get avgSessionTime;

  /// User retention rate
  ///
  /// In en, this message translates to:
  /// **'Retention Rate'**
  String get retentionRate;

  /// Most used features
  ///
  /// In en, this message translates to:
  /// **'Top Features'**
  String get topFeatures;

  /// Revenue breakdown by subscription tier
  ///
  /// In en, this message translates to:
  /// **'Revenue by Tier'**
  String get revenueByTier;

  /// User service requests page title
  ///
  /// In en, this message translates to:
  /// **'User Requests'**
  String get userRequests;

  /// Request age filter label
  ///
  /// In en, this message translates to:
  /// **'Filter by Age'**
  String get filterByAge;

  /// User role filter label
  ///
  /// In en, this message translates to:
  /// **'Filter by Role'**
  String get filterByRole;

  /// Subscription tier filter label
  ///
  /// In en, this message translates to:
  /// **'Filter by Plan'**
  String get filterBySubscription;

  /// Show all requests
  ///
  /// In en, this message translates to:
  /// **'All Requests'**
  String get allRequests;

  /// Requests from today
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayRequests;

  /// Type of service request
  ///
  /// In en, this message translates to:
  /// **'Request Type'**
  String get requestType;

  /// Status of a service request
  ///
  /// In en, this message translates to:
  /// **'Request Status'**
  String get requestStatus;

  /// Empty state for requests list
  ///
  /// In en, this message translates to:
  /// **'No requests found'**
  String get noRequests;

  /// Mark request as resolved
  ///
  /// In en, this message translates to:
  /// **'Mark Resolved'**
  String get markResolved;

  /// View request details
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// Request detail page title
  ///
  /// In en, this message translates to:
  /// **'Request Detail'**
  String get requestDetailTitle;

  /// Who submitted the request
  ///
  /// In en, this message translates to:
  /// **'Submitted by'**
  String get submittedBy;

  /// When the request was submitted
  ///
  /// In en, this message translates to:
  /// **'Submitted at'**
  String get submittedAt;

  /// Request resolved snackbar
  ///
  /// In en, this message translates to:
  /// **'Request marked as resolved'**
  String get requestResolved;

  /// No description provided for @enhancedFeatures.
  ///
  /// In en, this message translates to:
  /// **'Enhanced Features'**
  String get enhancedFeatures;
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
