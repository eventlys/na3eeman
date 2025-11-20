import '../api/api_interceptor_service.dart';
import '../api/api_service.dart';
import '../storage_service.dart';

class UserService {
  final ApiInterceptorService _apiInterceptor;
  final UnifiedStorageService _unifiedStorageService = UnifiedStorageService();

  UserService() : _apiInterceptor = ApiInterceptorService(ApiService());

  static const String _baseUrl = 'https://your-api-url.com/api';

  Future<UserStatistics> getUserStatistics() async {
    final result = await _apiInterceptor.executeApiCall(
      endpoint: '$_baseUrl/users/statistics/',
      method: 'GET',
      data: null,
      requireAuth: true,
    );

    if (result['success'] == true) {
      final data = result['data'];
      return UserStatistics.fromJson(data);
    } else {
      throw Exception('Failed to fetch user statistics: ${result['error']}');
    }
  }

  Future<void> sendVerificationEmail(int userId) async {
    final result = await _apiInterceptor.executeApiCall(
      endpoint: '$_baseUrl/users/send-verification-email/',
      method: 'POST',
      data: {'user_id': userId},
      requireAuth: true,
    );

    if (result['success'] != true) {
      throw Exception('Failed to send verification email: ${result['error']}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    final result = await _apiInterceptor.executeApiCall(
      endpoint: '$_baseUrl/users/send-password-reset-email/',
      method: 'POST',
      data: {'email': email},
      requireAuth: false, // This endpoint typically doesn't require auth
    );

    if (result['success'] != true) {
      throw Exception('Failed to send password reset email: ${result['error']}');
    }
  }

  // Additional user-related methods

  Future<UserProfile> getUserProfile(int userId) async {
    final result = await _apiInterceptor.executeApiCall(
      endpoint: '$_baseUrl/users/$userId/profile/',
      method: 'GET',
      data: null,
      requireAuth: true,
    );

    if (result['success'] == true) {
      final data = result['data'];
      return UserProfile.fromJson(data);
    } else {
      throw Exception('Failed to fetch user profile: ${result['error']}');
    }
  }

  Future<void> updateUserProfile(int userId, Map<String, dynamic> profileData) async {
    final result = await _apiInterceptor.executeApiCall(
      endpoint: '$_baseUrl/users/$userId/profile/',
      method: 'PUT',
      data: profileData,
      requireAuth: true,
    );

    if (result['success'] != true) {
      throw Exception('Failed to update user profile: ${result['error']}');
    }
  }

  Future<List<User>> getUsers({int page = 1, int limit = 20, String? search}) async {
    final Map<String, dynamic> queryParams = {
      'page': page,
      'limit': limit,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final result = await _apiInterceptor.executeApiCall(
      endpoint: '$_baseUrl/users/?${Uri(queryParameters: queryParams).query}',
      method: 'GET',
      data: null,
      requireAuth: true,
    );

    if (result['success'] == true) {
      final data = result['data'];
      if (data is List) {
        return data.map((userJson) => User.fromJson(userJson)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to fetch users: ${result['error']}');
    }
  }

  Future<void> updateUserRole(int userId, String newRole) async {
    final result = await _apiInterceptor.executeApiCall(
      endpoint: '$_baseUrl/users/$userId/role/',
      method: 'PATCH',
      data: {'role': newRole},
      requireAuth: true,
    );

    if (result['success'] != true) {
      throw Exception('Failed to update user role: ${result['error']}');
    }
  }

  Future<void> deactivateUser(int userId) async {
    final result = await _apiInterceptor.executeApiCall(
      endpoint: '$_baseUrl/users/$userId/deactivate/',
      method: 'POST',
      data: null,
      requireAuth: true,
    );

    if (result['success'] != true) {
      throw Exception('Failed to deactivate user: ${result['error']}');
    }
  }

  Future<void> activateUser(int userId) async {
    final result = await _apiInterceptor.executeApiCall(
      endpoint: '$_baseUrl/users/$userId/activate/',
      method: 'POST',
      data: null,
      requireAuth: true,
    );

    if (result['success'] != true) {
      throw Exception('Failed to activate user: ${result['error']}');
    }
  }

  // Analytics methods
  Future<Map<String, dynamic>> getUserAnalytics(DateTime startDate, DateTime endDate) async {
    final result = await _apiInterceptor.executeApiCall(
      endpoint: '$_baseUrl/users/analytics/',
      method: 'GET',
      data: null,
      requireAuth: true,
      headers: {
        'start-date': startDate.toIso8601String(),
        'end-date': endDate.toIso8601String(),
      },
    );

    if (result['success'] == true) {
      return result['data'];
    } else {
      throw Exception('Failed to fetch user analytics: ${result['error']}');
    }
  }
}

class UserStatistics {
  final int totalUsers;
  final int activeUsers;
  final int newUsersToday;
  final Map<String, int> usersByRole;

  UserStatistics({
    required this.totalUsers,
    required this.activeUsers,
    required this.newUsersToday,
    required this.usersByRole,
  });

  factory UserStatistics.fromJson(Map<String, dynamic> json) {
    return UserStatistics(
      totalUsers: json['total_users'] ?? 0,
      activeUsers: json['active_users'] ?? 0,
      newUsersToday: json['new_users_today'] ?? 0,
      usersByRole: Map<String, int>.from(json['users_by_role'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_users': totalUsers,
      'active_users': activeUsers,
      'new_users_today': newUsersToday,
      'users_by_role': usersByRole,
    };
  }
}

class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      avatar: json['avatar'],
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
