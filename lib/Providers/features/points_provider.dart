import 'package:flutter/material.dart';
import '../../Services/api/api_service.dart';
import '../../Services/storage_service.dart';
import '../../core/enums/app_enums.dart';

class PointsProvider with ChangeNotifier {
  final ApiService _loyaltyService;
  int _currentBalance = 0;
  bool _isLoading = false;

  PointsProvider(this._loyaltyService);

  int get currentBalance => _currentBalance;
  bool get isLoading => _isLoading;

  Future<void> loadBalance(int customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final balance = await _loyaltyService.getLoyaltyBalance(customerId);
      _currentBalance = balance.points;
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
      if (userProfile != null && userProfile.id != null) {
        await addPoints(
          customerId: userProfile.id!,
          type: PointsType.makeAppointment,
        );
      }
    } catch (error) {
      debugPrint('Error adding appointment points: $error');
      // Don't rethrow here to avoid breaking the appointment flow
    }
  }

  Future<void> submitShopFeedback({
    required int customerId,
    required String shopName,
    String? review,
    double? rating,
  }) async {
    final metadata = {
      'shop_name': shopName,
      if (review != null) 'review': review,
      if (rating != null) 'rating': rating,
    };

    await addPoints(
      customerId: customerId,
      type: PointsType.shopFeedback,
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

  int _getPointsValue(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
      case PointsType.referral:
        return 100;
      case PointsType.booking:
      case PointsType.purchase:
      case PointsType.appointmentComplete:
        return 50;
      case PointsType.loyalty:
      case PointsType.rateShop:
      case PointsType.reviewWrite:
      case PointsType.shopFeedback:
        return 25;
      case PointsType.arriveOnTime:
      case PointsType.rateApp:
      case PointsType.appFeedback:
      case PointsType.makeAppointment:
        return 10;
      case PointsType.rewardRedeem:
        return 0; // Redeeming costs points, doesn't add
      case PointsType.other:
        return 10;
    }
  }

  String _getSourceString(PointsType type) {
    switch (type) {
      case PointsType.inviteFriend:
        return 'invite_friend';
      case PointsType.rateShop:
        return 'rate_shop';
      case PointsType.arriveOnTime:
        return 'arrive_on_time';
      case PointsType.booking:
        return 'booking';
      case PointsType.loyalty:
        return 'loyalty';
      case PointsType.purchase:
        return 'purchase';
      case PointsType.shopFeedback:
        return 'shop_feedback';
      case PointsType.rateApp:
        return 'rate_app';
      case PointsType.appFeedback:
        return 'app_feedback';
      case PointsType.makeAppointment:
        return 'make_appointment';
      case PointsType.appointmentComplete:
        return 'appointment_complete';
      case PointsType.reviewWrite:
        return 'review_write';
      case PointsType.referral:
        return 'referral';
      case PointsType.rewardRedeem:
        return 'reward_redeem';
      case PointsType.other:
        return 'other';
    }
  }
}
