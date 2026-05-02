import 'package:flutter/material.dart';
import '../../Models/salon_extensions.dart';

/// Spa Amenities Grid Widget
/// Displays amenities with emoji icons and labels
class SpaAmenitiesGrid extends StatelessWidget {
  final SpaAmenities amenities;
  final String language;

  const SpaAmenitiesGrid({
    super.key,
    required this.amenities,
    this.language = 'ar',
  });

  @override
  Widget build(BuildContext context) {
    final amenityList = amenities.getAmenityList(language);

    if (amenityList.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            language == 'ar'
                ? 'لا توجد مرافق متوفرة'
                : 'No amenities available',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: amenityList.length,
      itemBuilder: (context, index) {
        final amenity = amenityList[index];
        return _buildAmenityTile(amenity, context);
      },
    );
  }

  Widget _buildAmenityTile(AmenityItem amenity, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(amenity.icon, style: TextStyle(fontSize: 32)),
          SizedBox(height: 8),
          Text(
            amenity.getName(language),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Spa Amenities Section Widget
/// Full section with header and grid
class SpaAmenitiesSection extends StatelessWidget {
  final SpaAmenities amenities;
  final String language;

  const SpaAmenitiesSection({
    super.key,
    required this.amenities,
    this.language = 'ar',
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: language == 'ar'
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            language == 'ar' ? 'المرافق المتوفرة' : 'Available Amenities',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            language == 'ar'
                ? 'استمتع بهذه المرافق أثناء زيارتك'
                : 'Enjoy these amenities during your visit',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          SizedBox(height: 20),
          SpaAmenitiesGrid(amenities: amenities, language: language),

          // Additional info if swimsuit is required
          if (amenities.requiresSwimsuit)
            Container(
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  if (language != 'ar') ...[
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      language == 'ar'
                          ? 'يرجى إحضار لباس سباحة'
                          : 'Please bring a swimsuit',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (language == 'ar') ...[
                    SizedBox(width: 12),
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
