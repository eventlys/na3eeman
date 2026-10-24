import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../Helpers/error_handler.dart';
import '../Models/auth/user_model.dart';
import '../Models/commerce/payment_method.dart';
import '../Models/inventory/inventory_item.dart';
import '../Models/loyalty/points_model.dart';
import '../Models/reports/earnings_model.dart';
import '../Models/reports/profit_data.dart';
import '../Models/salon/review_model.dart';
import '../Models/salon/salons_model.dart' hide Review;
import '../Models/staff/expert.dart';
import '../Models/staff/staff_member.dart';
import '../Models/subscription/subscription_model.dart';
import '../Models/subscription/subscription_plan_model.dart';
import '../Helpers/logger.dart';
import '../Services/api/api_service.dart';
import '../Services/api/endpoints.dart';
import 'enums/points_types.dart';
import 'enums/staff_role.dart';
import 'repositories/appointment_repository.dart';
import 'repositories/loyalty_repository.dart';
import 'repositories/payment_repository.dart';
import 'repositories/report_repository.dart';
import 'repositories/review_repository.dart';
import 'repositories/salon_catalog_repository.dart';
import 'repositories/staff_repository.dart';
import 'repositories/subscription_repository.dart';
import 'repositories/user_repository.dart';
import '../Models/appointments/booking_group_model.dart';
import '../Models/appointments/salon_appointments_model.dart';
import '../Models/appointments/soonest_appointment_model.dart';
import '../Models/reports/report_request_model.dart';

// Report-related classes (ReportRequest, StaffReportRequest, ReportService,
// ReportData) moved to Models/reports/report_request_model.dart and
// repositories/report_repository.dart. Re-exported here so existing imports
// of business_service.dart keep working.
export '../Models/reports/report_request_model.dart';
export 'repositories/report_repository.dart' show ReportService;

/// Legacy facade over the domain repositories in `lib/Services/repositories/`.
///
/// All logic has been moved verbatim into focused repositories
/// (appointments, staff, salon catalog, payments, loyalty, reviews,
/// subscriptions, users, reports). This class only delegates so that the
/// many existing call sites keep working unchanged.
///
/// TODO(Phase 3.3/4): migrate call sites to the focused repositories and
/// delete this facade.
class BusinessService {
  static final BusinessService _instance = BusinessService._internal();
  factory BusinessService() => _instance;

  BusinessService._internal();

  // Delegated repositories
  final AppointmentRepository _appointments = AppointmentRepository();
  final StaffRepository _staff = StaffRepository();
  final SalonCatalogRepository _salons = SalonCatalogRepository();
  final PaymentRepository _payments = PaymentRepository();
  final LoyaltyRepository _loyalty = LoyaltyRepository();
  final ReviewRepository _reviews = ReviewRepository();
  final SubscriptionRepository _subscriptions = SubscriptionRepository();
  final UserRepository _users = UserRepository();
  final ReportRepository _reports = ReportRepository();

  // ============ APPOINTMENT SERVICES ============

  Future<List<SalonAppointment>> getAppointments({
    int page = 1,
    int limit = 20,
    String? status,
    int? salonId,
    int? customerId,
  }) => _appointments.getAppointments(
    page: page,
    limit: limit,
    status: status,
    salonId: salonId,
    customerId: customerId,
  );

  Future<SalonAppointment> createAppointment(
    Map<String, dynamic> appointmentData,
  ) => _appointments.createAppointment(appointmentData);

  Future<SalonAppointment> bookAppointment({
    required int customerId,
    required int salonId,
    required int? expertId,
    required DateTime startTime,
    required DateTime endTime,
    required List<Map<String, dynamic>> services,
    required String attendeeType,
    int? requestedStyleId,
    String? recurrence,
    DateTime? recurrenceEndDate,
    bool isGroup = false,
  }) => _appointments.bookAppointment(
    customerId: customerId,
    salonId: salonId,
    expertId: expertId,
    startTime: startTime,
    endTime: endTime,
    services: services,
    attendeeType: attendeeType,
    requestedStyleId: requestedStyleId,
    recurrence: recurrence,
    recurrenceEndDate: recurrenceEndDate,
    isGroup: isGroup,
  );

  Future<void> generateStaffReport(
    StaffReportRequest request, {
    required int salonId,
  }) => _reports.generateStaffReport(request, salonId: salonId);

  Future<void> cancelAppointment(String appointmentId, String reason) =>
      _appointments.cancelAppointment(appointmentId, reason);

