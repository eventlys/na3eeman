import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../../../Packages/Core/constants/app_color.dart';
import '../../../../Packages/Core/constants/app_roles.dart';
import '../../../../Packages/Core/themes/app_theme.dart';
import '../../../../Packages/Core/widgets/common/app_card.dart';
import '../../../../Packages/Core/widgets/navigation/app_drawer.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/features/admin_service_provider.dart';
import '../../../../Models/auth/user_model.dart';

/// Super Admin — User Management Page.
/// Lists all platform users (customers + experts/staff) from backend.
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
        title: Text("user_management".tr()),
        bottom: TabBar(
          controller: _tabs,
          labelColor: primary,
          unselectedLabelColor: isDark
              ? AppColor.darkTextHint
              : AppColor.lightTextHint,
          indicatorColor: primary,
          tabs: const [
            Tab(text: 'Customers'),
            Tab(text: 'Staff / Experts'),
          ],
        ),
      ),
      drawer: const AppDrawer(
        role: UserRole.admin,
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
                _UserList(role: 'CUSTOMER', query: _query, isDark: isDark),
                _UserList(role: 'STAFF', query: _query, isDark: isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserList extends StatefulWidget {
  const _UserList({
    required this.role,
    required this.query,
    required this.isDark,
  });
  final String role;
  final String query;
  final bool isDark;

  @override
  State<_UserList> createState() => _UserListState();
}

class _UserListState extends State<_UserList> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void didUpdateWidget(_UserList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _loadUsers();
    }
  }

  void _loadUsers() {
    setState(() {
      _usersFuture = context
          .read<AdminServiceProvider>()
          .getUsers(
            role: widget.role == 'STAFF'
                ? null
                : widget
                      .role, // Backend handles staff grouping if role is null or 'STAFF'
            query: widget.query,
          )
          .then((list) => list.map((e) => User.fromJson(e)).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
      future: _usersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data ?? [];

        if (users.isEmpty) {
          return const Center(child: Text('No users found'));
        }

        return RefreshIndicator(
          onRefresh: () async => _loadUsers(),
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _UserTile(
              user: users[i],
              isDark: widget.isDark,
              onActionComplete: _loadUsers,
            ),
          ),
        );
      },
    );
  }
}

class _UserTile extends StatefulWidget {
  const _UserTile({
    required this.user,
    required this.isDark,
    required this.onActionComplete,
  });
  final User user;
  final bool isDark;
  final VoidCallback onActionComplete;

  @override
  State<_UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<_UserTile> {
  bool _isLoading = false;

  Color get _statusColor {
    if (!widget.user.isActive) return AppColor.error;
    return AppColor.success;
  }

  Future<void> _handleAction(BuildContext context, String action) async {
    if (action == 'view') {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(widget.user.fullName),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Username: @${widget.user.username}'),
              const SizedBox(height: 8),
              Text('Email: ${widget.user.email}'),
              const SizedBox(height: 8),
              Text('Phone: ${widget.user.phone ?? "N/A"}'),
              const SizedBox(height: 8),
              Text('Role: ${widget.user.role}'),
              const SizedBox(height: 8),
              Text('Status: ${widget.user.isActive ? "Active" : "Banned"}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final status = action == 'ban' ? 'INACTIVE' : 'ACTIVE';
      await context.read<AdminServiceProvider>().updateUserStatus(
        widget.user.id,
        status,
      );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully ${action == 'ban' ? 'banned' : 'unbanned'} ${widget.user.fullName}',
          ),
          backgroundColor: AppColor.success,
        ),
      );
      widget.onActionComplete();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user status: $e'),
          backgroundColor: AppColor.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      type: AppCardType.outlined,
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.1),
            backgroundImage: widget.user.profilePic != null
                ? NetworkImage(widget.user.profilePic!)
                : null,
            child: widget.user.profilePic == null
                ? Text(
                    widget.user.firstName.isNotEmpty
                        ? widget.user.firstName[0]
                        : '?',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : null,
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
                        widget.user.fullName,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.user.isEmailVerified) ...[
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
                      '@${widget.user.username}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        widget.user.isActive ? 'active' : 'inactive',
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
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: widget.isDark
                        ? AppColor.darkTextHint
                        : AppColor.lightTextHint,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  onSelected: (action) => _handleAction(context, action),
                  itemBuilder: (_) => [
                    if (widget.user.isActive)
                      const PopupMenuItem(
                        value: 'ban',
                        child: Text('Ban User'),
                      ),
                    if (!widget.user.isActive)
                      const PopupMenuItem(
                        value: 'unban',
                        child: Text('Unban / Restore'),
                      ),
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Profile'),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}
