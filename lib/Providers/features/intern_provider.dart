import 'package:flutter/material.dart';
import '../../Models/intern/intern_models.dart';
import '../../Services/api/api_service.dart';
import '../../Services/api/endpoints.dart';

class InternProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<InternTask> _tasks = [];
  List<InternTarget> _targets = [];
  bool _isLoading = false;
  String? _assignedMentor;
  int? _shopId;
  Map<String, dynamic> _activityData = {};

  List<InternTask> get tasks => _tasks;
  List<InternTarget> get targets => _targets;
  bool get isLoading => _isLoading;
  String? get assignedMentor => _assignedMentor;
  int? get shopId => _shopId;
  Map<String, dynamic> get activityData => _activityData;

  // Initialize data
  Future<void> initInternDashboard(String? currentMentor) async {
    _assignedMentor = currentMentor;
    await fetchProfile();
    await fetchTasks();
    await fetchTargets();
  }

  // Profile Operations
  Future<void> fetchProfile() async {
    try {
      final response = await _apiService.get(Endpoints.currentUser);
      final dynamic userData = response['user'] ?? response;
      
      // Extract shop ID - could be 'shop' (Object/int) or 'shop_id'
      final shopData = userData['shop'];
      debugPrint('DEBUG: Intern profile shop data: $shopData');
      
      if (shopData is int) {
        _shopId = shopData;
      } else if (shopData is Map) {
        _shopId = shopData['id'] ?? shopData['shop_id'];
      } else if (shopData is String) {
        _shopId = int.tryParse(shopData);
      }
      
      debugPrint('DEBUG: Extracted shopId: $_shopId');
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
      final List<dynamic> data = response['results'] ?? response['data'] ?? response;
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
      final response = await _apiService.post(Endpoints.internTasks, data: {'title': title});
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

  // Target Operations
  Future<void> fetchTargets() async {
    try {
      final response = await _apiService.get(Endpoints.internTargets);
      final List<dynamic> data = response['results'] ?? response['data'] ?? response;
      _targets = data.map((json) => InternTarget.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error fetching intern targets: $e');
    } finally {
      notifyListeners();
    }
  }

  // Mentorship attachment
  Future<void> attachToMentor(int mentorId, String? feedback, String mentorName) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _apiService.post(Endpoints.internAttach, data: {
        'mentor_id': mentorId,
        'feedback': feedback,
      });

      _assignedMentor = mentorName;
      notifyListeners();
    } catch (e) {
      debugPrint('Error attaching to mentor: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Activity Feed
  Future<void> fetchInternActivity() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _apiService.getInternActivity();
      _activityData = response as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Error fetching intern activity: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
