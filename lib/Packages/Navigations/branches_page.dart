import 'package:flutter/material.dart';

import '../../Models/branch_model.dart';
import '../../Services/api_service.dart';
import '../../Utils/constants.dart';
import '../../components/common/custom_app_bar.dart';
import '../../components/common/loading_indicator.dart';
import '../Widgets/branch_card_2.dart';

class BranchesPage extends StatefulWidget {
  const BranchesPage({super.key});

  @override
  State<BranchesPage> createState() => _BranchesPageState();
}

class _BranchesPageState extends State<BranchesPage> {
  late Future<List<Branch>> _branchesFuture;
  // final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _branchesFuture = ApiService.getBranches();
  }

  void _refreshData() {
    setState(() {
      _branchesFuture = ApiService.getBranches();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'Branches',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<Branch>>(
        future: _branchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading branches...');
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: AppColors.errorColor),
                  const SizedBox(height: 16),
                  const Text('Failed to load branches'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final branches = snapshot.data!;

          if (branches.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No branches found'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                return BranchCard2(
                  branch: branch,
                  onTap: () => _showBranchDetails(branch),
                  onAssignManager: () => _assignManager(branch),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBranch,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showBranchDetails(Branch branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(branch.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Address: ${branch.address}'),
            Text('Phone: ${branch.phone}'),
            Text('Staff: ${branch.totalStaff}'), // Using getter
            Text('Monthly Revenue: \$${branch.formattedMonthlyRevenue}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addNewBranch() {
    // Implement add new branch functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add new branch functionality')),
    );
  }

  void _assignManager(Branch branch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Manager'),
        content: const Text('Select a staff member to assign as branch manager:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement manager assignment
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Manager assigned for ${branch.name}')),
              );
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}

