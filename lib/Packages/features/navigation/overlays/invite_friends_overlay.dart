import 'package:flutter/material.dart';

class InviteFriendsOverlay extends StatefulWidget {
  const InviteFriendsOverlay({super.key});

  @override
  State<InviteFriendsOverlay> createState() => _InviteFriendsOverlayState();
}

class _InviteFriendsOverlayState extends State<InviteFriendsOverlay> {
  final String inviteLink = 'https://yourapp.com/invite/ABC123XYZ';
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
            border: Border.all(color: Color(0x80c25858)),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.card_giftcard, color: Color(0x80c25858)),
                  SizedBox(width: 8),
                  Text(
                    'Invitation Rewards',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
            color: Color(0x4dffffff),
            border: Border.all(color: Color(0x80ffffff)),
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
                label: const Text('Share'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Your referral code: ABC123XYZ',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRewardItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
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


