import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:na3eeman/Providers/features/owner_provider.dart';
import 'package:na3eeman/Services/api/api_service.dart';

/// Resource / room occupancy meter (Elite tier).
class ResourceOccupancyWidget extends StatefulWidget {
  const ResourceOccupancyWidget({super.key});

  @override
  State<ResourceOccupancyWidget> createState() => _ResourceOccupancyWidgetState();
}

class _ResourceOccupancyWidgetState extends State<ResourceOccupancyWidget> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  List<_Room> _rooms = [];

  @override
  void initState() {
    super.initState();
    _fetchOccupancy();
  }

  Future<void> _fetchOccupancy() async {
    if (!mounted) return;
    final owner = context.read<OwnerProvider>();
    final salonId = owner.activeSalonId;
    if (salonId == null) {
      if (mounted) setState(() { _isLoading = false; _error = 'No salon selected'; });
      return;
    }

    try {
      final response = await _apiService.get('/salons/$salonId/resource_occupancy/');
      final data = response['results'] as List;
      if (mounted) {
        setState(() {
          _rooms = data.map((json) => _Room(json['name'] ?? 'Unknown', json['pct'] ?? 0)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load occupancy';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.meeting_room_rounded,
                size: 18, color: theme.primaryColor),
            const SizedBox(width: 8),
            Text("resource_occupancy".tr(),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 14),
        if (_rooms.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('No resources available.'),
          ),
        ..._rooms.map((r) {
          final color = r.pct >= 80
              ? Colors.red
              : r.pct >= 50
                  ? Colors.orange
                  : Colors.green;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(
                  width: 70,
                  child: Text(r.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: r.pct / 100,
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${r.pct}%',
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _Room {
  final String name;
  final int pct;
  _Room(this.name, this.pct);
}
