import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Models/appointment_model.dart';

class AppointmentService {
  static const String baseUrl = 'https://your-api-url.com/api/appointments';

  static Future<List<ShopAppointment>> fetchAppointments() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => ShopAppointment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode}');
      }
    } catch (e) {
      // For demo purposes, return mock data
      print('Error fetching appointments: $e');
      return _getMockAppointments();
    }
  }

  static List<ShopAppointment> _getMockAppointments() {
    return [
      ShopAppointment(
        id: '1',
        imagePath: 'https://images.unsplash.com/photo-1562322140-8baeececf3df?w=400',
        title: 'Haircut & Styling',
        status: 'completed',
        totalPrice: 45.00,
        serviceTime: '30 mins',
        date: '2024-01-15',
        barberName: 'John Doe',
        barberNumber: '+1234567890',
        barberShopName: 'Modern Cuts',
      ),
      ShopAppointment(
        id: '2',
        imagePath: 'https://images.unsplash.com/photo-1599351431202-1e0f0137899a?w=400',
        title: 'Beard Trim',
        status: 'pending',
        totalPrice: 25.00,
        serviceTime: '20 mins',
        date: '2024-01-16',
        barberName: 'Mike Smith',
        barberNumber: '+1234567891',
        barberShopName: 'Elite Barbers',
      ),
      ShopAppointment(
        id: '3',
        imagePath: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
        title: 'Hair Color',
        status: 'cancelled',
        totalPrice: 85.00,
        serviceTime: '60 mins',
        date: '2024-01-14',
        barberName: 'Robert Johnson',
        barberNumber: '+1234567892',
        barberShopName: 'Style Studio',
      ),
    ];
  }
}

