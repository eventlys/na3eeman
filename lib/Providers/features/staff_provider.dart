import '../base_provider.dart';
import 'auth_provider.dart';
import '../../Models/staff/staff_member.dart';
import '../../Models/staff/expert.dart';
import '../../Models/intern/intern_models.dart';
import '../../Services/api/api_service.dart';
import '../../Services/api/endpoints.dart';
import '../../Helpers/logger.dart';

class StaffProvider extends BaseProvider {
  final ApiService _apiService;

  StaffProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();
  List<StaffMember> _staff = [];
  List<Expert> _experts = [];
  AuthProvider? _authProvider;
  StaffMember? _selectedStaff;
  List<InternAttendanceLog> _attendanceLogs = [];

  // Getters
  List<StaffMember> get staff => _staff;
  List<Expert> get experts => _experts;
  StaffMember? get selectedStaff => _selectedStaff;
  List<InternAttendanceLog> get attendanceLogs => _attendanceLogs;

  List<StaffMember> get manageableStaff {
    return _staff;
  }

  // Methods
  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true &&
        (_authProvider?.isOwner == true || _authProvider?.isAdmin == true)) {
      loadStaffData();
    }
  }

  Future<void> loadStaffData() async {
    try {
      setLoading(true);
      clearError();

      final salonId = _authProvider?.user?.salonId;
      if (salonId == null && _authProvider?.isAdmin != true) {
        // No salon assigned yet — not an error, just nothing to load.
        _staff = [];
        _experts = [];
        setLoading(false);
        notifyListeners();
        return;
      }

      // For Admin, they might need to select a salon first, but for Owner/Staff it's their salon
      if (salonId != null) {
        await loadStaff(salonId);
      }

      notifyListeners();
    } catch (e) {
      setError(e.toString());
      AppLogger.error('Error loading staff data: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> loadStaff(int salonId) async {
    try {
      final response = await _apiService.get(Endpoints.salonExperts(salonId));
      final List<dynamic> data = response is List
          ? response
          : (response['results'] ?? response['data'] ?? []);

      // Map to StaffMember or Expert based on needs
      // For now, mapping to both for backward compatibility with existing UI
      _staff = data.map((json) => StaffMember.fromJson(json)).toList();
      _experts = data.map((json) => Expert.fromJson(json)).toList();

      notifyListeners();
    } catch (e) {
      AppLogger.error('Failed to load staff for salon $salonId: $e');
      _staff = [];
      _experts = [];
    }
  }

  void selectStaff(StaffMember? staff) {
    _selectedStaff = staff;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // DATA-ACCESS DELEGATES
  // Pure pass-throughs so staff-facing widgets never touch ApiService directly.
  // ---------------------------------------------------------------------------

  /// Generic authenticated GET (raw JSON response).
  Future<dynamic> apiGet(
    String endpoint, {
    Map<String, dynamic>? queryParams,
  }) => _apiService.get(endpoint, queryParams: queryParams);

  /// Generic authenticated POST (raw JSON response).
  Future<dynamic> apiPost(String endpoint, {Map<String, dynamic>? data}) =>
      _apiService.post(endpoint, data: data);

  /// Fetches the current expert's insights. Keeps the endpoint inside the
  /// data layer so pages never name it directly.
  Future<dynamic> fetchExpertInsights() => apiGet(Endpoints.expertInsights);

  /// Fetches appointments. Keeps the endpoint inside the data layer so
  /// pages never name it directly.
  Future<dynamic> fetchAppointments() => apiGet(Endpoints.appointments);

  Future<void> fetchInternAttendance() async {
    try {
      setLoading(true);
      final response = await _apiService.get(Endpoints.attendanceLog);
      final List<dynamic> data = response is List
          ? response
          : (response['results'] ?? response['data'] ?? []);
      _attendanceLogs = data
          .map((json) => InternAttendanceLog.fromJson(json))
          .toList();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error fetching intern attendance: $e');
    } finally {
      setLoading(false);
    }
  }
}
