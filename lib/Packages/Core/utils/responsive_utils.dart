import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double _mobileBreakpoint = 600;
  static const double _tabletBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < _mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= _mobileBreakpoint && width < _tabletBreakpoint;
  }

  // static bool isDesktop(BuildContext context) {
  //   return MediaQuery.of(context).size.width >= _tabletBreakpoint;
  // }

  static double responsiveValue({
    required BuildContext context,
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static int responsiveGridCount({
    required BuildContext context,
    int mobile = 1,
    int tablet = 2,
    int desktop = 4,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static EdgeInsets responsivePadding({
    required BuildContext context,
    EdgeInsets mobile = const EdgeInsets.all(16),
    EdgeInsets tablet = const EdgeInsets.all(24),
    EdgeInsets desktop = const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  static double responsiveFontSize({
    required BuildContext context,
    required double baseSize,
  }) {
    final width = MediaQuery.of(context).size.width;
    final scale = width / 360; // Base width for mobile

    if (scale > 1.5) return baseSize * 1.5;
    if (scale > 1.2) return baseSize * 1.2;
    return baseSize;
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveUtils._tabletBreakpoint) {
          return desktop;
        } else if (constraints.maxWidth >= ResponsiveUtils._mobileBreakpoint) {
          return tablet;
        } else {
          return mobile;
        }
      },
    );
  }
}

class AdaptiveColumn extends StatelessWidget {
  final List<Widget> children;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;

  const AdaptiveColumn({
    super.key,
    required this.children,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        children: children,
      ),
      tablet: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
              mainAxisAlignment: mainAxisAlignment,
              children: children.sublist(0, (children.length / 2).ceil()),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: crossAxisAlignment,
              mainAxisAlignment: mainAxisAlignment,
              children: children.sublist((children.length / 2).ceil()),
            ),
          ),
        ],
      ),
      desktop: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < children.length; i++) ...[
            Expanded(child: children[i]),
            if (i < children.length - 1) const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }
}
