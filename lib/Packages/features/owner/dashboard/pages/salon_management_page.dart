import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/salon_provider.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';

class SalonManagementPage extends StatefulWidget {
  const SalonManagementPage({super.key});

  @override
  State<SalonManagementPage> createState() => _SalonManagementPageState();
}

class _SalonManagementPageState extends State<SalonManagementPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _sloganCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _locationCtrl;
  late TextEditingController _descCtrl;

  final List<XFile> _salonImages = [];

  @override
  void initState() {
    super.initState();
    final salon = context.read<SalonProvider>().selectedSalon;
    _nameCtrl = TextEditingController(text: salon?.salonName ?? '');
    _sloganCtrl = TextEditingController(text: salon?.slogan ?? '');
    _phoneCtrl = TextEditingController(text: salon?.salonPhonNum ?? '');
    _locationCtrl = TextEditingController(text: salon?.location ?? '');
    _descCtrl = TextEditingController(text: salon?.salonDescription ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sloganCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _salonImages.addAll(images);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<SalonProvider>().updateSalonOnBackend(
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        location: _locationCtrl.text,
        description: _descCtrl.text,
      );
      // Slogan is local for now as API might not have it yet
      context.read<SalonProvider>().updateSalonInMemory(
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        location: _locationCtrl.text,
        description: _descCtrl.text,
      );
      if (mounted) AppSnackBar.success(context, 'Salon details updated successfully!');
    } catch (e) {
      if (mounted) AppSnackBar.error(context, 'Failed to update salon: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Salon Management', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Visual Identity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildImageSection(isDark),
              const SizedBox(height: 32),
              const Text('Basic Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildField('Salon Name', _nameCtrl, Icons.store_rounded),
              const SizedBox(height: 16),
              _buildField('Salon Slogan', _sloganCtrl, Icons.auto_awesome_rounded, hint: 'e.g. The Art of Grooming'),
              const SizedBox(height: 16),
              _buildField('Phone Number', _phoneCtrl, Icons.phone_rounded, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildField('Location Address', _locationCtrl, Icons.location_on_rounded),
              const SizedBox(height: 16),
              _buildField('Description', _descCtrl, Icons.description_rounded, maxLines: 4),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: PrimaryButton(
                  text: 'Save Salon Details',
                  onPressed: _saveChanges,
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(bool isDark) {
    return Column(
      children: [
        if (_salonImages.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.almostBlack50.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1), style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, size: 40, color: Theme.of(context).primaryColor),
                  const SizedBox(height: 12),
                  const Text('Upload Salon Photos', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.almostBlack300)),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _salonImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _salonImages.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.add_rounded),
                    ),
                  );
                }
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(image: FileImage(File(_salonImages[index].path)), fit: BoxFit.cover),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {String? hint, TextInputType keyboardType = TextInputType.text, int maxLines = 1}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.almostBlack300)),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor, size: 20),
            hintText: hint,
            filled: true,
            fillColor: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.almostBlack50.withValues(alpha: 0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }
}
