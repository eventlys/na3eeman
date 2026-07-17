// ignore_for_file: unused_local_variable
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../Core/widgets/common/app_text_field.dart';
// import 'package:easy_localization/easy_localization.dart';

class AdminCreateStaffPage extends StatefulWidget {
  const AdminCreateStaffPage({super.key});

  @override
  State<AdminCreateStaffPage> createState() => _AdminCreateStaffPageState();
}

class _AdminCreateStaffPageState extends State<AdminCreateStaffPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'EXPERT';
  int? _selectedSalonId;
  bool _isLoading = false;
  List<dynamic> _salons = [];
  bool _fetchingSalons = false;

  final List<Map<String, String>> _roles = [
    {'value': 'EXPERT', 'label': 'Expert'},
    {'value': 'RECEPTIONIST', 'label': 'Receptionist'},
    {'value': 'INTERN', 'label': 'Intern'},
    {'value': 'OWNER', 'label': 'Owner'},
    {'value': 'MANAGER', 'label': 'Manager'},
    {'value': 'OWNER_EXPERT', 'label': 'Owner Expert'},
    {'value': 'COFOUNDER', 'label': 'Co-Founder'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSalons();
  }

  Future<void> _loadSalons() async {
    setState(() => _fetchingSalons = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final salons = await authProvider.fetchSalons();
      if (mounted) {
        setState(() {
          _salons = salons;
          if (_salons.isNotEmpty) {
            _selectedSalonId = _salons.first['id'];
          }
          _fetchingSalons = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _fetchingSalons = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _createStaff() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSalonId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a salon')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      final staffData = {
        'role': _selectedRole,
        'salon_id': _selectedSalonId,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'username': _usernameController.text,
        'phone': _phoneController.text,
        'password': _passwordController.text.isNotEmpty
            ? _passwordController.text
            : null,
      };

      final success = await authProvider.adminCreateStaff(staffData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("staff_created_successfully".tr())),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "create_staff".tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create a new staff member for a salon.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.almostBlack400,
                ),
              ),
              const SizedBox(height: 32),

              // Role Selection
              Text(
                "role".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role['value'],
                    child: Text(role['label']!),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedRole = val!),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Salon Selection
              Text(
                "salon".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _fetchingSalons
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      initialValue: _selectedSalonId,
                      hint: const Text('Select Salon'),
                      items: _salons.map((salon) {
                        return DropdownMenuItem<int>(
                          value: salon['id'] as int,
                          child: Text(
                            salon['salon_name']?.toString() ?? 'Unnamed Salon',
                          ),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedSalonId = val),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

              const SizedBox(height: 24),

              AppTextField(
                controller: _firstNameController,
                label: "first_name".tr(),
                prefixIcon: Icons.person_outline,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _lastNameController,
                label: "last_name".tr(),
                prefixIcon: Icons.person_outline,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                label: "email".tr(),
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _usernameController,
                label: "username".tr(),
                prefixIcon: Icons.alternate_email,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: "phone".tr(),
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                label: "temporary_password".tr(),
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                hint: 'Leave empty for auto-generated',
              ),

              const SizedBox(height: 48),

              PrimaryButton(
                text: "create_staff_member".tr(),
                isLoading: _isLoading,
                onPressed: _createStaff,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
