import 'package:flutter/material.dart';

import '../../constants/app_color.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: AppColor.primary,
    );
  }
}
