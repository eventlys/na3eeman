import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Services/api/api_service.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/themes/app_scaffold.dart';
import '../../../Core/themes/button_theme.dart';
import '../../../Core/themes/loading_indicator.dart';
import '../../../Core/widgets/common/earnings_chart.dart';
import '../../../Core/widgets/common/pending_confirmations.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../../appointments/widgets/appointments_list.dart';
import '../../salon/widgets/branches_overview.dart';
import '../widgets/status_row.dart';
import '../widgets/working_hours_tracker.dart';
// import 'package:easy_localization/easy_localization.dart';

class BarberHomePage extends StatefulWidget {
  const BarberHomePage({super.key});

  @override
  State<BarberHomePage> createState() => _BarberHomePageState();
}

class _BarberHomePageState extends State<BarberHomePage>
    with TickerProviderStateMixin {
  late SidebarController sidebarController;
  final ScrollController _scrollController = ScrollController();

  late AuthProvider _authProvider;
  late SalonProvider _salonProvider;
  late AppointmentProvider _appointmentProvider;
  final ApiService _apiService = ApiService();

  Map<String, dynamic> _homeData = {
    'stats': {'completed': 0, 'pending': 0},
    'appointments': [],
    'earnings': [],
  };

  List<dynamic> _branches = [];
  List<dynamic> _pendingConfirmations = [];
  Map<String, dynamic>? _workingHours;
  bool _isLoading = true;
  String? _error;
  bool _isSidebarOpen = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
  }

  /// Use didChangeDependencies so the Provider tree (context) is ready.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      _salonProvider = Provider.of<SalonProvider>(context, listen: false);
      _appointmentProvider =
          Provider.of<AppointmentProvider>(context, listen: false);
      _loadAllData();
    }
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load providers first (they have their own fallbacks / mock data)
      await Future.wait([
        _salonProvider.loadSalonData(),
        _appointmentProvider.loadAppointments(),
      ]);

      final salonId = _salonProvider.branches.isNotEmpty
          ? (_salonProvider.branches.first.id as int? ?? 0)
          : 0;

      // Fetch optional API data with individual error handling so one
      // failure doesn't block the whole page.
      Map<String, dynamic> homeData = {
        'stats': {
          'completed': _appointmentProvider.myAppointments
              .where((a) => a.status == 'COMPLETED')
              .length,
          'pending': _appointmentProvider.myAppointments
              .where((a) => a.status == 'PENDING')
              .length,
        },
        'appointments': _appointmentProvider.myAppointments,
        'earnings': [],
      };

      Map<String, dynamic>? workingHours;
      List<dynamic> pendingConfirmations = [];

      if (salonId > 0) {
        try {
          workingHours = await _apiService.fetchTodayWorkingHours(salonId);
        } catch (_) {
          // Backend endpoint may not exist yet; gracefully ignore
        }
        try {
          final raw = await _apiService.fetchPendingConfirmations(salonId);
          pendingConfirmations = raw;
        } catch (_) {}
      }

      setState(() {
        _homeData = homeData;
        _branches = _salonProvider.branches;
        _pendingConfirmations = pendingConfirmations;
        _workingHours = workingHours;
        _isLoading = false;
      });
    } catch (e) {
      // Even on total failure, show mock data so the UI isn't blank
      setState(() {
        _homeData = _getMockHomeData();
        _branches = [];
        _pendingConfirmations = [];
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Map<String, dynamic> _getMockHomeData() {
    return {
      'stats': {'completed': 12, 'pending': 3},
      'appointments': [
        {
          'id': 1,
          'customer_name': 'Ahmed Al-Rashid',
          'start_time': DateTime.now()
              .add(const Duration(hours: 1))
              .toIso8601String(),
          'status': 'PENDING',
          'services': ['Haircut'],
        },
        {
          'id': 2,
          'customer_name': 'Sara Khalid',
          'start_time': DateTime.now()
              .add(const Duration(hours: 3))
              .toIso8601String(),
          'status': 'CONFIRMED',
          'services': ['Beard Trim', 'Haircut'],
        },
      ],
      'earnings': [
        {'date': 'Mon', 'amount': 120.0},
        {'date': 'Tue', 'amount': 95.0},
        {'date': 'Wed', 'amount': 150.0},
        {'date': 'Thu', 'amount': 80.0},
        {'date': 'Fri', 'amount': 200.0},
        {'date': 'Sat', 'amount': 175.0},
        {'date': 'Sun', 'amount': 60.0},
      ],
    };
  }

  Future<void> _handleConfirmationSuccess(int appointmentId) async {
    try {
      await _apiService.confirmCashPayment(appointmentId);
      await _loadAllData();
    } catch (e) {
      print('Error confirming payment: $e');
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
    sidebarController.toggleSidebar();
  }

  @override
  void dispose() {
    sidebarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldWithSidebar(
      sidebar: Sidebar(controller: sidebarController),
      isSidebarOpen: _isSidebarOpen,
      onSidebarToggle: _toggleSidebar,
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return AppScaffold(
      title: 'Barber Dash',
      showAppBar: false,
      useGlassSliverAppBar: true,
      showBackButton: false,
      user: _authProvider.user,
      scrollController: _scrollController,
      glassLeading: IconButton(
        icon: Image.asset(AppImages.menu, width: 30, height: 30),
        onPressed: _toggleSidebar,
      ),
      showLoading: _isLoading,
      errorMessage: _error,
      onErrorRetry: _loadAllData,
      onRefresh: _loadAllData, // Use onRefresh instead of onRefreshFuture
      customBody: _isLoading
          ? const Center(child: LoadingIndicator.skeleton())
          : _error != null
          ? _buildErrorContent()
          : _buildContent(),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error: $_error',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColor.lightError),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: AppLocalizations.of(context)!.retry,
            onPressed: _loadAllData,
            variant: ButtonVariant.filled,
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final stats = _homeData['stats'] ?? {'completed': 0, 'pending': 0};
    final appointments = _homeData['appointments'] ?? [];
    final earnings = _homeData['earnings'] ?? [];

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: StatsRow(
            completedOrders: (stats['completed'] ?? 0) as int,
            pendingOrders: (stats['pending'] ?? 0) as int,
          ),
        ),

        SliverToBoxAdapter(
          child: _workingHours != null
              ? WorkingHoursTracker(workingHours: _workingHours!)
              : _buildEmptyState(
                  message: 'No working hours data',
                  icon: Icons.access_time,
                ),
        ),

        SliverToBoxAdapter(
          child: _branches.isNotEmpty
              ? BranchesOverview(branches: _branches)
              : _buildEmptyState(
                  message: 'No branches data',
                  icon: Icons.store,
                ),
        ),

        SliverToBoxAdapter(
          child: _pendingConfirmations.isNotEmpty
              ? PendingConfirmations(
                  pendingConfirmations: _pendingConfirmations,
                  onConfirmationSuccess: _handleConfirmationSuccess,
                )
              : _buildEmptyState(
                  message: 'No pending confirmations',
                  icon: Icons.pending_actions,
                ),
        ),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Upcoming Appointments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        AppointmentsList(appointments: appointments),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(AppLocalizations.of(context)!.todaySEarnings,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        SliverToBoxAdapter(child: EarningsChart(earningsData: earnings)),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),
      ],
    );
  }

  Widget _buildEmptyState({required String message, required IconData icon}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark
            ? AppColor.darkCard.withValues(alpha: 0.7)
            : AppColor.lightCard.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColor.darkTextHint.withValues(alpha: 0.1)
              : AppColor.lightTextHint.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColor.darkTextSecondary
                  : AppColor.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
