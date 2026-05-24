import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../Services/api/api_service.dart';
import '../../../../core/theme/colors.dart';

class PerServiceSelectionPage extends StatefulWidget {
  final Map<String, dynamic> service;
  final int salonId;

  const PerServiceSelectionPage({
    super.key,
    required this.service,
    required this.salonId,
  });

  @override
  State<PerServiceSelectionPage> createState() =>
      _PerServiceSelectionPageState();
}

class _PerServiceSelectionPageState extends State<PerServiceSelectionPage> {
  final ApiService _api = ApiService();
  List<dynamic> _experts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExperts();
  }

  Future<void> _loadExperts() async {
    try {
      final experts = await _api.getSalonExperts(widget.salonId);
      // In a real app, you might filter experts by the specific service they provide
      if (mounted) {
        setState(() {
          _experts = experts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "select_for_service".tr(args: [widget.service['name'] ?? 'Service']),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _experts.isEmpty
          ? const Center(
              child: Text('No professionals available for this service.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(24),
              itemCount: _experts.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final expert = _experts[index];
                final name = expert['first_name'] ?? 'Professional';
                final rating = (expert['rating'] ?? 5.0).toDouble();

                return InkWell(
                  onTap: () => Navigator.pop(context, expert),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.almostBlack600 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.almostBlack50,
                          child: Icon(
                            Icons.person,
                            size: 30,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
