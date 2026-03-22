import 'dart:convert';
// import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// Models
import '../Helpers/customized/reports_helper.dart';
import '../Helpers/error_handler.dart';
import '../Helpers/config.dart';
import '../Helpers/gallery_helper.dart';
import '../Models/appointments/booking_group_model.dart';
import '../Models/appointments/shop_appointments_model.dart';
import '../Models/appointments/soonest_appointment_model.dart';
import '../Models/commerce/payment_method.dart';
import '../Models/inventory/inventory_item.dart';
import '../Models/loyalty/points_model.dart';
import '../Models/reports/earnings_model.dart';
import '../Models/reports/profit_data.dart';
import '../Models/shop/review_model.dart';
import '../Models/shop/shops_model.dart' hide Review;
import '../Models/staff/barber.dart';
import '../Models/staff/staff_member.dart';
import '../Models/subscriptions/subscription.dart';
import '../Models/subscriptions/subscription_model.dart';
import '../Models/auth/user_model.dart';

// Core
import 'enums/appointment_status.dart';
import 'enums/attendee_type.dart';
import '../Helpers/logger.dart';
import '../Packages/Core/utils/formatters.dart';

// Services
import '../Services/api/api_service.dart';
import 'api/api_interceptor_service.dart';
import 'enums/report_enums.dart';
import 'enums/staff_role.dart';
import 'security_service.dart';

class ReportRequest {
  final ReportTime time;
  final DateTime startDate;
  final DateTime endDate;
  final String? branchId;
  final ReportFormat format;
  final String fileName;
  final ReportType? reportType;

  ReportRequest({
    required this.time,
    required this.startDate,
    required this.endDate,
    this.branchId,
    this.format = ReportFormat.pdf,
    required this.fileName,
    this.reportType,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'branch_id': branchId,
      'format': format.toString().split('.').last,
      'file_name': fileName,
      'report_type': reportType?.toString().split('.').last,
    };
  }
}

class StaffReportRequest {
  final ReportTime time;
  final DateTime startDate;
  final DateTime endDate;
  final String? branchId;
  final String? staffId;
  final String fileName;
  final StaffReportType reportType;

  StaffReportRequest({
    required this.time,
    required this.startDate,
    required this.endDate,
    this.branchId,
    this.staffId,
    required this.fileName,
    required this.reportType,
  });

  Map<String, dynamic> toJson() {
    return {
      'time': time.toString().split('.').last,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'branch_id': branchId,
      'staff_id': staffId,
      'file_name': fileName,
      'report_type': reportType.toString().split('.').last,
    };
  }
}

class ReportService {
  final ApiService _apiService = ApiService();
  final BusinessService _businessService = BusinessService();

