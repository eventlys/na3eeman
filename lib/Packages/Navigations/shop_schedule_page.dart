import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Models/points_model.dart';
import '../../Models/service_selection_model.dart';
// import '../../Models/shop_schedule_model.dart';
import '../../Models/shop_service_model.dart';
import '../../Providers/points_provider.dart';
// import '../../Services/schedule_helper.dart';
import '../../Theme/glass_appbar.dart';
import '../../Theme/sphere_neomorphic.dart';
import '../../features/Backgrounds/bd_faded.dart';
import '../Widgets/date_time_pickers.dart';
import '../Widgets/service_details_section.dart';


class ShopSchedulePage extends StatefulWidget {
  final ShopService shopService;

  const ShopSchedulePage({
    super.key,
    required this.shopService,
  });

  @override
  ShopSchedulePageState createState() => ShopSchedulePageState();
}

class ShopSchedulePageState extends State<ShopSchedulePage> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  late ServiceSelection _serviceSelection;

  bool _homeActive = false;
  bool _settingsActive = false;
  bool _profileActive = false;
  bool _infoActive = false;
  bool _searchActive = false;

  final List<ShopService> _availableAdditionalServices = [
    ShopService(name: 'Hair Cream', price: '\$8', duration: '10 min'),
    ShopService(name: 'Face Scrub', price: '\$12', duration: '15 min'),
    ShopService(name: 'Hair Wash', price: '\$10', duration: '15 min'),
    ShopService(name: 'Beard Styling', price: '\$8', duration: '10 min'),
    ShopService(name: 'Head Massage', price: '\$15', duration: '20 min'),
  ];

  @override
  void initState() {
    super.initState();
    _serviceSelection = ServiceSelection(mainService: widget.shopService);
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

  void _toggleService(ShopService service) {
    setState(() {
      if (_serviceSelection.containsService(service)) {
        _serviceSelection = _serviceSelection.removeService(service);
      } else {
        _serviceSelection = _serviceSelection.addService(service);
      }
      // Reset date and time when services change
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  // void _confirmSchedule() {
  //   if (_selectedDate == null || _selectedTime == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Please select both date and time'),
  //         backgroundColor: Colors.red,
  //       ),
  //     );
  //     return;
  //   }
  //
  //   final scheduleSlot = ShopScheduleSlot(
  //     date: _selectedDate!,
  //     time: _selectedTime!,
  //     shopService: widget.shopService,
  //   );
  //
  //   ScheduleHelper.bookSchedule(scheduleSlot).then((_) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('Schedule booked successfully!'),
  //         backgroundColor: Colors.green,
  //       ),
  //     );
  //     Navigator.pop(context);
  //   });
  // }

  void _showScheduleTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xffffffff),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Color(0xFFFFFFFF),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Color(0xffc25858)),
                      const SizedBox(width: 8),
                      Text(
                        'Schedule Type',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffc25858),
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
                        title: 'One Time Only',
                        subtitle: 'Schedule this appointment once',
                        icon: Icons.event,
                        onTap: () {
                          Navigator.of(context).pop();
                          _confirmSchedule('one_time');
                          Provider.of<PointsProvider>(context, listen: false)
                            .addPoints(PointsType.makeAppointment);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildScheduleOption(
                        context,
                        title: 'Bi-Weekly',
                        subtitle: 'Repeat every 2 weeks',
                        icon: Icons.repeat,
                        onTap: () {
                          Navigator.of(context).pop();
                          _confirmSchedule('bi_weekly');
                          Provider.of<PointsProvider>(context, listen: false)
                            .addPoints(PointsType.makeAppointment);
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildScheduleOption(
                        context,
                        title: 'Monthly',
                        subtitle: 'Repeat every month',
                        icon: Icons.calendar_month,
                        onTap: () {
                          Navigator.of(context).pop();
                          _confirmSchedule('monthly');
                          Provider.of<PointsProvider>(context, listen: false)
                            .addPoints(PointsType.makeAppointment);
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
                      border: Border.all(
                        color: Color(0xffc25858),
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color(0xffc25858),
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

  Widget _buildScheduleOption(BuildContext context, {
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
          color: Color(0x26c25858),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xffc25858)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Color(0xffc25858), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Color(0xff040000),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Color(0xff040000).withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Icon(Icons.chevron_right, color: Color(0xffc25858)),
          ],
        ),
      ),
    );
  }

  void _confirmSchedule(String scheduleType) {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both date and time'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Your schedule confirmation logic here with scheduleType
    print('Schedule confirmed: $scheduleType for ${_serviceSelection.allServices.length} services');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$scheduleType schedule booked successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadedBackground(
      startColor: Color(0xff806C99),
      endColor: const Color(0xFFDFA8A4),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          slivers: [
            GlassSliverAppBar(
              title: 'Book a haircut',
              // backgroundColor: Colors.transparent,
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Service Information
                        ServiceDetailsSection(
                          serviceSelection: _serviceSelection,
                          onServiceToggled: _toggleService,
                          availableAdditionalServices: _availableAdditionalServices,
                        ),
                        SizedBox(height: 24),

                        // Date Picker
                        ScheduleDatePicker(
                          selectedDate: _selectedDate,
                          onDateSelected: _selectDate,
                        ),
                        SizedBox(height: 16),

                        // Time Picker
                        ScheduleTimePicker(
                          selectedDate: _selectedDate,
                          selectedTime: _selectedTime,
                          onTimeSelected: _selectTime,
                        ),
                        SizedBox(height: 32),

                        // Confirm Button
                        Center(
                          child: ElevatedButton(
                            onPressed: () => _showScheduleTypeDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                            ),
                            child: Text(
                              'Confirm Schedule',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFC25858),
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
                NeomorphicSphere(
                  activeIconPath: 'assets/icons/home_view.png',
                  inactiveIconPath: 'assets/icons/home_front.png',
                  size: 80,
                  navigationRoute: '/home',
                  isActive: _homeActive,
                  onTap: () {
                    print('Home sphere tapped');
                    setState(() {
                      _homeActive = true;
                      _settingsActive = false;
                      _profileActive = false;
                      _infoActive = false;
                      _searchActive = false;
                    });
                  },
                  onActiveChanged: (active) {
                    if (active) {
                      setState(() {
                        _homeActive = true;
                        _settingsActive = false;
                        _profileActive = false;
                        _infoActive = false;
                        _searchActive = false;
                      });
                    }
                  },
                ),
                NeomorphicSphere(
                  activeIconPath: 'assets/icons/flash_view.png',
                  inactiveIconPath: 'assets/icons/flash.png',
                  size: 80,
                  navigationRoute: '/settings',
                  isActive: _settingsActive,
                  onTap: () {
                    print('Settings sphere tapped');
                    setState(() {
                      _homeActive = false;
                      _settingsActive = true;
                      _profileActive = false;
                      _infoActive = false;
                      _searchActive = false;
                    });
                  },
                  onActiveChanged: (active) {
                    if (active) {
                      setState(() {
                        _homeActive = false;
                        _settingsActive = true;
                        _profileActive = false;
                        _infoActive = false;
                        _searchActive = false;
                      });
                    }
                  },
                ),
                NeomorphicSphere(
                  activeIconPath: 'assets/icons/fire_view.png',
                  inactiveIconPath: 'assets/icons/fire.png',
                  size: 80,
                  navigationRoute: '/profile',
                  isActive: _profileActive,
                  onTap: () {
                    print('Profile sphere tapped');
                    setState(() {
                      _homeActive = false;
                      _settingsActive = false;
                      _profileActive = true;
                      _infoActive = false;
                      _searchActive = false;
                    });
                  },
                  onActiveChanged: (active) {
                    if (active) {
                      setState(() {
                        _homeActive = false;
                        _settingsActive = false;
                        _profileActive = true;
                        _infoActive = false;
                        _searchActive = false;
                      });
                    }
                  },
                ),
                NeomorphicSphere(
                  activeIconPath: 'assets/icons/clock_view.png',
                  inactiveIconPath: 'assets/icons/clock.png',
                  size: 80,
                  isActive: _infoActive,
                  onTap: () {
                    Navigator.pushNamed(context, '/appointments');
                    setState(() {
                      _homeActive = false;
                      _settingsActive = false;
                      _profileActive = false;
                      _infoActive = true;
                      _searchActive = false;
                    });
                  },
                  onActiveChanged: (active) {
                    if (active) {
                      setState(() {
                        _homeActive = false;
                        _settingsActive = false;
                        _profileActive = false;
                        _infoActive = true;
                        _searchActive = false;
                      });
                    }
                  },
                ),
                NeomorphicSphere(
                  activeIconPath: 'assets/icons/avatar_male_view.png',
                  inactiveIconPath: 'assets/icons/avatar_male.png',
                  size: 80,
                  isActive: _searchActive,
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                    setState(() {
                      _homeActive = false;
                      _settingsActive = false;
                      _profileActive = false;
                      _infoActive = false;
                      _searchActive = true;
                    });
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

