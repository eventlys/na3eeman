import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../Helpers/config.dart';

// import 'package:easy_localization/easy_localization.dart';

class InviteFriendsOverlay extends StatefulWidget {
  const InviteFriendsOverlay({super.key});

  @override
  State<InviteFriendsOverlay> createState() => _InviteFriendsOverlayState();
}

class _InviteFriendsOverlayState extends State<InviteFriendsOverlay> {
  // TODO: invite code should come from the backend per-user; using webAppUrl base.
  String get inviteLink => '${AppConfig.webAppUrl}/invite/';
  bool _copied = false;

  void _copyToClipboard() {
    // Implement clipboard functionality
    setState(() {
      _copied = true;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _copied = false;
        });
      }
    });
  }

  void _shareLink() {
    // Implement share functionality
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // const Divider(),
        const SizedBox(height: 10),
        const Text(
          'Share with your friends and earn rewards!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.pink.withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    color: AppColors.pink.withValues(alpha: 0.5),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Invitation Rewards',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildRewardItem('You get:', '50 points per friend'),
              _buildRewardItem('Friend gets:', '100 bonus points'),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.3),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.5)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  inviteLink,
                  style: const TextStyle(fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  _copied ? Icons.check : Icons.copy,
                  color: _copied ? Colors.green : Colors.grey,
                ),
                onPressed: _copyToClipboard,
                iconSize: 20,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (_copied)
          const Text(
            'Copied to clipboard!',
            style: TextStyle(color: Colors.green, fontSize: 12),
          ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _shareLink,
                icon: const Icon(Icons.share, size: 18, color: Colors.black),
                label: Text("share".tr()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Your referral code: ABC123XYZ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRewardItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
