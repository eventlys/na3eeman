import 'package:flutter/material.dart';
import '../../Models/salon_extensions.dart';
import '../../Services/translation_service.dart';

/// Spa Package Card for Men's Spas and Turkish Baths
/// Displays multi-service spa packages with savings
class SpaPackageCard extends StatelessWidget {
  final SpaPackage package;
  final String language;
  final VoidCallback onTap;

  const SpaPackageCard({
    super.key,
    required this.package,
    this.language = 'ar',
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: language == 'ar'
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Featured badge
              if (package.isFeatured)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade400, Colors.orange.shade400],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (language != 'ar') ...[
                        Icon(Icons.star, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                      ],
                      Text(
                        language == 'ar' ? 'مميز' : 'Featured',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (language == 'ar') ...[
                        SizedBox(width: 6),
                        Icon(Icons.star, size: 16, color: Colors.white),
                      ],
                    ],
                  ),
                ),

              // Package name
              Row(
                children: [
                  Expanded(
                    child: Text(
                      language == 'ar' ? package.nameArabic : package.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  // Package type badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      package.getPackageTypeDisplay(language),
                      style: TextStyle(
                        color: _getTypeColor(),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              // Description
              if (package.descriptionArabic.isNotEmpty ||
                  package.description.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    language == 'ar'
                        ? package.descriptionArabic
                        : package.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),

              SizedBox(height: 12),

              // Duration
              Row(
                children: [
                  if (language != 'ar')
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.blueGrey.shade700,
                    ),
                  if (language != 'ar') SizedBox(width: 6),
                  Text(
                    TranslationService.formatDuration(
                      package.totalDuration,
                      language,
                    ),
                    style: TextStyle(
                      color: Colors.blueGrey.shade700,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (language == 'ar') SizedBox(width: 6),
                  if (language == 'ar')
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.blueGrey.shade700,
                    ),
                ],
              ),

              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),

              // Services list
              Column(
                children: package.items.map((item) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (language != 'ar') ...[
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: Colors.green.shade600,
                          ),
                          SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Text(
                            '${language == 'ar' ? item.serviceNameArabic : item.serviceName} (${item.durationMinutes} ${TranslationService.translate('minutes', language)})',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        if (language == 'ar') ...[
                          SizedBox(width: 12),
                          Icon(
                            Icons.check_circle,
                            size: 20,
                            color: Colors.green.shade600,
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),

              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 12),

              // Pricing with savings
              Column(
                children: [
                  // Show savings if available
                  if (package.savingsJod != null && package.savingsJod! > 0)
                    Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (language != 'ar')
                            Icon(
                              Icons.savings,
                              size: 18,
                              color: Colors.green.shade700,
                            ),
                          if (language != 'ar') SizedBox(width: 6),
                          Text(
                            '${language == 'ar' ? 'توفير' : 'Save'} ${TranslationService.formatCurrency(package.savingsJod!, language)}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          if (language == 'ar') SizedBox(width: 6),
                          if (language == 'ar')
                            Icon(
                              Icons.savings,
                              size: 18,
                              color: Colors.green.shade700,
                            ),
                        ],
                      ),
                    ),

                  // Book button and price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (language != 'ar')
                        ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            TranslationService.translate('book_now', language),
                          ),
                        ),
                      Text(
                        TranslationService.formatCurrency(
                          package.price,
                          language,
                        ),
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      if (language == 'ar')
                        ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            TranslationService.translate('book_now', language),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor() {
    switch (package.packageType) {
      case 'TRADITIONAL':
        return Colors.brown.shade700;
      case 'MODERN':
        return Colors.blue.shade700;
      case 'LUXURY':
        return Colors.purple.shade700;
      case 'ATHLETIC':
        return Colors.orange.shade700;
      case 'RELAXATION':
        return Colors.teal.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
