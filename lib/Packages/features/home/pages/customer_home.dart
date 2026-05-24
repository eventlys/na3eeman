import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Services/enums/gender.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
// import '../../../../Providers/app_providers.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Services/api/api_service.dart';
import '../../../features/navigation/sidebar.dart';
import '../../../features/navigation/sidebar_controller.dart';
import '../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../appointments/widgets/soonest_appointment_card.dart';
import '../widgets/category_card.dart';
import '../widgets/customer_feedback_section.dart';
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
  final ApiService _apiService = ApiService();

  List<Category> _allCategories = [];
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
        context.read<PointsProvider>().loadBalance(),
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
      if (mounted) setState(() => _allCategories = []);
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

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  const Expanded(child: GlobalSearchBar()),
                  const SizedBox(width: 12),
                  IconButtonStyled(
                    icon: Icons.wallet_giftcard_rounded,
                    color: Theme.of(context).primaryColor,
                    onPressed: () => Navigator.pushNamed(context, '/gift-card'),
                  ),
                  const SizedBox(width: 8),
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
                        const SoonestAppointmentCard(),
                        const SizedBox(height: 24),
                        _buildCategoriesGrid(
                          isDark,
                          Provider.of<AuthProvider>(context).user?.gender,
                        ),
                        const SizedBox(height: 32),
                        _buildPointsTracker(isDark),
                        const SizedBox(height: 32),
                        const CustomerFeedbackSection(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
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
                  ? [
                      AppColors.almostBlack600,
                      AppColors.almostBlack600.withOpacity(0.8),
                    ]
                  : [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.85),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).primaryColor.withOpacity(isDark ? 0 : 0.2),
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
                        'loyalty_balance_caps'.tr(),
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'points_count'.tr(args: [points.toString()]),
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
                    child: const Icon(
                      Icons.stars_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 32, color: Colors.white24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'complete_more_appointments_to_unlock_rewards'.tr(),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  InkWell(
                    onTap: () => Navigator.pushNamed(context, '/history'),
                    child: Row(
                      children: [
                        Text(
                          'history'.tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 16,
                        ),
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

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBottomSheetContainer(
        context: context,
        title: "notifications".tr(),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 3,
          itemBuilder: (context, index) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.05),
                child: Icon(
                  Icons.notifications_rounded,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              title: Text(
                'notification_title_indexed'.tr(args: [(index + 1).toString()]),
              ),
              subtitle: Text(
                "this_is_a_notification_message_mockup_details".tr(),
              ),
              trailing: Text("key2_h_ago".tr(), style: TextStyle(fontSize: 12)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(bool isDark, Gender? userGender) {
    final isLadies = userGender == Gender.female;

    // Filter categories by gender from the dynamic list
    final List<Category> curatedCategories = _allCategories.where((cat) {
      final catGender = cat.targetGender.toLowerCase();
      if (catGender == 'all') return true;
      if (isLadies && catGender == 'female') return true;
      if (!isLadies && catGender == 'male') return true;
      return false;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "catigories".tr(),
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
          ),
          itemCount: curatedCategories.length,
          itemBuilder: (context, index) {
            final cat = curatedCategories[index];
            return CategoryCard(
              category: cat,
              onTap: () => _handleCategoryTap(cat, isLadies),
            );
          },
        ),
      ],
    );
  }

  void _handleCategoryTap(Category cat, bool isLadies) {
    // If it's a female category and has sub-categories in the 'icon' field
    // if (isLadies && cat.icon != 'none' && cat.icon.contains(',')) {
    //   _showSubCategories(cat);
    // } else {
    _navigateToCategoryDetails(cat);
    // }
  }

  // void _showSubCategories(Category parentCat) {
  //   final subCats = parentCat.icon.split(',').map((s) => s.trim()).toList();

  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (context) => _buildBottomSheetContainer(
  //       context: context,
  //       title: parentCat.nameEn,
  //       child: Column(
  //         children: [
  //           SizedBox(
  //             height: 120,
  //             child: ListView.builder(
  //               scrollDirection: Axis.horizontal,
  //               padding: const EdgeInsets.symmetric(horizontal: 16),
  //               itemCount: subCats.length,
  //               itemBuilder: (context, index) {
  //                 final subName = subCats[index];
  //                 return Padding(
  //                   padding: const EdgeInsets.only(right: 12),
  //                   child: GestureDetector(
  //                     onTap: () {
  //                       Navigator.pop(context);
  //                       // Create a temporary category object for the sub-category
  //                       final subCat = Category(
  //                         id: parentCat
  //                             .id, // Keep parent ID for API calls or use a specific one if available
  //                         name: subName,
  //                         nameEn: subName,
  //                         icon: 'none',
  //                         targetGender: 'female',
  //                         image: parentCat.image,
  //                       );
  //                       _navigateToCategoryDetails(subCat, subQuery: subName);
  //                     },
  //                     child: Column(
  //                       children: [
  //                         Container(
  //                           width: 80,
  //                           height: 80,
  //                           decoration: BoxDecoration(
  //                             color: Theme.of(
  //                               context,
  //                             ).primaryColor.withOpacity(0.1),
  //                             borderRadius: BorderRadius.circular(20),
  //                             border: Border.all(
  //                               color: Theme.of(
  //                                 context,
  //                               ).primaryColor.withOpacity(0.2),
  //                             ),
  //                           ),
  //                           child: Icon(
  //                             Icons.auto_awesome_rounded,
  //                             color: Theme.of(context).primaryColor,
  //                           ),
  //                         ),
  //                         const SizedBox(height: 8),
  //                         Text(
  //                           subName,
  //                           style: const TextStyle(
  //                             fontSize: 12,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 );
  //               },
  //             ),
  //           ),
  //           const SizedBox(height: 32),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _navigateToCategoryDetails(Category cat, {String? subQuery}) {
    Navigator.pushNamed(
      context,
      '/category_details',
      arguments: {
        'category': cat,
        'giftMode': false,
        'giftGender': null,
        'subQuery': subQuery,
      },
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
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
