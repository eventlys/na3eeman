import 'package:flutter/material.dart';
import '../../../data/models/user/profile_model.dart';
import '../../../Models/olds/user_model.dart';
import '../../../Theme/glass_appbar.dart';
import '../../Backgrounds/bd_faded.dart';
import '../widgets/profile_widgets.dart';
import '../../../Core/utils/helpers/profile_helper_functions.dart';
import '../../Widgets/custom_navigation_bar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _userProfile;
  UserProfile? _originalProfile;
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
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      // Simulate API call - replace with your actual API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - replace with actual API response
      final mockProfile = UserProfile(
        firstName: 'John',
        lastName: 'Doe',
        email: 'john.doe@example.com',
        username: 'johndoe',
        phone: '+1234567890',
        role: 'Customer',
        gender: 'Male',
        profilePic: 'assets/mojies/image65.png',
        location: 'New York, USA',
        bio: 'Professional barber with 5 years of experience',
        specialties: ['Haircut', 'Beard Trim', 'Shaving'],
        vrfidEmail: true,
        vrfidPhone: true,
        isSubscribed: true,
        isOwner: false,
        isWorker: false,
        createdAt: DateTime.now().subtract(const Duration(days: 365)),
        updatedAt: DateTime.now(),
      );

      setState(() {
        _userProfile = mockProfile;
        _originalProfile = mockProfile;
        _isLoading = false;
      });

      _initializeControllers();
    } catch (e) {
      print('Error fetching profile: $e');
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

  void _initializeControllers() {
    ProfileHelperFunctions.initializeControllers(
      userProfile: _userProfile,
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
        _userProfile = _originalProfile;
        _initializeControllers();
      }
      _isEditing = !_isEditing;
    });
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate() && _userProfile != null) {
      final updatedProfile = ProfileHelperFunctions.updateProfileFromControllers(
        userProfile: _userProfile!,
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
        _userProfile = updatedProfile;
        _originalProfile = updatedProfile;
        _isEditing = false;
      });

      _saveToBackend(updatedProfile);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  Future<void> _saveToBackend(UserProfile profile) async {
    await ProfileHelperFunctions.saveToBackend(
      profile: profile,
      context: context,
      onError: () {
        setState(() {
          _userProfile = _originalProfile;
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
    return ProfileHelperFunctions.getAccountType(_userProfile);
  }

  @override
  Widget build(BuildContext context) {
    final user = User(
      id: 1,
      email: 'customer@example.com',
      role: 'customer',
      name: 'John Doe',
    );
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
            user: user,
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
                    userProfile: _userProfile!,
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

