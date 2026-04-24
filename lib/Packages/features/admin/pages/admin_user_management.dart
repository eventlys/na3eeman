import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../../../../Packages/Core/constants/app_color.dart';
import '../../../../Packages/Core/constants/app_roles.dart';
import '../../../../Packages/Core/themes/app_theme.dart';
import '../../../../Packages/Core/widgets/common/app_card.dart';
import '../../../../Packages/Core/widgets/navigation/app_drawer.dart';
// import 'package:easy_localization/easy_localization.dart';

/// Super Admin — User Management Page.
/// Lists all platform users (customers + barbers/staff) with ban/verify actions.
class AdminUserManagementPage extends StatefulWidget {
  const AdminUserManagementPage({super.key});

  @override
  State<AdminUserManagementPage> createState() =>
      _AdminUserManagementPageState();
}

class _AdminUserManagementPageState extends State<AdminUserManagementPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.userManagement),
        bottom: TabBar(
          controller: _tabs,
          labelColor: primary,
          unselectedLabelColor: isDark
              ? AppColor.darkTextHint
              : AppColor.lightTextHint,
          indicatorColor: primary,
          tabs: const [
            Tab(text: 'Customers'),
            Tab(text: 'Staff / Barbers'),
          ],
        ),
      ),
      drawer: const AppDrawer(
        role: UserRole.superAdmin,
        currentRoute: '/admin/users',
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search users…',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _UserList(role: 'customer', query: _query, isDark: isDark),
                _UserList(role: 'staff', query: _query, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mock data ─────────────────────────────────────────────────────────────────

class _UserModel {
  const _UserModel({
    required this.name,
    required this.username,
    required this.role,
    required this.status,
    required this.verified,
    required this.joinDate,
  });
  final String name;
  final String username;
  final String role;
  final String status; // 'active' | 'banned' | 'suspended'
  final bool verified;
  final String joinDate;
}

final _mockCustomers = [
  const _UserModel(
    name: 'Ahmed Al-Rashid',
    username: '@ahmed.rashid',
    role: 'customer',
    status: 'active',
    verified: true,
    joinDate: 'Jan 2025',
  ),
  const _UserModel(
    name: 'Sara Al-Otaibi',
    username: '@sara.o',
    role: 'customer',
    status: 'active',
    verified: false,
    joinDate: 'Feb 2025',
  ),
  const _UserModel(
    name: 'Khalid Ibrahim',
    username: '@k.ibrahim',
    role: 'customer',
    status: 'banned',
    verified: true,
    joinDate: 'Nov 2024',
  ),
  const _UserModel(
    name: 'Fatima Hassan',
    username: '@fatima_h',
    role: 'customer',
    status: 'suspended',
    verified: false,
    joinDate: 'Mar 2025',
  ),
  const _UserModel(
    name: 'Omar Saud',
    username: '@omar_s99',
    role: 'customer',
    status: 'active',
    verified: true,
    joinDate: 'Dec 2024',
  ),
];

final _mockStaff = [
  const _UserModel(
    name: 'Nasser Barber',
    username: '@nasserstyle',
    role: 'owner',
    status: 'active',
    verified: true,
    joinDate: 'Jul 2024',
  ),
  const _UserModel(
    name: 'Walid Ahmad',
    username: '@walid.cuts',
    role: 'barber',
    status: 'active',
    verified: true,
    joinDate: 'Sep 2024',
  ),
  const _UserModel(
    name: 'Majid Al-Enezi',
    username: '@majid_mgr',
    role: 'manager',
    status: 'suspended',
    verified: false,
    joinDate: 'Oct 2024',
  ),
  const _UserModel(
    name: 'Laila Salim',
    username: '@lailasalon',
    role: 'receptionist',
    status: 'active',
    verified: true,
    joinDate: 'Jan 2025',
  ),
];

// ── User list ─────────────────────────────────────────────────────────────────

class _UserList extends StatelessWidget {
  const _UserList({
    required this.role,
    required this.query,
    required this.isDark,
  });
  final String role;
  final String query;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final list = role == 'customer' ? _mockCustomers : _mockStaff;
    final filtered = list
        .where(
          (u) =>
              u.name.toLowerCase().contains(query) ||
              u.username.toLowerCase().contains(query),
        )
        .toList();

    if (filtered.isEmpty) {
      return Center(
        child: Text(
          'No users found',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _UserTile(user: filtered[i], isDark: isDark),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.isDark});
  final _UserModel user;
  final bool isDark;

  Color get _statusColor {
    switch (user.status) {
      case 'banned':
        return AppColor.error;
      case 'suspended':
        return AppColor.warning;
      default:
        return AppColor.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      child: Row(
        children: [
          // Avatar placeholder
          CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.1),
            child: Text(
              user.name[0],
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        user.name,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (user.verified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: AppColor.info,
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Text(
                      user.username,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        user.status,
                        style: TextStyle(
                          fontSize: 10,
                          color: _statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert_rounded,
              color: isDark ? AppColor.darkTextHint : AppColor.lightTextHint,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            onSelected: (action) => _handleAction(context, action),
            itemBuilder: (_) => [
              if (user.status != 'banned')
                const PopupMenuItem(value: 'ban', child: Text('Ban User')),
              if (user.status != 'active')
                const PopupMenuItem(
                  value: 'unban',
                  child: Text('Unban / Restore'),
                ),
              if (user.status == 'active' && user.status != 'suspended')
                const PopupMenuItem(value: 'suspend', child: Text('Suspend')),
              if (!user.verified)
                const PopupMenuItem(
                  value: 'verify',
                  child: Text('Verify Account'),
                ),
              const PopupMenuItem(value: 'view', child: Text('View Profile')),
            ],
          ),
        ],
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Action: $action on ${user.name}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
