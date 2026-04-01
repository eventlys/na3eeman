import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Providers/main_providers.dart';
import 'package:easy_localization/easy_localization.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<dynamic> _appointments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    final authProvider = context.read<AuthProvider>();
    final appointmentProvider = context.read<AppointmentProvider>();

    if (!authProvider.isAuthenticated) {
      setState(() {
        _isLoading = false;
        _error = 'Please login to view appointment history';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Use the appointment provider to load appointments
      await appointmentProvider.loadAppointments();

      // Get appointments based on user role using authProvider
      if (authProvider.isCustomer) {
        _appointments = _filterCustomerAppointments(appointmentProvider, authProvider);
      } else if (authProvider.isBarber || authProvider.isOwner) {
        _appointments = _filterStaffAppointments(appointmentProvider, authProvider);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load appointments: $e';
      });
    }
  }

  List<dynamic> _filterCustomerAppointments(AppointmentProvider provider, AuthProvider authProvider) {
    // Filter appointments where current user is the customer
    final user = authProvider.user;
    if (user == null) return [];

    return provider.appointments.where((appt) {
      final customerId = _getAppointmentCustomerId(appt);
      return customerId == user.id;
    }).toList();
  }

  List<dynamic> _filterStaffAppointments(AppointmentProvider provider, AuthProvider authProvider) {
    // For barbers/owners, show appointments assigned to them or in their shop
    final user = authProvider.user;
    if (user == null) return [];

    if (authProvider.isBarber) {
      return provider.appointments.where((appt) {
        final barberId = _getAppointmentBarberId(appt);
        return barberId == user.id;
      }).toList();
    } else if (authProvider.isOwner) {
      // Owners can see all appointments in their shop(s)
      return provider.appointments;
    }

    return [];
  }

  int _getAppointmentCustomerId(dynamic appointment) {
    if (appointment is Map) {
      return appointment['customerId'] ?? appointment['customer'] ?? 0;
    }
    // If using a model with customerId property
    try {
      return appointment.customerId as int;
    } catch (e) {
      return 0;
    }
  }

  int? _getAppointmentBarberId(dynamic appointment) {
    if (appointment is Map) {
      return appointment['barberId'] ?? appointment['barber'];
    }
    // If using a model with barberId property
    try {
      return appointment.barberId as int?;
    } catch (e) {
      return null;
    }
  }

  String _getAppointmentStatus(dynamic appointment) {
    if (appointment is Map) {
      return appointment['status'] ?? 'scheduled';
    }
    try {
      return appointment.status.toString().toLowerCase();
    } catch (e) {
      return 'scheduled';
    }
  }

  DateTime _getAppointmentStartTime(dynamic appointment) {
    if (appointment is Map) {
      final startTime = appointment['startTime'] ?? appointment['dateTime'];
      if (startTime is DateTime) return startTime;
      if (startTime is String) return DateTime.parse(startTime);
    }
    try {
      return appointment.startTime as DateTime;
    } catch (e) {
      return DateTime.now();
    }
  }

  DateTime _getAppointmentEndTime(dynamic appointment) {
    if (appointment is Map) {
      final endTime = appointment['endTime'];
      if (endTime is DateTime) return endTime;
      if (endTime is String) return DateTime.parse(endTime);
    }
    try {
      return appointment.endTime as DateTime;
    } catch (e) {
      return _getAppointmentStartTime(appointment).add(const Duration(hours: 1));
    }
  }

  List<String> _getAppointmentServices(dynamic appointment) {
    final List<String> services = [];

    if (appointment is Map) {
      final servicesData = appointment['services'];
      if (servicesData is List) {
        for (var service in servicesData) {
          if (service is Map) {
            services.add(service['name']?.toString() ?? 'Service');
          } else if (service is String) {
            services.add(service);
          }
        }
      }
      return services;
    }

    try {
      final servicesData = appointment.services;
      if (servicesData is List) {
        for (var service in servicesData) {
          if (service is String) {
            services.add(service);
          } else {
            services.add(service.toString());
          }
        }
      }
      return services;
    } catch (e) {
      return [];
    }
  }

  String _getAppointmentId(dynamic appointment) {
    if (appointment is Map) {
      return appointment['id']?.toString() ?? 'Unknown';
    }
    try {
      return appointment.id.toString();
    } catch (e) {
      return 'Unknown';
    }
  }

  int _getAppointmentShopId(dynamic appointment) {
    if (appointment is Map) {
      return appointment['shopId'] ?? appointment['shop'] ?? 0;
    }
    try {
      return appointment.shopId as int;
    } catch (e) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('appointment_history'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
          ),
        ],
      ),
      body: _buildBody(authProvider),
    );
  }

  Widget _buildBody(AuthProvider authProvider) {
    if (!authProvider.isAuthenticated) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Login Required',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please login to view your appointment history',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Appointments',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAppointments,
              child: Text('try_again'.tr()),
            ),
          ],
        ),
      );
    }

    if (_appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Appointments',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'You don\'t have any appointments yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAppointments,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _appointments.length,
        itemBuilder: (context, index) {
          final appointment = _appointments[index];
          return _buildAppointmentCard(appointment, authProvider);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(dynamic appointment, AuthProvider authProvider) {
    final status = _getAppointmentStatus(appointment);
    final startTime = _getAppointmentStartTime(appointment);
    final endTime = _getAppointmentEndTime(appointment);
    final services = _getAppointmentServices(appointment);
    final appointmentId = _getAppointmentId(appointment);
    final shopId = _getAppointmentShopId(appointment);
    final customerId = _getAppointmentCustomerId(appointment);
    final barberId = _getAppointmentBarberId(appointment);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Status and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatusChip(status),
                Text(
                  _formatDate(startTime),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Time
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  '${_formatTime(startTime)} - ${_formatTime(endTime)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Services
            if (services.isNotEmpty) ...[
              Text(
                'Services: ${services.join(', ')}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Role-specific information
            if (authProvider.isCustomer) ..._buildCustomerInfo(shopId, barberId),
            if (authProvider.isBarber || authProvider.isOwner) ..._buildStaffInfo(customerId, shopId),

            // Appointment ID
            Text(
              'ID: $appointmentId',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCustomerInfo(int shopId, int? barberId) {
    return [
      const Row(
        children: [
          Icon(Icons.store, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            'Shop Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        'Shop ID: $shopId',
        style: const TextStyle(fontSize: 14),
      ),
      if (barberId != null) ...[
        Text(
          'Barber ID: $barberId',
          style: const TextStyle(fontSize: 14),
        ),
      ],
      const SizedBox(height: 8),
    ];
  }

  List<Widget> _buildStaffInfo(int customerId, int shopId) {
    return [
      const Row(
        children: [
          Icon(Icons.person, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(
            'Customer Information',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        'Customer ID: $customerId',
        style: const TextStyle(fontSize: 14),
      ),
      Text(
        'Shop ID: $shopId',
        style: const TextStyle(fontSize: 14),
      ),
      const SizedBox(height: 8),
    ];
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'scheduled':
      case 'SCHEDULED':
        backgroundColor = Colors.blue[50]!;
        textColor = Colors.blue[800]!;
        statusText = 'Scheduled';
        break;
      case 'checked_in':
      case 'CHECKED_IN':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        statusText = 'Checked In';
        break;
      case 'pending':
      case 'PENDING':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        statusText = 'Pending';
        break;
      case 'completed':
      case 'COMPLETED':
        backgroundColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        statusText = 'Completed';
        break;
      case 'cancelled':
      case 'CANCELLED':
        backgroundColor = Colors.red[50]!;
        textColor = Colors.red[800]!;
        statusText = 'Cancelled';
        break;
      case 'no_show':
      case 'NO_SHOW':
        backgroundColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        statusText = 'No Show';
        break;
      default:
        backgroundColor = Colors.grey[50]!;
        textColor = Colors.grey[800]!;
        statusText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
