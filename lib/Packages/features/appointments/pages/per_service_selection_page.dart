import 'package:flutter/material.dart';
import 'package:na3eeman/l10n/app_localizations.dart';
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
  State<PerServiceSelectionPage> createState() => _PerServiceSelectionPageState();
}

class _PerServiceSelectionPageState extends State<PerServiceSelectionPage> {
  final ApiService _api = ApiService();
  List<dynamic> _barbers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBarbers();
  }

  Future<void> _loadBarbers() async {
    try {
      final barbers = await _api.getSalonBarbers(widget.salonId);
      // In a real app, you might filter barbers by the specific service they provide
      if (mounted) {
        setState(() {
          _barbers = barbers;
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
        title: Text(AppLocalizations.of(context)!.selectForService(widget.service['name'] ?? 'Service')),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _barbers.isEmpty
              ? const Center(child: Text('No professionals available for this service.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: _barbers.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final barber = _barbers[index];
                    final name = barber['first_name'] ?? 'Professional';
                    final rating = (barber['rating'] ?? 5.0).toDouble();

                    return InkWell(
                      onTap: () => Navigator.pop(context, barber),
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
                              child: Icon(Icons.person, size: 30, color: Theme.of(context).primaryColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        rating.toStringAsFixed(1),
                                        style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
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
