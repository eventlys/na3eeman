import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../Providers/main_providers.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/buttons/styled_buttons.dart';
import '../../../../Services/ui/overlay_service.dart';
import '../../../../Services/ui/navigation_service.dart';
import '../../../features/shop/widgets/services_section.dart';

class BookAppointmentPage extends StatefulWidget {
  const BookAppointmentPage({super.key});

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  Map<String, dynamic>? shopData;
  List<Map<String, dynamic>> _selectedServices = [];
  final Set<String> _selectedServiceNames = {};
  
  Map<String, dynamic>? _selectedBarber;
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        shopData = args['shopData'];
        _selectedServices = List<Map<String, dynamic>>.from(args['selectedServices'] ?? []);
        _selectedServiceNames.addAll(_selectedServices.map((e) => (e['name'] ?? e['serviceName'] ?? '').toString()));
      }
      _initialized = true;
    }
  }

  void _toggleService(Map<String, dynamic> service) {
    setState(() {
      final name = service['name'] ?? service['serviceName'] ?? 'Service';
      if (_selectedServiceNames.contains(name)) {
        _selectedServiceNames.remove(name);
        _selectedServices.removeWhere((s) => (s['name'] ?? s['serviceName'] ?? 'Service') == name);
      } else {
        _selectedServiceNames.add(name);
        _selectedServices.add(service);
      }
      _selectedTime = null; // Reset time if duration changes
    });
  }

  double _calculateTotalCost() {
    return _selectedServices.fold(0.0, (sum, service) {
      final priceStr = (service['price'] ?? '0').toString().replaceAll(RegExp(r'[^0-9.]'), '');
      return sum + (double.tryParse(priceStr) ?? 0.0);
    });
  }

  int _calculateTotalDuration() {
    return _selectedServices.fold(0, (sum, service) {
      final durationStr = (service['duration'] ?? '30').toString().replaceAll(RegExp(r'[^0-9]'), '');
      return sum + (int.tryParse(durationStr) ?? 30);
    });
  }

  List<String> _generateTimeSlots() {
    // Dummy logic for generating time slots
    if (_selectedBarber == null) return [];
    
    final slots = <String>[];
    final startHour = 9; // 9 AM
    final endHour = 20; // 8 PM
    final durationFormat = _calculateTotalDuration() > 0 ? _calculateTotalDuration() : 30;
    
    for (int hour = startHour; hour < endHour; hour++) {
      for (int minute = 0; minute < 60; minute += durationFormat) {
        if (minute >= 60) break;
        final timeString = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
        // Randomly skip some slots to simulate unavailability 
        if ((hour + minute) % 3 != 0) {
          slots.add(timeString);
        }
      }
    }
    return slots;
  }

  void _handleConfirmBooking() {
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one service.')));
      return;
    }
    if (_selectedBarber == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a barber.')));
      return;
    }
    if (_selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a time slot.')));
      return;
    }

    final totalAmount = _calculateTotalCost();
    
    try {
      OverlayService.showPayment(
        amount: totalAmount,
        appointmentId: 'NEW_APT_${DateTime.now().millisecondsSinceEpoch}',
        onPaymentSuccess: (receipt) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment Successful! Appointment Confirmed.')));
          Navigator.of(context).popUntil((route) => route.isFirst);
          NavigationService.navigateToHomeBasedOnRole(context, 'CUSTOMER');
        },
        onPaymentFailure: (error) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Failed: $error')));
        },
      );
    } catch (e) {
      // Fallback simple dialog if OverlayService isn't fully configured
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Options'),
          content: Text('Total Amount: \$${totalAmount.toStringAsFixed(2)}\n\nSelect your payment method:'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _completeBooking('Cash');
              },
              child: const Text('Cash'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _completeBooking('CliQ');
              },
              child: const Text('CliQ / Card'),
            ),
           ],
        )
      );
    }
  }

  void _completeBooking(String method) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking Confirmed ($method)!')));
      Navigator.of(context).popUntil((route) => route.isFirst);
      NavigationService.navigateToHomeBasedOnRole(context, 'CUSTOMER');
  }

  @override
  Widget build(BuildContext context) {
    final barberProvider = context.watch<BarberProvider>();
    final barbers = barberProvider.barbers;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        centerTitle: true,
      ),
      body: shopData == null 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // Services Review
              Text(
                '1. Select Services',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 16),
              ServicesSection(
                selectedServiceNames: _selectedServiceNames,
                onToggleService: _toggleService,
                services: shopData!['services'] != null
                    ? List<Map<String, dynamic>>.from(shopData!['services'])
                    : [
                        {'name': 'Classic Haircut', 'price': '15.00', 'duration': '30 min'},
                        {'name': 'Beard Grooming', 'price': '10.00', 'duration': '20 min'},
                        {'name': 'Premium Shave', 'price': '20.00', 'duration': '40 min'},
                      ],
              ),
              const SizedBox(height: 24),
              
              // Totals 
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.almostBlack600 : Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Duration', style: TextStyle(color: Colors.grey)),
                        Text('${_calculateTotalDuration()} mins', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Cost', style: TextStyle(color: Colors.grey)),
                        Text('\$${_calculateTotalCost().toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Staff Selection 
              Text(
                '2. Choose a Barber',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 16),
              barberProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: barbers.length > 0 ? barbers.length : 3, // Fallback dummy
                      itemBuilder: (context, index) {
                        final barber = barbers.length > 0 ? barbers[index].toJson() : {'id': index, 'first_name': 'Barber ${index+1}', 'last_name': ''};
                        final isSelected = _selectedBarber != null && _selectedBarber!['id'] == barber['id'];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBarber = barber;
                              _selectedTime = null; // Reset time slot on new barber
                            });
                          },
                          child: Container(
                            width: 80,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? Theme.of(context).primaryColor : (isDark ? AppColors.almostBlack600 : Colors.white),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected ? Colors.white24 : AppColors.almostBlack50,
                                  child: Icon(Icons.person, color: isSelected ? Colors.white : Theme.of(context).primaryColor),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  barber['first_name'] ?? 'Barber',
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

              const SizedBox(height: 32),

              // Calendar Date Picker
              Text(
                '3. Pick a Date & Time',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(height: 16),
              
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                      _selectedTime = null;
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      Text(DateFormat('EEEE, MMM d, yyyy').format(_selectedDate), style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              
              // Time Slots Planner
              if (_selectedBarber != null) ...[
                const Text('Available Time Slots:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (_generateTimeSlots().isEmpty)
                   const Text('No slots available for this date.', style: TextStyle(color: Colors.red))
                else 
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _generateTimeSlots().map((slot) {
                      final isSelected = _selectedTime == slot;
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTime = slot;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Theme.of(context).primaryColor : (isDark ? AppColors.almostBlack600 : Colors.white),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.3)),
                          ),
                          child: Text(
                            slot,
                            style: TextStyle(
                              color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ] else ...[
                 const Center(child: Text('Select a barber to see available times.', style: TextStyle(color: Colors.grey))),
              ],

              const SizedBox(height: 48),
            ],
          ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: PrimaryButton(
            text: 'Confirm & Pay',
            onPressed: _handleConfirmBooking,
          ),
        ),
      ),
    );
  }
}