  Future<SalonAppointment> rescheduleAppointment(
    String appointmentId,
    DateTime newStartTime,
    DateTime newEndTime,
  ) => _appointments.rescheduleAppointment(
    appointmentId,
    newStartTime,
    newEndTime,
  );

  Future<SoonestAppointment?> getSoonestAppointment(int customerId) =>
      _appointments.getSoonestAppointment(customerId);

  Future<SalonAppointment> createFreeAppointment(
    int customerId, {
    int? salonId,
  }) => _appointments.createFreeAppointment(customerId, salonId: salonId);

  // ============ BOOKING GROUP SERVICES ============

  Future<List<BookingGroup>> getBookingGroups({
    int page = 1,
    int limit = 20,
    int? organizerId,
  }) => _appointments.getBookingGroups(
    page: page,
    limit: limit,
    organizerId: organizerId,
  );

  Future<BookingGroup> createBookingGroup({
    required int organizerId,
    required bool isRecurring,
    int? salonId,
  }) => _appointments.createBookingGroup(
    organizerId: organizerId,
    isRecurring: isRecurring,
    salonId: salonId,
  );

  // ============ PAYMENT SERVICES ============

  Future<PaymentIntent> processPayment({
    required double amount,
    required String paymentMethod,
    PaymentCard? cardDetails,
    String? paymentMethodId,
    String currency = 'USD',
    int? userId,
    Map<String, dynamic>? metadata,
  }) => _payments.processPayment(
    amount: amount,
    paymentMethod: paymentMethod,
    cardDetails: cardDetails,
    paymentMethodId: paymentMethodId,
    currency: currency,
    userId: userId,
    metadata: metadata,
  );

  Future<PaymentIntent> createPaymentIntent({
    required double amount,
    required String paymentMethod,
    String currency = 'USD',
    Map<String, dynamic>? metadata,
  }) => _payments.createPaymentIntent(
    amount: amount,
    paymentMethod: paymentMethod,
    currency: currency,
    metadata: metadata,
  );

  Future<void> confirmCashPayment(
    int appointmentId,
    int confirmedByUserId,
    double amount,
  ) => _payments.confirmCashPayment(appointmentId, confirmedByUserId, amount);

  Future<List<PaymentIntent>> getPaymentHistory({
    int? userId,
    int? appointmentId,
    int page = 1,
    int limit = 20,
  }) => _payments.getPaymentHistory(
    userId: userId,
    appointmentId: appointmentId,
    page: page,
    limit: limit,
  );

  // ============ PDF REPORT SERVICES ============

  static Future<void> generateProfitReport(
    List<ProfitData> data,
    String period,
    String fileName,
  ) => ReportRepository.generateProfitReport(data, period, fileName);

  static Future<void> generateEarningsReport(
    List<EarningsData> data,
    String period,
    String fileName,
  ) => ReportRepository.generateEarningsReport(data, period, fileName);

  static Future<void> generateStaffPerformanceReport(
    List<Expert> experts,
    StaffReportRequest request,
  ) => ReportRepository.generateStaffPerformanceReport(experts, request);

  static Future<void> generateInventoryReport(
    List<InventoryItem> items,
    String reportType,
    String fileName,
  ) => ReportRepository.generateInventoryReport(items, reportType, fileName);

  static Future<void> generateAppointmentReport(
    List<SalonAppointment> appointments,
    String period,
    String fileName,
  ) => ReportRepository.generateAppointmentReport(
    appointments,
    period,
    fileName,
  );

  // ============ LOYALTY/POINTS SERVICES ============

  static const Map<PointsType, int> pointsValues =
      LoyaltyRepository.pointsValues;

  int getPointsForAction(PointsType action) =>
      _loyalty.getPointsForAction(action);

  Future<PointsModel> awardPoints({
    required int userId,
    required PointsType action,
    String description = '',
    Map<String, dynamic>? metadata,
  }) => _loyalty.awardPoints(
    userId: userId,
    action: action,
    description: description,
    metadata: metadata,
  );

  Future<PointsModel> awardReviewPoints(int userId, int reviewId) =>
      _loyalty.awardReviewPoints(userId, reviewId);

  Future<PointsModel> awardAppointmentPoints(int userId, int appointmentId) =>
      _loyalty.awardAppointmentPoints(userId, appointmentId);

  // ============ REVIEW SERVICES ============

  Future<Review> createReview({
    required int customerId,
    required int salonId,
    required int rating,
    required String comment,
    int? appointmentId,
    List<String>? photos,
  }) => _reviews.createReview(
    customerId: customerId,
    salonId: salonId,
    rating: rating,
    comment: comment,
    appointmentId: appointmentId,
    photos: photos,
  );

