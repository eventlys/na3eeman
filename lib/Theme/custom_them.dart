

import 'package:flutter/material.dart';
import 'package:na3eeman/Theme/app_color.dart';

class CustomTheme {
  // * * * * * * * * * * * * *** Light *** * * * * * * * * * * * *
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    appBarTheme: AppBarTheme(
      color: AppColor.white,
      iconTheme: IconThemeData(color: AppColor.white, size: 35),
      centerTitle: true,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: AppColor.white,
    ),
  );

  // * * * * * * * * * * * * *** Dark *** * * * * * * * * * * * *
  static final ThemeData darkTheme = ThemeData.dark().copyWith(
    appBarTheme: AppBarTheme(
      color: AppColor.white,
      iconTheme: IconThemeData(color: AppColor.white, size: 35),
      centerTitle: true,
    ),
  );
}
