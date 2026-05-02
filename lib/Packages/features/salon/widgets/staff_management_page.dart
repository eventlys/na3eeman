import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/colors.dart';
// import '../../../../../core/widgets/dashboard/dashboard_widgets.dart';
import '../../../../../Services/api/api_service.dart';
import '../../../../../Services/api/endpoints.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage> {
  List<Map<String, dynamic>> _staffList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    try {
      final apiService = ApiService();
      final response = await apiService.get(Endpoints.usersStaff);
      final List<dynamic> data = response['results'] ?? response['data'] ?? [];

      setState(() {
        _staffList = data.map((s) {
          return {
            'id': s['id']?.toString() ?? '',
            'name': '${s['first_name'] ?? ''} ${s['last_name'] ?? ''}'.trim().isNotEmpty 
                ? '${s['first_name']} ${s['last_name']}' 
                : (s['username'] ?? 'Unnamed'),
            'role': s['role'] ?? 'Expert',
            'phone': s['phone'] ?? 'N/A',
            'rating': s['average_rating'] ?? 5.0,
            'workingHours': s['working_hours_display'] ?? 'Flexible',
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading staff: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showExpertDetails(Map<String, dynamic> staff) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Expert Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(height: 32),
            Center(
              child: CircleAvatar(radius: 40, backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), child: Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor)),
            ),
            const SizedBox(height: 16),
            Center(child: Text(staff['name'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
            Center(child: Text(staff['role'], style: const TextStyle(color: AppColors.almostBlack300))),
            const SizedBox(height: 24),

            Text("performance_rating".tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.star_rounded, color: Colors.amber), const SizedBox(width: 4), Text('${staff['rating']} / 5.0')]),
            const SizedBox(height: 24),

            Text("working_hours".tr(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(staff['workingHours'], style: const TextStyle(color: AppColors.almostBlack300)),
            const SizedBox(height: 16),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () {
                  Navigator.pop(context);
                  _removeExpert(staff['id']);
                },
                child: Text("remove_from_salon".tr(), style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _removeExpert(String id) async {
    setState(() {
      _staffList.removeWhere((item) => item['id'] == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Expert removed successfully'), backgroundColor: AppColors.success));
  }

  void _showAddExpertDialog() {
    final nameController = TextEditingController();
    final roleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Expert'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name', hintText: 'John Doe')),
            TextField(controller: roleController, decoration: const InputDecoration(labelText: 'Role', hintText: 'Expert')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("cancel".tr())),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Instead of adding to local list, navigate to AdminCreateStaffPage
              // or handle via proper API call. For now, we point to the creation page.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please use the Admin Create Staff page for new members'))
              );
            },
            child: Text("add".tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Expert Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpertDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: _staffList.length,
              itemBuilder: (context, index) {
                final staff = _staffList[index];
                return GestureDetector(
                  onTap: () => _showExpertDetails(staff),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.almostBlack600 : AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.almostBlack50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(staff['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(staff['role'] as String, style: const TextStyle(color: AppColors.almostBlack300, fontSize: 12)),
                          ],
                        ),
                        const Icon(Icons.chevron_right_rounded, color: AppColors.almostBlack200)
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