  Future<List<Review>> getSalonReviews(int salonId) =>
      _reviews.getSalonReviews(salonId);

  // ============ SALON SERVICES ============

  Future<List<Salon>> getSalons({
    int page = 1,
    int limit = 20,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
    double? lat,
    double? lng,
    double? radius,
  }) => _salons.getSalons(
    page: page,
    limit: limit,
    search: search,
    minRating: minRating,
    location: location,
    openNow: openNow,
    lat: lat,
    lng: lng,
    radius: radius,
  );

  Future<Salon> getSalonDetails(int salonId) =>
      _salons.getSalonDetails(salonId);

  Future<List<Expert>> getSalonExperts(int salonId) =>
      _salons.getSalonExperts(salonId);

  Future<double> calculateAppointmentTotal(String appointmentId) =>
      _salons.calculateAppointmentTotal(appointmentId);

  // ============ STAFF SERVICES ============

  Future<List<StaffMember>> getStaffMembers({
    String? branchId,
    int? salonId,
    StaffRole? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
  }) => _staff.getStaffMembers(
    branchId: branchId,
    salonId: salonId,
    role: role,
    isActive: isActive,
    page: page,
    limit: limit,
  );

  Future<List<Expert>> getExperts({
    String? branchId,
    int? salonId,
    bool? includePerformance,
  }) => _staff.getExperts(
    branchId: branchId,
    salonId: salonId,
    includePerformance: includePerformance,
  );

  // ============ SUBSCRIPTION SERVICES ============

  Future<Subscription> getSubscriptionDetails() =>
      _subscriptions.getSubscriptionDetails();

  Future<List<SubscriptionPlan>> getAvailablePlans() =>
      _subscriptions.getAvailablePlans();

  Future<Subscription> subscribe({
    required String planId,
    required String paymentMethodId,
    String? couponCode,
    bool autoRenew = true,
  }) => _subscriptions.subscribe(
    planId: planId,
    paymentMethodId: paymentMethodId,
    couponCode: couponCode,
    autoRenew: autoRenew,
  );

  // ============ USER SERVICES ============

  Future<User> getUserProfile(int userId) => _users.getUserProfile(userId);

  Future<User> updateUserProfile(int userId, Map<String, dynamic> updates) =>
      _users.updateUserProfile(userId, updates);
}

class InventoryService {
  final ApiService _apiService;

  InventoryService(this._apiService);

  Future<List<dynamic>> getLowStockItems({int? salonId}) async {
    try {
      if (salonId == null) {
        throw Exception('Salon ID is required to fetch inventory items.');
      }
      final Map<String, dynamic> queryParams = {};
      final String endpoint = '/salons/salons/$salonId/inventory/';
      queryParams['low_stock_only'] =
          'true'; // Map to general endpoint list filter

      final response = await _apiService.get(
        endpoint,
        queryParams: queryParams,
      );

      final List<dynamic> data = response['results'] ?? response['data'] ?? [];

      AppLogger.info('--- getLowStockItems ---');
      AppLogger.info('salonId: $salonId');
      AppLogger.info('Items count: ${data.length}');
      if (data.isNotEmpty) AppLogger.info('First item: ${data.first}');

      return data;
    } catch (e) {
      AppLogger.error('Error fetching low stock items: $e');
      throw ErrorHandler.handleException(e);
    }
  }

  Future<List<dynamic>> getInventoryItems({
    int? salonId,
    bool? lowStockOnly,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (salonId == null) {
        throw Exception('Salon ID is required to fetch inventory items.');
      }
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (lowStockOnly != null) {
        queryParams['low_stock_only'] = lowStockOnly.toString();
      }
      if (category != null) queryParams['category'] = category;

      final String endpoint = '/salons/salons/$salonId/inventory/';

      final response = await _apiService.get(
        endpoint,
        queryParams: queryParams,
      );

      final List<dynamic> data = response['results'] ?? response['data'] ?? [];

      AppLogger.info('--- getInventoryItems ---');
      AppLogger.info(
        'salonId: $salonId, lowStock: $lowStockOnly, category: $category',
      );
      AppLogger.info('Items count: ${data.length}');
      if (data.isNotEmpty) AppLogger.info('First item: ${data.first}');

      return data;
    } catch (e) {
      AppLogger.error('Error fetching inventory items: $e');
      rethrow;
    }
  }