  Future<ReportResult> generateReport({
    required ReportType reportType,
    required ReportTime timePeriod,
    required DateTime startDate,
    required DateTime endDate,
    String? fileName,
    String? branchId,
    ReportFormat format = ReportFormat.pdf,
  })
  async {
    try {
      final request = ReportRequest(
        time: timePeriod,
        startDate: startDate,
        endDate: endDate,
        branchId: branchId,
        format: format,
        fileName: fileName ?? 'report_${DateTime.now().millisecondsSinceEpoch}',
        reportType: reportType,
      );

      final response = await _apiService.post(
        '/reports/generate',
        data: request.toJson(),
      );

      return ReportResult(
        success: true,
        downloadUrl: response['download_url'],
        fileName: response['file_name'],
      );
    } catch (e) {
      return ReportResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<ReportResult> generateStaffReport(StaffReportRequest request) async {
    try {
      // Use the BusinessService method for staff reports
      await _businessService.generateStaffReport(
        request,
        shopId: 1, // You'll need to get this from context/auth
      );

      return ReportResult(
        success: true,
        downloadUrl: 'generated_staff_report_${DateTime.now().millisecondsSinceEpoch}.pdf',
        fileName: request.fileName,
      );
    } catch (e) {
      return ReportResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }
}

class ReportData {
  final String id;
  final ReportTime time;
  final DateTime generatedAt;
  final Map<String, dynamic> data;
  final String downloadUrl;
  final String fileName;

  ReportData({
    required this.id,
    required this.time,
    required this.generatedAt,
    required this.data,
    required this.downloadUrl,
    required this.fileName,
  });

  factory ReportData.fromJson(Map<String, dynamic> json) {
    return ReportData(
      id: json['id']?.toString() ?? '',
      time: ReportTime.values.firstWhere(
        (e) => e.toString().split('.').last == json['time'],
        orElse: () => ReportTime.monthly,
      ),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      downloadUrl: json['download_url'] as String,
      fileName: json['file_name'] as String,
    );
  }
}

class BusinessService {
  static final BusinessService _instance = BusinessService._internal();
  factory BusinessService() => _instance;

  BusinessService._internal();

  // Service instances
  final ApiService _apiService = ApiService();
  final ApiInterceptorService _logger = ApiInterceptorService(ApiService());
  final SecurityService _networkSecurity = SecurityService();

  static String get _baseUrl => AppConfig.baseUrl;

  // ============ APPOINTMENT SERVICES ============

  Future<List<ShopAppointment>> getAppointments({
    int page = 1,
    int limit = 20,
    String? status,
    int? shopId,
    int? customerId,
  })
  async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) queryParams['status'] = status;
      if (shopId != null) queryParams['shop'] = shopId.toString();
      if (customerId != null) queryParams['customer'] = customerId.toString();

      final response = await _apiService.get(
        '/appointments',
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => ShopAppointment.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching appointments: $e');
      return _getMockAppointments();
    }
  }

  Future<ShopAppointment> createAppointment(Map<String, dynamic> appointmentData) async {
    try {
      final response = await _apiService.post(
        '/appointments',
        data: appointmentData,
      );
      return ShopAppointment.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error creating appointment: $e');
      rethrow;
    }
  }

  Future<ShopAppointment> bookAppointment({
    required int customerId,
    required int shopId,
    required int? barberId,
    required DateTime startTime,
    required DateTime endTime,
    required List<Map<String, dynamic>> services,
    required String attendeeType,
    int? requestedStyleId,
    String? recurrence,
    DateTime? recurrenceEndDate,
    bool isGroup = false,
  })
  async {
    try {
      final appointmentData = {
        'customer': customerId,
        'shop': shopId,
        'barber': barberId,
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'attendee_type': attendeeType,
        'services': services,
        'style': requestedStyleId,
        'recurrence': recurrence,
        'recurrence_end_date': recurrenceEndDate?.toIso8601String(),
        'is_group': isGroup,
      };

      final response = await _apiService.post(
        '/appointments/book',
        data: appointmentData,
      );
      return ShopAppointment.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error booking appointment: $e');
      rethrow;
    }
  }

  // Add this method to your BusinessService class
  Future<void> generateStaffReport(StaffReportRequest request, {required int shopId}) async {
    try {
      AppLogger.debug('Generating staff report: ${request.reportType} for shop: $shopId');

      switch (request.reportType) {
        case StaffReportType.performance:
          final barbers = await getBarbers(
            shopId: shopId,
            includePerformance: true,
          );
          await generateStaffPerformanceReport(barbers, request);
          break;

        case StaffReportType.attendance:
          final appointments = await getAppointments(
            shopId: shopId,
            status: 'completed',
          );
          await generateAppointmentReport(
            appointments,
            _getTimeDisplayName(request.time),
            request.fileName,
          );
          break;

        case StaffReportType.payroll:
          final barbers = await getBarbers(
            shopId: shopId,
            includePerformance: true,
          );
          final earningsData = barbers.map((barber) => EarningsData(
            date: DateTime.now(),
            amount: barber.totalEarnings,
            appointments: barber.totalAppointments,
            tips: 0.0,
            shopId: shopId, // Add the required shopId
            barberId: barber.userId, // Add barberId
          )).toList();

          await generateEarningsReport(
            earningsData,
            _getTimeDisplayName(request.time),
            request.fileName,
          );
          break;

        case StaffReportType.daily:
        case StaffReportType.weekly:
        case StaffReportType.monthly:
        case StaffReportType.annually:
          // Generate summary report for the time period
          final barbers = await getBarbers(
            shopId: shopId,
            includePerformance: true,
          );
          await generateStaffPerformanceReport(barbers, request);
          break;
      }

      AppLogger.debug('Staff report generated successfully');
    } catch (e) {
      AppLogger.error('Error generating staff report: $e');
      rethrow;
    }
  }

  // Add this helper method to BusinessService
  String _getTimeDisplayName(ReportTime time) {
    switch (time) {
      case ReportTime.daily:
        return 'Daily';
      case ReportTime.weekly:
        return 'Weekly';
      case ReportTime.monthly:
        return 'Monthly';
      case ReportTime.annually:
        return 'Annually';
    }
  }

  Future<void> cancelAppointment(String appointmentId, String reason) async {
    try {
      await _apiService.patch(
        '/appointments/$appointmentId/cancel',
        data: {'reason': reason},
      );
    } catch (e) {
      AppLogger.error('Error cancelling appointment: $e');
      rethrow;
    }
  }

  Future<ShopAppointment> rescheduleAppointment(
    String appointmentId,
    DateTime newStartTime,
    DateTime newEndTime,
  )
  async {
    try {
      final response = await _apiService.patch(
        '/appointments/$appointmentId/reschedule',
        data: {
          'new_start_time': newStartTime.toIso8601String(),
          'new_end_time': newEndTime.toIso8601String(),
        },
      );
      return ShopAppointment.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error rescheduling appointment: $e');
      rethrow;
    }
  }

  Future<SoonestAppointment?> getSoonestAppointment(int customerId)
  async {
    try {
      final response = await _apiService.get(
        '/appointments/soonest',
        queryParams: {'customer': customerId.toString()},
      );

      if (response['data'] != null) {
        return SoonestAppointment.fromAppointment(response['data']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error fetching soonest appointment: $e');
      return null;
    }
  }

  Future<ShopAppointment> createFreeAppointment(int customerId, {int? shopId})
  async {
    try {
      final data = {'customer': customerId};
      if (shopId != null) data['shop'] = shopId;

      final response = await _apiService.post(
        '/appointments/free',
        data: data,
      );
      return ShopAppointment.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error creating free appointment: $e');
      rethrow;
    }
  }

  // ============ BOOKING GROUP SERVICES ============

  Future<List<BookingGroup>> getBookingGroups({
    int page = 1,
    int limit = 20,
    int? organizerId,
  })
  async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (organizerId != null) queryParams['organizer'] = organizerId.toString();

      final response = await _apiService.get(
        '/booking-groups',
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => BookingGroup.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching booking groups: $e');
      return [];
    }
  }

  Future<BookingGroup> createBookingGroup({
    required int organizerId,
    required bool isRecurring,
    int? shopId,
  })
  async {
    try {
      _logger.logRequest('POST', '$_baseUrl/booking-groups/', {
        'organizer': organizerId,
        'is_recurring': isRecurring,
        'shop': shopId,
      });

      final response = await _networkSecurity.securePost(
        '$_baseUrl/booking-groups/',
        headers: await _getAuthHeaders(),
        body: json.encode({
          'organizer': organizerId,
          'is_recurring': isRecurring,
          'shop': shopId,
        }),
      );

      final responseBody = await response.transform(utf8.decoder).join();
      _logger.logResponse(response.statusCode, responseBody);

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        return BookingGroup.fromJson(data);
      } else {
        throw Exception('Failed to create booking group: ${response.statusCode}');
      }
    } catch (error) {
      AppLogger.error('Error creating booking group: $error');
      rethrow;
    }
  }

  // ============ PAYMENT SERVICES ============

  Future<PaymentIntent> processPayment({
    required double amount,
    required String paymentMethod,
    PaymentCard? cardDetails,
    String? paymentMethodId,
    String currency = 'USD',
    int? userId,
    Map<String, dynamic>? metadata,
  })
  async {
    try {
      String endpoint = '/payments/process/$paymentMethod';
      Map<String, dynamic> data = {
        'amount': amount,
        'currency': currency,
      };

      if (paymentMethod == 'visa' && cardDetails != null) {
        data['card_details'] = cardDetails.toJson();
        if (userId != null) data['user_id'] = userId;
      } else if (paymentMethod == 'stripe' && paymentMethodId != null) {
        data['payment_method_id'] = paymentMethodId;
      }

      if (metadata != null) data['metadata'] = metadata;

      final response = await _apiService.post(endpoint, data: data);
      return PaymentIntent.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error processing payment: $e');
      rethrow;
    }
  }

  Future<PaymentIntent> createPaymentIntent({
    required double amount,
    required String paymentMethod,
    String currency = 'USD',
    Map<String, dynamic>? metadata,
  })
  async {
    try {
      final response = await _apiService.post(
        '/payments/create-intent',
        data: {
          'amount': amount,
          'currency': currency,
          'payment_method': paymentMethod,
          'metadata': metadata ?? {},
        },
      );
      return PaymentIntent.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error creating payment intent: $e');
      rethrow;
    }
  }

  Future<void> confirmCashPayment(int appointmentId, int confirmedByUserId, double amount) async {
    try {
      await _apiService.post(
        '/payments/confirm-cash',
        data: {
          'appointment': appointmentId,
          'confirmed_by': confirmedByUserId,
          'amount': amount,
        },
      );
    } catch (e) {
      AppLogger.error('Error confirming cash payment: $e');
      rethrow;
    }
  }

  Future<List<PaymentIntent>> getPaymentHistory({
    int? userId,
    int? appointmentId,
    int page = 1,
    int limit = 20,
  })
  async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (userId != null) queryParams['user'] = userId.toString();
      if (appointmentId != null) queryParams['appointment'] = appointmentId.toString();

      final response = await _apiService.get(
        '/payments/history',
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => PaymentIntent.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching payment history: $e');
      return [];
    }
  }

