import 'package:flutter/material.dart';

import '../../../Core/utils/helpers/service_calculator.dart';

class ServiceDetailsSection extends StatelessWidget {
  final ServiceSelection serviceSelection;
  final Function(ShopService) onServiceToggled;
  final List<ShopService> availableAdditionalServices;

  const ServiceDetailsSection({
    super.key,
    required this.serviceSelection,
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
              color: const Color(0xffffffff),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC25858),
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // color: const Color(0xffffffff),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle, color: Color(0xffc25858)),
                      const SizedBox(width: 8),
                      Text(
                        'Add Additional Services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xffc25858),
                        ),
                      ),
                    ],
                  ),
                ),

                // Services List
                Container(
                  // color: Color(0x80806c99),
                  constraints: BoxConstraints(maxHeight: 400),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableAdditionalServices.length,
                    itemBuilder: (context, index) {
                      final service = availableAdditionalServices[index];
                      final isSelected = serviceSelection.containsService(service);

                      return ListTile(
                        leading: Icon(
                          isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                          color: isSelected ? Color(0xffc25858) : Colors.grey,
                        ),
                        title: Text(
                          service.name,
                          style: TextStyle(
                            color: Color(0xff040000),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          '${service.duration} • ${service.price}',
                          style: TextStyle(
                            color: Color(0xff040000).withValues(alpha: 0.7),
                          ),
                        ),
                        trailing: Text(
                          service.price,
                          style: TextStyle(
                            color: Color(0xffc25858),
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
                        color: Color(0xffc25858), // Same color as the text
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          color: Color(0xffc25858),
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
    final allServices = serviceSelection.allServices;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0x4dffffff),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFFFFF),
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
                color: Color(0xff040000),
              ),
            ),
            const SizedBox(height: 16),

            // Main Selected Service
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0x26c25858),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xffc25858)),
              ),
              child: Row(
                children: [
                  Icon(Icons.celebration, color: Color(0xffc25858), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Main Service',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xffc25858),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${serviceSelection.mainService.name} - ${serviceSelection.mainService.price}',
                          style: TextStyle(
                            color: Color(0xff040000),
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
            if (serviceSelection.additionalServices.isNotEmpty) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Additional Services:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff040000),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...serviceSelection.additionalServices.map((service) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(0x1Ac25858),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xffc25858), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${service.name} - ${service.price}',
                              style: TextStyle(
                                color: Color(0xff040000),
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.remove_circle, color: Color(0xffc25858), size: 20),
                            onPressed: () => onServiceToggled(service),
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 12),
                  Divider(color: Color(0xffffffff)),
                  const SizedBox(height: 12),
                ],
              ),
            ],

            // Total summary
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0x33C25858),
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
                          color: Color(0xff040000),
                        ),
                      ),
                      Text(
                        ServiceCalculator.formatTotalDuration(allServices),
                        style: TextStyle(
                          color: Color(0xff040000),
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
                          color: Color(0xff040000),
                        ),
                      ),
                      Text(
                        ServiceCalculator.formatTotalPrice(allServices),
                        style: TextStyle(
                          color: Color(0xff040000),
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
                    backgroundColor: Color(0x4dffffff),
                    foregroundColor: Color(0xffc25858),
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  icon: Icon(Icons.add, size: 20),
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
}