  Future<dynamic> updateItemQuantity({
    required String itemId,
    required int salonId,
    required int newQuantity,
    String? reason,
  }) async {
    try {
      final response = await _apiService.patch(
        '/salons/salons/$salonId/inventory/$itemId/',
        data: {'quantity_in_stock': newQuantity, 'notes': ?reason},
      );
      return response['data'];
    } catch (e) {
      AppLogger.error('Error updating item quantity: $e');
      throw ErrorHandler.handleException(e);
    }
  }

  Future<dynamic> addInventoryItem({
    int? productId,
    String? productName,
    double? productPrice,
    String? category,
    required int salonId,
    required int initialQuantity,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '/salons/salons/$salonId/inventory/',
        data: {
          'product': ?productId,
          'product_name': ?productName,
          'product_price': ?productPrice,
          'category': ?category,
          'quantity_in_stock': initialQuantity,
          'notes': ?notes,
        },
      );
      return response['data'];
    } catch (e) {
      AppLogger.error('Error adding inventory item: $e');
      throw ErrorHandler.handleException(e);
    }
  }

  Future<void> deleteInventoryItem({
    required String itemId,
    required int salonId,
  }) async {
    try {
      await _apiService.delete('/salons/salons/$salonId/inventory/$itemId/');
    } catch (e) {
      AppLogger.error('Error deleting inventory item: $e');
      throw ErrorHandler.handleException(e);
    }
  }

  Future<Map<String, dynamic>> getInventoryAlerts({int? salonId}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (salonId != null) queryParams['salon'] = salonId.toString();

      final response = await _apiService.get(
        '/inventory/alerts',
        queryParams: queryParams,
      );

      return response['data'] ??
          {'low_stock_count': 0, 'out_of_stock_count': 0, 'critical_items': []};
    } catch (e) {
      AppLogger.error('Error fetching inventory alerts: $e');
      return {
        'low_stock_count': 0,
        'out_of_stock_count': 0,
        'critical_items': [],
      };
    }
  }

  List<dynamic> getCriticalStockItemsFromList(List<dynamic> items) {
    try {
      return items.where((item) {
        final currentStock =
            item['current_stock'] ?? item['quantity_in_stock'] ?? 0;
        final minStock = item['min_stock_level'] ?? 3;
        return currentStock <= minStock;
      }).toList();
    } catch (e) {
      AppLogger.error('Error filtering critical stock items: $e');
      return [];
    }
  }

  // Additional methods that might be needed
  Future<dynamic> getInventoryItem(String itemId) async {
    try {
      final response = await _apiService.get('/inventory/$itemId');
      return response['data'];
    } catch (e) {
      AppLogger.error('Error fetching inventory item: $e');
      throw ErrorHandler.handleException(e);
    }
  }

  Future<dynamic> updateInventoryItem({
    required String itemId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _apiService.patch(
        '/inventory/$itemId',
        data: data,
      );
      return response['data'];
    } catch (e) {
      AppLogger.error('Error updating inventory item: $e');
      throw ErrorHandler.handleException(e);
    }
  }

  Future<Map<String, dynamic>> getInventoryStats({int? salonId}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (salonId != null) queryParams['salon'] = salonId.toString();

      final response = await _apiService.get(
        '/inventory/stats',
        queryParams: queryParams,
      );

      return response['data'] ??
          {
            'total_items': 0,
            'low_stock_count': 0,
            'out_of_stock_count': 0,
            'total_value': 0,
          };
    } catch (e) {
      AppLogger.error('Error fetching inventory stats: $e');
      return {
        'total_items': 0,
        'low_stock_count': 0,
        'out_of_stock_count': 0,
        'total_value': 0,
      };
    }
  }
}

class OffersService {
  final ApiService _apiService = ApiService();

  Future<List<dynamic>> getSalonOffers(int salonId) async {
    return _apiService.getSalonOffers(salonId);
  }

  Future<Map<String, dynamic>> createOffer(
    int salonId,
    Map<String, dynamic> offerData,
  ) async {
    final response = await _apiService.createOffer(salonId, offerData);
    return response is Map<String, dynamic>
        ? response
        : (response as Map).cast<String, dynamic>();
  }

  Future<void> deleteOffer(int salonId, int offerId) async {
    await _apiService.deleteOffer(salonId, offerId);
  }

  Future<List<dynamic>> getSalonAdCampaigns(int salonId) async {
    return _apiService.getSalonAdCampaigns(salonId);
  }

  Future<Map<String, dynamic>> createAdCampaign(
    int salonId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.createAdCampaign(salonId, data);
    return response is Map<String, dynamic>
        ? response
        : (response as Map).cast<String, dynamic>();
  }

