import 'package:flutter/material.dart';
import '../../Models/loyalty/gift_card_model.dart';
import '../../Services/api/api_service.dart';

// import '../../Services/storage_service.dart';

class GiftCardProvider with ChangeNotifier {
  final ApiService _apiService;
  List<UserGiftCard> _myCards = [];
  bool _isLoading = false;

  GiftCardProvider({ApiService? apiService})
    : _apiService = apiService ?? ApiService();

  List<UserGiftCard> get myCards => _myCards;
  List<UserGiftCard> get activeCards => _myCards
      .where(
        (c) =>
            c.isActive && c.expiresAt.isAfter(DateTime.now()) && c.balance > 0,
      )
      .toList();
  bool get isLoading => _isLoading;

  Future<void> loadMyCards() async {
    _isLoading = true;
    notifyListeners();

    try {
      _myCards = await _apiService.getUserGiftCards();
    } catch (e) {
      debugPrint('Error loading gift cards: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBalance(int userGiftCardId) async {
    // Optional: implemented if there's a specific endpoint to check balance
    await loadMyCards();
  }

  /// Verify a gift card / voucher code (pure delegate, no state change).
  Future<Map<String, dynamic>> verifyGiftCard(String code) =>
      _apiService.verifyGiftCard(code);

  /// List purchasable gift cards (pure delegate, no state change).
  Future<List<GiftCard>> getGiftCards() => _apiService.getGiftCards();

  /// List the current user's gift cards (pure delegate, no state change).
  Future<List<UserGiftCard>> getUserGiftCards() =>
      _apiService.getUserGiftCards();

  /// Purchase a gift card (pure delegate, no state change).
  Future<dynamic> purchaseGiftCard(
    int giftCardId, {
    String? receiverPhone,
    String? message,
  }) => _apiService.purchaseGiftCard(
    giftCardId,
    receiverPhone: receiverPhone,
    message: message,
  );
}