  // ============ PDF REPORT SERVICES ============

  static Future<void> generateProfitReport(
    List<ProfitData> data,
    String period,
    String fileName,
  )
  async {
    final pdf = pw.Document();
    pdf.addPage(_buildProfitReportPage(data, period));
    await _savePdf(pdf, fileName);
  }

  static Future<void> generateEarningsReport(
    List<EarningsData> data,
    String period,
    String fileName,
  )
  async {
    final pdf = pw.Document();
    pdf.addPage(_buildEarningsReportPage(data, period));
    await _savePdf(pdf, fileName);
  }

  static Future<void> generateStaffPerformanceReport(
    List<Barber> barbers,
    StaffReportRequest request,
  )
  async {
    final pdf = pw.Document();
    pdf.addPage(_buildStaffPerformancePage(barbers, request));
    await _savePdf(pdf, 'staff_performance_${DateTime.now().millisecondsSinceEpoch}');
  }

  static Future<void> generateInventoryReport(
    List<InventoryItem> items,
    String reportType,
    String fileName,
  )
  async {
    final pdf = pw.Document();
    pdf.addPage(_buildInventoryReportPage(items, reportType));
    await _savePdf(pdf, fileName);
  }

  static Future<void> generateAppointmentReport(
    List<ShopAppointment> appointments,
    String period,
    String fileName,
  )
  async {
    final pdf = pw.Document();
    pdf.addPage(_buildAppointmentReportPage(appointments, period));
    await _savePdf(pdf, fileName);
  }

  // ============ LOYALTY/POINTS SERVICES ============

  static const Map<PointsType, int> pointsValues = {
    PointsType.appointmentComplete: 50,
    PointsType.reviewWrite: 25,
    PointsType.referral: 100,
    PointsType.rewardRedeem: 0,
    PointsType.other: 10,
  };

  int getPointsForAction(PointsType action) {
    return pointsValues[action] ?? 0;
  }

  Future<PointsModel> awardPoints({
    required int userId,
    required PointsType action,
    String description = '',
    Map<String, dynamic>? metadata,
  })
  async {
    try {
      final points = getPointsForAction(action);
      AppLogger.debug('Awarding $points points to user $userId for $action');

      final pointsModel = PointsModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        points: points,
        type: action,
        description: description.isNotEmpty ? description : _getDefaultDescription(action),
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      AppLogger.debug('Points awarded successfully: ${pointsModel.id}');
      return pointsModel;
    } catch (e) {
      AppLogger.error('Failed to award points: $e');
      rethrow;
    }
  }

