import 'package:flutter/material.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';

class ProfileWidgets {
  static Widget buildLoadingState() {
    return Builder(
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }

  static Widget buildProfileContent({
    required GlobalKey<FormState> formKey,
    required Map<String, dynamic> userData,
    required bool isEditing,
    required Map<String, TextEditingController> controllers,
    required String Function() getAccountType,
    required VoidCallback onDeleteProfile,
    required VoidCallback onChangeProfilePicture,
  }) {
    final isCustomer = userData['role']?.toString().toLowerCase() == 'customer';

    return Form(
      key: formKey,
      child: Column(
        children: [
          if (!isCustomer)
            _buildProfileHeader(userData, isEditing, onChangeProfilePicture),
          if (isCustomer) ...[
            const SizedBox(height: 16),
            Text(
              '${userData['firstName']} ${userData['lastName']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Builder(
              builder: (context) {
                return Text(
                  '@${userData['username']}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
          const SizedBox(height: 16),
          _buildInfoSection(
            userData,
            isEditing,
            controllers,
            getAccountType,
            onDeleteProfile,
          ),
        ],
      ),
    );
  }

  static Widget _buildProfileHeader(
    Map<String, dynamic> userData,
    bool isEditing,
    VoidCallback onChangePicture,
  ) {
    return Builder(
      builder: (context) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor,
                      width: 3,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.05),
                    backgroundImage: userData['profilePic'] != null
                        ? AssetImage(
                            userData['profilePic'],
                          ) // Use local for now
                        : null,
                    child: userData['profilePic'] == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          )
                        : null,
                  ),
                ),
                if (isEditing)
                  IconButtonStyled(
                    icon: Icons.camera_alt_rounded,
                    onPressed: onChangePicture,
                    backgroundColor: Theme.of(context).primaryColor,
                    color: AppColors.white,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${userData['firstName']} ${userData['lastName']}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              '@${userData['username']}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildInfoSection(
    Map<String, dynamic> userData,
    bool isEditing,
    Map<String, TextEditingController> controllers,
    String Function() getAccountType,
    VoidCallback onDelete,
  ) {
    final isCustomer = userData['role']?.toString().toLowerCase() == 'customer';

    return Column(
      children: [
        _buildSectionCard(
          title: 'Personal Information',
          icon: Icons.person_outline_rounded,
          children: [
            _buildField('First Name', controllers['firstName']!, isEditing),
            _buildField('Last Name', controllers['lastName']!, isEditing),
            if (isCustomer)
              _buildField('Nickname', controllers['nickname']!, isEditing),
            _buildField(
              'Email',
              controllers['email']!,
              isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildField(
              'Phone',
              controllers['phone']!,
              isEditing,
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        if (!isCustomer) ...[
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Profile Details',
            icon: Icons.info_outline_rounded,
            children: [
              _buildField('Bio', controllers['bio']!, isEditing, maxLines: 3),
              _buildField('Location', controllers['location']!, isEditing),
            ],
          ),
          const SizedBox(height: 16),
          _buildSectionCard(
            title: 'Account Status',
            icon: Icons.verified_user_outlined,
            children: [
              _buildReadOnlyRow('Account Type', getAccountType()),
              _buildReadOnlyRow(
                'Subscription',
                userData['isSubscribed'] == true ? 'Premium' : 'Free',
              ),
              _buildReadOnlyRow(
                'Role',
                userData['role'].toString().toUpperCase(),
              ),
            ],
          ),
        ],
        const SizedBox(height: 32),
        if (!isEditing)
          DangerButton(text: 'Delete Account', onPressed: onDelete),
      ],
    );
  }

  static Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.almostBlack600 : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.1)
                  : AppColors.almostBlack50,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Divider(height: 1),
              ),
              ...children,
            ],
          ),
        );
      },
    );
  }

  static Widget _buildField(
    String label,
    TextEditingController controller,
    bool isEditing, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.almostBlack400,
            ),
          ),
          const SizedBox(height: 8),
          if (isEditing)
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: 'Enter $label',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            )
          else
            Text(
              controller.text.isEmpty ? 'Not set' : controller.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
        ],
      ),
    );
  }

  static Widget _buildReadOnlyRow(String label, String value) {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.almostBlack400),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
