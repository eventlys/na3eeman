import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Helpers/service_models_helper.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../pages/shop_schedule_page.dart';
import '../../../../Services/business_service.dart';

class ServicesSection extends StatelessWidget {
  final Map<String, dynamic> shopData;

  const ServicesSection({
    super.key,
    required this.shopData,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ServiceProvider>(
      builder: (context, serviceProvider, child) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _loadServices(context, shopData),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingSection();
            }

            if (snapshot.hasError) {
              return _buildErrorSection(snapshot.error.toString());
            }

            final services = snapshot.data ?? [];

            return _buildServicesSection(context, services, serviceProvider);
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadServices(BuildContext context, Map<String, dynamic> shopData) async {
    try {
      final serviceProvider = Provider.of<ServiceProvider>(context, listen: false);
      final businessService = BusinessService();

      // Try to get services from shop data first
      if (shopData['services'] != null) {
        final services = _parseServicesFromShopData(shopData['services']);
        if (services.isNotEmpty) return services;
      }

      // Fallback: Try to fetch services from API using shop ID
      final shopId = shopData['id'];
      if (shopId != null) {
        // Convert shop details to service format
        final shopDetails = await businessService.getShopDetails(shopId);
        final services = _convertShopDetailsToServices(shopDetails);
        if (services.isNotEmpty) return services;
      }

      // Final fallback: Use service provider's available services
      if (serviceProvider.availableAdditionalServices.isNotEmpty) {
        return serviceProvider.availableAdditionalServices;
      }

      return [];
    } catch (e) {
      throw Exception('Failed to load services: $e');
    }
  }

  List<Map<String, dynamic>> _parseServicesFromShopData(dynamic servicesData) {
    if (servicesData is List<Map<String, dynamic>>) {
      return servicesData;
    } else if (servicesData is List) {
      return servicesData.map((service) {
        if (service is Map<String, dynamic>) {
          return service;
        } else {
          // Handle other types by creating a default service structure
          return ServiceDataHelper.createServiceData(
            id: service['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
            name: service['name']?.toString() ?? 'Unknown Service',
            duration: service['duration']?.toString() ?? '30 min',
            price: service['price']?.toString() ?? '\$0',
            description: service['description']?.toString(),
          );
        }
      }).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> _convertShopDetailsToServices(dynamic shopDetails) {
    // Extract services from various possible shop detail structures
    final List<Map<String, dynamic>> services = [];

    if (shopDetails is Map<String, dynamic>) {
      // Try different possible service field names
      final servicesData = shopDetails['services'] ??
                          shopDetails['service_list'] ??
                          shopDetails['available_services'];

      if (servicesData is List) {
        return _parseServicesFromShopData(servicesData);
      }
    }

    return services;
  }

  Widget _buildLoadingSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.buttonBackgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                AppImages.scissors,
                width: 24,
                height: 24,
                color: AppColor.lightText,
              ),
              const SizedBox(width: 8),
              Text(
                'Services & Prices',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildServiceItemShimmer(),
          _buildServiceItemShimmer(),
        ],
      ),
    );
  }

  Widget _buildErrorSection(String error) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.buttonBackgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                AppImages.scissors,
                width: 24,
                height: 24,
                color: AppColor.lightText,
              ),
              const SizedBox(width: 8),
              Text(
                'Services & Prices',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColor.lightCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColor.borderLight),
            ),
            child: Center(
              child: Text(
                'Unable to load services. Please try again.',
                style: TextStyle(
                  color: AppColor.lightTextSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection(
    BuildContext context,
    List<Map<String, dynamic>> services,
    ServiceProvider serviceProvider,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColor.buttonBackgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                AppImages.scissors,
                width: 24,
                height: 24,
                color: AppColor.lightText,
              ),
              const SizedBox(width: 8),
              Text(
                'Services & Prices',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColor.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (services.isEmpty)
            _buildNoServicesAvailable()
          else
            ...services.map((service) => _buildServiceItem(
              context: context,
              service: service,
              serviceProvider: serviceProvider,
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildNoServicesAvailable() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Center(
        child: Text(
          'No services available',
          style: TextStyle(
            color: AppColor.lightTextSecondary,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItemShimmer() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColor.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 16,
                  color: AppColor.borderLight,
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 14,
                  color: AppColor.borderLight,
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 30,
            color: AppColor.borderLight,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required Map<String, dynamic> service,
    required ServiceProvider serviceProvider,
  }) {
    final serviceName = ServiceDataHelper.getServiceName(service);
    final serviceDuration = ServiceDataHelper.getServiceDuration(service);
    final servicePrice = ServiceDataHelper.getServicePrice(service);

    return InkWell(
      onTap: () {
        // Initialize service selection in provider
        serviceProvider.initializeServiceSelection(service);

        // Navigate to scheduling page - pass service data directly
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShopSchedulePage(serviceData: service),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColor.lightCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColor.borderLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: TextStyle(
                      color: AppColor.lightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Image.asset(
                        AppImages.clock,
                        width: 14,
                        height: 14,
                        color: AppColor.lightTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        serviceDuration,
                        style: TextStyle(
                          color: AppColor.lightTextSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColor.lightSecondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.lightSecondary.withOpacity(0.3)),
              ),
              child: Text(
                servicePrice,
                style: TextStyle(
                  color: AppColor.lightSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