  Future<PointsModel> awardReviewPoints(int userId, int reviewId) async {
    return await awardPoints(
      userId: userId,
      action: PointsType.reviewWrite,
      description: 'Points for writing a review',
      metadata: {'review_id': reviewId},
    );
  }

  Future<PointsModel> awardAppointmentPoints(int userId, int appointmentId) async {
    return await awardPoints(
      userId: userId,
      action: PointsType.appointmentComplete,
      description: 'Points for completing an appointment',
      metadata: {'appointment_id': appointmentId},
    );
  }

  // ============ REVIEW SERVICES ============

  Future<Review> createReview({
    required int customerId,
    required int shopId,
    required int rating,
    required String comment,
    int? appointmentId,
    List<String>? photos,
  })
  async {
    try {
      _logger.logRequest('POST', '$_baseUrl/reviews/', {
        'customer': customerId,
        'shop': shopId,
        'rating': rating,
        'comment': comment,
        'appointment': appointmentId,
        'photos': photos,
      });

      final response = await _networkSecurity.securePost(
        '$_baseUrl/reviews/',
        headers: await _getAuthHeaders(),
        body: json.encode({
          'customer': customerId,
          'shop': shopId,
          'rating': rating,
          'comment': comment,
          'appointment': appointmentId,
          'photos': photos ?? [],
        }),
      );

      final responseBody = await response.transform(utf8.decoder).join();
      _logger.logResponse(response.statusCode, responseBody);

      if (response.statusCode == 201) {
        final data = json.decode(responseBody);
        await awardReviewPoints(customerId, data['id']);
        return Review.fromJson(data);
      } else {
        throw Exception('Failed to create review: ${response.statusCode}');
      }
    } catch (error) {
      AppLogger.error('Error creating review: $error');
      rethrow;
    }
  }

  Future<List<Review>> getShopReviews(int shopId) async {
    try {
      final response = await _apiService.get('/shops/$shopId/reviews');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Review.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching shop reviews: $e');
      return [];
    }
  }

  // ============ SHOP SERVICES ============

  Future<List<Shop>> getShops({
    int page = 1,
    int limit = 20,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
    double? lat,
    double? lng,
    double? radius,
  })
  async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (search != null) queryParams['search'] = search;
      if (minRating != null) queryParams['min_rating'] = minRating.toString();
      if (location != null) queryParams['location'] = location;
      if (openNow != null) queryParams['open_now'] = openNow.toString();
      if (lat != null) queryParams['lat'] = lat.toString();
      if (lng != null) queryParams['lng'] = lng.toString();
      if (radius != null) queryParams['radius'] = radius.toString();

      final response = await _apiService.get(
        '/shops',
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((json) => Shop.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('Error fetching shops: $e');
      return [];
    }
  }

  Future<Shop> getShopDetails(int shopId) async {
    try {
      final response = await _apiService.get('/shops/$shopId');
      return Shop.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error fetching shop details: $e');
      rethrow;
    }
  }

