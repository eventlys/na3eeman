import 'package:flutter/material.dart';
import '../../Models/shop/offer_model.dart';
import '../../Models/shop/ad_campaign_model.dart';
import '../../Services/business_service.dart';
// import 'package:easy_localization/easy_localization.dart';

class OffersProvider with ChangeNotifier {
  final OffersService _offersService = OffersService();

  List<OfferModel> _offers = [];
  List<AdCampaignModel> _adCampaigns = [];
  bool _isLoading = false;
  String? _error;

  List<OfferModel> get offers => _offers;
  List<AdCampaignModel> get adCampaigns => _adCampaigns;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Loads all campaigns (Offers & Ads) for a specific shop.
  /// Used by Owner Dashboard and Specific Shop pages.
  Future<void> loadCampaigns(int shopId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final offersData = await _offersService.getShopOffers(shopId);
      final adsData = await _offersService.getShopAdCampaigns(shopId);
      
      _offers = offersData.map((e) => OfferModel.fromMap(e as Map<String, dynamic>)).toList();
      _adCampaigns = adsData.map((e) => AdCampaignModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = 'Failed to load campaigns: $e';
      // No fallback to mock as per Sprint 2 rules
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Alias for loadCampaigns used by generic shop preview widgets.
  /// If [shopId] is null, it attempts to load featured offers (currently fallback to shop 1).
  Future<void> loadOffers({int? shopId}) async {
    await loadCampaigns(shopId ?? 1); 
  }

  Future<void> createOffer(int shopId, OfferModel offer) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _offersService.createOffer(shopId, offer.toMap());
      await loadCampaigns(shopId);
    } catch (e) {
      _error = 'Failed to create offer: $e';
      notifyListeners();
    }
  }

  Future<void> createAdCampaign(int shopId, AdCampaignModel ad) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _offersService.createAdCampaign(shopId, ad.toMap());
      await loadCampaigns(shopId);
    } catch (e) {
      _error = 'Failed to create ad campaign: $e';
      notifyListeners();
    }
  }

  Future<void> deleteOffer(int shopId, int offerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _offersService.deleteOffer(shopId, offerId);
      await loadCampaigns(shopId);
    } catch (e) {
      _error = 'Failed to delete offer: $e';
      notifyListeners();
    }
  }

  Future<void> deleteAdCampaign(int shopId, int adId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _offersService.deleteAdCampaign(shopId, adId);
      await loadCampaigns(shopId);
    } catch (e) {
      _error = 'Failed to delete ad campaign: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
