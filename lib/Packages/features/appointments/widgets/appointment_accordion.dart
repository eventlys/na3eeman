import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../../../Helpers/customized/soonest_appointment_helpers.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/utils/helpers/themes_helpers.dart';

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
           widget.appointment['shopName']?.toString() ??
           'Appointment';
  }

  String _getBarberName() {
    return widget.appointment['barberName']?.toString() ??
           widget.appointment['barber']?.toString() ??
           'Unknown Barber';
  }

  String _getBarberNumber() {
    return widget.appointment['barberNumber']?.toString() ??
           widget.appointment['shopPhoneNumber']?.toString() ??
           'No phone number';
  }

  String _getBarberShopName() {
    return widget.appointment['barberShopName']?.toString() ??
           widget.appointment['shopName']?.toString() ??
           'Unknown Shop';
  }

  String _getImagePath() {
    return widget.appointment['imagePath']?.toString() ??
           widget.appointment['barberImage']?.toString() ??
           widget.appointment['shopImage']?.toString() ??
           '';
  }

  @override
  Widget build(BuildContext context) {
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
                      title: 'Date',
                      value: _formatAppointmentDate(),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.schedule,
                      title: 'Time',
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
                      title: 'Barber',
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
                      title: 'Barber Shop',
                      value: _getBarberShopName(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                      service.toString(),
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
                color: isClickable ? primaryColor : textColor,
                fontWeight: isClickable ? FontWeight.w600 : FontWeight.normal,
                decoration: isClickable ? TextDecoration.underline : TextDecoration.none,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ),
      ],
    );
  }

  void _callBarber(String phoneNumber) {
    // You would typically use url_launcher here
    print('Calling: $phoneNumber');
    // Example: launchUrl(Uri.parse('tel:$phoneNumber'));
  }
}