  Future<List<Barber>> getShopBarbers(int shopId) async {
    try {
      final response = await _apiService.get('/shops/$shopId/barbers');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => Barber.fromJson(item)).toList();
    } catch (e) {
      AppLogger.error('Error fetching shop barbers: $e');
      return [];
    }
  }

  Future<double> calculateAppointmentTotal(String appointmentId) async {
    try {
      final response = await _apiService.get('/shops/calculate-total/$appointmentId');
      return (response['data']['total'] as num).toDouble();
    } catch (e) {
      AppLogger.error('Error calculating appointment total: $e');
      rethrow;
    }
  }

  // ============ STAFF SERVICES ============

  Future<List<StaffMember>> getStaffMembers({
    String? branchId,
    int? shopId,
    StaffRole? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
  })
  async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (branchId != null) queryParams['branch_id'] = branchId;
      if (shopId != null) queryParams['shop'] = shopId.toString();
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
      return _getMockStaffMembers();
    }
  }

  Future<List<Barber>> getBarbers({
    String? branchId,
    int? shopId,
    bool? includePerformance,
  })
  async {
    try {
      final Map<String, dynamic> queryParams = {};

      if (branchId != null) queryParams['branch_id'] = branchId;
      if (shopId != null) queryParams['shop'] = shopId.toString();
      if (includePerformance != null) queryParams['include_performance'] = includePerformance.toString();

      final response = await _apiService.get(
        '/barbers',
        queryParams: queryParams,
      );

      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => Barber.fromJson(item)).toList();
    } catch (e) {
      AppLogger.error('Error fetching barbers: $e');
      final staff = await getStaffMembers(shopId: shopId);
      return _convertStaffToBarbers(staff.where((member) => member.role == StaffRole.barber).toList());
    }
  }

  // ============ SUBSCRIPTION SERVICES ============

  Future<Subscription> getSubscriptionDetails() async {
    try {
      final response = await _apiService.get('/subscription');
      return Subscription.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error fetching subscription details: $e');
      rethrow;
    }
  }

  Future<List<SubscriptionPlan>> getAvailablePlans() async {
    try {
      final response = await _apiService.get('/subscription/plans');
      final List<dynamic> data = response['data'] ?? [];
      return data.map((item) => SubscriptionPlan.fromJson(item)).toList();
    } catch (e) {
      AppLogger.error('Error fetching subscription plans: $e');
      return _getMockSubscriptionPlans();
    }
  }

  Future<Subscription> subscribe({
    required String planId,
    required String paymentMethodId,
    String? couponCode,
    bool autoRenew = true,
  })
  async {
    try {
      final response = await _apiService.post(
        '/subscription/subscribe',
        data: {
          'plan_id': planId,
          'payment_method_id': paymentMethodId,
          'coupon_code': couponCode,
          'auto_renew': autoRenew,
        },
      );
      return Subscription.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error subscribing to plan: $e');
      rethrow;
    }
  }

  // ============ USER SERVICES ============

  Future<User> getUserProfile(int userId) async {
    try {
      final response = await _apiService.get('/users/$userId');
      return User.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error fetching user profile: $e');
      rethrow;
    }
  }

  Future<User> updateUserProfile(int userId, Map<String, dynamic> updates) async {
    try {
      final response = await _apiService.patch(
        '/users/$userId',
        data: updates,
      );
      return User.fromJson(response['data']);
    } catch (e) {
      AppLogger.error('Error updating user profile: $e');
      rethrow;
    }
  }

  // ============ HELPER METHODS ============

  Future<Map<String, String>> _getAuthHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${await _getToken()}',
    };
  }

  Future<String> _getToken() async {
    // Implement token retrieval from your auth service
    return ''; // Replace with actual token retrieval
  }

  String _getDefaultDescription(PointsType action) {
    switch (action) {
      case PointsType.appointmentComplete:
        return 'Appointment completed';
      case PointsType.reviewWrite:
        return 'Review written';
      case PointsType.referral:
        return 'Customer referred';
      case PointsType.rewardRedeem:
        return 'Reward redeemed';
      case PointsType.other:
        return 'Points awarded';
    }
  }

  // ============ MOCK DATA METHODS ============

  List<ShopAppointment> _getMockAppointments() {
    return [
      ShopAppointment(
        id: '1',
        customerId: 1,
        shopId: 1,
        barberId: 1,
        startTime: DateTime.now().add(Duration(hours: 2)),
        endTime: DateTime.now().add(Duration(hours: 2, minutes: 30)),
        status: AppointmentStatus.scheduled,
        isFree: false,
        attendeeType: AttendeeType.self,
        createdAt: DateTime.now(),
        services: [
          AppointmentServiceModel(
            serviceType: 'OPTION',
            optionId: 1,
            quantity: 1,
          ),
        ],
      ),
    ];
  }

  List<InventoryItem> _getMockInventoryItems() {
    return [
      InventoryItem(
        id: '1',
        productId: 1,
        shopId: 1,
        quantityInStock: 5,
        lastUpdated: DateTime.now(),
        productName: 'Professional Shampoo',
        productDescription: 'Premium shampoo for all hair types',
        productPrice: 15.99,
      ),
      InventoryItem(
        id: '2',
        productId: 2,
        shopId: 1,
        quantityInStock: 2,
        lastUpdated: DateTime.now(),
        productName: 'Conditioner',
        productDescription: 'Hydrating conditioner',
        productPrice: 12.99,
      ),
    ];
  }

  List<StaffMember> _getMockStaffMembers() {
    return [
      StaffMember(
        id: '1',
        userId: 1,
        name: 'John Barber',
        email: 'john@barbershop.com',
        phone: '+1234567890',
        role: StaffRole.barber,
        joinDate: DateTime(2023, 1, 15),
        shopId: 1,
        hourlyRate: 25.0,
        specialties: ['Haircut', 'Beard Trim', 'Styling'],
        isActive: true,
      ),
    ];
  }

  List<Barber> _convertStaffToBarbers(List<StaffMember> barberStaff) {
    return barberStaff.asMap().entries.map((entry) {
      final index = entry.key;
      final staffMember = entry.value;
      return Barber(
        id: staffMember.id,
        userId: staffMember.userId,
        name: staffMember.name,
        email: staffMember.email,
        joinDate: staffMember.joinDate,
        profileImage: staffMember.profileImage,
        shopId: staffMember.shopId,
        isActive: staffMember.isActive,
        hourlyRate: staffMember.hourlyRate,
        barberProfile: null,
        rating: 4.5 + (index * 0.1),
        totalAppointments: 100 + (index * 50),
        totalEarnings: 5000 + (index * 2500).toDouble(),
        specialties: staffMember.specialties ?? ['Haircut', 'Beard Trim'],
        servicesCount: {'Haircut': 70 + index * 20, 'Beard Trim': 30 + index * 10},
        lastActive: DateTime.now().subtract(Duration(hours: index * 2)),
      );
    }).toList();
  }

  List<SubscriptionPlan> _getMockSubscriptionPlans() {
    return [
      SubscriptionPlan(
        id: '1',
        name: 'Basic',
        description: 'Perfect for small barbershops',
        price: 29.99,
        duration: 'MONTHLY',
        features: [
          'Up to 2 branches',
          'Basic analytics',
          'Email support',
          'Staff management',
        ],
        maxBranches: 2,
        maxStaff: 5,
        analyticsEnabled: true,
        premiumSupport: false,
        trialDays: 14,
      ),
      SubscriptionPlan(
        id: '2',
        name: 'Professional',
        description: 'For growing barbershop businesses',
        price: 59.99,
        duration: 'MONTHLY',
        features: [
          'Up to 5 branches',
          'Advanced analytics',
          'Priority support',
          'Staff management',
          'Marketing tools',
        ],
        isPopular: true,
        maxBranches: 5,
        maxStaff: 15,
        analyticsEnabled: true,
        premiumSupport: true,
        trialDays: 14,
      ),
    ];
  }

  // ============ PDF HELPER METHODS ============

  static Future<void> _savePdf(pw.Document pdf, String fileName) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Page _buildProfitReportPage(List<ProfitData> data, String period) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, child: pw.Text('Profit Report - $period')),
            pw.SizedBox(height: 20),
            _buildProfitTable(data),
            pw.SizedBox(height: 20),
            _buildProfitSummary(data),
          ],
        );
      },
    );
  }

  static pw.Page _buildEarningsReportPage(List<EarningsData> data, String period) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(level: 0, child: pw.Text('Earnings Report - $period')),
            pw.SizedBox(height: 20),
            _buildEarningsTable(data),
            pw.SizedBox(height: 20),
            _buildEarningsSummary(data),
          ],
        );
      },
    );
  }

  static pw.Page _buildStaffPerformancePage(List<Barber> barbers, StaffReportRequest request) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Staff Performance Report',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              'Period: ${Formatters.formatDate(request.startDate)} - ${Formatters.formatDate(request.endDate)}',
              style: const pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 20),
            _buildStaffPerformanceTable(barbers),
            pw.SizedBox(height: 30),
            _buildPerformanceSummary(barbers),
          ],
        );
      },
    );
  }

  static pw.Page _buildInventoryReportPage(List<InventoryItem> items, String reportType) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Inventory Report - $reportType',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildInventoryTable(items),
            pw.SizedBox(height: 20),
            _buildInventorySummary(items),
          ],
        );
      },
    );
  }

  static pw.Page _buildAppointmentReportPage(List<ShopAppointment> appointments, String period) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Appointment Report - $period',
                style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            _buildAppointmentTable(appointments),
            pw.SizedBox(height: 20),
            _buildAppointmentSummary(appointments),
          ],
        );
      },
    );
  }

  // Table builders (static methods from original PdfService)
  static pw.Widget _buildProfitTable(List<ProfitData> data) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('Revenue'),
            _buildTableHeader('Profit'),
            _buildTableHeader('Expenses'),
            _buildTableHeader('Profit Margin'),
          ],
        ),
        for (var item in data)
          pw.TableRow(
            children: [
              _buildTableCell(Formatters.formatDate(item.date)),
              _buildTableCell(Formatters.formatCurrency(item.revenue)),
              _buildTableCell(Formatters.formatCurrency(item.profit)),
              _buildTableCell(Formatters.formatCurrency(item.expenses)),
              _buildTableCell('${item.profitMargin.toStringAsFixed(1)}%'),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildEarningsTable(List<EarningsData> data) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('Amount'),
            _buildTableHeader('Appointments'),
            _buildTableHeader('Tips'),
            _buildTableHeader('Avg per Appointment'),
          ],
        ),
        for (var item in data)
          pw.TableRow(
            children: [
              _buildTableCell(Formatters.formatDate(item.date)),
              _buildTableCell(Formatters.formatCurrency(item.amount)),
              _buildTableCell(item.appointments.toString()),
              _buildTableCell(Formatters.formatCurrency(item.tips)),
              _buildTableCell(Formatters.formatCurrency(item.appointments > 0 ? item.amount / item.appointments : 0)),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildStaffPerformanceTable(List<Barber> barbers) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Name'),
            _buildTableHeader('Appointments'),
            _buildTableHeader('Earnings'),
            _buildTableHeader('Rating'),
            _buildTableHeader('Specialties'),
          ],
        ),
        for (var barber in barbers)
          pw.TableRow(
            children: [
              _buildTableCell(barber.name),
              _buildTableCell(barber.totalAppointments.toString()),
              _buildTableCell(Formatters.formatCurrency(barber.totalEarnings)),
              _buildTableCell(barber.rating.toStringAsFixed(1)),
              _buildTableCell(barber.specialties.join(', ')),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildInventoryTable(List<InventoryItem> items) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Product'),
            _buildTableHeader('Quantity'),
            _buildTableHeader('Price'),
            _buildTableHeader('Status'),
            _buildTableHeader('Last Updated'),
          ],
        ),
        for (var item in items)
          pw.TableRow(
            children: [
              _buildTableCell(item.productName ?? 'Unknown'),
              _buildTableCell(item.quantityInStock.toString()),
              _buildTableCell(Formatters.formatCurrency(item.productPrice ?? 0)),
              _buildTableCell(item.isCriticalStock ? 'Critical' : item.isLowStock ? 'Low' : 'Good'),
              _buildTableCell(Formatters.formatDate(item.lastUpdated)),
            ],
          ),
      ],
    );
  }

  static pw.Widget _buildAppointmentTable(List<ShopAppointment> appointments) {
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            _buildTableHeader('Date'),
            _buildTableHeader('Customer'),
            _buildTableHeader('Service'),
            _buildTableHeader('Status'),
            _buildTableHeader('Amount'),
          ],
        ),
        for (var appointment in appointments)
          pw.TableRow(
            children: [
              _buildTableCell(Formatters.formatDate(appointment.startTime)),
              _buildTableCell('Customer ${appointment.customerId}'),
              _buildTableCell(appointment.services.isNotEmpty ? appointment.services.first.serviceType : 'Unknown'),
              _buildTableCell(appointment.status.toString().split('.').last),
              _buildTableCell(appointment.payment != null ? Formatters.formatCurrency(appointment.payment!.amount) : 'N/A'),
            ],
          ),
      ],
    );
  }

  // Summary builders
  static pw.Widget _buildProfitSummary(List<ProfitData> data) {
    final totalRevenue = data.fold(0.0, (sum, item) => sum + item.revenue);
    final totalProfit = data.fold(0.0, (sum, item) => sum + item.profit);
    final totalExpenses = data.fold(0.0, (sum, item) => sum + item.expenses);
    final avgProfitMargin = totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0;

    return _buildSummaryContainer(
      'Profit Summary',
      [
        'Total Revenue: ${Formatters.formatCurrency(totalRevenue)}',
        'Total Profit: ${Formatters.formatCurrency(totalProfit)}',
        'Total Expenses: ${Formatters.formatCurrency(totalExpenses)}',
        'Average Profit Margin: ${avgProfitMargin.toStringAsFixed(1)}%',
        'Number of Records: ${data.length}',
      ],
    );
  }

  static pw.Widget _buildEarningsSummary(List<EarningsData> data) {
    final totalEarnings = data.fold(0.0, (sum, item) => sum + item.amount);
    final totalTips = data.fold(0.0, (sum, item) => sum + item.tips);
    final totalAppointments = data.fold(0, (sum, item) => sum + item.appointments);
    final avgPerAppointment = totalAppointments > 0.0 ? totalEarnings / totalAppointments : 0.0;

    return _buildSummaryContainer(
      'Earnings Summary',
      [
        'Total Earnings: ${Formatters.formatCurrency(totalEarnings)}',
        'Total Tips: ${Formatters.formatCurrency(totalTips)}',
        'Total Appointments: $totalAppointments',
        'Average per Appointment: ${Formatters.formatCurrency(avgPerAppointment)}',
      ],
    );
  }

  static pw.Widget _buildPerformanceSummary(List<Barber> barbers) {
    final totalAppointments = barbers.fold(0, (sum, barber) => sum + barber.totalAppointments);
    final totalEarnings = barbers.fold(0.0, (sum, barber) => sum + barber.totalEarnings);
    final averageRating = barbers.fold(0.0, (sum, barber) => sum + barber.rating) / barbers.length;

    return _buildSummaryContainer(
      'Performance Summary',
      [
        'Total Appointments: $totalAppointments',
        'Total Earnings: ${Formatters.formatCurrency(totalEarnings)}',
        'Average Rating: ${averageRating.toStringAsFixed(1)}',
        'Number of Barbers: ${barbers.length}',
      ],
    );
  }

  static pw.Widget _buildInventorySummary(List<InventoryItem> items) {
    final lowStockCount = items.where((item) => item.isLowStock).length;
    final criticalStockCount = items.where((item) => item.isCriticalStock).length;
    final totalValue = items.fold(0.0, (sum, item) {
      final price = item.productPrice ?? 0;
      return sum + (price * item.quantityInStock);
    });

    return _buildSummaryContainer(
      'Inventory Summary',
      [
        'Total Items: ${items.length}',
        'Low Stock Items: $lowStockCount',
        'Critical Stock Items: $criticalStockCount',
        'Total Inventory Value: ${Formatters.formatCurrency(totalValue)}',
      ],
    );
  }

  static pw.Widget _buildAppointmentSummary(List<ShopAppointment> appointments) {
    final completed = appointments.where((a) => a.status == AppointmentStatus.completed).length;
    final cancelled = appointments.where((a) => a.status == AppointmentStatus.cancelled).length;
    final scheduled = appointments.where((a) => a.status == AppointmentStatus.scheduled).length;
    final totalRevenue = appointments.fold(0.0, (sum, appointment) {
      if (appointment.payment != null && appointment.status == AppointmentStatus.completed) {
        return sum + appointment.payment!.amount;
      }
      return sum;
    });

    return _buildSummaryContainer(
      'Appointment Summary',
      [
        'Total Appointments: ${appointments.length}',
        'Completed: $completed',
        'Scheduled: $scheduled',
        'Cancelled: $cancelled',
        'Total Revenue: ${Formatters.formatCurrency(totalRevenue)}',
      ],
    );
  }

  // Helper methods for table building
  static pw.Widget _buildTableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
    );
  }

  static pw.Widget _buildTableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8.0),
      child: pw.Text(text),
    );
  }

  static pw.Widget _buildSummaryContainer(String title, List<String> items) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.SizedBox(height: 10),
          for (var item in items) pw.Text(item),
        ],
      ),
    );
  }
}

