import 'package:flutter/material.dart';
import 'package:na3eeman/Models/staff/weekly_working_hours.dart';
import 'package:na3eeman/Services/api/api_service.dart';

class ScheduleProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  
  List<WeeklyWorkingHours> _workingHours = [];
  bool _isLoading = false;
  String? _error;

  List<WeeklyWorkingHours> get workingHours => _workingHours;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWorkingHours({int? salonId, int? expertId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final List<dynamic> data = await _api.getWorkingHours(
        salonId: salonId,
        expertId: expertId,
      );
      
      _workingHours = data.map((json) => WeeklyWorkingHours.fromJson(json)).toList();
      
      // Sort by day of week
      _workingHours.sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateWorkingHours(int id, Map<String, dynamic> data) async {
    try {
      await _api.patch('/salons/working-hours/$id/', data: data);
      // Refresh local data or update optimisticly
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
