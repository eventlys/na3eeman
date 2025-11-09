import 'package:flutter/material.dart';

import '../../Models/barber.dart';
import '../../Services/api_service.dart';
import '../../Utils/constants.dart';
import '../../components/common/custom_app_bar.dart';
import '../../components/common/loading_indicator.dart';
import '../Widgets/barber_card.dart';

class BarbersListPage extends StatefulWidget {
  const BarbersListPage({super.key});

  @override
  State<BarbersListPage> createState() => _BarbersListPageState();
}

class _BarbersListPageState extends State<BarbersListPage> {
  late Future<List<Barber>> _barbersFuture;
  // final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _barbersFuture = ApiService.getBarbers();
  }

  void _refreshData() {
    setState(() {
      _barbersFuture = ApiService.getBarbers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'Barbers',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: FutureBuilder<List<Barber>>(
        future: _barbersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading barbers...');
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: AppColors.errorColor),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load barbers',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final barbers = snapshot.data!;

          if (barbers.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'No barbers found',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.builder(
              itemCount: barbers.length,
              itemBuilder: (context, index) {
                final barber = barbers[index];
                return BarberCard(
                  barber: barber,
                  onTap: () => _showBarberDetails(barber),
                  onEdit: () => _editBarber(barber),
                  onDelete: () => _deleteBarber(barber),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewBarber,
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showBarberDetails(Barber barber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(barber.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${barber.email}'),
            Text('Phone: ${barber.phone}'),
            Text('Rating: ${barber.rating}'),
            Text('Total Appointments: ${barber.totalAppointments}'),
            Text('Specialties: ${barber.specialties.join(', ')}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _addNewBarber() {
    // Implement add new barber functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add new barber functionality')),
    );
  }

  void _editBarber(Barber barber) {
    // Implement edit barber functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${barber.name}')),
    );
  }

  void _deleteBarber(Barber barber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Barber'),
        content: Text('Are you sure you want to delete ${barber.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement delete functionality
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted ${barber.name}')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

