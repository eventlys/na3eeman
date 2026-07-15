import 'package:flutter/material.dart';
import '../../Models/salon_extensions.dart';
import '../../Services/translation_service.dart';

/// Service Chain Card for Female Salons
/// Displays wedding/event packages with service sequences
class ServiceChainCard extends StatelessWidget {
  final ServiceChain chain;
  final String language;
  final VoidCallback onTap;

  const ServiceChainCard({
    super.key,
    required this.chain,
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
              // Event badge (if wedding/engagement)
              if (chain.eventType != 'EVERYDAY')
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  margin: EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.pink.shade100,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (language != 'ar') ...[
                        Icon(
                          Icons.event,
                          size: 16,
                          color: Colors.pink.shade700,
                        ),
                        SizedBox(width: 6),
                      ],
                      Text(
                        chain.getEventTypeDisplay(language),
                        style: TextStyle(
                          color: Colors.pink.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (language == 'ar') ...[
                        SizedBox(width: 6),
                        Icon(
                          Icons.event,
                          size: 16,
                          color: Colors.pink.shade700,
                        ),
                      ],
                    ],
                  ),
                ),

              // Package name
              Text(
                language == 'ar' ? chain.nameArabic : chain.name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              // Description (if available)
              if (chain.descriptionArabic.isNotEmpty ||
                  chain.description.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    language == 'ar'
                        ? chain.descriptionArabic
                        : chain.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),

              SizedBox(height: 12),

              // Duration and service count
              Row(
                children: [
                  if (language != 'ar')
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                  if (language != 'ar') SizedBox(width: 6),
                  Text(
                    TranslationService.formatDuration(
                      chain.totalDuration,
                      language,
                    ),
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  if (language == 'ar') SizedBox(width: 6),
                  if (language == 'ar')
                    Icon(
                      Icons.access_time,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                  SizedBox(width: 16),
                  if (language != 'ar')
                    Icon(Icons.list_alt, size: 18, color: Colors.grey.shade600),
                  if (language != 'ar') SizedBox(width: 6),
                  Text(
                    '${chain.items.length} ${language == 'ar' ? 'خدمات' : 'services'}',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                  if (language == 'ar') SizedBox(width: 6),
                  if (language == 'ar')
                    Icon(Icons.list_alt, size: 18, color: Colors.grey.shade600),
                ],
              ),

              SizedBox(height: 12),
              Divider(),
              SizedBox(height: 8),

              // Services list
              Column(
                children: chain.items.map((item) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (language != 'ar') ...[
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.order}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: language == 'ar'
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                language == 'ar'
                                    ? item.serviceNameArabic
                                    : item.serviceName,
                                style: TextStyle(fontSize: 15),
                              ),
                              Text(
                                '${item.durationMinutes} ${TranslationService.translate('minutes', language)}',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (language == 'ar') ...[
                          SizedBox(width: 12),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${item.order}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
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

              // Pricing and book button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (language != 'ar')
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
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
                    TranslationService.formatCurrency(chain.price, language),
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade700,
                    ),
                  ),
                  if (language == 'ar')
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
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
        ),
      ),
    );
  }
}
