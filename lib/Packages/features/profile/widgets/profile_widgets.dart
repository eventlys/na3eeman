import 'package:flutter/material.dart';
import '../../../../data/models/user/profile_model.dart';

class ProfileWidgets {
  static Widget buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading profile...'),
        ],
      ),
    );
  }

  static Widget buildProfileContent({
    required GlobalKey<FormState> formKey,
    required UserProfile userProfile,
    required bool isEditing,
    required Map<String, TextEditingController> controllers,
    required String Function() getAccountType,
    required VoidCallback onDeleteProfile,
    required VoidCallback onChangeProfilePicture,
  }) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Profile Picture
          _buildProfilePicture(
            userProfile: userProfile,
            isEditing: isEditing,
            onChangeProfilePicture: onChangeProfilePicture,
          ),
          const SizedBox(height: 20),
          _buildProfileFieldsContainer(
            userProfile: userProfile,
            isEditing: isEditing,
            controllers: controllers,
            getAccountType: getAccountType,
            onDeleteProfile: onDeleteProfile,
          ),
        ],
      ),
    );
  }

  static Widget _buildProfilePicture({
    required UserProfile userProfile,
    required bool isEditing,
    required VoidCallback onChangeProfilePicture,
  }) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 70,
            backgroundImage: userProfile.profilePic != null
                ? NetworkImage(userProfile.profilePic!)
                : const AssetImage('assets/mojies/image11.png') as ImageProvider,
          ),
          if (isEditing)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                  onPressed: onChangeProfilePicture,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _buildProfileFieldsContainer({
    required UserProfile userProfile,
    required bool isEditing,
    required Map<String, TextEditingController> controllers,
    required String Function() getAccountType,
    required VoidCallback onDeleteProfile,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Editable Fields
          _buildEditableField(
            label: 'First Name',
            value: userProfile.firstName ?? '',
            controller: controllers['firstName']!,
            isEditing: isEditing,
          ),
          _buildEditableField(
            label: 'Last Name',
            value: userProfile.lastName ?? '',
            controller: controllers['lastName']!,
            isEditing: isEditing,
          ),
          _buildEditableField(
            label: 'Username',
            value: userProfile.username ?? '',
            controller: controllers['username']!,
            isEditing: isEditing,
            isRequired: true,
          ),
          _buildEditableField(
            label: 'Email',
            value: userProfile.email ?? '',
            controller: controllers['email']!,
            isEditing: isEditing,
            keyboardType: TextInputType.emailAddress,
            isRequired: true,
          ),
          _buildEditableField(
            label: 'Phone',
            value: userProfile.phone ?? '',
            controller: controllers['phone']!,
            isEditing: isEditing,
            keyboardType: TextInputType.phone,
          ),
          _buildEditableField(
            label: 'Bio',
            value: userProfile.bio ?? '',
            controller: controllers['bio']!,
            isEditing: isEditing,
          ),
          _buildEditableField(
            label: 'Location',
            value: userProfile.location ?? '',
            controller: controllers['location']!,
            isEditing: isEditing,
          ),
          _buildEditableField(
            label: 'Specialties',
            value: userProfile.specialties?.join(', ') ?? '',
            controller: controllers['specialties']!,
            isEditing: isEditing,
          ),

          // Read-only Fields
          _buildReadOnlyField('Role', userProfile.role),
          _buildReadOnlyField('Gender', userProfile.gender),
          _buildReadOnlyField('Email Verified', userProfile.vrfidEmail == true ? 'Yes' : 'No'),
          _buildReadOnlyField('Phone Verified', userProfile.vrfidPhone == true ? 'Yes' : 'No'),
          _buildReadOnlyField('Account Type', getAccountType()),
          _buildReadOnlyField('Subscription', userProfile.isSubscribed == true ? 'Active' : 'Inactive'),
          _buildReadOnlyField('Member Since', userProfile.createdAt?.toLocal().toString().split(' ')[0]),

          const SizedBox(height: 20),

          // Action Buttons
          if (!isEditing)
            ElevatedButton(
              onPressed: onDeleteProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete Profile'),
            ),
        ],
      ),
    );
  }

  static Widget _buildEditableField({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xbfffffff),
            ),
          ),
          const SizedBox(height: 4),
          isEditing
              ? TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    hintText: 'Enter $label',
                  ),
                  validator: (value) {
                    if (isRequired && (value == null || value.isEmpty)) {
                      return '$label is required';
                    }
                    return null;
                  },
                )
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0x80ffffff)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    value.isEmpty ? 'Not set' : value,
                    style: TextStyle(
                      color: value.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  static Widget _buildReadOnlyField(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0x80ffffff),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: Text(
              value?.toString() ?? 'Not set',
              style: TextStyle(
                color: value == null ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}



