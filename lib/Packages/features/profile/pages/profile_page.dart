import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Helpers/profile_helper_functions.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/backgrounds/bd_faded.dart';
import '../../../Core/themes/glass_appbar.dart';
import '../../navigation/widgets/custom_navigation_bar.dart';
import '../widgets/profile_widgets.dart';

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
  final ScrollController _scrollController = ScrollController();

  // Controllers for editable fields
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
      setState(() {
        _isLoading = true;
      });

      // Get user data from AuthProvider
      final authProvider = context.read<AuthProvider>();
      
      if (authProvider.user != null) {
        // Convert user object to map for the profile page
        final user = authProvider.user!;
        final mockData = {
          'firstName': user.firstName,
          'lastName': user.lastName,
          'email': user.email,
          'username': user.username,
          'phone': user.phone,
          'role': user.role.toString().split('.').last,
          'gender': user.gender.toString().split('.').last,
          'profilePic': 'assets/mojies/image65.png',
          'location': user.location,
          'bio': 'Professional barber with 5 years of experience',
          'specialties': ['Haircut', 'Beard Trim', 'Shaving'],
          'vrfidEmail': true,
          'vrfidPhone': true,
          'isSubscribed': true,
          'isOwner': authProvider.isOwner,
          'isWorker': authProvider.isBarber,
          'createdAt': user.createdAt,
          'updatedAt': user.updatedAt,
        };

        setState(() {
          _userData = mockData;
          _originalData = Map<String, dynamic>.from(mockData);
          _isLoading = false;
        });

        _initializeControllers();
      } else {
        // Fallback mock data if no user in provider
        _loadMockData();
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() {
        _isLoading = false;
      });

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  void _loadMockData() {
    final mockData = {
      'firstName': 'John',
      'lastName': 'Doe',
      'email': 'john.doe@example.com',
      'username': 'johndoe',
      'phone': '+1234567890',
      'role': 'customer',
      'gender': 'male',
      'profilePic': 'assets/mojies/image65.png',
      'location': 'New York, USA',
      'bio': 'Professional barber with 5 years of experience',
      'specialties': ['Haircut', 'Beard Trim', 'Shaving'],
      'vrfidEmail': true,
      'vrfidPhone': true,
      'isSubscribed': true,
      'isOwner': false,
      'isWorker': false,
      'createdAt': DateTime.now().subtract(const Duration(days: 365)),
      'updatedAt': DateTime.now(),
    };

    setState(() {
      _userData = mockData;
      _originalData = Map<String, dynamic>.from(mockData);
      _isLoading = false;
    });

    _initializeControllers();
  }

  void _initializeControllers() {
    ProfileHelperFunctions.initializeControllers(
      userData: _userData,
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
    );
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
    _specialtiesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      if (_isEditing) {
        // Cancel editing - revert changes
        _userData = _originalData;
        _initializeControllers();
      }
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate() && _userData != null) {
      final updatedData = ProfileHelperFunctions.updateUserFromControllers(
        userData: _userData!,
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
      );

      setState(() {
        _userData = updatedData;
        _originalData = Map<String, dynamic>.from(updatedData);
        _isEditing = false;
      });

      _saveToBackend(updatedData);
    }
  }

  Future<void> _saveToBackend(Map<String, dynamic> data) async {
    await ProfileHelperFunctions.saveToBackend(
      profile: data,
      context: context,
      onError: () {
        setState(() {
          _userData = _originalData;
          _initializeControllers();
        });
      },
    );
  }

  void _deleteProfile() {
    ProfileHelperFunctions.showDeleteConfirmationDialog(
      context: context,
      onConfirm: _performDelete,
    );
  }

  Future<void> _performDelete() async {
    await ProfileHelperFunctions.performDelete(
      context: context,
      onSuccess: () {
        Navigator.popUntil(context, (route) => route.isFirst);
      },
    );
  }

  void _changeProfilePicture() {
    ProfileHelperFunctions.showImagePickerDialog(context: context);
  }

  String _getAccountType() {
    return ProfileHelperFunctions.getAccountType(_userData);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: FadedBackground(
            startColor: const Color(0x80806C99),
            endColor: const Color(0xFFDFA8A4),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: CustomNavigationBar(
            currentRoute: ModalRoute.of(context)?.settings.name ?? '/',
          ),
          body: _isLoading
              ? ProfileWidgets.buildLoadingState()
              : CustomScrollView(
                  controller: _scrollController,
                  slivers: [
                    GlassSliverAppBar(
                      title: 'My Profile',
                      showBackButton: true,
                      textColor: Colors.white,
                      pinned: true,
                      actions: [
                        IconButton(
                          icon: Icon(_isEditing ? Icons.close : Icons.edit, color: Colors.white),
                          onPressed: _toggleEdit,
                          tooltip: _isEditing ? 'Cancel' : 'Edit',
                        ),
                        if (_isEditing)
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.white),
                            onPressed: _saveChanges,
                            tooltip: 'Check',
                          ),
                      ],
                    ),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ProfileWidgets.buildProfileContent(
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
                          getAccountType: _getAccountType,
                          onDeleteProfile: _deleteProfile,
                          onChangeProfilePicture: _changeProfilePicture,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
