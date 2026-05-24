import 'package:flutter/material.dart';

class PrivacyPolicyOverlay extends StatelessWidget {
  const PrivacyPolicyOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 500),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPolicySection('Information We Collect', '''
• Personal Information: Name, email, phone number
• Usage Data: App interactions, preferences
• Device Information: Device type, operating system
• Location Data: With your permission
                      '''),
                  const SizedBox(height: 20),
                  _buildPolicySection('How We Use Your Information', '''
• Provide and maintain our services
• Improve user experience
• Communicate with you
• Ensure security and prevent fraud
• Comply with legal obligations
                      '''),
                  const SizedBox(height: 20),
                  _buildPolicySection('Data Sharing', '''
We do not sell your personal data. We may share information with:
• Service providers who assist our operations
• Legal authorities when required by law
• Business partners with your consent
                      '''),
                  const SizedBox(height: 20),
                  _buildPolicySection('Your Rights', '''
• Access your personal data
• Correct inaccurate data
• Delete your data
• Object to processing
• Data portability
• Withdraw consent
                      '''),
                  const SizedBox(height: 20),
                  _buildPolicySection('Contact Us', '''
For privacy-related questions, contact our Data Protection Officer at:
privacy@yourapp.com
                      '''),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xffc25858),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'I Understand',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xffc25858),
          ),
        ),
        const SizedBox(height: 8),
        Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
      ],
    );
  }
}
