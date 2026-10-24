import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('admin_home'.tr())),
      body: Center(child: Text('welcome_admin'.tr())),
    );
  }
}
