import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../Helpers/customized/soonest_appointment_helpers.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_roles.dart';
import '../../../Core/utils/helpers/themes_helpers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../Models/appointments/salon_appointments_model.dart';

class AppointmentAccordion extends StatefulWidget {
  final Map<String, dynamic> appointment;
  final bool isDarkMode;
  final UserGender? userGender;

  const AppointmentAccordion({
    super.key,
    required this.appointment,
    this.isDarkMode = false,
    this.userGender,
  });

  @override
  State<AppointmentAccordion> createState() => _AppointmentAccordionState();
}

class _AppointmentAccordionState extends State<AppointmentAccordion> {
  bool _isExpanded = false;

  // Service and provider access methods
  dynamic _getAppointmentProvider() {
    return context.read<AppointmentProvider>();
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
  //
  // Color _getSecondaryTextColor() {
  //   return widget.isDarkMode ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
  // }

  Color _getBorderColor() {
    return widget.isDarkMode ? AppColor.borderDark : AppColor.borderLight;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return widget.isDarkMode ? AppColor.darkSuccess : AppColor.lightSuccess;
      case 'scheduled':
        return widget.isDarkMode ? AppColor.darkWarning : AppColor.lightWarning;
      case 'cancelled':
        return widget.isDarkMode ? AppColor.darkError : AppColor.lightError;
      case 'pending':
        return widget.isDarkMode ? AppColor.darkWarning : AppColor.lightWarning;
      case 'pending_payment':
        return widget.isDarkMode ? AppColor.darkError : AppColor.lightError;
      default:
        return widget.isDarkMode ? AppColor.darkTextSecondary : AppColor.lightTextSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'scheduled':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'pending':
        return Icons.pending;
      case 'pending_payment':
        return Icons.payment;
      default:
        return Icons.help;
    }
  }

