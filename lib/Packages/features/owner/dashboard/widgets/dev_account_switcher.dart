import 'package:na3eeman/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/auth_provider.dart';
import 'package:na3eeman/Models/auth/user_model.dart';
import 'package:na3eeman/Models/auth/barber_profile.dart';
import 'package:na3eeman/Models/auth/owner_profile.dart';
import 'package:na3eeman/core/enums/owner_enums.dart';
import 'package:na3eeman/Services/enums/gender.dart';
import 'package:na3eeman/core/enums/app_enums.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../../Core/constants/app_roles.dart';

class DevAccountSwitcher extends StatelessWidget {
  const DevAccountSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showSwitcher(context),
      backgroundColor: Colors.redAccent,
      child: const Icon(Icons.developer_mode_rounded, color: Colors.white),
    );
  }

  void _showSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context)!.devAccountSwitcher, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 16),
            _buildOption(context, 'Male Salon Owner (Empire)', Gender.male, OwnerType.pureOwner, OwnerSubscriptionTier.empire),
            _buildOption(context, 'Female Salon Owner (Elite)', Gender.female, OwnerType.employeeOwner, OwnerSubscriptionTier.elite),
            _buildOption(context, 'Male Freelancer (Artisan)', Gender.male, OwnerType.soloFreelancer, OwnerSubscriptionTier.artisan),
            _buildOption(context, 'Female Studio Sync', Gender.female, OwnerType.employeeOwner, OwnerSubscriptionTier.studio),
            _buildOption(context, 'Expired Subscription', Gender.male, OwnerType.employeeOwner, OwnerSubscriptionTier.studio, expired: true),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, 
    String label, 
    Gender gender, 
    OwnerType type, 
    OwnerSubscriptionTier tier,
    {bool expired = false}
  ) {
    return ListTile(
      title: Text(label),
      leading: Icon(gender == Gender.male ? Icons.male : Icons.female, color: Colors.blue),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        _switchAccount(context, label, gender, type, tier, expired);
        Navigator.pop(context);
      },
    );
  }

  void _switchAccount(
    BuildContext context, 
    String label,
    Gender gender, 
    OwnerType type, 
    OwnerSubscriptionTier tier,
    bool expired
  ) {
    final authProvider = context.read<AuthProvider>();
    
    final user = User(
      id: 999,
      email: 'mock_${tier.name}@example.com',
      username: 'mock_owner',
      firstName: gender == Gender.male ? 'Ahmed' : 'Sarah',
      lastName: 'Wilson',
      role: UserRole.owner,
      gender: gender,
      location: 'Amman, Jordan',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final barber = BarberProfile(
      id: 999,
      barberId: 999,
      bio: 'Mock profile for testing',
      specialties: 'All',
      hasAccess: true,
      avgRating: 4.8,
    );

    final owner = OwnerProfile(
      id: 999,
      barberProfileId: 999,
      ownerType: type,
      isSubscribed: !expired,
      subscriptionTier: tier,
      subscriptionStartDate: DateTime.now().subtract(const Duration(days: 30)),
      subscriptionEndDate: expired 
          ? DateTime.now().subtract(const Duration(days: 1)) 
          : DateTime.now().add(const Duration(days: 30)),
    );

    authProvider.debugSetOwnerProfile(
      user: user,
      barberProfile: barber,
      ownerProfile: owner,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Switched to $label')),
    );
  }
}
