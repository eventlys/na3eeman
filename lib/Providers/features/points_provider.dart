import 'package:flutter/material.dart';
// import '../../Models/loyalty/points_model.dart';
import '../../Services/api/api_service.dart';
import '../../Services/storage_service.dart';
import '../../Services/enums/points_types.dart';
import '../../Models/loyalty/loyalty_program_model.dart';

class PointsProvider with ChangeNotifier {
  final ApiService _loyaltyService;
  int _currentBalance = 0;
  bool _isLoading = false;
  bool _hasPendingPenalty = false;
  LoyaltyProgram? _rules;

  PointsProvider(this._loyaltyService);

  int get currentBalance => _currentBalance;
  bool get isLoading => _isLoading;
  bool get hasPendingPenalty => _hasPendingPenalty;

  Future<void> loadBalance([int? customerId]) async {
    _isLoading = true;
    notifyListeners();

    try {
      final targetCustomerId = customerId ?? (await UnifiedStorageService().getUserProfile())?.id;
      
      // Load rules first if not loaded
      if (_rules == null) {
        final rulesData = await _loyaltyService.getLoyaltyRules();
        if (rulesData.isNotEmpty) {
          _rules = LoyaltyProgram.fromJson(rulesData.first as Map<String, dynamic>);
        }
      }

      if (targetCustomerId == null) return;

      final balance = await _loyaltyService.getLoyaltyBalance(targetCustomerId);
      _currentBalance = balance.points;
      _hasPendingPenalty = balance.hasPendingPenalty;
    } catch (error) {
      // Handle error appropriately
      debugPrint('Error loading balance: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPoints({
    required int customerId,
    required PointsType type,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final points = _getPointsValue(type);
      final source = _getSourceString(type);

      final balance = await _loyaltyService.awardPoints(
        customerId: customerId,
        points: points,
        source: source,
        metadata: metadata,
      );

      _currentBalance =
          balance['points'] as int? ??
          balance['balance'] as int? ??
          _currentBalance;
      _hasPendingPenalty = balance['has_pending_penalty'] as bool? ?? _hasPendingPenalty;
      notifyListeners();
    } catch (error) {
      debugPrint('Error adding points: $error');
      rethrow;
    }
  }

  Future<void> addAppointmentPoints() async {
    try {
      // Get customer ID from storage or user profile
      final userProfile = await UnifiedStorageService().getUserProfile();
      if (userProfile != null) {
        await addPoints(
          customerId: userProfile.id,
          type: PointsType.makeAppointment,
        );
      }
    } catch (error) {
      debugPrint('Error adding appointment points: $error');
      // Don't rethrow here to avoid breaking the appointment flow
    }
  }

  Future<void> submitSalonFeedback({
    required int customerId,
    required String salonName,
    String? review,
    double? rating,
  }) async {
    final metadata = {
      'salon_name': salonName,
      'review': review,
      'rating': rating,
    };

    await addPoints(
      customerId: customerId,
      type: PointsType.salonFeedback,
      metadata: metadata,
    );
  }

  Future<void> inviteFriend({
    required int customerId,
    String? friendName,
  }) async {
    final metadata = friendName != null ? {'friend_name': friendName} : null;

    await addPoints(
      customerId: customerId,
      type: PointsType.referral,
      metadata: metadata,
    );
  }

  Future<void> submitAppFeedback({
    required int customerId,
    String? feedback,
  }) async {
    final metadata = feedback != null ? {'feedback': feedback} : null;

    await addPoints(
      customerId: customerId,
      type: PointsType.other, // Using 'other' for app feedback
      metadata: metadata,
    );
  }

  Future<void> rateApp({required int customerId, int? rating}) async {
    final metadata = rating != null ? {'rating': rating} : null;

    await addPoints(
      customerId: customerId,
      type: PointsType.reviewWrite, // Using reviewWrite for app rating
      metadata: metadata,
    );
  }

  Future<bool> redeemPointsForPayment(int customerId, double amountJod) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _loyaltyService.redeemPoints(customerId, amountJod);
      _currentBalance = response['points'] as int? ?? _currentBalance;
      return true;
    } catch (error) {
      debugPrint('Error redeeming points: $error');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int calculatePointsValue(double jod) => (jod * 200).toInt();

  int _getPointsValue(PointsType type) {
    if (_rules == null) return _getFallbackPointsValue(type);
    
    switch (type) {
      case PointsType.invite: return 100;
      case PointsType.referral: return 100;
      case PointsType.gifting: return 100;
      case PointsType.salonFeedback: return 50;
      case PointsType.expertFeedback: return 25;
      case PointsType.rateApp: return 100;
      case PointsType.arriveOnTime: return 50;
      case PointsType.booking: return 50;
      case PointsType.makeAppointment: return 50;
      case PointsType.delay5Min: return -10;
      case PointsType.delay10Min: return -20;
      case PointsType.delay15Min: return -30;
      default: return 0;
    }
  }

  int _getFallbackPointsValue(PointsType type) {
    return _getPointsValue(type);
  }

  String _getSourceString(PointsType type) {
    switch (type) {
      case PointsType.invite: return 'INVITE';
      case PointsType.referral: return 'INVITE';
      case PointsType.salonFeedback: return 'REVIEW_SALON';
      case PointsType.expertFeedback: return 'EMPLOYEE_REVIEW_GOOD';
      case PointsType.rateApp: return 'RATING_APP';
      case PointsType.arriveOnTime: return 'EARLY';
      case PointsType.booking: return 'APPOINTMENT';
      case PointsType.makeAppointment: return 'APPOINTMENT';
      case PointsType.gifting: return 'GIFT';
      case PointsType.delay5Min: return 'DELAY_REQUEST';
      case PointsType.delay10Min: return 'DELAY_REQUEST';
      case PointsType.delay15Min: return 'DELAY_REQUEST';
      case PointsType.redeem: return 'PAYMENT_REDEEM';
      default: return 'ADMIN';
    }
  }
}
