import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../../core/theme/colors.dart';
import '../../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../../Providers/features/salon_provider.dart';

class ReceptionistSalonProfilePage extends StatefulWidget {
  const ReceptionistSalonProfilePage({super.key});

  @override
  State<ReceptionistSalonProfilePage> createState() =>
      _ReceptionistSalonProfilePageState();
}

class _ReceptionistSalonProfilePageState
    extends State<ReceptionistSalonProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;

  final List<File> _pickerImages = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final salon = context.read<SalonProvider>().selectedSalon;
    _nameController = TextEditingController(
      text: salon?.salonName ?? 'Na3eeman Expertsalon',
    );
    _phoneController = TextEditingController(
      text: salon?.salonPhonNum ?? '+962791234567',
    );
    _locationController = TextEditingController(
      text: salon?.location ?? 'Amman, Jordan',
    );
    _descriptionController = TextEditingController(
      text:
          salon?.salonDescription ??
          'Premium Men Expertsalon and Grooming experiences.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickerImages.add(File(pickedFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "manage_salon".tr(),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photos Section Placeholder
              const Text(
                'Salon Photos',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildAddPhotoCard(),
                    ..._pickerImages.map((file) => _buildPhotoThumb(file)),
                  ],
                ),
              ),
              const Divider(height: 48),

              const Text(
                'General Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "salon_name".tr(),
                controller: _nameController,
                icon: Icons.storefront_rounded,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Phone Number',
                controller: _phoneController,
                icon: Icons.phone_android_rounded,
                keyboard: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: 'Location Address',
                controller: _locationController,
                icon: Icons.location_on_rounded,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                label: "description".tr(),
                controller: _descriptionController,
                icon: Icons.description_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              const Text(
                'Management Tools',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              /*
              _buildModalActionButton(
                context,
                Icons.confirmation_num_rounded,
                'Voucher Management',
                Colors.orange,
                () => Navigator.pushNamed(context, '/management/vouchers'),
              ),
              */
              const SizedBox(height: 32),

              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      text: 'Save Details',
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isSaving = true);

                          // Update on Backend
                          await context
                              .read<SalonProvider>()
                              .updateSalonOnBackend(
                                name: _nameController.text,
                                phone: _phoneController.text,
                                location: _locationController.text,
                                description: _descriptionController.text,
                              );

                          await Future.delayed(
                            const Duration(milliseconds: 800),
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Salon profile saved successfully! (Simulated)',
                                ),
                              ),
                            );
                            setState(() => _isSaving = false);
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
        filled: true,
        fillColor: isDark
            ? AppColors.almostBlack600
            : AppColors.almostBlack50.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Cannot be empty' : null,
    );
  }

  Widget _buildAddPhotoCard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.almostBlack600
            : AppColors.almostBlack50.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: IconButton(
        icon: Icon(
          Icons.add_photo_alternate_rounded,
          color: Theme.of(context).primaryColor,
          size: 30,
        ),
        onPressed: _pickImage,
      ),
    );
  }

  Widget _buildPhotoThumb(File file) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.almostBlack50,
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildModalActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
