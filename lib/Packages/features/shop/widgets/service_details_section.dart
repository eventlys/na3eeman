import 'package:flutter/material.dart';
import '../../../../Helpers/service_models_helper.dart';
import '../../../../Providers/main_providers.dart';
import '../../../Core/constants/app_color.dart';
import '../../../Core/constants/app_images.dart';
import '../../../Core/utils/helpers/service_calculator.dart';

class ServiceDetailsSection extends StatelessWidget {
  final ServiceProvider serviceProvider;
  final Function(Map<String, dynamic>) onServiceToggled;
  final List<Map<String, dynamic>> availableAdditionalServices;

  const ServiceDetailsSection({
    super.key,
    required this.serviceProvider,
    required this.onServiceToggled,
    this.availableAdditionalServices = const [],
  });

  void _showAddServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: AppColor.lightCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColor.lightSecondary,
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Image.asset(
                        AppImages.plus,
                        width: 24,
                        height: 24,
                        color: AppColor.lightSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Add Additional Services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColor.lightSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Services List
                Container(
                  constraints: BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableAdditionalServices.length,
                    itemBuilder: (context, index) {
                      final service = availableAdditionalServices[index];
                      final isSelected = serviceProvider.isServiceSelected(service);

                      return ListTile(
                        leading: Image.asset(
                          isSelected ? AppImages.check : AppImages.uncheck,
                          width: 24,
                          height: 24,
                          color: isSelected ? AppColor.lightSecondary : AppColor.lightTextHint,
                        ),
                        title: Text(
                          ServiceDataHelper.getServiceName(service),
                          style: TextStyle(
                            color: AppColor.lightText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${ServiceDataHelper.getServiceDuration(service)} • ${ServiceDataHelper.getServicePrice(service)}',
                          style: TextStyle(
                            color: AppColor.lightTextSecondary,
                          ),
                        ),
                        trailing: Text(
                          ServiceDataHelper.getServicePrice(service),
                          style: TextStyle(
                            color: AppColor.lightSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          onServiceToggled(service);
                          Navigator.of(context).pop();
                        },
                      );
                    },
                  ),
                ),

                // Close Button
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 5, 20, 5),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColor.lightSecondary,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: AppColor.lightSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final serviceSelection = serviceProvider.currentServiceSelection;

    if (serviceSelection == null) {
      return _buildEmptyState();
    }

    final allServices = serviceProvider.allSelectedServices;
    final mainService = serviceProvider.mainService;
    final additionalServices = serviceProvider.additionalServices;

    return Container(
      decoration: BoxDecoration(
        color: AppColor.buttonBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.borderLight,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColor.lightText,
              ),
            ),
            const SizedBox(height: 16),

            // Main Selected Service
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.lightSecondary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColor.lightSecondary),
              ),
              child: Row(
                children: [
                  Image.asset(
                    AppImages.scissors,
                    width: 20,
                    height: 20,
                    color: AppColor.lightSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Main Service',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColor.lightSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${ServiceDataHelper.getServiceName(mainService!)} - ${ServiceDataHelper.getServicePrice(mainService)}',
                          style: TextStyle(
                            color: AppColor.lightText,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Selected additional services list
            if (additionalServices.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Services:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...additionalServices.map((service) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColor.lightSecondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            AppImages.check,
                            width: 20,
                            height: 20,
                            color: AppColor.lightSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${ServiceDataHelper.getServiceName(service)} - ${ServiceDataHelper.getServicePrice(service)}',
                              style: TextStyle(
                                color: AppColor.lightText,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Image.asset(
                              AppImages.minus,
                              width: 20,
                              height: 20,
                              color: AppColor.lightSecondary,
                            ),
                            onPressed: () => onServiceToggled(service),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 12),
                  Divider(color: AppColor.borderLight),
                  const SizedBox(height: 12),
                ],
              ),
            ],

            // Total summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.lightSecondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Duration:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.lightText,
                        ),
                      ),
                      Text(
                        ServiceCalculator.formatTotalDuration(allServices),
                        style: TextStyle(
                          color: AppColor.lightText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Price:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColor.lightText,
                        ),
                      ),
                      Text(
                        ServiceCalculator.formatTotalPrice(allServices),
                        style: TextStyle(
                          color: AppColor.lightText,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Add more services button
            if (availableAdditionalServices.isNotEmpty) ...[
              Center(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddServiceDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.buttonBackgroundLight,
                    foregroundColor: AppColor.lightSecondary,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                      side: BorderSide(color: AppColor.lightSecondary),
                    ),
                  ),
                  icon: Image.asset(
                    AppImages.plus,
                    width: 20,
                    height: 20,
                    color: AppColor.lightSecondary,
                  ),
                  label: Text(
                    'Add More Services',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      decoration: BoxDecoration(
        color: AppColor.buttonBackgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColor.borderLight,
          width: 1.0,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Image.asset(
              AppImages.scissors,
              width: 48,
              height: 48,
              color: AppColor.lightSecondary,
            ),
            SizedBox(height: 8),
            Text(
              'No Service Selected',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.lightText,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Please select a main service to continue',
              style: TextStyle(
                color: AppColor.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
