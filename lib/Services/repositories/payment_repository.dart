import '../../Helpers/logger.dart';
import '../../Models/commerce/payment_method.dart';
import '../api/api_service.dart';

/// Repository for payment backend access.
///
/// Extracted verbatim from the former god service `BusinessService`
/// (see `lib/Services/business_service.dart`, now a delegating facade).
class PaymentRepository {
  final ApiService _apiService;

  PaymentRepository({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  Future<PaymentIntent> processPayment({
    required double amount,
    required String paymentMethod,
    PaymentCard? cardDetails,
    String? paymentMethodId,
    String currency = 'USD',
    int? userId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      String endpoint = '/payments/process/$paymentMethod';
      Map<String, dynamic> data = {'amount': amount, 'currency': currency};

      // if (paymentMethod == 'visa' && cardDetails != null) {
      //   data['card_details'] = cardDetails.toJson();
      //   if (userId != null) data['user_id'] = userId;
      // } else if (paymentMethod == 'stripe' && paymentMethodId != null) {
      //   data['payment_method_id'] = paymentMethodId;
      // }

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
  }) async {
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

  Future<void> confirmCashPayment(
    int appointmentId,
    int confirmedByUserId,
    double amount,
  ) async {
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
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (userId != null) queryParams['user'] = userId.toString();
      if (appointmentId != null) {
        queryParams['appointment'] = appointmentId.toString();
      }

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
}
