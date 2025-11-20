import 'package:flutter/material.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Services/api/api_service.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/themes/app_scaffold.dart';
import '../../../Core/themes/button_theme.dart';
import '../../../Core/themes/loading_indicator.dart';
import '../../../Core/widgets/common/earnings_chart.dart';
import '../../../Core/widgets/common/pending_confirmations.dart';
import '../../Navigation/sidebar.dart';
import '../../Navigation/sidebar_controller.dart';
import '../../appointments/widgets/appointments_list.dart';
import '../../shop/widgets/branches_overview.dart';
import '../widgets/status_row.dart';
import '../widgets/working_hours_tracker.dart';

class BarberHomePage extends StatefulWidget {
  const BarberHomePage({super.key});

  @override
  State<BarberHomePage> createState() => _BarberHomePageState();
}

class _BarberHomePageState extends State<BarberHomePage> with TickerProviderStateMixin {
  late SidebarController sidebarController;
  final ScrollController _scrollController = ScrollController();

  late AuthProvider _authProvider;
  late ShopProvider _shopProvider;
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

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);

    _authProvider = AuthProvider();
    _shopProvider = ShopProvider();
    _appointmentProvider = AppointmentProvider();

    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load all data from services
      final homeData = await _apiService.fetchHomeData();
      await _shopProvider.loadShopData();
      await _appointmentProvider.loadAppointments();
      final workingHours = await _apiService.fetchTodayWorkingHours();
      final pendingConfirmations = await _apiService.fetchPendingConfirmations();

      setState(() {
        _homeData = homeData;
        _branches = _shopProvider.branches;
        _pendingConfirmations = pendingConfirmations;
        _workingHours = workingHours;
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleConfirmationSuccess(int appointmentId) async {
    try {
      await _apiService.confirmCashPayment(appointmentId, _authProvider.user?.id ?? 0);
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
        icon: Image.asset(
          AppImages.menu,
          width: 30,
          height: 30,
        ),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColor.lightError,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            text: 'Retry',
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
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        AppointmentsList(appointments: appointments),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Today's Earnings",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: EarningsChart(earningsData: earnings),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
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
            color: isDark
                ? AppColor.darkTextHint
                : AppColor.lightTextHint,
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
