import 'package:easy_localization/easy_localization.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Services/enums/gender.dart';
// import 'package:na3eeman/Packages/Core/widgets/shared/error_widget.dart';


import '../../../../Helpers/logger.dart';
import '../../../../Models/shop/shops_model.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Services/api/api_service.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../../appointments/widgets/soonest_appointment_card.dart';
import '../../shop/widgets/barbershop_card.dart';
import '../../shop/widgets/customer_shop_ads.dart';
import '../widgets/category_card.dart';
import '../../../../Models/shop/category_model.dart';

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

  List<Category> _categories = [];
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
      final categories = await _apiService.getCategories();
      final userGender = _authProvider.user?.gender;

      final filtered = categories.where((cat) {
        if (cat.targetGender == 'all') return true;
        if (userGender == Gender.female && cat.targetGender == 'female') return true;
        if (userGender == Gender.male && cat.targetGender == 'male') return true;
        return false;
      }).toList();

      if (mounted) setState(() => _categories = filtered);
    } catch (e) {
      if (mounted) setState(() => _categories = []);
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
              const Spacer(),
              IconButtonStyled(
                icon: Icons.notifications_none_rounded,
                onPressed: () => _showNotifications(context),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  child: Icon(Icons.person, color: Theme.of(context).primaryColor),
                ),
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
                    Text(
                      'Hello, $userName! 👋',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ready for your fresh look today?',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: isDark ? AppColors.cream600 : AppColors.almostBlack300,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Categories Grid (was "Our Services")
                    _buildCategoriesGrid(isDark),

                    const SizedBox(height: 32),

                    // Soonest Appointment
                    const SoonestAppointmentCard(),

                    const SizedBox(height: 32),

                    // Loyalty / Points Card
                    _buildPointsTracker(isDark),

                    const SizedBox(height: 32),

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
    final points = _userPoints['points'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR BALANCE',
                style: TextStyle(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              Icon(Icons.stars_rounded, color: AppColors.cream400, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$points Points',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _redeemPoints,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('redeem'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _showHistory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('history'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catygories'.tr(),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            return CategoryCard(
              category: _categories[index],
              onTap: () => Navigator.pushNamed(
                context, 
                '/category_details', 
                arguments: _categories[index],
              ),
            );
          },
        ),
      ],
    );
  }

  // _buildTopServices was removed as it's replaced by _buildCategoriesGrid


  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        context: context,
        title: 'notifications'.tr(),
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
              subtitle: Text('this_is_a_notification_message_mockup_details'.tr()),
              trailing: Text('2h_ago'.tr(), style: TextStyle(fontSize: 12)),
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
              child: Text('cancel'.tr()),
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
