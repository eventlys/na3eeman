import 'dart:ui';

import 'package:flutter/material.dart';
import '../../Models/user_model.dart';
import '../Navigations/navigation_config.dart';
import 'neomorphic_sphere.dart';

class CustomNavigationBar extends StatefulWidget {
  final User user;
  final String currentRoute;

  const CustomNavigationBar({
    super.key,
    required this.user,
    required this.currentRoute,
  });

  @override
  _CustomNavigationBarState createState() => _CustomNavigationBarState();
}

class _CustomNavigationBarState extends State<CustomNavigationBar> {
  String? _lastTappedId;
  bool _shouldAnimate = true;

  void _handleSphereTap(String itemId, String route) {
    setState(() {
      _lastTappedId = itemId;
      _shouldAnimate = true;
    });

    // Navigate to the route if we're not already there
    if (ModalRoute.of(context)?.settings.name != route) {
      Navigator.pushNamed(context, route);
    }
  }

  Widget _buildFrostedContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0x80806C99),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navItems = NavigationConfig.getNavItems(widget.user, widget.currentRoute);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: _buildFrostedContainer(
        Container(
          height: 90,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0x4dC25858),
                blurRadius: 10,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: navItems.map((item) {
              final isActive = NavigationConfig.isItemActive(item, widget.currentRoute, widget.user);
              final shouldAnimateForThisItem = _shouldAnimate && _lastTappedId == item.id;

              return NeomorphicSphere(
                activeIconPath: item.activeIconPath,
                inactiveIconPath: item.inactiveIconPath,
                size: 80,
                isActive: isActive,
                shouldAnimate: shouldAnimateForThisItem,
                onTap: () => _handleSphereTap(item.id, item.route),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

