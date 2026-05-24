import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../Services/business_service.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/themes/loading_indicator.dart';
import '../widgets/branch_card_2.dart';

class BranchesPage extends StatefulWidget {
  const BranchesPage({super.key});

  @override
  State<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  late BranchService _branchService;

  @override
  void initState() {
    super.initState();
    // Initialize branch service
    _branchService = BranchService(apiService: ApiService());
    _loadBranches();
  }

  void _loadBranches() {
    _branchService.getBranches();
  }

  void _refreshData() {
    _loadBranches();
  }

  void _addNewBranch() {
    // Check if user has permission to add branches
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    if (!appState.canAccessSalonManagement()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Image.asset(
                AppImages.error,
                width: 20,
                height: 20,
                color: AppColor.light,
              ),
              SizedBox(width: 8),
              Text("you_do_not_have_permission_to_add_branches".tr()),
            ],
          ),
          backgroundColor: AppColor.lightError,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Implement add new branch functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Image.asset(
              AppImages.info,
              width: 20,
              height: 20,
              color: AppColor.light,
            ),
            SizedBox(width: 8),
            Text("add_new_branch_functionality_coming_soon".tr()),
          ],
        ),
        backgroundColor: AppColor.lightInfo,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showBranchDetails(dynamic branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          branch['name'] ?? 'Branch',
          style: TextStyle(color: AppColor.lightText),
        ),
        backgroundColor: AppColor.lightCard,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address: ${branch['address'] ?? 'N/A'}',
              style: TextStyle(color: AppColor.lightText),
            ),
            SizedBox(height: 8),
            Text(
              'Phone: ${branch['phone'] ?? 'N/A'}',
              style: TextStyle(color: AppColor.lightText),
            ),
            SizedBox(height: 8),
            Text(
              'Email: ${branch['email'] ?? 'N/A'}',
              style: TextStyle(color: AppColor.lightText),
            ),
            SizedBox(height: 8),
            Text(
              'Status: ${branch['is_active'] == true ? 'Active' : 'Inactive'}',
              style: TextStyle(
                color: branch['is_active'] == true
                    ? AppColor.lightSuccess
                    : AppColor.lightError,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "close".tr(),
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _assignManager(dynamic branch) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);

    if (!appState.canAccessSalonManagement()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Image.asset(
                AppImages.error,
                width: 20,
                height: 20,
                color: AppColor.light,
              ),
              SizedBox(width: 8),
              Text("you_do_not_have_permission_to_assign_managers".tr()),
            ],
          ),
          backgroundColor: AppColor.lightError,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "assign_manager".tr(),
          style: TextStyle(color: AppColor.lightText),
        ),
        backgroundColor: AppColor.lightCard,
        content: Text(
          'Select a staff member to assign as branch manager for ${branch['name'] ?? 'this branch'}:',
          style: TextStyle(color: AppColor.lightTextSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              "cancel".tr(),
              style: TextStyle(color: AppColor.lightTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement manager assignment
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Image.asset(
                        AppImages.check,
                        width: 20,
                        height: 20,
                        color: AppColor.light,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Manager assigned for ${branch['name'] ?? 'branch'}',
                      ),
                    ],
                  ),
                  backgroundColor: AppColor.lightSuccess,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.lightPrimary,
            ),
            child: Text("assign".tr(), style: TextStyle(color: AppColor.light)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _branchService,
      child: Scaffold(
        backgroundColor: AppColor.lightBackground,
        appBar: AppBar(
          title: Text(
            "branches".tr(),
            style: TextStyle(
              color: AppColor.lightText,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColor.lightCard,
          elevation: 0,
          leading: IconButton(
            icon: Image.asset(
              AppImages.arrow_red,
              width: 24,
              height: 24,
              color: AppColor.lightText,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: Image.asset(
                AppImages.refresh,
                width: 24,
                height: 24,
                color: AppColor.lightPrimary,
              ),
              onPressed: _refreshData,
            ),
          ],
        ),
        body: Consumer<BranchService>(
          builder: (context, branchService, child) {
            if (branchService.isLoading && branchService.branches.isEmpty) {
              return LoadingIndicator(message: "loading_branches".tr());
            }

            if (branchService.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.error,
                      width: 64,
                      height: 64,
                      color: AppColor.lightError,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "failed_to_load_branches".tr(),
                      style: TextStyle(color: AppColor.lightText, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      branchService.error!,
                      style: TextStyle(
                        color: AppColor.lightTextSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.lightPrimary,
                      ),
                      child: Text(
                        "retry".tr(),
                        style: TextStyle(color: AppColor.light),
                      ),
                    ),
                  ],
                ),
              );
            }

            final branches = branchService.branches;

            if (branches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      AppImages.store,
                      width: 64,
                      height: 64,
                      color: AppColor.lightTextSecondary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "no_branches_found".tr(),
                      style: TextStyle(
                        color: AppColor.lightTextSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer<AppStateProvider>(
                      builder: (context, appState, child) {
                        if (appState.canAccessSalonManagement()) {
                          return ElevatedButton(
                            onPressed: _addNewBranch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.lightPrimary,
                            ),
                            child: Text(
                              "add_first_branch".tr(),
                              style: TextStyle(color: AppColor.light),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              color: AppColor.lightPrimary,
              backgroundColor: AppColor.lightCard,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: branches.length,
                itemBuilder: (context, index) {
                  final branch = branches[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12),
                    child: BranchCard2(
                      // branch: branch, // Pass the dynamic branch data
                      onTap: () => _showBranchDetails(branch),
                      onAssignManager: () => _assignManager(branch),
                    ),
                  );
                },
              ),
            );
          },
        ),
        floatingActionButton: Consumer<AppStateProvider>(
          builder: (context, appState, child) {
            // Only show FAB if user has permission to add branches
            if (appState.canAccessSalonManagement()) {
              return FloatingActionButton(
                onPressed: _addNewBranch,
                backgroundColor: AppColor.lightPrimary,
                child: Image.asset(
                  AppImages.plus,
                  width: 24,
                  height: 24,
                  color: AppColor.light,
                ),
              );
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
