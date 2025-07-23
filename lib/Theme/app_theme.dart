import 'package:flutter/material.dart';

class AppTheme {
// * status Mode
  static bool getTheme({required BuildContext context}) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}