  Future<void> deleteAdCampaign(int salonId, int campaignId) async {
    await _apiService.deleteAdCampaign(salonId, campaignId);
  }

  Future<void> updateOffer(
    int salonId,
    int offerId,
    Map<String, dynamic> data,
  ) async {
    await _apiService.updateOffer(salonId, offerId, data);
  }

  Future<void> updateAdCampaign(
    int salonId,
    int campaignId,
    Map<String, dynamic> data,
  ) async {
    await _apiService.updateAdCampaign(salonId, campaignId, data);
  }

  Future<List<dynamic>> getSalonPackages(int salonId) async {
    return _apiService.getSalonPackages(salonId);
  }

  Future<Map<String, dynamic>> createPackage(
    int salonId,
    Map<String, dynamic> data,
  ) async {
    final response = await _apiService.createPackage(salonId, data);
    return response is Map<String, dynamic>
        ? response
        : (response as Map).cast<String, dynamic>();
  }

  Future<void> deletePackage(int salonId, int packageId) async {
    await _apiService.deletePackage(salonId, packageId);
  }

  Future<void> updatePackage(
    int salonId,
    int packageId,
    Map<String, dynamic> data,
  ) async {
    await _apiService.updatePackage(salonId, packageId, data);
  }
}

class ProfitService {
  final String baseUrl;

  ProfitService({required this.baseUrl});

  Future<Map<String, dynamic>> generateReport({
    required String reportType,
    required String format,
    required String fileName,
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
    String? authToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reports/generate'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'report_type': reportType,
          'format': format,
          'file_name': fileName,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
          'branch_id': branchId,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate report: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Report generation failed: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getProfitData({
    required DateTime startDate,
    required DateTime endDate,
    String? branchId,
    String? authToken,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/reports/profit-data?'
          'start_date=${startDate.toIso8601String()}'
          '&end_date=${endDate.toIso8601String()}'
          '${branchId != null ? '&branch_id=$branchId' : ''}',
        ),
        headers: {'Authorization': 'Bearer $authToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to fetch profit data: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Error fetching profit data: $e');
      rethrow;
    }
  }
}

class SalonGalleryService {
  final ApiService _apiService;

  SalonGalleryService({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<List<String>> getSalonGalleryImages(
    String salonId, {
    int limit = 4,
  }) async {
    try {
      final response = await _apiService.get(
        Endpoints.salonGallery(int.parse(salonId)),
        queryParams: {'limit': limit.toString()},
      );

      final List<dynamic> data = response is List
          ? response
          : (response['results'] ?? response['data'] ?? []);
      return data.map((item) => item['image_url'] as String).toList();
    } catch (e) {
      // If gallery fails, we can return empty or handle error
      AppLogger.error('Gallery Error: $e');
      return [];
    }
  }

  Future<List<String>> getSalonGalleryImagesFromUrls(
    List<String> imageUrls, {
    int limit = 4,
  }) async {
    try {
      if (imageUrls.isEmpty) {
        return [];
      }

      final effectiveLimit = limit > imageUrls.length
          ? imageUrls.length
          : limit;
      return imageUrls.sublist(0, effectiveLimit);
    } catch (e) {
      throw AppError(
        'Failed to process gallery images: ${ErrorHandler.handleError(e)}',
      );
    }
  }

  Future<bool> validateImageUrl(String imageUrl) async {
    try {
      // In a real app, you might want to make a HEAD request to check if the image exists
      return imageUrl.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

class SubscriptionService with ChangeNotifier {
  final ApiService _apiService;
  bool _isLoading = false;
  String? _error;
  dynamic _currentSubscription;

  bool get isLoading => _isLoading;
  String? get error => _error;
  dynamic get currentSubscription => _currentSubscription;

  SubscriptionService({required ApiService apiService})
    : _apiService = apiService;

  Future<void> getSubscriptionDetails() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/subscriptions/current');
      _currentSubscription = response['data'];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> upgradeSubscription(String plan) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.post('/subscriptions/upgrade', data: {'plan': plan});
      await getSubscriptionDetails(); // Refresh data
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class BranchService with ChangeNotifier {
  final ApiService _apiService;
  bool _isLoading = false;
  String? _error;
  List<dynamic> _branches = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<dynamic> get branches => _branches;

  BranchService({required ApiService apiService}) : _apiService = apiService;

  Future<void> getBranches() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/branches');
      _branches = response['data'] ?? [];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
