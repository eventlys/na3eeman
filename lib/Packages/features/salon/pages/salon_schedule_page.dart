// ignore_for_file: avoid_print, unused_local_variable
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Helpers/service_models_helper.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/backgrounds/bd_faded.dart';
import '../../../Core/themes/glass_appbar.dart';
import '../../../Core/widgets/common/date_time_pickers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/snackbar/app_snackbar.dart';

class SalonSchedulePage extends StatefulWidget {
  final Map<String, dynamic> serviceData;

  const SalonSchedulePage({super.key, required this.serviceData});

  @override
  SalonSchedulePageState createState() => SalonSchedulePageState();
}

class SalonSchedulePageState extends State<SalonSchedulePage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late Map<String, dynamic> _serviceSelection;

  final List<Map<String, dynamic>> _availableAdditionalServices = [
    ServiceDataHelper.createServiceData(
      id: '1',
      name: 'Hair Cream',
      price: '\$8',
      duration: '10 min',
    ),
    ServiceDataHelper.createServiceData(
      id: '2',
      name: 'Face Scrub',
      price: '\$12',
      duration: '15 min',
    ),
    ServiceDataHelper.createServiceData(
      id: '3',
      name: 'Hair Wash',
      price: '\$10',
      duration: '15 min',
    ),
    ServiceDataHelper.createServiceData(
      id: '4',
      name: 'Beard Styling',
      price: '\$8',
      duration: '10 min',
    ),
    ServiceDataHelper.createServiceData(
      id: '5',
      name: 'Head Massage',
      price: '\$15',
      duration: '20 min',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Initialize service selection with the main service
    _serviceSelection = ServiceSelectionHelper.createServiceSelection(
      mainService: widget.serviceData,
    );
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTime = null; // Reset time when date changes
    });
  }

  void _selectTime(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
  }

  void _toggleService(Map<String, dynamic> service) {
    setState(() {
      if (ServiceSelectionHelper.containsService(_serviceSelection, service)) {
        _serviceSelection = ServiceSelectionHelper.removeAdditionalService(
          _serviceSelection,
          service,
        );
      } else {
        _serviceSelection = ServiceSelectionHelper.addAdditionalService(
          _serviceSelection,
          service,
        );
      }
      // Reset date and time when services change
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  void _showScheduleTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.white, width: 1.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: AppColors.pink),
                      const SizedBox(width: 8),
                      Text(
                        "schedule_type".tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.pink,
                        ),
                      ),
                    ],
                  ),
                ),

                // Options
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildScheduleOption(
                        context,
                        title: "one_time_only".tr(),
                        subtitle: "schedule_this_appointment_once".tr(),
                        icon: Icons.event,
                        onTap: () {
                          Navigator.of(context).pop();
                          _confirmSchedule('one_time');
                          // Use the simplified method
                          Provider.of<PointsProvider>(
                            context,
                            listen: false,
                          ).addAppointmentPoints();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildScheduleOption(
                        context,
                        title: "bi_weekly".tr(),
                        subtitle: "repeat_every2_weeks".tr(),
                        icon: Icons.repeat,
                        onTap: () {
                          Navigator.of(context).pop();
                          _confirmSchedule('bi_weekly');
                          // Use the simplified method
                          Provider.of<PointsProvider>(
                            context,
                            listen: false,
                          ).addAppointmentPoints();
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildScheduleOption(
                        context,
                        title: "monthly".tr(),
                        subtitle: "repeat_every_month".tr(),
                        icon: Icons.calendar_month,
                        onTap: () {
                          Navigator.of(context).pop();
                          _confirmSchedule('monthly');
                          // Use the simplified method
                          Provider.of<PointsProvider>(
                            context,
                            listen: false,
                          ).addAppointmentPoints();
                        },
                      ),
                    ],
                  ),
                ),

                // Close Button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.pink, width: 1.0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        "cancel".tr(),
                        style: TextStyle(
                          color: AppColors.pink,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScheduleOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pink.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.pink),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.pink, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.almostBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.almostBlack.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSchedule(String scheduleType) {
    if (_selectedDate == null || _selectedTime == null) {
      AppSnackBar.warning(context, "please_select_both_date_and_time".tr());
      return;
    }

    // Get all selected services
    final allServices = ServiceSelectionHelper.getAllServices(
      _serviceSelection,
    );

    // Your schedule confirmation logic here with scheduleType
    print(
      'Schedule confirmed: $scheduleType for ${allServices.length} services',
    );

    AppSnackBar.success(context, '$scheduleType schedule booked successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return FadedBackground(
      startColor: const Color(0xff806C99),
      endColor: const Color(0xFFDFA8A4),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            GlassSliverAppBar(title: "book_a_haircut".tr()),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Information - Updated to use service data
                      _buildServiceDetailsSection(),
                      const SizedBox(height: 24),

                      // Date Picker
                      ScheduleDatePicker(
                        selectedDate: _selectedDate,
                        onDateSelected: _selectDate,
                      ),
                      const SizedBox(height: 16),

                      // Time Picker
                      ScheduleTimePicker(
                        selectedDate: _selectedDate,
                        selectedTime: _selectedTime,
                        onTimeSelected: _selectTime,
                      ),
                      const SizedBox(height: 32),

                      // Confirm Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _showScheduleTypeDialog(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 16,
                            ),
                          ),
                          child: Text(
                            "confirm_schedule".tr(),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildServiceDetailsSection() {
    final mainService = ServiceSelectionHelper.getMainService(
      _serviceSelection,
    );
    final additionalServices = ServiceSelectionHelper.getAdditionalServices(
      _serviceSelection,
    );
    final allServices = ServiceSelectionHelper.getAllServices(
      _serviceSelection,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "selected_services".tr(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // Main Service
          _buildServiceItem(mainService, isMain: true),

          // Additional Services
          if (additionalServices.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              "additional_services".tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            ...additionalServices.map((service) => _buildServiceItem(service)),
          ],

          const SizedBox(height: 12),

          // Available Additional Services
          Text(
            "add_more_services".tr(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          ..._availableAdditionalServices.map(
            (service) => _buildAdditionalServiceOption(service),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(
    Map<String, dynamic> service, {
    bool isMain = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ServiceDataHelper.getServiceName(service),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ServiceDataHelper.getServiceDuration(service),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            ServiceDataHelper.getServicePrice(service),
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalServiceOption(Map<String, dynamic> service) {
    final isSelected = ServiceSelectionHelper.containsService(
      _serviceSelection,
      service,
    );

    return GestureDetector(
      onTap: () => _toggleService(service),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.pink.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.pink
                : Colors.white.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ServiceDataHelper.getServiceName(service),
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ServiceDataHelper.getServiceDuration(service),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  ServiceDataHelper.getServicePrice(service),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isSelected ? Icons.check_circle : Icons.add_circle_outline,
                  color: isSelected ? AppColors.pink : Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: AppColors.pink,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.7),
              blurRadius: 10,
              offset: const Offset(5, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // ... (keep your existing bottom navigation bar code)
            // This part remains the same as your original code
          ],
        ),
      ),
    );
  }
}
