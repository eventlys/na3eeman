import 'package:na3eeman/l10n/app_localizations.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Services/enums/gender.dart';
// import 'package:na3eeman/Packages/Core/widgets/shared/error_widget.dart';


// import '../../../../Helpers/logger.dart';
// import '../../../../Models/salon/salons_model.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Providers/app_providers.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Packages/Core/utils/helpers/themes_helpers.dart';
import '../../../../Services/api/api_service.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../appointments/widgets/soonest_appointment_card.dart';
// import '../../salon/widgets/barbershop_card.dart';
// import '../../salon/widgets/customer_salon_ads.dart';
import '../widgets/category_card.dart';
import '../../../../Models/salon/category_model.dart';

class CustomerHomePage extends StatefulWidget {
  const CustomerHomePage({super.key});

  @override
  State<CustomerHomePage> createState() => _CustomerHomePageState();
}

class _CustomerHomePageState extends State<CustomerHomePage>
    with SingleTickerProviderStateMixin {
  late SidebarController sidebarController;
  final ScrollController _scrollController = ScrollController();
  bool _isSidebarOpen = false;

  late AuthProvider _authProvider;
  late FavoritesProvider _favoritesProvider;
  final ApiService _apiService = ApiService();

  List<Category> _allCategories = [];
  Map<String, dynamic> _userPoints = {'points': 0};
  bool _isLoading = true;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    sidebarController = SidebarController();
    sidebarController.init(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _authProvider = Provider.of<AuthProvider>(context, listen: false);
      _favoritesProvider =Provider.of<FavoritesProvider>(context, listen: false);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadAllData();
      });
    }
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.wait([
        _loadCategories(),
        _loadUserPoints(),
      ]);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadCategories() async {
    try {
      final List<dynamic> categories = await _apiService.getCategories();
      if (mounted) {
        setState(() {
          _allCategories = categories.map((e) => Category.fromJson(e)).toList();
        });
      }
    } catch (e) {
      print("Error loading categories: $e"); if (mounted) setState(() => _allCategories = []);
    }
  }

  Future<void> _loadUserPoints() async {
    try {
      if (_authProvider.user?.id != null) {
        final pointsData = await _apiService.getLoyaltyBalance(_authProvider.user!.id);
        setState(() {
          _userPoints = {'points': pointsData.points};
        });
      }
    } catch (e) {
      setState(() => _userPoints = {'points': 0});
    }
  }

  @override
  void dispose() {
    sidebarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    setState(() => _isSidebarOpen = !_isSidebarOpen);
    sidebarController.toggleSidebar();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final userName = _authProvider.user?.firstName ?? 'there';

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor)),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          // drawer: Sidebar(controller: sidebarController), // Removed
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              IconButtonStyled(
                icon: Icons.menu_rounded,
                onPressed: _toggleSidebar,
              ),
              const SizedBox(width: 12),
              const GlobalSearchBar(),
              const SizedBox(width: 12),
              IconButtonStyled(
                icon: Icons.notifications_none_rounded,
                onPressed: () => _showNotifications(context),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAllData,
        color: Theme.of(context).primaryColor,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Text(
                    //   'Hello, $userName! 👋',
                    //   style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 8),
                    // Text(
                    //   'Ready for your fresh look today?',
                    //   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    //     color: isDark ? AppColors.cream600 : AppColors.almostBlack300,
                    //   ),
                    // ),
                    // const SizedBox(height: 16),
                    // // Categories Grid (Scenario 1: Book for yourself)
                    _buildCategoriesGrid(isDark, Provider.of<AuthProvider>(context).user?.gender),
                    const SizedBox(height: 32),

                    // Gift a Service (Scenario 2: Gift for someone)
                    _buildGiftModeToggle(isDark),

                    const SizedBox(height: 32),

                    // Soonest Appointment
                    const SoonestAppointmentCard(),

                    const SizedBox(height: 32),

                    // Loyalty / Points Card
                    _buildPointsTracker(isDark),

                    const SizedBox(height: 32),

                    // Help Us Improve Section
                    const FeedbackSection(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    ),
    Sidebar(controller: sidebarController),
    ],
    );
  }

  Widget _buildPointsTracker(bool isDark) {
    return Consumer<PointsProvider>(
      builder: (context, pointsProvider, child) {
        final points = pointsProvider.currentBalance;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [AppColors.almostBlack600, AppColors.almostBlack600.withOpacity(0.8)]
                : [Theme.of(context).primaryColor, Theme.of(context).primaryColor.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(isDark ? 0 : 0.2),
                offset: const Offset(0, 10),
                blurRadius: 20,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LOYALTY BALANCE',
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$points Points',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.amber, size: 32),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                   _buildPointsInfoItem(Icons.add_circle_outline, '+25', 'Per Visit'),
                   const SizedBox(width: 24),
                   _buildPointsInfoItem(Icons.verified_user_outlined, '+15', 'On Time'),
                ],
              ),
              const Divider(height: 32, color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text(
                    'Complete more appointments to unlock rewards!',
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  InkWell(
                    onTap: _showHistory,
                    child: const Row(
                      children: [
                        Text('History', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Icon(Icons.chevron_right, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPointsInfoItem(IconData icon, String points, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(points, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildGiftModeToggle(bool isDark) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isMaleTheme = themeProvider.gender == UserGender.male;
    final giftColor = isMaleTheme ? AppColors.pink : AppColors.blue;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: giftColor.withOpacity(isDark ? 0.3 : 0.1),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: giftColor.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: giftColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.card_giftcard_rounded, color: giftColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gift a Service',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.almostBlack,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Perfect for friends and loved ones',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _giftGenderButton(
                  label: 'GIFT HIM',
                  gender: Gender.male,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _giftGenderButton(
                  label: 'GIFT HER',
                  gender: Gender.female,
                  color: AppColors.pink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _giftGenderButton({
    required String label,
    required Gender gender,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/category_selection',
          arguments: {
            'giftMode': true,
            'giftGender': gender.name.toUpperCase(),
          },
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isDark, Gender? userGender) {
    // Dynamically filter categories based on the live user state
    final displayCategories = _allCategories.where((cat) {
      final catGender = cat.targetGender.trim().toLowerCase();
      
      // Universally show unisex
      if (catGender == 'all' || catGender == 'both' || catGender == 'unisex') return true;
      
      // Strict matching for populated user
      if (userGender == Gender.female && (catGender == 'female' || catGender == 'women' || catGender == 'f')) return true;
      if (userGender == Gender.male && (catGender == 'male' || catGender == 'men' || catGender == 'm')) return true;
      
      return false;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.catigories,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (displayCategories.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'No categories found.',
                style: TextStyle(color: isDark ? AppColors.cream600 : AppColors.almostBlack300),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: displayCategories.length,
            itemBuilder: (context, index) {
              return CategoryCard(
                category: displayCategories[index],
                onTap: () => Navigator.pushNamed(
                  context, 
                  '/category_details', 
                  arguments: {
                    'category': displayCategories[index],
                    'giftMode': false,
                    'giftGender': null,
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        context: context,
        title: AppLocalizations.of(context)!.notifications,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                child: Icon(Icons.notifications_rounded, color: Theme.of(context).primaryColor),
              ),
              title: Text('Notification Title ${index + 1}'),
              subtitle: Text(AppLocalizations.of(context)!.thisIsANotificationMessageMockupDetails),
              trailing: Text(AppLocalizations.of(context)!.key2HAgo, style: TextStyle(fontSize: 12)),
            );
          },
        ),
      ),
    );
  }

  void _redeemPoints() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        context: context,
        title: 'Redeem Points',
        child: Column(
          children: [
            Text('You have ${_userPoints['points'] ?? 0} points to redeem.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
              child: Text(AppLocalizations.of(context)!.cancel),
            )
          ],
        ),
      ),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        context: context,
        title: 'Points History',
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Earned ${index + 50} Points'),
              subtitle: const Text('For booking appointment #123'),
              trailing: const Text('+50', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBottomSheetContainer({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.almostBlack600 : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
