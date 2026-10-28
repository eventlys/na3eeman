import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/themes/app_scaffold.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../widgets/appointment_accordion.dart';

// import 'package:easy_localization/easy_localization.dart';

class AppointmentsPage extends StatefulWidget {
  const AppointmentsPage({super.key});

  @override
  AppointmentsPageState createState() => AppointmentsPageState();
}

class AppointmentsPageState extends State<AppointmentsPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAppointments();
    });
  }

  Future<void> _loadAppointments() async {
    final provider = Provider.of<AppointmentProvider>(context, listen: false);
    if (!provider.isLoading) {
      await provider.loadAppointments();
    }
  }

  Future<void> _refreshAppointments() async {
    await _loadAppointments();
  }

  String _getUserGender(dynamic user) {
    if (user == null) return 'male';

    // Handle different user object types
    if (user is String) {
      return user.toLowerCase();
    } else if (user is Map) {
      final gender = user['gender']?.toString().toLowerCase() ?? 'male';
      return gender;
    } else {
      // If user has a gender property, try to access it
      try {
        final gender = user.gender?.toString().toLowerCase() ?? 'male';
        return gender;
      } catch (e) {
        return 'male';
      }
    }
  }

  Color _getBackgroundColor(BuildContext context, String gender) {
    final brightness = Theme.of(context).brightness;

    if (brightness == Brightness.dark) {
      switch (gender.toLowerCase()) {
        case 'male':
          return AppColor.darkMaleBackground;
        case 'female':
          return AppColor.darkFemaleBackground;
        case 'non-binary':
          return AppColor.darkNonBinaryBackground;
        default:
          return AppColor.darkBackground;
      }
    } else {
      switch (gender.toLowerCase()) {
        case 'male':
          return AppColor.maleBackground;
        case 'female':
          return AppColor.femaleBackground;
        case 'non-binary':
          return AppColor.nonBinaryBackground;
        default:
          return AppColor.lightBackground;
      }
    }
  }

  Color _getAccentColor(BuildContext context, String gender) {
    final brightness = Theme.of(context).brightness;

    if (brightness == Brightness.dark) {
      switch (gender.toLowerCase()) {
        case 'male':
          return AppColor.darkMaleBG;
        case 'female':
          return AppColor.darkFemaleBG;
        case 'non-binary':
          return AppColor.darkNonBinaryBG;
        default:
          return AppColor.darkPrimary;
      }
    } else {
      switch (gender.toLowerCase()) {
        case 'male':
          return AppColor.maleAccent;
        case 'female':
          return AppColor.femaleAccent;
        case 'non-binary':
          return AppColor.nonBinaryAccent;
        default:
          return AppColor.primary;
      }
    }
  }

  Color _getTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColor.darkText
        : AppColor.lightText;
  }

  Color _getTextSecondaryColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColor.darkTextSecondary
        : AppColor.lightTextSecondary;
  }

  Color _getLoadingColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColor.loadingPrimaryDark
        : AppColor.loadingPrimaryLight;
  }

  Color _getErrorColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColor.darkError
        : AppColor.lightError;
  }

  Color _getIconColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppColor.darkTextSecondary
        : AppColor.lightTextSecondary;
  }

  String _getErrorIcon(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppImages.error_view
        : AppImages.error;
  }

  String _getCalendarIcon(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? AppImages.calender_view
        : AppImages.calender;
  }

  Widget _buildContent(List<dynamic> appointments, String userGender) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return FadeSlideIn(
          index: index,
          interval: const Duration(milliseconds: 60),
          child: AppointmentAccordion(appointment: appointments[index]),
        );
      }, childCount: appointments.length),
    );
  }

  Widget _buildLoading(BuildContext context, String userGender) {
    return SliverFillRemaining(
      child: Container(
        color: _getBackgroundColor(context, userGender),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              _getLoadingColor(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(String error, BuildContext context, String userGender) {
    return SliverFillRemaining(
      child: Container(
        color: _getBackgroundColor(context, userGender),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _getErrorIcon(context),
                width: 64,
                height: 64,
                color: _getErrorColor(context),
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading appointments',
                style: TextStyle(color: _getTextColor(context), fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshAppointments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getAccentColor(context, userGender),
                  foregroundColor: Colors.white,
                ),
                child: Text("try_again".tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, String userGender) {
    return SliverFillRemaining(
      child: Container(
        color: _getBackgroundColor(context, userGender),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                _getCalendarIcon(context),
                width: 64,
                height: 64,
                color: _getIconColor(context),
              ),
              const SizedBox(height: 16),
              Text(
                'No appointments found',
                style: TextStyle(
                  color: _getTextSecondaryColor(context),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSliverContent(
    AppointmentProvider provider,
    BuildContext context,
    String userGender,
  ) {
    if (provider.isLoading) {
      return [_buildLoading(context, userGender)];
    }

    if (provider.hasError) {
      return [_buildError(provider.error!, context, userGender)];
    }

    final appointments = provider.myAppointments;

    if (appointments.isEmpty) {
      return [_buildEmpty(context, userGender)];
    }

    return [_buildContent(appointments, userGender)];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        final userGender = _getUserGender(user);

        return GlassPage(
          title: 'My Appointments',
          showBackButton: true,
          user: user,
          glassTextColor: _getTextColor(context),
          glassPinned: true,
          slivers: _buildSliverContent(provider, context, userGender),
          child: const SizedBox.shrink(),
        );
      },
    );
  }
}
