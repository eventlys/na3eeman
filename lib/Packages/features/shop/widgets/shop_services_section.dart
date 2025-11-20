import 'package:flutter/material.dart';
import '../../Models/shop_service_model.dart';
import '../Navigations/shop_schedule_page.dart'; // Correct import

class ServicesSection extends StatelessWidget {
  final Map<String, dynamic> shopData;

  const ServicesSection({
    super.key,
    required this.shopData,
  });

  @override
  Widget build(BuildContext context) {
    // FIX: Properly handle the service data conversion
    final List<ShopService> services;

    if (shopData['services'] != null) {
      services = (shopData['services'] as List).map((service) {
        if (service is ShopService) {
          return service;
        } else if (service is Map<String, dynamic>) {
          return ShopService.fromMap(service);
        } else {
          // Fallback for unexpected types
          return ShopService(
            name: 'Unknown Service',
            price: '\$0',
            duration: '0 min',
          );
        }
      }).toList();
    } else {
      // Default mock data
      services = [
        {'name': 'Haircut', 'price': '\$25', 'duration': '30 min'},
        {'name': 'Beard Trim', 'price': '\$15', 'duration': '20 min'},
        {'name': 'Haircut & Beard', 'price': '\$35', 'duration': '45 min'},
        {'name': 'Hair Wash', 'price': '\$10', 'duration': '15 min'},
      ].map((service) => ShopService.fromMap(service)).toList();
    }

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Services & Prices',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFFFFF),
            ),
          ),
          SizedBox(height: 16),
          ...services.map((shopService) => _buildServiceItem(
            context: context,
            service: shopService,
          )),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required ShopService service,
  }) {
    return InkWell(
      onTap: () {
        // FIX: Use ShopSchedulePage instead of ScheduleAppointmentPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopSchedulePage(shopService: service),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0x1AFFFFFF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  service.duration,
                  style: TextStyle(
                    color: Color(0xFFCCCCCC),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            Text(
              service.price,
              style: TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