class InventoryService {
  final ApiService _apiService;

  InventoryService(this._apiService);

  Future<List<dynamic>> getLowStockItems({int? shopId}) async {
    try {
      if (shopId == null) {
        throw Exception('Shop ID is required to fetch inventory items.');
      }
      final Map<String, dynamic> queryParams = {};
      final String endpoint = '/shops/shops/$shopId/inventory/';
      queryParams['low_stock_only'] = 'true'; // Map to general endpoint list filter

      final response = await _apiService.get(
        endpoint,
        queryParams: queryParams,
      );

      final List<dynamic> data = response['results'] ?? response['data'] ?? [];
      
      print('--- getLowStockItems ---');
      print('shopId: $shopId');
      print('Items count: ${data.length}');
      if (data.isNotEmpty) print('First item: ${data.first}');
      print('--------------------------');

      return data;
    } catch (e) {
      AppLogger.error('Error fetching low stock items: $e');
      throw ErrorHandler.handleException(e);
    }
  }

  Future<List<dynamic>> getInventoryItems({
    int? shopId,
    bool? lowStockOnly,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      if (shopId == null) {
        throw Exception('Shop ID is required to fetch inventory items.');
      }
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (lowStockOnly != null) queryParams['low_stock_only'] = lowStockOnly.toString();
      if (category != null) queryParams['category'] = category;

      final String endpoint = '/shops/shops/$shopId/inventory/';

      final response = await _apiService.get(
        endpoint,
        queryParams: queryParams,
      );

      final List<dynamic> data = response['results'] ?? response['data'] ?? [];
      
      print('--- getInventoryItems ---');
      print('shopId: $shopId, lowStock: $lowStockOnly, category: $category');
      print('Items count: ${data.length}');
      if (data.isNotEmpty) print('First item: ${data.first}');
      print('--------------------------');

      return data;
    } catch (e) {
      AppLogger.error('Error fetching inventory items: $e');
      throw ErrorHandler.handleException(e);
    }
  }

