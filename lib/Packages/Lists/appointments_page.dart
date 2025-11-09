import 'package:flutter/material.dart';
import '../../Models/appointment_model.dart';
import '../../Services/appointment_service.dart';
import '../../Theme/glass_appbar.dart';
import '../../Theme/sphere_neomorphic.dart';
import '../../features/Backgrounds/bd_faded.dart';
import '../widgets/appointment_accordion.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({Key? key}) : super(key: key);

  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage> {
  late Future<List<ShopAppointment>> _appointmentsFuture;
  bool _isLoading = false;

  bool _homeActive = false;
  bool _settingsActive = false;
  bool _profileActive = false;
  bool _infoActive = true;
  bool _searchActive = false;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = AppointmentService.fetchAppointments();
  }

  Future<void> _refreshAppointments() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _appointmentsFuture = AppointmentService.fetchAppointments();
      _isLoading = false;
    });
  }

  Widget _buildContent(List<ShopAppointment> appointments) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return AppointmentAccordion(
            appointment: appointments[index],
          );
        },
        childCount: appointments.length,
      ),
    );
  }

  Widget _buildLoading() {
    return const SliverFillRemaining(
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildError(String error) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading appointments',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshAppointments,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // FadedBackground covering the entire screen
        Positioned.fill(
          child: FadedBackground(
            startColor: Color(0x80806C99),
            endColor: const Color(0xFFDFA8A4),
          ),
        ),
        // Scaffold on top with transparent background
        Scaffold(
          backgroundColor: Colors.transparent,
          body: RefreshIndicator(
            onRefresh: _refreshAppointments,
            child: CustomScrollView(
              slivers: [
                GlassSliverAppBar(
                  title: 'My Appointments',
                  showBackButton: true,
                  textColor: Colors.white,
                  pinned: true,
                ),
                FutureBuilder<List<ShopAppointment>>(
                  future: _appointmentsFuture,
                  builder: (context, snapshot) {
                    if (_isLoading) {
                      return _buildLoading();
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoading();
                    }

                    if (snapshot.hasError) {
                      return _buildError(snapshot.error.toString());
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildEmpty();
                    }

                    return _buildContent(snapshot.data!);
                  },
                ),
              ],
            ),
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
                    navigationRoute: '/customer_home',
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
        )
      ],
    );
  }
}

