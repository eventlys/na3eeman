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

  // Salon onboarding fields
  final _salonNameController = TextEditingController();
  final _salonPhoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _openingTimeController = TextEditingController(text: "09:00:00");
  final _closingTimeController = TextEditingController(text: "22:00:00");

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
    _salonNameController.dispose();
    _salonPhoneController.dispose();
    _locationController.dispose();
    _openingTimeController.dispose();
    _closingTimeController.dispose();
    super.dispose();
  }

  Future<void> _createStaff() async {
    if (!_formKey.currentState!.validate()) return;

    final isOwnerMode =
        _selectedRole == 'OWNER' ||
        _selectedRole == 'OWNER_EXPERT' ||
        _selectedRole == 'COFOUNDER';

    if (!isOwnerMode && _selectedSalonId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a salon')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();

      if (isOwnerMode) {
        // Atomic Onboarding Payload
        final payload = {
          "salon_name": _salonNameController.text,
          "salon_phone_num": _salonPhoneController.text,
          "location": _locationController.text,
          "opening_time": _openingTimeController.text,
          "closing_time": _closingTimeController.text,
          "owner_first_name": _firstNameController.text,
          "owner_last_name": _lastNameController.text,
          "owner_email": _emailController.text,
          "owner_phone": _phoneController.text,
          "owner_password": _passwordController.text,
        };

        final response = await authProvider.adminOnboardSalon(payload);

        if (mounted) {
          final autoPassword = response['auto_generated_password'];
          final pwdMessage = autoPassword != null
              ? 'Salon & Owner onboarded!\nAuto-generated Password: $autoPassword'
              : 'Salon & Owner onboarded successfully!';

          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Success'),
              content: Text(pwdMessage),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } else {
        // Normal Staff Creation
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

        await authProvider.adminCreateStaff(staffData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("staff_created_successfully".tr())),
          );
          Navigator.pop(context);
        }
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

              const SizedBox(height: 24),

              if (_selectedRole != 'OWNER' &&
                  _selectedRole != 'OWNER_EXPERT' &&
                  _selectedRole != 'COFOUNDER') ...[
                // Salon Selection for regular staff
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
                              salon['salon_name']?.toString() ??
                                  'Unnamed Salon',
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
              ],

              if (_selectedRole == 'OWNER' ||
                  _selectedRole == 'OWNER_EXPERT' ||
                  _selectedRole == 'COFOUNDER') ...[
                // Salon Onboarding Fields
                const Text(
                  "Salon Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _salonNameController,
                  label: "Salon Name",
                  prefixIcon: Icons.store_outlined,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _salonPhoneController,
                  label: "Salon Phone",
                  prefixIcon: Icons.phone_android_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _locationController,
                  label: "Location",
                  prefixIcon: Icons.location_on_outlined,
                  validator: (val) => val!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _openingTimeController,
                        label: "Opening Time (HH:MM:SS)",
                        prefixIcon: Icons.access_time,
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppTextField(
                        controller: _closingTimeController,
                        label: "Closing Time (HH:MM:SS)",
                        prefixIcon: Icons.access_time_filled,
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  "Owner Details",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
              ],

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
