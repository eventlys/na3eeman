// import 'package:flutter/material.dart';
// import '../../Services/api_service.dart';
// import '../../Models/user_model.dart';
// import '../../Theme/glass_appbar.dart';
// import '../../Theme/sphere_neomorphic.dart';
// import '../../features/Backgrounds/bd_faded.dart';
// import '../../features/sidebar/sidebar.dart';
// import '../../features/sidebar/sidebar_controller.dart';
// import '../Widgets/appointments_list.dart';
// import '../Widgets/custom_navigation_bar.dart';
// import '../Widgets/earnings_chart.dart';
// import '../Widgets/stats_row.dart';
//
// class BarberHomePage extends StatefulWidget {
//   const BarberHomePage({super.key});
//
//   @override
//   State<BarberHomePage> createState() => _BarberHomePageState();
// }
//
// class _BarberHomePageState extends State<BarberHomePage> with TickerProviderStateMixin {
//   late Future<Map<String, dynamic>> _homeData;
//   late SidebarController sidebarController;
//   final ScrollController _scrollController = ScrollController();
//
//   // Default values to avoid undefined errors
//   Map<String, dynamic> _stats = {
//     'completed': 0,
//     'pending': 0,
//   };
//   List<dynamic> _appointments = [];
//   Map<String, dynamic> _earnings = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _homeData = ApiService.fetchHomeData();
//     sidebarController = SidebarController();
//     sidebarController.init(this);
//
//     // Load data when the future completes
//     _homeData.then((data) {
//       setState(() {
//         _stats = data['stats'] ?? _stats;
//         _appointments = data['appointments'] ?? _appointments;
//         _earnings = data['earnings'] ?? _earnings;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     sidebarController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _loadPoints() {
//     // Implement your points loading logic here
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final user = User(
//       id: 1,
//       email: 'customer@example.com',
//       role: 'owner',
//       name: 'John Doe',
//     );
//
//     return FadedBackground(
//       startColor: const Color(0xffffffff),
//       endColor: const Color(0xFFDFA8A4),
//       child: Scaffold(
//         backgroundColor: Colors.transparent,
//         extendBody: true,
//         body: Stack(
//           children: [
//             // Main Content with Animation
//             AnimatedBuilder(
//               animation: sidebarController.animation,
//               builder: (context, child) {
//                 return Transform(
//                   transform: Matrix4.identity()
//                     ..translate(
//                       sidebarController.animation.value * 250,
//                       sidebarController.animation.value * 25,
//                     )
//                     ..scale(1 - sidebarController.animation.value * 0.3),
//                   alignment: Alignment.centerLeft,
//                   child: Opacity(
//                     opacity: 1 - sidebarController.animation.value * 0.1,
//                     child: Container(
//                       decoration: BoxDecoration(
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(20),
//                           bottomLeft: Radius.circular(20),
//                         ),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(
//                                 sidebarController.animation.value * 0.2),
//                             blurRadius: 20,
//                             spreadRadius: 5,
//                           ),
//                         ],
//                       ),
//                       child: Scaffold(
//                         backgroundColor: Colors.transparent,
//                         extendBody: true,
//                         body: FutureBuilder<Map<String, dynamic>>(
//                           future: _homeData,
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState == ConnectionState.waiting) {
//                               return const Center(child: CircularProgressIndicator());
//                             }
//
//                             if (snapshot.hasError) {
//                               return Center(child: Text('Error: ${snapshot.error}'));
//                             }
//
//                             // Use the data from snapshot or fallback to defaults
//                             final data = snapshot.data ?? {};
//                             final stats = data['stats'] ?? _stats;
//                             final appointments = data['appointments'] ?? _appointments;
//                             final earnings = data['earnings'] ?? _earnings;
//
//                             return CustomScrollView(
//                               controller: _scrollController,
//                               slivers: [
//                                 GlassSliverAppBar(
//                                   title: 'Barber Dash',
//                                   backgroundColor: Colors.transparent,
//                                   leading: IconButton(
//                                     icon: Image.asset(
//                                       'assets/icons/menu.png',
//                                       width: 30,
//                                       height: 30,
//                                     ),
//                                     onPressed: () => sidebarController.toggleSidebar(),
//                                   ),
//                                   showBackButton: false,
//                                 ),
//
//                                 // Stats Row
//                                 SliverToBoxAdapter(
//                                   child: StatsRow(
//                                     completedOrders: stats['completed'] as int,
//                                     pendingOrders: stats['pending'] as int,
//                                   ),
//                                 ),
//
//                                 // Upcoming Appointments Header
//                                 const SliverToBoxAdapter(
//                                   child: Padding(
//                                     padding: EdgeInsets.all(16.0),
//                                     child: Text(
//                                       'Upcoming Appointments',
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//
//                                 // Appointments List
//                                 AppointmentsList(appointments: appointments),
//
//                                 // Earnings Chart Header
//                                 const SliverToBoxAdapter(
//                                   child: Padding(
//                                     padding: EdgeInsets.all(16.0),
//                                     child: Text(
//                                       "Today's Earnings",
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//
//                                 // Earnings Chart
//                                 SliverToBoxAdapter(
//                                   child: EarningsChart(earningsData: earnings),
//                                 ),
//
//                                 // Bottom padding
//                                 const SliverToBoxAdapter(
//                                   child: SizedBox(height: 20),
//                                 ),
//                               ],
//                             );
//                           },
//                         ),
//                         bottomNavigationBar: CustomNavigationBar(
//                           user: user,
//                           currentRoute: ModalRoute.of(context)?.settings.name ?? '/',
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//
//             // Sidebar Overlay
//             Sidebar(controller: sidebarController),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
import 'package:flutter/material.dart';
import '../../Services/api_service.dart';
import '../../Models/user_model.dart';
import '../../Models/branch_model.dart';
import '../../Models/pending_confirmation_model.dart';
import '../../Models/working_hours_model.dart';
import '../../Theme/glass_appbar.dart';
// import '../../Theme/sphere_neomorphic.dart';
import '../../features/Backgrounds/bd_faded.dart';
import '../../features/sidebar/sidebar.dart';
import '../../features/sidebar/sidebar_controller.dart';
import '../Widgets/appointments_list.dart';
import '../Widgets/custom_navigation_bar.dart';
import '../Widgets/earnings_chart.dart';
import '../Widgets/stats_row.dart';
import '../Widgets/branches_overview.dart';
import '../Widgets/pending_confirmations.dart';
import '../Widgets/working_hours_tracker.dart';

class BarberHomePage extends StatefulWidget {
  const BarberHomePage({super.key});

  @override
  State<BarberHomePage> createState() => _BarberHomePageState();
}

class _BarberHomePageState extends State<BarberHomePage> with TickerProviderStateMixin {
  late SidebarController sidebarController;
  final ScrollController _scrollController = ScrollController();

  // Simple data holders
  Map<String, dynamic> _homeData = {
    'stats': {'completed': 0, 'pending': 0},
    'appointments': [],
    'earnings': [],
  };
  List<Branch> _branches = [];
  List<PendingConfirmation> _pendingConfirmations = [];
  WorkingHours? _workingHours;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('Loading all data...');

      // Load all data in parallel
      final results = await Future.wait([
        ApiService.fetchHomeData(),
        ApiService.fetchBranches(),
        ApiService.fetchPendingConfirmations(),
        ApiService.fetchTodayWorkingHours(),
      ]);

      print('Data loaded successfully');

      setState(() {
        _homeData = results[0] as Map<String, dynamic>;
        _branches = results[1] as List<Branch>;
        _pendingConfirmations = results[2] as List<PendingConfirmation>;
        _workingHours = results[3] as WorkingHours;
        _isLoading = false;
      });

    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    sidebarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = User(
      id: 1,
      email: 'customer@example.com',
      role: 'owner',
      name: 'John Doe',
    );

    return FadedBackground(
      startColor: const Color(0xffffffff),
      endColor: const Color(0xFFDFA8A4),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            // Main Content with Animation
            AnimatedBuilder(
              animation: sidebarController.animation,
              builder: (context, child) {
                return Transform(
                  transform: Matrix4.identity()
                    ..translate(
                      sidebarController.animation.value * 250,
                      sidebarController.animation.value * 25,
                    )
                    ..scale(1 - sidebarController.animation.value * 0.3),
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: 1 - sidebarController.animation.value * 0.1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                sidebarController.animation.value * 0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        extendBody: true,
                        body: _buildContent(),
                        bottomNavigationBar: CustomNavigationBar(
                          user: user,
                          currentRoute: ModalRoute.of(context)?.settings.name ?? '/',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Sidebar Overlay
            Sidebar(controller: sidebarController),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final stats = _homeData['stats'] ?? {'completed': 0, 'pending': 0};
    final appointments = _homeData['appointments'] ?? [];
    final earnings = _homeData['earnings'] ?? [];

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        GlassSliverAppBar(
          title: 'Barber Dash',
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: Image.asset(
              'assets/icons/menu.png',
              width: 30,
              height: 30,
            ),
            onPressed: () => sidebarController.toggleSidebar(),
          ),
          showBackButton: false,
        ),

        // Stats Row
        SliverToBoxAdapter(
          child: StatsRow(
            completedOrders: (stats['completed'] ?? 0) as int,
            pendingOrders: (stats['pending'] ?? 0) as int,
          ),
        ),

        // Working Hours Tracker
        SliverToBoxAdapter(
          child: _workingHours != null
              ? WorkingHoursTracker(workingHours: _workingHours!)
              : _buildPlaceholder('No working hours data'),
        ),

        // Shop Branches
        SliverToBoxAdapter(
          child: _branches.isNotEmpty
              ? BranchesOverview(branches: _branches)
              : _buildPlaceholder('No branches data'),
        ),

        // Pending Confirmations
        SliverToBoxAdapter(
          child: _pendingConfirmations.isNotEmpty
              ? PendingConfirmations(pendingConfirmations: _pendingConfirmations)
              : _buildPlaceholder('No pending confirmations'),
        ),

        // Upcoming Appointments Header
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

        // Appointments List
        AppointmentsList(appointments: appointments),

        // Earnings Chart Header
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

        // Earnings Chart
        SliverToBoxAdapter(
          child: EarningsChart(earningsData: earnings),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(String text) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

