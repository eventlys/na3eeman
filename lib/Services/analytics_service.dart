// lib/Services/analytics/analytics_service.dart
import 'api/api_service.dart';
import 'api/endpoints.dart';
import 'package:na3eeman/Helpers/logger.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();

  factory AnalyticsService() => _instance;

  AnalyticsService._internal();

  final ApiService _apiService = ApiService();

  Future<void> logAppOpen() async {
    await _logEvent('app_open');
  }

  Future<void> logLogin({String? method, int? userId}) async {
    await _logEvent('login', parameters: {'method': method, 'user_id': userId});
  }

  Future<void> logSignUp({String? method, int? userId}) async {
    await _logEvent(
      'sign_up',
      parameters: {'method': method, 'user_id': userId},
    );
  }

  Future<void> logSearch({required String searchTerm, int? resultCount}) async {
    await _logEvent(
      'search',
      parameters: {'search_term': searchTerm, 'result_count': resultCount},
    );
  }

  Future<void> logViewItem({
    required int itemId,
    required String itemName,
    String? itemCategory,
  }) async {
    await _logEvent(
      'view_item',
      parameters: {
        'item_id': itemId,
        'item_name': itemName,
        'item_category': itemCategory ?? 'salon',
      },
    );
  }

  Future<void> logAddToCart({
    required int itemId,
    required String itemName,
    required double price,
    int? quantity,
    String? itemType, // 'OPTION', 'PACKAGE', 'PRODUCT'
  }) async {
    await _logEvent(
      'add_to_cart',
      parameters: {
        'item_id': itemId,
        'item_name': itemName,
        'price': price,
        'quantity': quantity ?? 1,
        'item_type': itemType,
        'currency': 'USD',
      },
    );
  }

  Future<void> logBeginCheckout({
    required double value,
    int? itemCount,
    List<int>? itemIds,
  }) async {
    await _logEvent(
      'begin_checkout',
      parameters: {
        'value': value,
        'currency': 'USD',
        'item_count': itemCount,
        'item_ids': itemIds,
      },
    );
  }

  Future<void> logPurchase({
    required String transactionId,
    required double value,
    List<int>? itemIds,
    String? paymentMethod,
  }) async {
    await _logEvent(
      'purchase',
      parameters: {
        'transaction_id': transactionId,
        'value': value,
        'currency': 'USD',
        'item_ids': itemIds,
        'payment_method': paymentMethod,
      },
    );
  }

  Future<void> logAppointmentBooked({
    required int appointmentId,
    required int salonId,
    required double amount,
    String? bookingGroupId,
  }) async {
    await _logEvent(
      'appointment_booked',
      parameters: {
        'appointment_id': appointmentId,
        'salon_id': salonId,
        'amount': amount,
        'booking_group_id': bookingGroupId,
      },
    );
  }

  Future<void> logFreeHaircutRedeemed({
    required int customerId,
    required int appointmentId,
  }) async {
    await _logEvent(
      'free_haircut_redeemed',
      parameters: {'customer_id': customerId, 'appointment_id': appointmentId},
    );
  }

  Future<void> logLoyaltyPointsEarned({
    required int customerId,
    required int points,
    required String source,
  }) async {
    await _logEvent(
      'loyalty_points_earned',
      parameters: {
        'customer_id': customerId,
        'points': points,
        'source': source,
      },
    );
  }

  Future<void> logCustomEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    await _logEvent(name, parameters: parameters);
  }

  Future<void> setUserProperties({
    int? userId,
    String? userRole,
    String? email,
    String? name,
  }) async {
    await _logEvent(
      'user_identify',
      parameters: {
        'user_id': userId,
        'user_role': userRole,
        'email': email,
        'name': name,
      },
    );
  }

  Future<void> _logEvent(
    String name, {
    Map<String, Object?>? parameters,
  }) async {
    try {
      final eventData = {
        'event_name': name,
        'parameters': parameters ?? {},
        'timestamp': DateTime.now().toIso8601String(),
        'platform': 'flutter',
        'app_version': '1.0.0',
      };

      // Disable API call temporarily as backend does not have analytics app
      // await _apiService.post('/analytics/events', data: eventData);

      // Also log locally for debugging
      AppLogger.info('Analytics Event: $name, Parameters: $parameters');
    } catch (e) {
      // Silent fail for analytics - we don't want analytics failures to break the app
      AppLogger.error('Analytics error: $e');
    }
  }

  // Screen view tracking
  Future<void> logScreenView(
    String screenName, {
    Map<String, Object?>? parameters,
  }) async {
    await _logEvent(
      'screen_view',
      parameters: {'screen_name': screenName, ...?parameters},
    );
  }

  // Error tracking
  Future<void> logError(
    String error,
    StackTrace stackTrace, {
    String? context,
  }) async {
    await _logEvent(
      'error_occurred',
      parameters: {
        'error': error,
        'stack_trace': stackTrace.toString(),
        'context': context,
      },
    );
  }

  // Performance tracking
  Future<void> logPerformance(
    String action,
    int durationMs, {
    Map<String, Object?>? parameters,
  }) async {
    await _logEvent(
      'performance',
      parameters: {'action': action, 'duration_ms': durationMs, ...?parameters},
    );
  }

  // ============ ADMIN ANALYTICS FETCHING ============

  Future<Map<String, dynamic>> getAdminOverview() async {
    return await _apiService.get(Endpoints.adminAnalyticsOverview);
  }

  Future<Map<String, dynamic>> getAdminUserAnalytics() async {
    return await _apiService.get(Endpoints.adminAnalyticsUsers);
  }

  Future<Map<String, dynamic>> getAdminUsageAnalytics() async {
    return await _apiService.get(Endpoints.adminAnalyticsUsage);
  }

  Future<Map<String, dynamic>> getAdminFinancialAnalytics() async {
    return await _apiService.get(Endpoints.adminAnalyticsFinancial);
  }

  Future<Map<String, dynamic>> getAdminSystemAnalytics() async {
    return await _apiService.get(Endpoints.adminAnalyticsSystem);
  }

  /// Fetch filtered service requests for admin review.
  Future<List<dynamic>> getServiceRequests(Map<String, String> params) async {
    final result = await _apiService.get(
      Endpoints.feedback,
      queryParams: params,
    );
    if (result is List) return result;
    if (result is Map && result.containsKey('results')) {
      return result['results'];
    }
    return [];
  }
}