  Future<dynamic> updateItemQuantity({
    required String itemId,
    required int shopId,
    required int newQuantity,
    String? reason,
  }) async {
    try {
      final response = await _apiService.patch(
        '/shops/shops/$shopId/inventory/$itemId/',
        data: {
          'quantity_in_stock': newQuantity,
          if (reason != null) 'notes': reason, // Map reason to notes if needed
        },
      );
      return response['data'];
    } catch (e) {
      AppLogger.error('Error updating item quantity: $e');
      throw ErrorHandler.handleException(e);
    }
  }

  Future<dynamic> addInventoryItem({
    required int productId,
    required int shopId,
    required int initialQuantity,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post(
        '/shops/shops/$shopId/inventory/',
        data: {
          'product': productId,
          'quantity_in_stock': initialQuantity,
          if (notes != null) 'notes': notes,
        },
      );
      return response['data'];
    } catch (e) {
      AppLogger.error('Error adding inventory item: $e');
      throw ErrorHandler.handleException(e);
    }
  }

  Future<void> deleteInventoryItem({required String itemId, required int shopId}) async {
    try {
      await _apiService.delete('/shops/shops/$shopId/inventory/$itemId/');
    } catch (e) {
      AppLogger.error('Error deleting inventory item: $e');
      throw ErrorHandler.handleException(e);
    }
  }

