import 'package:na3eeman/l10n/app_localizations.dart';
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
  
  String _selectedRole = 'EMPLOYEE';
  int? _selectedSalonId;
  bool _isLoading = false;

  final List<Map<String, String>> _roles = [
    {'value': 'EMPLOYEE', 'label': 'Employee'},
    {'value': 'RECEPTIONIST', 'label': 'Receptionist'},
    {'value': 'INTERN', 'label': 'Intern'},
    {'value': 'OWNER', 'label': 'Owner'},
  ];

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a salon')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final authProvider = context.read<AuthProvider>();
      // We need an API call for this. For now let's assume AuthService has it.
      // final success = await authProvider.adminCreateStaff(...)
      
      await Future.delayed(const Duration(seconds: 1)); // Mock
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.staffCreatedSuccessfully)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
        title: Text(AppLocalizations.of(context)!.createStaff, style: const TextStyle(fontWeight: FontWeight.bold)),
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.almostBlack400),
              ),
              const SizedBox(height: 32),
              
              // Role Selection
              Text(AppLocalizations.of(context)!.role, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedRole,
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
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Salon Selection (Mocked for now)
              Text(AppLocalizations.of(context)!.salon, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedSalonId,
                hint: const Text('Select Salon'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Salon Al-Amira')),
                  DropdownMenuItem(value: 2, child: Text('Royal Barber Salon')),
                ],
                onChanged: (val) => setState(() => _selectedSalonId = val),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              
              const SizedBox(height: 24),
              
              AppTextField(
                controller: _firstNameController,
                label: AppLocalizations.of(context)!.firstName,
                prefixIcon: Icons.person_outline,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _lastNameController,
                label: AppLocalizations.of(context)!.lastName,
                prefixIcon: Icons.person_outline,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _emailController,
                label: AppLocalizations.of(context)!.email,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _usernameController,
                label: AppLocalizations.of(context)!.username,
                prefixIcon: Icons.alternate_email,
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: AppLocalizations.of(context)!.phone,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _passwordController,
                label: AppLocalizations.of(context)!.temporaryPassword,
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                hint: 'Leave empty for auto-generated',
              ),
              
              const SizedBox(height: 48),
              
              PrimaryButton(
                text: AppLocalizations.of(context)!.createStaffMember,
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
