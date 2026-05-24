import 'package:flutter/material.dart';

class AppRulesOverlay extends StatelessWidget {
  const AppRulesOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                  _buildRuleCategory('User Conduct', Icons.person, [
                    'Be respectful to other users',
                    'No harassment or hate speech',
                    'No spamming or flooding',
                    'No impersonation of others',
                    'Respect privacy of other users',
                  ]),
                  const SizedBox(height: 20),
                  _buildRuleCategory('Content Guidelines', Icons.content_copy, [
                    'No illegal content',
                    'No explicit or adult content',
                    'No copyrighted material without permission',
                    'No false or misleading information',
                    'No commercial spam',
                  ]),
                  const SizedBox(height: 20),
                  _buildRuleCategory('Account Usage', Icons.account_circle, [
                    'One account per person',
                    'You are responsible for your account',
                    'No sharing of account credentials',
                    'Report lost or stolen accounts immediately',
                    'Accounts must not be bought or sold',
                  ]),
                  const SizedBox(height: 20),
                  _buildRuleCategory('Prohibited Activities', Icons.warning, [
                    'No hacking or exploiting vulnerabilities',
                    'No automated bots or scripts',
                    'No reverse engineering',
                    'No data scraping',
                    'No unauthorized commercial use',
                  ]),
                  const SizedBox(height: 20),
                  _buildConsequencesSection(),
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
                backgroundColor: Color(0x80ffffff),
                side: BorderSide(color: Color(0x80c25858)),
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'I Agree',
                style: TextStyle(fontSize: 16, color: Color(0xffc25858)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleCategory(String title, IconData icon, List<String> rules) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Color(0x80c25858), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xffc25858),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...rules.map((rule) => _buildRuleItem(rule)),
      ],
    );
  }

  Widget _buildRuleItem(String rule) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(rule, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildConsequencesSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0x4dffffff),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0x80ffffff)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Violation Consequences:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildConsequenceItem('Warning and content removal'),
          _buildConsequenceItem('Temporary suspension'),
          _buildConsequenceItem('Permanent account ban'),
          _buildConsequenceItem('Legal action for severe violations'),
        ],
      ),
    );
  }

  Widget _buildConsequenceItem(String consequence) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.red, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              consequence,
              style: const TextStyle(fontSize: 12, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
