import '../../Helpers/logger.dart';
import '../../Models/staff/expert.dart';
import '../../Models/staff/staff_member.dart';
import '../api/api_service.dart';
import '../enums/staff_role.dart';

/// Repository for staff/expert backend access.
///
/// Extracted verbatim from the former god service `BusinessService`
/// (see `lib/Services/business_service.dart`, now a delegating facade).
class StaffRepository {
  final ApiService _apiService;

  StaffRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<StaffMember>> getStaffMembers({
    String? branchId,
    int? salonId,
    StaffRole? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (branchId != null) queryParams['branch_id'] = branchId;
      if (salonId != null) queryParams['salon'] = salonId.toString();
      if (role != null) queryParams['role'] = role.value;
      if (isActive != null) queryParams['is_active'] = isActive.toString();

      final response = await _apiService.get(
        '/staff',
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => StaffMember.fromJson(item)).toList();
    } catch (e) {
      AppLogger.error('Error fetching staff members: $e');
      rethrow;
    }
  }

  Future<List<Expert>> getExperts({
    String? branchId,
    int? salonId,
    bool? includePerformance,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (branchId != null) queryParams['branch_id'] = branchId;
      if (salonId != null) queryParams['salon'] = salonId.toString();
      if (includePerformance != null) {
        queryParams['include_performance'] = includePerformance.toString();
      }

      final response = await _apiService.get(
        '/experts',
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => Expert.fromJson(item)).toList();
    } catch (e) {
      AppLogger.error('Error fetching experts: $e');
      rethrow;
    }
  }
}
