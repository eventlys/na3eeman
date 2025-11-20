import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Helpers/customized/soonest_appointment_helpers.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/themes/app_theme.dart';
import '../../../Core/utils/helpers/themes_helpers.dart';
import '../../../Core/widgets/base/error_boundary.dart';


class SoonestAppointmentCard extends StatefulWidget {
  final Function(Map<String, dynamic>)? onAppointmentDelayed;
  final Function(Map<String, dynamic>)? onAppointmentRescheduleNeeded;
  final bool isDarkMode;
  final UserGender? userGender;

  const SoonestAppointmentCard({
    super.key,
    this.onAppointmentDelayed,
    this.onAppointmentRescheduleNeeded,
    this.isDarkMode = false,
    this.userGender,
  });

  @override
  State<SoonestAppointmentCard> createState() => _SoonestAppointmentCardState();
}

class _SoonestAppointmentCardState extends State<SoonestAppointmentCard> {
  Map<String, dynamic>? _soonestAppointment;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSoonestAppointment();
  }

  Future<void> _loadSoonestAppointment() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final businessService = _getBusinessService();
    final authProvider = _getAuthProvider();

    if (authProvider?.user?['id'] == null) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final appointment = await businessService.getSoonestAppointment(authProvider!.user!['id']);

      if (mounted) {
        setState(() {
          _soonestAppointment = appointment;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading soonest appointment: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _handleDelayAppointment() async {
    if (_soonestAppointment == null) return;

    final result = await showDialog<Duration>(
      context: context,
      builder: (context) => Theme(
        data: AppThemes.getGenderTheme(
          widget.userGender ?? UserGender.male,
          widget.isDarkMode,
        ),
        child: _DelayAppointmentDialog(
          currentAppointment: _soonestAppointment!,
          isDarkMode: widget.isDarkMode,
          userGender: widget.userGender,
        ),
      ),
    );

    if (result != null && mounted) {
      _processDelay(result);
    }
  }

  void _processDelay(Duration delay) async {
    if (_soonestAppointment == null) return;

    try {
      // Use the helper to check if delay is possible
      if (SoonestAppointmentHelpers.canDelayAppointment(_soonestAppointment!, delay)) {
        final delayedAppointment = SoonestAppointmentHelpers.delayAppointment(
          _soonestAppointment!,
          delay,
        );

        // Update the appointment via service
        final businessService = _getBusinessService();
        await businessService.rescheduleAppointment(
          delayedAppointment['id'] as String,
          DateTime.parse(delayedAppointment['dateTime'] as String),
          DateTime.parse(delayedAppointment['dateTime'] as String).add(const Duration(minutes: 30)),
        );

        // Notify parent widget
        widget.onAppointmentDelayed?.call(delayedAppointment);

        // Update local state
        setState(() {
          _soonestAppointment = delayedAppointment;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment delayed by ${delay.inMinutes} minutes'),
            backgroundColor: widget.isDarkMode ? AppColor.darkSuccess : AppColor.lightSuccess,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        // Delay not possible, need to reschedule
        widget.onAppointmentRescheduleNeeded?.call(_soonestAppointment!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot delay. Please reschedule your appointment.'),
            backgroundColor: widget.isDarkMode ? AppColor.darkWarning : AppColor.lightWarning,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error delaying appointment: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error delaying appointment. Please try again.'),
          backgroundColor: widget.isDarkMode ? AppColor.darkError : AppColor.lightError,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _callShop() {
    if (_soonestAppointment != null) {
      final phoneNumber = _soonestAppointment!['shopPhoneNumber'];
      // You would typically use url_launcher here
      print('Calling: $phoneNumber');
      // Example: launchUrl(Uri.parse('tel:$phoneNumber'));
    }
  }

  // Service and provider access methods
  dynamic _getBusinessService() {
    return context.read<AppointmentProvider>();
  }

  dynamic _getAuthProvider() {
    try {
      return context.read<dynamic>();
    } catch (e) {
      return null;
    }
  }

  Color _getCardColor() {
    if (widget.userGender != null) {
      switch (widget.userGender!) {
        case UserGender.male:
          return widget.isDarkMode ? AppColor.darkMaleBG.withValues(alpha: 0.1) : AppColor.lightMaleBG.withValues(alpha: 0.1);
        case UserGender.female:
          return widget.isDarkMode ? AppColor.darkFemaleBG.withValues(alpha: 0.1) : AppColor.lightFemaleBG.withValues(alpha: 0.1);
        case UserGender.nonBinary:
          return widget.isDarkMode ? AppColor.darkNonBinaryBG.withValues(alpha: 0.1) : AppColor.lightNonBinaryBG.withValues(alpha: 0.1);
      }
    }
    return widget.isDarkMode ? AppColor.darkCard : AppColor.lightCard;
  }

  Color _getPrimaryColor() {
    if (widget.userGender != null) {
      switch (widget.userGender!) {
        case UserGender.male:
          return AppColor.maleAccent;
        case UserGender.female:
          return AppColor.femaleAccent;
        case UserGender.nonBinary:
          return AppColor.nonBinaryAccent;
      }
    }
    return widget.isDarkMode ? AppColor.darkPrimary : AppColor.primary;
  }

  Color _getTextColor() {
    return widget.isDarkMode ? AppColor.darkText : AppColor.lightText;
  }

  Color _getSecondaryTextColor() {
    return widget.isDarkMode ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
  }

  Color _getBorderColor() {
    return widget.isDarkMode ? AppColor.borderDark : AppColor.borderLight;
  }

  Color _getButtonBackgroundColor() {
    return widget.isDarkMode ? AppColor.buttonBackgroundDark : AppColor.buttonBackgroundLight;
  }

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      isDarkMode: widget.isDarkMode,
      userGender: widget.userGender,
      onRetry: _loadSoonestAppointment,
      child: _buildCardContent(),
    );
  }

  Widget _buildCardContent() {
    if (_hasError) {
      return _buildErrorCard();
    }

    if (_isLoading) {
      return _buildLoadingCard();
    }

    if (_soonestAppointment == null) {
      return _buildNoAppointmentCard();
    }

    return _buildAppointmentCard(_soonestAppointment!);
  }

  Widget _buildErrorCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: _getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: _getPrimaryColor(),
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to Load Appointment',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again',
              style: TextStyle(
                color: _getSecondaryTextColor(),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSoonestAppointment,
              style: ElevatedButton.styleFrom(
                backgroundColor: _getPrimaryColor(),
                foregroundColor: widget.isDarkMode ? AppColor.dark : AppColor.light,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: _getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: const Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Loading appointment...'),
          ],
        ),
      ),
    );
  }

  Widget _buildNoAppointmentCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      color: _getCardColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.calendar_today,
              size: 48,
              color: _getSecondaryTextColor(),
            ),
            const SizedBox(height: 12),
            Text(
              'No Upcoming Appointments',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _getSecondaryTextColor(),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book an appointment to see it here',
              style: TextStyle(
                color: _getSecondaryTextColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final services = appointment['services'] as List<dynamic>? ?? [];
    final primaryColor = _getPrimaryColor();

    return Card(
      color: _getCardColor(),
      shadowColor: Colors.transparent,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Next Appointment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _getTextColor(),
                  ),
                ),
                Icon(
                  Icons.access_time,
                  color: primaryColor,
                ),
              ],
            ),

            const SizedBox(height: 16),
            // Appointment Details
            _buildDetailRow(
              Icons.calendar_today,
              SoonestAppointmentHelpers.formatAppointmentDateTime(appointment['dateTime']),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.attach_money,
              'Total: ${SoonestAppointmentHelpers.formatPrice((appointment['totalPrice'] as num?)?.toDouble() ?? 0.0)}',
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              Icons.store,
              appointment['shopName'] ?? 'Unknown Shop',
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _callShop,
              child: _buildDetailRow(
                Icons.phone,
                appointment['shopPhoneNumber'] ?? 'No phone number',
                isClickable: true,
              ),
            ),
            const SizedBox(height: 16),

            // Services
            if (services.isNotEmpty) ...[
              Text(
                'Services:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getTextColor(),
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: services
                    .map((service) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getButtonBackgroundColor(),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            service.toString(),
                            style: TextStyle(
                              color: _getTextColor(),
                              fontSize: 12,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Delay Button
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton.icon(
                  onPressed: _handleDelayAppointment,
                  icon: Icon(Icons.schedule, size: 18, color: primaryColor),
                  label: Text(
                    'Delay Appointment',
                    style: TextStyle(color: primaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    shadowColor: Colors.transparent,
                    backgroundColor: _getButtonBackgroundColor(),
                    foregroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, {bool isClickable = false}) {
    final primaryColor = _getPrimaryColor();
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: isClickable ? primaryColor : _getTextColor(),
              fontWeight: isClickable ? FontWeight.w600 : FontWeight.normal,
              decoration: isClickable ? TextDecoration.underline : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _DelayAppointmentDialog extends StatefulWidget {
  final Map<String, dynamic> currentAppointment;
  final bool isDarkMode;
  final UserGender? userGender;

  const _DelayAppointmentDialog({
    required this.currentAppointment,
    required this.isDarkMode,
    this.userGender,
  });

  @override
  State<_DelayAppointmentDialog> createState() => _DelayAppointmentDialogState();
}

class _DelayAppointmentDialogState extends State<_DelayAppointmentDialog> {
  int _selectedMinutes = 5;

  Color _getPrimaryColor() {
    if (widget.userGender != null) {
      switch (widget.userGender!) {
        case UserGender.male:
          return AppColor.maleAccent;
        case UserGender.female:
          return AppColor.femaleAccent;
        case UserGender.nonBinary:
          return AppColor.nonBinaryAccent;
      }
    }
    return widget.isDarkMode ? AppColor.darkPrimary : AppColor.primary;
  }

  Color _getTextColor() {
    return widget.isDarkMode ? AppColor.darkText : AppColor.lightText;
  }

  Color _getBackgroundColor() {
    return widget.isDarkMode ? AppColor.darkCard : AppColor.lightCard;
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getPrimaryColor();
    
    return Dialog(
      backgroundColor: _getBackgroundColor(),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Delay Appointment',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Current time: ${SoonestAppointmentHelpers.formatAppointmentDateTime(widget.currentAppointment['dateTime'])}',
              style: TextStyle(
                color: _getTextColor(),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select delay duration:',
              style: TextStyle(
                color: _getTextColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: widget.isDarkMode ? AppColor.darkCard : AppColor.lightCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedMinutes,
                  isExpanded: true,
                  dropdownColor: _getBackgroundColor(),
                  items: [5, 10, 15]
                      .map((minutes) => DropdownMenuItem(
                            value: minutes,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$minutes minutes',
                                style: TextStyle(
                                  color: _getTextColor(),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedMinutes = value!;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (_selectedMinutes == 15)
              Text(
                'Note: Delays longer than 15 minutes require rescheduling',
                style: TextStyle(
                  color: widget.isDarkMode ? AppColor.darkWarning : AppColor.lightWarning,
                  fontSize: 12,
                ),
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: _getTextColor(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, Duration(minutes: _selectedMinutes)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: widget.isDarkMode ? AppColor.dark : AppColor.light,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('Delay Appointment'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