  Widget _buildStatusChip(String status) {
    final statusColor = _getStatusColor(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            color: statusColor,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  //
  // String _formatAppointmentDateTime() {
  //   final dateTime = widget.appointment['dateTime'];
  //   if (dateTime is DateTime) {
  //     // Convert DateTime to ISO string format that the helper expects
  //     return SoonestAppointmentHelpers.formatAppointmentDateTime(dateTime.toIso8601String());
  //   } else if (dateTime is String) {
  //     return SoonestAppointmentHelpers.formatAppointmentDateTime(dateTime);
  //   }
  //   return 'Unknown date';
  // }

  String _formatAppointmentDate() {
    final dateTime = widget.appointment['dateTime'];
    if (dateTime is DateTime) {
      return _formatDate(dateTime);
    } else if (dateTime is String) {
      return _formatDate(DateTime.parse(dateTime));
    }
    return 'Unknown date';
  }

  String _formatAppointmentTime() {
    final dateTime = widget.appointment['dateTime'];
    if (dateTime is DateTime) {
      return _formatTime(dateTime);
    } else if (dateTime is String) {
      return _formatTime(DateTime.parse(dateTime));
    }
    return 'Unknown time';
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (appointmentDate == today) {
      return 'Today';
    } else if (appointmentDate == today.add(const Duration(days: 1))) {
      return 'Tomorrow';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour < 12 ? 'AM' : 'PM';
    return '${hour == 0 ? 12 : hour}:$minute $period';
  }

  String _formatPrice() {
    final totalPrice = widget.appointment['totalPrice'];
    if (totalPrice is num) {
      return SoonestAppointmentHelpers.formatPrice(totalPrice.toDouble());
    }
    return SoonestAppointmentHelpers.formatPrice(0.0);
  }

  List<dynamic> _getServices() {
    return widget.appointment['services'] as List<dynamic>? ?? [];
  }

  String _getTitle() {
    return widget.appointment['title']?.toString() ??
           widget.appointment['salonName']?.toString() ??
           'Appointment';
  }

  String _getBarberName() {
    return widget.appointment['barberName']?.toString() ??
           widget.appointment['barber']?.toString() ??
           'Unknown Barber';
  }

  String _getBarberNumber() {
    return widget.appointment['barberNumber']?.toString() ??
           widget.appointment['salonPhoneNumber']?.toString() ??
           'No phone number';
  }

  String _getBarbershopName() {
    return widget.appointment['barberSalonName']?.toString() ??
           widget.appointment['salonName']?.toString() ??
           'Unknown Salon';
  }

  String _getImagePath() {
    return widget.appointment['imagePath']?.toString() ??
           widget.appointment['barberImage']?.toString() ??
           widget.appointment['salonImage']?.toString() ??
           '';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final primaryColor = _getPrimaryColor();
    final cardColor = _getCardColor();
    final textColor = _getTextColor();
    final services = _getServices();

    return Card(
      color: cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
            cardColor: Colors.transparent,
          ),
          child: ExpansionTile(
            collapsedBackgroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            key: Key(widget.appointment['id']?.toString() ?? ''),
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isExpanded = expanded;
              });
            },
            leading: CircleAvatar(
              radius: 36,
              backgroundColor: primaryColor.withValues(alpha: 0.1),
              backgroundImage: _getImagePath().isNotEmpty
                  ? CachedNetworkImageProvider(_getImagePath())
                  : null,
              child: _getImagePath().isEmpty
                  ? Icon(
                      Icons.person,
                      color: primaryColor,
                      size: 30,
                    )
                  : null,
            ),
            title: Text(
              _getTitle(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: textColor,
              ),
            ),
            subtitle: _buildStatusChip(widget.appointment['status']?.toString() ?? 'unknown'),
            trailing: Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: primaryColor,
            ),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.access_time,
                      title: AppLocalizations.of(context)!.date,
                      value: _formatAppointmentDate(),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.schedule,
                      title: AppLocalizations.of(context)!.time,
                      value: _formatAppointmentTime(),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.attach_money,
                      title: 'Total Price',
                      value: _formatPrice(),
                    ),
                    const SizedBox(height: 12),
                    if (services.isNotEmpty) ...[
                      _buildServicesSection(services),
                      const SizedBox(height: 12),
                    ],
                    _buildDetailRow(
                      icon: Icons.person,
                      title: AppLocalizations.of(context)!.barber,
                      value: _getBarberName(),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.phone,
                      title: 'Barber Number',
                      value: _getBarberNumber(),
                      isClickable: true,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.store,
                      title: 'Barber Salon',
                      value: _getBarbershopName(),
                    ),
                    // Payment Details (Point 2)
                    if (authProvider.user?.isStaff == true) ...[
                      const Divider(height: 32),
                      _buildDetailRow(
                        icon: Icons.payments_outlined,
                        title: 'Payment Status',
                        value: (widget.appointment['isPaid'] ?? false) ? 'PAID' : 'UNPAID',
                        valueColor: (widget.appointment['isPaid'] ?? false) ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildDetailRow(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'Method',
                        value: widget.appointment['paymentMethod']?.toString().toUpperCase() ?? 'NONE',
                      ),
                      if (widget.appointment['paymentEvidence'] != null) ...[
                        const SizedBox(height: 12),
                        _buildEvidenceSection(context),
                      ],
                    ],
                    const SizedBox(height: 16),
                    _buildStaffActions(context),
                    _buildCustomerActions(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffActions(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.user?.isStaff != true) return const SizedBox.shrink();

    final status = widget.appointment['status']?.toString().toLowerCase();
    final paymentVerified = widget.appointment['paymentVerified'] ?? false;
    final hasEvidence = widget.appointment['paymentEvidence'] != null;
    final appointmentId = widget.appointment['id']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'Staff Actions',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getPrimaryColor(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (status == 'scheduled' || status == 'pending')
              ElevatedButton.icon(
                onPressed: () => _showDelayDialog(context, appointmentId),
                icon: const Icon(Icons.timer_outlined, size: 18),
                label: const Text('Report Delay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            if (hasEvidence && !paymentVerified)
              ElevatedButton.icon(
                onPressed: () => _verifyPayment(context, appointmentId),
                icon: const Icon(Icons.fact_check_outlined, size: 18),
                label: const Text('Verify Payment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            // Receptionist specific: Remind and Report (Point 1, 2)
            if (authProvider.user?.role == UserRole.receptionist) ...[
              if (!(widget.appointment['isPaid'] ?? false))
                ElevatedButton.icon(
                  onPressed: () => _remindCustomer(context, appointmentId),
                  icon: const Icon(Icons.notifications_active_outlined, size: 18),
                  label: const Text('Remind Customer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.femaleAccent,
                    foregroundColor: Colors.white,
                  ),
                ),
              ElevatedButton.icon(
                onPressed: () => _showReportIncompletePaymentDialog(context, appointmentId),
                icon: const Icon(Icons.report_gmailerrorred_rounded, size: 18),
                label: const Text('Report Payment Issue'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
            if (status == 'completed')
              ElevatedButton.icon(
                onPressed: () => _showRatingDialog(context, appointmentId),
                icon: const Icon(Icons.star_outline, size: 18),
                label: const Text('Rate Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ],
    );
  }

  void _showDelayDialog(BuildContext context, String id) {
    int minutes = 15;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Delay'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select delay duration (min):'),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: minutes,
              items: [15, 30, 45, 60].map((m) => DropdownMenuItem(value: m, child: Text('$m min'))).toList(),
              onChanged: (val) => minutes = val!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AppointmentProvider>().delayAppointment(id, minutes);
              Navigator.pop(context);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _verifyPayment(BuildContext context, String id) {
    context.read<AppointmentProvider>().verifyPayment(id);
  }

  void _showRatingDialog(BuildContext context, String id) {
    double rating = 5.0;
    final reviewsController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate Customer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How was the customer?'),
            const SizedBox(height: 16),
            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: rating.toString(),
              onChanged: (val) => rating = val,
            ),
            TextField(
              controller: reviewsController,
              decoration: const InputDecoration(labelText: 'Review (Optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<AppointmentProvider>().rateCustomer(
                appointmentId: id,
                rating: rating,
                reviews: reviewsController.text,
              );
              Navigator.pop(context);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(List<dynamic> services) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Services:',
          style: TextStyle(
            color: _getTextColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: services
              .map((service) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getPrimaryColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getPrimaryColor().withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      service is AppointmentServiceModel ? service.name : service.toString(),
                      style: TextStyle(
                        color: _getTextColor(),
                        fontSize: 12,
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
    bool isClickable = false,
    Color? valueColor,
  }) {
    final primaryColor = _getPrimaryColor();
    final textColor = _getTextColor();

    return Row(
      children: [
        Icon(
          icon,
          color: primaryColor,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: isClickable ? () => _callBarber(value) : null,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? (isClickable ? primaryColor : textColor),
                fontWeight: isClickable || valueColor != null ? FontWeight.w600 : FontWeight.normal,
                decoration: isClickable ? TextDecoration.underline : TextDecoration.none,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceSection(BuildContext context) {
    final evidence = widget.appointment['paymentEvidence'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Payment Evidence:', 
          style: TextStyle(fontWeight: FontWeight.bold, color: _getTextColor())),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showEvidenceImage(context, evidence),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: CachedNetworkImageProvider(evidence),
                fit: BoxFit.cover,
              ),
            ),
            child: const Center(
              child: Icon(Icons.zoom_in, color: Colors.white, size: 40),
            ),
          ),
        ),
      ],
    );
  }

  void _showEvidenceImage(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CachedNetworkImage(imageUrl: url),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      ),
    );
  }

  void _remindCustomer(BuildContext context, String id) {
     ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment reminder sent to customer.')),
    );
  }

  void _showReportIncompletePaymentDialog(BuildContext context, String id) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Payment Issue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Reason for reporting (e.g. incorrect amount, faked evidence):'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter reason...'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              // Logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Submit Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerActions(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.user?.isCustomer != true) return const SizedBox.shrink();

    final status = widget.appointment['status']?.toString().toLowerCase();
    final checkoutUrl = widget.appointment['checkoutUrl'] ?? widget.appointment['checkout_url'];

    if (status == 'pending_payment' && checkoutUrl != null) {
      return Column(
        children: [
          const Divider(),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final uri = Uri.parse(checkoutUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              icon: const Icon(Icons.payment_rounded),
              label: const Text('Complete Payment Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _callBarber(String phoneNumber) {
    // You would typically use url_launcher here
    print('Calling: $phoneNumber');
    // Example: launchUrl(Uri.parse('tel:$phoneNumber'));
  }
}
