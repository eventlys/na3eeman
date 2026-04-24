import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.logout)),
      body: Center(child: Text(AppLocalizations.of(context)!.logoutPageComingSoon)),
    );
  }
}

