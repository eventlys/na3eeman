import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../../../Helpers/profile_helper_functions.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../widgets/profile_widgets.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _originalData;
  bool _isEditing = false;
  bool _isLoading = true;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _specialtiesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      setState(() => _isLoading = true);
      final authProvider = context.read<AuthProvider>();
      
      if (authProvider.user != null) {
        final user = authProvider.user!;
        final data = {
          'firstName': user.firstName,
          'lastName': user.lastName,
          'email': user.email,
          'username': user.username,
          'phone': user.phone,
          'role': user.role.toString().split('.').last,
          'gender': user.gender.toString().split('.').last,
          'profilePic': 'assets/mojies/image65.png', // Temporary local asset
          'location': user.location,
          'bio': 'Barber enthusiast',
          'isSubscribed': true,
        };

        setState(() {
          _userData = data;
          _originalData = Map<String, dynamic>.from(data);
          _isLoading = false;
        });

        _initializeControllers();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _initializeControllers() {
    _firstNameController.text = _userData?['firstName'] ?? '';
    _lastNameController.text = _userData?['lastName'] ?? '';
    _usernameController.text = _userData?['username'] ?? '';
    _emailController.text = _userData?['email'] ?? '';
    _phoneController.text = _userData?['phone'] ?? '';
    _bioController.text = _userData?['bio'] ?? '';
    _locationController.text = _userData?['location'] ?? '';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        _userData = Map<String, dynamic>.from(_originalData!);
        _initializeControllers();
      }
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      final updated = Map<String, dynamic>.from(_userData!);
      updated['firstName'] = _firstNameController.text;
      updated['lastName'] = _lastNameController.text;
      updated['email'] = _emailController.text;
      updated['phone'] = _phoneController.text;
      updated['bio'] = _bioController.text;
      updated['location'] = _locationController.text;

      setState(() {
        _userData = updated;
        _originalData = Map<String, dynamic>.from(updated);
        _isEditing = false;
      });

      // Save to provider/backend here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('profile'.tr(), style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Theme.of(context).primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  ProfileWidgets.buildProfileContent(
                    formKey: _formKey,
                    userData: _userData!,
                    isEditing: _isEditing,
                    controllers: {
                      'firstName': _firstNameController,
                      'lastName': _lastNameController,
                      'username': _usernameController,
                      'email': _emailController,
                      'phone': _phoneController,
                      'bio': _bioController,
                      'location': _locationController,
                      'specialties': _specialtiesController,
                    },
                    getAccountType: () => _userData!['role'],
                    onDeleteProfile: () {},
                    onChangeProfilePicture: () {},
                  ),
                  const SizedBox(height: 32),
                  PrimaryButton(
                    text: _isEditing ? 'Save Changes' : 'Edit Profile',
                    onPressed: _isEditing ? _saveChanges : _toggleEdit,
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _toggleEdit,
                      child: Text('cancel'.tr(), style: TextStyle(color: AppColors.almostBlack400)),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
