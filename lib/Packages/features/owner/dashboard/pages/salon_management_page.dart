import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/salon_provider.dart';
import 'package:na3eeman/core/theme/colors.dart';
import 'package:na3eeman/core/widgets/buttons/styled_buttons.dart';
import 'package:na3eeman/core/widgets/snackbar/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:na3eeman/Models/salon/salons_model.dart';

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

  TimeOfDay? _openingTime;
  TimeOfDay? _closingTime;

  final List<XFile> _newSalonImages = [];
  List<SalonGalleryImage> _existingImages = [];

  @override
  void initState() {
    super.initState();
    final salon = context.read<SalonProvider>().selectedSalon;
    _nameCtrl = TextEditingController(text: salon?.salonName ?? '');
    _sloganCtrl = TextEditingController(text: salon?.slogan ?? '');
    _phoneCtrl = TextEditingController(text: salon?.salonPhonNum ?? '');
    _locationCtrl = TextEditingController(text: salon?.location ?? '');
    _descCtrl = TextEditingController(text: salon?.salonDescription ?? '');

    if (salon?.openingTime != null) {
      final parts = salon!.openingTime.split(':');
      if (parts.length >= 2) {
        _openingTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    if (salon?.closingTime != null) {
      final parts = salon!.closingTime.split(':');
      if (parts.length >= 2) {
        _closingTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    }

    _existingImages = salon?.galleryImages ?? [];
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
        _newSalonImages.addAll(images);
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isOpening) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime:
          (isOpening ? _openingTime : _closingTime) ??
          const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        if (isOpening) {
          _openingTime = picked;
        } else {
          _closingTime = picked;
        }
      });
    }
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '--:--';
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final openingStr = _openingTime != null
          ? _formatTimeOfDay(_openingTime)
          : null;
      final closingStr = _closingTime != null
          ? _formatTimeOfDay(_closingTime)
          : null;

      final images = _newSalonImages.map((x) => File(x.path)).toList();

      await context.read<SalonProvider>().updateSalonOnBackend(
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        location: _locationCtrl.text,
        description: _descCtrl.text,
        slogan: _sloganCtrl.text,
        openingTime: openingStr,
        closingTime: closingStr,
        images: images.isNotEmpty ? images : null,
      );

      context.read<SalonProvider>().updateSalonInMemory(
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
        location: _locationCtrl.text,
        description: _descCtrl.text,
        slogan: _sloganCtrl.text,
        openingTime: openingStr,
        closingTime: closingStr,
      );

      if (mounted) {
        AppSnackBar.success(context, 'salon_details_updated_successfully'.tr());
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.error(
          context,
          'failed_to_update_salon_err'.tr(args: [e.toString()]),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'salon_management'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'visual_identity'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildImageSection(isDark),
              const SizedBox(height: 32),

              Text(
                'working_hours'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'set_global_hours_or_manage_weekly'.tr(),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.almostBlack300,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTimeSelector(
                      'opening_time'.tr(),
                      _openingTime,
                      () => _selectTime(context, true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimeSelector(
                      'closing_time'.tr(),
                      _closingTime,
                      () => _selectTime(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                'basic_information'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildField('salon_name'.tr(), _nameCtrl, Icons.store_rounded),
              const SizedBox(height: 16),
              _buildField(
                'salon_slogan'.tr(),
                _sloganCtrl,
                Icons.auto_awesome_rounded,
                hint: 'the_art_of_grooming'.tr(),
              ),
              const SizedBox(height: 16),
              _buildField(
                'salon_phone'.tr(),
                _phoneCtrl,
                Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildField(
                'salon_location'.tr(),
                _locationCtrl,
                Icons.location_on_rounded,
              ),
              const SizedBox(height: 16),
              _buildField(
                'salon_description'.tr(),
                _descCtrl,
                Icons.description_rounded,
                maxLines: 4,
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: PrimaryButton(
                  text: 'save_salon_details'.tr(),
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

  Widget _buildTimeSelector(String label, TimeOfDay? time, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.almostBlack300,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.05)
                  : AppColors.almostBlack50.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  _formatTimeOfDay(time),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(bool isDark) {
    return Column(
      children: [
        if (_existingImages.isEmpty && _newSalonImages.isEmpty)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.white.withValues(alpha: 0.05)
                    : AppColors.almostBlack50.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.1),
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_rounded,
                    size: 40,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'upload_salon_photos'.tr(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.almostBlack300,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _existingImages.length + _newSalonImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _existingImages.length + _newSalonImages.length) {
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

                if (index < _existingImages.length) {
                  final img = _existingImages[index];
                  return Container(
                    width: 120,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(img.image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            // onTap: () {
                            //   // TODO: Implement image deletion
                            //   AppSnackBar.info(context, 'Image deletion coming soon');
                            // },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final newIdx = index - _existingImages.length;
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: FileImage(File(_newSalonImages[newIdx].path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: 4,
                        top: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _newSalonImages.removeAt(newIdx);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: AppColors.almostBlack300,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 20,
            ),
            hintText: hint,
            filled: true,
            fillColor: isDark
                ? AppColors.white.withValues(alpha: 0.05)
                : AppColors.almostBlack50.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}
