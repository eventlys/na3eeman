import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalDocsPage extends StatelessWidget {
  const LegalDocsPage({super.key});

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      debugPrint('Could not launch $urlString');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isRtl = context.locale.languageCode == 'ar';
    final String lang = isRtl ? 'ar' : 'en';
    final String baseUrl = 'https://legal.n3eemn.com/$lang';

    return Scaffold(
      appBar: AppBar(title: Text(isRtl ? 'الشروط والأحكام' : 'Legal & Terms')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildLinkTile(
            title: isRtl ? 'المركز القانوني (الرئيسية)' : 'Legal Center Home',
            icon: Icons.home_rounded,
            onTap: () => _launchUrl(baseUrl),
          ),
          const Divider(),
          _buildLinkTile(
            title: isRtl
                ? 'الشروط والأحكام للعملاء'
                : 'Customer Terms & Conditions',
            icon: Icons.description_rounded,
            onTap: () => _launchUrl('$baseUrl/customers/terms'),
          ),
          _buildLinkTile(
            title: isRtl
                ? 'الشروط والأحكام للبائعين'
                : 'Vendor Terms & Conditions',
            icon: Icons.store_rounded,
            onTap: () => _launchUrl('$baseUrl/vendors/terms'),
          ),
          const Divider(),
          _buildLinkTile(
            title: isRtl ? 'سياسة الخصوصية' : 'Privacy Policy',
            icon: Icons.privacy_tip_rounded,
            onTap: () => _launchUrl('$baseUrl/privacy'),
          ),
          _buildLinkTile(
            title: isRtl ? 'سياسة ملفات تعريف الارتباط' : 'Cookie Policy',
            icon: Icons.cookie_rounded,
            onTap: () => _launchUrl('$baseUrl/cookies'),
          ),
          _buildLinkTile(
            title: isRtl ? 'سياسة الاسترداد والإلغاء' : 'Refund & Cancellation',
            icon: Icons.money_off_rounded,
            onTap: () => _launchUrl('$baseUrl/refunds'),
          ),
          _buildLinkTile(
            title: isRtl ? 'سياسة الاستخدام المقبول' : 'Acceptable Use Policy',
            icon: Icons.rule_rounded,
            onTap: () => _launchUrl('$baseUrl/acceptable-use'),
          ),
        ],
      ),
    );
  }

  Widget _buildLinkTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.open_in_new_rounded, size: 16),
      onTap: onTap,
    );
  }
}
