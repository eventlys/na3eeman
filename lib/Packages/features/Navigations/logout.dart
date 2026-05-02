import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class LogoutPage extends StatelessWidget {
  const LogoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("logout".tr())),
      body: Center(child: Text("logout_page_coming_soon".tr())),
    );
  }
}

