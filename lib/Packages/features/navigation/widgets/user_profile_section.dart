import 'package:flutter/material.dart';
import '../sidebar_controller.dart';
import '../../../Models/olds/user_model.dart';
import '../../../Helpers/old/animations.dart';

class UserProfileSection extends StatelessWidget {
  final SidebarController controller;

  const UserProfileSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = User.getCurrentUser();

    return AnimatedBuilder(
      animation: controller.animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            -100 + (controller.animation.value * 100),
            0,
          ),
          child: Opacity(
            opacity: controller.animation.value,
            child: child,
          ),
        );
      },
      child: DelayedWidget(
        delay: const Duration(milliseconds: 50),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Profile Picture
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(user.profilePicture),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 16),
              // User Name
              Text(
                user.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

