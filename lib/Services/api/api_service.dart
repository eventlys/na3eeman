import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:na3eeman/Helpers/config.dart';
import 'package:na3eeman/Models/salon/payment_config_model.dart';
import 'package:na3eeman/Models/loyalty/points_balance_model.dart';
import 'package:na3eeman/Models/loyalty/gift_card_model.dart';
import 'package:na3eeman/Models/loyalty/feedback_model.dart';
import 'package:na3eeman/Services/api/endpoints.dart';
import 'package:na3eeman/Services/storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String get baseUrl => AppConfig.baseUrl;
  final UnifiedStorageService _storage = UnifiedStorageService();

  Future<Map<String, String>> _getHeaders(String path, [Map<String, String>? customHeaders]) async {
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Skip Authorization header for public endpoints to avoid issues with stale tokens
    final bool isPublicEndpoint = path.contains(Endpoints.login) || 
                                 path.contains(Endpoints.register) ||
                                 path.contains('/auth/password/reset/') ||
                                 path.contains('/auth/social/login');

    if (!isPublicEndpoint) {
      final token = await _storage.getAuthToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParams, Map<String, String>? customHeaders}) async {
    final headers = await _getHeaders(path, customHeaders);
    
    // Convert queryParams dynamic values to strings
    Map<String, String>? stringParams;
    if (queryParams != null) {
      stringParams = queryParams.map((key, value) => MapEntry(key, value.toString()));
    }
    
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: stringParams);
    
    try {
      final response = await http.get(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String path, {dynamic data, Map<String, String>? customHeaders}) async {
    final headers = await _getHeaders(path, customHeaders);
    final uri = Uri.parse('$baseUrl$path');
    
    try {
      final response = await http.post(
        uri, 
        headers: headers, 
        body: data != null ? jsonEncode(data) : null
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(String path, {dynamic data, Map<String, String>? customHeaders}) async {
    final headers = await _getHeaders(path, customHeaders);
    final uri = Uri.parse('$baseUrl$path');
    
    try {
      final response = await http.put(
        uri, 
        headers: headers, 
        body: data != null ? jsonEncode(data) : null
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> patch(String path, {dynamic data, Map<String, String>? customHeaders}) async {
    final headers = await _getHeaders(path, customHeaders);
    final uri = Uri.parse('$baseUrl$path');
    
    try {
      final response = await http.patch(
        uri, 
        headers: headers, 
        body: data != null ? jsonEncode(data) : null
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(String path, {Map<String, String>? customHeaders}) async {
    final headers = await _getHeaders(path, customHeaders);
    final uri = Uri.parse('$baseUrl$path');
    
    try {
      final response = await http.delete(uri, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body?['detail'] ?? body?['message'] ?? 'API Error ${response.statusCode}');
    }
  }

  // Specialized methods
  
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    final response = await get(Endpoints.subscriptionPlans);
    return List<Map<String, dynamic>>.from(response is List ? response : (response['results'] ?? []));
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    return await post(Endpoints.tokenRefresh, data: {'refresh': refreshToken});
  }

  Future<SalonPaymentConfig> getSalonPaymentConfig(int salonId) async {
    final response = await get(Endpoints.salonPaymentConfig(salonId));
    return SalonPaymentConfig.fromJson(response);
  }

  Future<dynamic> updateSalonPaymentConfig(int salonId, Map<String, dynamic> data) async {
    return await patch(Endpoints.salonPaymentConfig(salonId), data: data);
  }

  Future<LoyaltyBalance> getLoyaltyBalance(int customerId) async {
    final response = await get(Endpoints.loyaltyBalance, queryParams: {'customer_id': customerId});
    return LoyaltyBalance.fromJson(response);
  }

  Future<dynamic> awardPoints({
    required int customerId,
    required int points,
    required String source,
    Map<String, dynamic>? metadata,
  }) async {
    return await post(Endpoints.loyaltyAwardPoints, data: {
      'customer_id': customerId,
      'points': points,
      'source': source,
      'metadata': metadata,
    });
  }

  Future<dynamic> redeemPoints(int customerId, double amountJod) async {
    return await post(Endpoints.loyaltyRedeemPoints, data: {
      'customer_id': customerId,
      'amount': amountJod,
    });
  }

  // Gift Cards
  Future<List<GiftCard>> getGiftCards() async {
    final response = await get(Endpoints.giftCardList);
    final List<dynamic> data = response is List ? response : (response['results'] ?? response['data'] ?? []);
    return data.map((e) => GiftCard.fromJson(e)).toList();
  }

  Future<dynamic> purchaseGiftCard(int giftCardId, {String? receiverPhone, String? message}) async {
    return await post(Endpoints.giftCardPurchase, data: {
      'gift_card_id': giftCardId,
      'receiver_phone': receiverPhone,
      'message': message,
    });
  }

  Future<List<UserGiftCard>> getUserGiftCards() async {
    final response = await get(Endpoints.userGiftCards);
    final List<dynamic> data = response is List ? response : (response['results'] ?? response['data'] ?? []);
    return data.map((e) => UserGiftCard.fromJson(e)).toList();
  }

  Future<Map<String, dynamic>> verifyGiftCard(String code) async {
    return await post('/loyalty/gift-cards/verify/', data: {'code': code});
  }

  // Feedback
  Future<dynamic> submitFeedback(String content) async {
    return await post(Endpoints.feedback, data: {
      'content': content,
    });
  }

  // Admin User Management
  Future<List<dynamic>> getUsers({String? role, String? query}) async {
    final Map<String, dynamic> params = {};
    if (role != null) params['role'] = role;
    if (query != null && query.isNotEmpty) params['search'] = query;
    
    final response = await get(Endpoints.adminUsers, queryParams: params);
    return response is List ? response : (response['results'] ?? []);
  }

  Future<dynamic> updateUserStatus(int userId, String status) async {
    return await patch(Endpoints.adminUserDetail(userId), data: {'status': status});
  }

  Future<List<dynamic>> fetchServiceRequests({
    String? ageFilter,
    String? roleFilter,
    String? subFilter,
  }) async {
    final Map<String, dynamic> params = {};
    if (ageFilter != null && ageFilter != 'all') params['age'] = ageFilter;
    if (roleFilter != null && roleFilter != 'all') params['role'] = roleFilter;
    if (subFilter != null && subFilter != 'all') params['plan'] = subFilter;

    final response = await get(Endpoints.adminUserRequests, queryParams: params);
    return response is List ? response : (response['results'] ?? []);
  }

  Future<List<HelpFeedback>> getFeedback() async {
    final response = await get(Endpoints.feedback);
    final List<dynamic> data = response is List ? response : (response['results'] ?? response['data'] ?? []);
    return data.map((e) => HelpFeedback.fromJson(e)).toList();
  }

  Future<dynamic> reviewFeedback(int feedbackId, String status) async {
    return await post(Endpoints.adminFeedbackReview, data: {
      'feedback_id': feedbackId,
      'status': status,
      'is_valuable': status.toUpperCase() == 'APPROVED' || status.toUpperCase() == 'VALUABLE',
    });
  }



  Future<dynamic> uploadPaymentProof({required dynamic appointmentId, required File proof}) async {
    final id = appointmentId is int ? appointmentId : int.tryParse(appointmentId.toString()) ?? 0;
    final uri = Uri.parse('$baseUrl/salons/appointments/$id/upload_proof/');
    final request = http.MultipartRequest('POST', uri);
    
    final token = await _storage.getAuthToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.files.add(await http.MultipartFile.fromPath('proof', proof.path));
    
    final response = await request.send();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to upload proof: ${response.statusCode}');
    }
    return true;
  }

  Future<dynamic> updateSalonWithImages({
    required int salonId,
    required Map<String, String> fields,
    List<File>? images,
  }) async {
    final uri = Uri.parse('$baseUrl/salons/salons/$salonId/');
    final request = http.MultipartRequest('PATCH', uri);
    
    final token = await _storage.getAuthToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    
    request.fields.addAll(fields);
    
    if (images != null && images.isNotEmpty) {
      for (var image in images) {
        request.files.add(await http.MultipartFile.fromPath('images', image.path));
      }
    }
    
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    return _handleResponse(response);
  }

  Future<List<dynamic>> getSalonExperts(int salonId) async {
    final response = await get(Endpoints.salonExperts(salonId));
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<Map<String, dynamic>> fetchTodayWorkingHours(int salonId) async {
    return await get(Endpoints.salonSchedule(salonId));
  }

  Future<List<dynamic>> fetchPendingConfirmations(int salonId) async {
    final response = await get(Endpoints.appointments, queryParams: {
      'salon': salonId,
      'status': 'PENDING',
    });
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<dynamic> confirmCashPayment(dynamic appointmentId) async {
    final id = appointmentId is int ? appointmentId : int.tryParse(appointmentId.toString()) ?? 0;
    return await post(Endpoints.appointmentConfirmCashPayment(id));
  }

  Future<dynamic> confirmPayment(dynamic appointmentId, {String? voucherCode}) async {
    final id = appointmentId is int ? appointmentId : int.tryParse(appointmentId.toString()) ?? 0;
    return await post(Endpoints.appointmentConfirmCashPayment(id), data: {
      'voucher_code': voucherCode,
    });
  }

  Future<Map<String, dynamic>> getAppointments({int? customerId, String? status, int? pageSize}) async {
    return await get(Endpoints.appointments, queryParams: {
      'customer': customerId,
      'status': status,
      'page_size': pageSize,
    });
  }

  Future<Map<String, dynamic>> bookAppointment(Map<String, dynamic> data) async {
    return await post(Endpoints.appointmentBook, data: data);
  }

  Future<Map<String, dynamic>> getSalonDetails(int salonId) async {
    return await get(Endpoints.salonDetails(salonId));
  }

  Future<List<dynamic>> getCategories() async {
    final response = await get(Endpoints.categories);
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<List<dynamic>> getAdsByCategory(int categoryId) async {
    final response = await get(Endpoints.salonAdCampaigns(0), queryParams: {'category': categoryId});
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<List<dynamic>> getOffersByCategory(int categoryId) async {
    final response = await get(Endpoints.allOffers, queryParams: {'category': categoryId});
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<Map<String, dynamic>> getNearbySalonsByCategory({
    required double latitude,
    required double longitude,
    required int categoryId,
    bool forGift = false,
    String? giftGender,
  }) async {
    final url = Endpoints.getNearbySalonsByCategoryUrl(
      latitude: latitude,
      longitude: longitude,
      categoryId: categoryId,
      forGift: forGift,
      giftGender: giftGender,
    );
    final path = url.replaceFirst(Endpoints.baseUrl, '');
    return await get(path);
  }

  Future<dynamic> getSalons({
    int? categoryId, 
    int? page, 
    int? limit, 
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
    Map<String, dynamic>? filters,
  }) async {
    return await get(Endpoints.salons, queryParams: {
      'category': categoryId,
      'page': page,
      'limit': limit,
      'search': search,
      'min_rating': minRating,
      'location': location,
      'open_now': openNow,
      if (filters != null) ...filters,
    });
  }

  Future<List<dynamic>> getSalonVouchers(int salonId) async {
    final response = await get(Endpoints.vouchers, queryParams: {'salon': salonId});
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<dynamic> addToFavorites(dynamic salonId) async {
    final id = salonId is int ? salonId : int.tryParse(salonId.toString()) ?? 0;
    return await post('/salons/salons/$id/favorite/');
  }

  Future<dynamic> removeFromFavorites(dynamic salonId) async {
    final id = salonId is int ? salonId : int.tryParse(salonId.toString()) ?? 0;
    return await post('/salons/salons/$id/unfavorite/');
  }

  Future<List<dynamic>> getUserFavorites() async {
    final response = await get('/salons/salons/', queryParams: {'favorites': true});
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<dynamic> getInternActivity() async {
    return await get(Endpoints.internActivity);
  }

  Future<List<dynamic>> getNotifications() async {
    final response = await get(Endpoints.notifications);
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<dynamic> markNotificationRead(int id) async {
    return await post(Endpoints.notificationMarkRead(id));
  }

  Future<dynamic> markAllNotificationsRead() async {
    return await post(Endpoints.notificationsMarkAllRead);
  }

  Future<dynamic> getTeamLeaderboard(int salonId) async {
    return await get(Endpoints.salonTeamLeaderboard(salonId));
  }

  Future<dynamic> getRetailSnapshot(int salonId) async {
    return await get(Endpoints.salonRetailSnapshot(salonId));
  }

  Future<dynamic> getDailyEarnings(int salonId) async {
    return await get(Endpoints.salonDailyEarnings(salonId));
  }

  Future<List<dynamic>> getSalonOffers(int salonId) async {
    final response = await get(Endpoints.salonOffers(salonId));
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<dynamic> createOffer(int salonId, Map<String, dynamic> data) async {
    return await post(Endpoints.salonOffers(salonId), data: data);
  }

  Future<dynamic> deleteOffer(int salonId, int offerId) async {
    return await delete('/salons/salons/$salonId/offers/$offerId/');
  }

  Future<List<dynamic>> getSalonAdCampaigns(int salonId) async {
    final response = await get(Endpoints.salonAdCampaigns(salonId));
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<dynamic> createAdCampaign(int salonId, Map<String, dynamic> data) async {
    return await post(Endpoints.salonAdCampaigns(salonId), data: data);
  }

  Future<dynamic> deleteAdCampaign(int salonId, int campaignId) async {
    return await delete('/salons/salons/$salonId/campaigns/$campaignId/');
  }

  Future<dynamic> updateOffer(int salonId, int offerId, Map<String, dynamic> data) async {
    return await patch('/salons/salons/$salonId/offers/$offerId/', data: data);
  }

  Future<dynamic> updateAdCampaign(int salonId, int campaignId, Map<String, dynamic> data) async {
    return await patch('/salons/salons/$salonId/campaigns/$campaignId/', data: data);
  }

  Future<List<dynamic>> getSalonServices(int salonId) async {
    final response = await get(Endpoints.salonServices(salonId));
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<dynamic> submitServiceRequest(Map<String, dynamic> data) async {
    return await post('/salons/service-requests/', data: data);
  }

  Future<dynamic> reportCustomer(String appointmentId, {required String reason}) async {
    return await post('/salons/appointments/$appointmentId/report/', data: {
      'reason': reason,
      'deduct_points': true,
      'late_penalty': true,
    });
  }

  // FAQs
  Future<List<dynamic>> getFAQs() async {
    final response = await get(Endpoints.faqs);
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<dynamic> createFAQ(Map<String, dynamic> data) async {
    return await post(Endpoints.faqs, data: data);
  }

  Future<dynamic> updateFAQ(int id, Map<String, dynamic> data) async {
    return await patch(Endpoints.faqDetails(id), data: data);
  }

  Future<dynamic> deleteFAQ(int id) async {
    return await delete(Endpoints.faqDetails(id));
  }

  // Loyalty
  Future<List<dynamic>> getLoyaltyRules() async {
    final response = await get(Endpoints.loyaltyRules);
    return response is List ? response : (response['results'] ?? response['data'] ?? []);
  }

  Future<dynamic> createRecurringBooking(Map<String, dynamic> data) async {
    return await post('/salons/recurring-bookings/', data: data);
  }

  Future<List<dynamic>> getWorkingHours({int? salonId, int? expertId}) async {
    final response = await get(Endpoints.workingHours, queryParams: {
      'salon_id': salonId,
      'expert_id': expertId,
    });
    return response is List ? response : (response['results'] ?? []);
  }
  
  Future<List<dynamic>> getPTORequests({int? salonId}) async {
    final response = await get(Endpoints.pto, queryParams: {
      if (salonId != null) 'salon_id': salonId,
    });
    return response is List ? response : (response['results'] ?? []);
  }

  Future<dynamic> submitPTORequest(Map<String, dynamic> data) async {
    return await post(Endpoints.pto, data: data);
  }
}