  Future<Map<String, dynamic>> getInventoryAlerts({int? shopId}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (shopId != null) queryParams['shop'] = shopId.toString();

      final response = await _apiService.get(
        '/inventory/alerts',
        queryParams: queryParams,
      );

      return response['data'] ?? {
        'low_stock_count': 0,
        'out_of_stock_count': 0,
        'critical_items': [],
      };
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
        final currentStock = item['current_stock'] ?? item['quantity_in_stock'] ?? 0;
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

  Future<Map<String, dynamic>> getInventoryStats({int? shopId}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (shopId != null) queryParams['shop'] = shopId.toString();

      final response = await _apiService.get(
        '/inventory/stats',
        queryParams: queryParams,
      );

      return response['data'] ?? {
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
  Future<Map<String, dynamic>> getBarberOffers() async {
    // This would typically make an API call to get offers
    // For now, we'll return an empty list since we don't have the endpoint
    return {'offers': []};
  }

  Future<Map<String, dynamic>> createOffer(Map<String, dynamic> offerData) async {
    // This would create a new offer via API
    return {'success': true, 'offer': offerData};
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
        Uri.parse('$baseUrl/reports/profit-data?'
            'start_date=${startDate.toIso8601String()}'
            '&end_date=${endDate.toIso8601String()}'
            '${branchId != null ? '&branch_id=$branchId' : ''}'),
        headers: {
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception('Failed to fetch profit data: ${response.statusCode}');
      }
    } catch (e) {
      // For demo purposes, return mock data
      return _getMockProfitData(startDate, endDate);
    }
  }

  List<Map<String, dynamic>> _getMockProfitData(DateTime startDate, DateTime endDate) {
    final data = <Map<String, dynamic>>[];
    var current = DateTime(startDate.year, startDate.month);
    final end = DateTime(endDate.year, endDate.month);
    var baseRevenue = 5000.0;

    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      final revenue = baseRevenue + (DateTime.now().month % 12 * 500);
      final expenses = revenue * 0.3;
      final profit = revenue - expenses;

      data.add({
        'date': current.toIso8601String(),
        'revenue': revenue,
        'expenses': expenses,
        'profit': profit,
        'profitMargin': (profit / revenue) * 100,
      });

      baseRevenue += 200;
      current = DateTime(current.year, current.month + 1);
    }

    return data;
  }
}

class ShopGalleryService {
  // In a real app, this would fetch from your API
  Future<List<String>> getShopGalleryImages(String shopId, {int limit = 4}) async {
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 300));

      // For demo purposes, return placeholder images
      // In production, this would fetch from your backend
      return ImageHelper.getShopGalleryImages(shopId, count: limit);
    } catch (e) {
      throw AppError('Failed to load gallery images: ${ErrorHandler.handleError(e)}');
    }
  }

  Future<List<String>> getShopGalleryImagesFromUrls(List<String> imageUrls, {int limit = 4}) async {
    try {
      if (imageUrls.isEmpty) {
        return [];
      }

      final effectiveLimit = limit > imageUrls.length ? imageUrls.length : limit;
      return imageUrls.sublist(0, effectiveLimit);
    } catch (e) {
      throw AppError('Failed to process gallery images: ${ErrorHandler.handleError(e)}');
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

  SubscriptionService({required ApiService apiService}) : _apiService = apiService;

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
