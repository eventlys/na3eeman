import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../Core/widgets/common/app_text_field.dart';

class StaffProfilePage extends StatefulWidget {
  const StaffProfilePage({super.key});

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _specializationController;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final expert = auth.expertProfile;
    _firstNameController = TextEditingController(text: user?.firstName);
    _lastNameController = TextEditingController(text: user?.lastName);
    _phoneController = TextEditingController(text: user?.phone);
    _bioController = TextEditingController(text: expert?.bio ?? '');
    _specializationController = TextEditingController(
      text: user?.specialization,
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _specializationController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final auth = context.read<AuthProvider>();

      await auth.updateProfile(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        specialization: _specializationController.text.trim(),
        bio: _bioController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("profile_updated_successfully".tr())),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "profile".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Header
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user?.role.toString().split('.').last.toUpperCase() ?? '',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 40),

              // Non-editable fields (Point 1 requirement: "not all of it")
              _buildInfoTile(
                'Username',
                user?.username ?? '',
                Icons.alternate_email,
                isEditable: false,
              ),
              _buildInfoTile(
                'Email',
                user?.email ?? '',
                Icons.email_outlined,
                isEditable: false,
              ),

              const SizedBox(height: 16),

              // Editable fields
              AppTextField(
                controller: _firstNameController,
                label: "first_name".tr(),
                prefixIcon: Icons.person_outline,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _lastNameController,
                label: "last_name".tr(),
                prefixIcon: Icons.person_outline,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: "phone".tr(),
                prefixIcon: Icons.phone_outlined,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _specializationController,
                label: "specialization".tr(),
                prefixIcon: Icons.star_outline,
                enabled: _isEditing,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _bioController,
                label: "bio".tr(),
                prefixIcon: Icons.info_outline,
                enabled: _isEditing,
                maxLines: 3,
              ),

              const SizedBox(height: 48),

              if (_isEditing) ...[
                PrimaryButton(
                  text: 'Save Changes',
                  isLoading: _isLoading,
                  onPressed: _saveChanges,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: Text(
                    "cancel".tr(),
                    style: const TextStyle(color: AppColors.almostBlack400),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon, {
    bool isEditable = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.almostBlack50),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.almostBlack400),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.almostBlack300,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            if (!isEditable)
              Icon(
                Icons.lock_outline,
                size: 16,
                color: AppColors.almostBlack200,
              ),
          ],
        ),
      ),
    );
  }
}
