import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';

class SecurityPolicyOverlay extends StatelessWidget {
  const SecurityPolicyOverlay({super.key});

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
                  _buildSecurityFeature(
                    'Data Encryption',
                    Icons.lock,
                    'All data is encrypted in transit and at rest using industry-standard AES-256 encryption.',
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityFeature(
                    'Two-Factor Authentication',
                    Icons.enhanced_encryption,
                    'Enable 2FA for an extra layer of security on your account.',
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityFeature(
                    'Regular Security Audits',
                    Icons.security_update_good,
                    'We conduct regular security audits and penetration testing.',
                  ),
                  const SizedBox(height: 16),
                  _buildSecurityFeature(
                    'Secure Payment Processing',
                    Icons.payment,
                    'All payments are processed through PCI-DSS compliant providers.',
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Security Tips:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildSecurityTip('Use a strong, unique password'),
                  _buildSecurityTip('Enable two-factor authentication'),
                  _buildSecurityTip('Keep your app updated'),
                  _buildSecurityTip('Log out from shared devices'),
                  _buildSecurityTip('Be cautious of phishing attempts'),
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
                backgroundColor: Color(0xFF806C99),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Got It',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityFeature(
    String title,
    IconData icon,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Color(0xFF806C99), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.almostBlack.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTip(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF806C99), size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}
