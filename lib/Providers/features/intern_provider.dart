import 'package:flutter/material.dart';
import '../../Models/intern/intern_models.dart';
import '../../Services/api/api_service.dart';
import '../../Services/api/endpoints.dart';

class InternProvider with ChangeNotifier {
  final ApiService _apiService;

  InternProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  List<InternTask> _tasks = [];
  List<InternFeedback> _feedbacks = [];
  bool _isLoading = false;
  int? _salonId;
  Map<String, dynamic> _activityData = {};

  List<InternTask> get tasks => _tasks;
  List<InternFeedback> get feedbacks => _feedbacks;
  bool get isLoading => _isLoading;
  int? get salonId => _salonId;
  Map<String, dynamic> get activityData => _activityData;

  // Initialize data
  Future<void> initInternDashboard() async {
    await Future.wait([
      fetchProfile(),
      fetchTasks(),
      fetchInternActivity(), // This fetches feedbacks too if included in dashboard response
    ]);
  }

  // Profile Operations
  Future<void> fetchProfile() async {
    try {
      final response = await _apiService.get(Endpoints.currentUser);
      final dynamic userData = response['user'] ?? response;

      // Extract salon ID - could be 'salon' (Object/int) or 'salon_id'
      final salonData = userData['salon'];
      debugPrint('DEBUG: Intern profile salon data: $salonData');

      if (salonData is int) {
        _salonId = salonData;
      } else if (salonData is Map) {
        _salonId = salonData['id'] ?? salonData['salon_id'];
      } else if (salonData is String) {
        _salonId = int.tryParse(salonData);
      }

      debugPrint('DEBUG: Extracted salonId: $_salonId');
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching intern profile: $e');
    }
  }

  // Task Operations
  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.get(Endpoints.internTasks);
      final List<dynamic> data =
          response['results'] ?? response['data'] ?? response;
      _tasks = data.map((json) => InternTask.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching intern tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title) async {
    try {
      final response = await _apiService.post(
        Endpoints.internTasks,
        data: {'title': title},
      );
      final newTask = InternTask.fromJson(response['data'] ?? response);
      _tasks.insert(0, newTask);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding intern task: $e');
    }
  }

  Future<void> toggleTaskStatus(int taskId, bool isCompleted) async {
    try {
      final response = await _apiService.patch(
        Endpoints.internTaskDetail(taskId),
        data: {'is_completed': isCompleted},
      );

      final dynamic responseData = response['data'] ?? response;
      final updatedTask = InternTask.fromJson(responseData);

      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling intern task: $e');
    }
  }

  Future<void> toggleTaskCompletion(InternTask task) async {
    return toggleTaskStatus(task.id, !task.isCompleted);
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await _apiService.delete(Endpoints.internTaskDetail(taskId));
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting intern task: $e');
    }
  }

  // Activity Feed
  Future<void> fetchInternActivity() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getInternActivity();
      _activityData = response;

      // Extract feedbacks if present
      if (response['feedbacks'] != null) {
        final List<dynamic> feedbackList = response['feedbacks'];
        _feedbacks = feedbackList
            .map((json) => InternFeedback.fromJson(json))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching intern activity: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
