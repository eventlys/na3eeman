import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/salon_provider.dart';
import '../../../../../core/theme/colors.dart';
import '../../../../../Services/api/api_service.dart';
import '../../../../../Services/api/endpoints.dart';
import 'package:na3eeman/Helpers/logger.dart';

class StaffManagementPage extends StatefulWidget {
  const StaffManagementPage({super.key});

  @override
  State<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends State<StaffManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _staffList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStaff();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStaff() async {
    setState(() => _isLoading = true);
    try {
      final salon = context.read<SalonProvider>().selectedSalon;
      final apiService = ApiService();
      final response = await apiService.get(
        Endpoints.usersStaff,
        queryParams: salon != null ? {'salon': salon.id.toString()} : null,
      );
      final List<dynamic> data = response['results'] ?? response['data'] ?? [];

      setState(() {
        _staffList = data.map((s) {
          return {
            'id': s['id']?.toString() ?? '',
            'name':
                '${s['first_name'] ?? ''} ${s['last_name'] ?? ''}'
                    .trim()
                    .isNotEmpty
                ? '${s['first_name']} ${s['last_name']}'
                : (s['username'] ?? 'Unnamed'),
            'role': s['role'] ?? 'Expert',
            'phone': s['phone'] ?? 'N/A',
            'rating': s['average_rating'] ?? 5.0,
            'workingHours': s['working_hours_display'] ?? 'Flexible',
            'status': s['on_shift'] == true ? 'Available' : 'Offline',
            'color': s['on_shift'] == true
                ? AppColors.success
                : AppColors.almostBlack200,
          };
        }).toList();
      });
    } catch (e) {
      AppLogger.error('Error loading staff: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'employee_management'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: [
            Tab(text: 'staff'.tr()),
            Tab(text: 'schedule'.tr()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddExpertDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildStaffListTab(), _buildScheduleListTab()],
      ),
    );
  }

  Widget _buildStaffListTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_staffList.isEmpty) {
      return Center(child: Text('no_staff_members_found'.tr()));
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
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
              border: Border.all(
                color: isDark
                    ? AppColors.white.withValues(alpha: 0.1)
                    : AppColors.almostBlack50,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withValues(alpha: 0.1),
                  child: Text(
                    staff['name'][0],
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        staff['role'] as String,
                        style: const TextStyle(
                          color: AppColors.almostBlack300,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.almostBlack200,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleListTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_staffList.isEmpty) {
      return Center(child: Text('no_staff_schedules_found'.tr()));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _staffList.length,
      itemBuilder: (context, index) {
        final s = _staffList[index];
        final Color statusColor = s['color'] as Color;
        final bool isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.1)
                  : AppColors.almostBlack50,
            ),
          ),
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              leading: Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: statusColor.withValues(alpha: 0.1),
                    child: Text(
                      (s['name'] as String)[0],
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.almostBlack600
                              : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              title: Text(
                s['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                s['role'] as String,
                style: const TextStyle(
                  color: AppColors.almostBlack300,
                  fontSize: 11,
                ),
              ),
              trailing: Text(
                s['status'] as String,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'staff_timeline'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTimelineItem('09:00 AM', 'Shift Start', true),
                      _buildTimelineItem(
                        '01:00 PM',
                        'Lunch Break',
                        false,
                        isBreak: true,
                      ),
                      _buildTimelineItem(
                        '05:00 PM',
                        'Shift End',
                        false,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimelineItem(
    String time,
    String detail,
    bool isFirst, {
    bool isOccupied = false,
    bool isBreak = false,
    bool isLast = false,
  }) {
    final Color indicatorColor = isOccupied
        ? AppColors.error
        : (isBreak ? AppColors.warning : AppColors.success);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: indicatorColor.withValues(alpha: 0.2),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                detail,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.almostBlack300,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  void _showExpertDetails(Map<String, dynamic> staff) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'staff_profile'.tr(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 32),
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                staff['name'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                staff['role'],
                style: const TextStyle(color: AppColors.almostBlack300),
              ),
            ),
            const SizedBox(height: 32),
            _buildProfileInfo(
              Icons.phone_rounded,
              'phone'.tr(),
              staff['phone'],
            ),
            const SizedBox(height: 16),
            _buildProfileInfo(
              Icons.star_rounded,
              'performance'.tr(),
              '${staff['rating']} / 5.0',
            ),
            const SizedBox(height: 16),
            _buildProfileInfo(
              Icons.access_time_rounded,
              'schedule'.tr(),
              staff['workingHours'],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _removeExpert(staff['id']);
                },
                child: Text(
                  'detach_staff_member'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 18),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.almostBlack300,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _removeExpert(String id) async {
    setState(() => _staffList.removeWhere((item) => item['id'] == id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('staff_member_removed_successfully'.tr()),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _showAddExpertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('add_staff_member'.tr()),
        content: Text('to_maintain_system_integrity'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
          // ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('open_admin_portal'.tr())),
        ],
      ),
    );
  }
}
