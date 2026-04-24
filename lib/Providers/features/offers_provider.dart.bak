import 'package:flutter/material.dart';
import '../../Models/salon/offer_model.dart';
import '../../Models/salon/ad_campaign_model.dart';
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
  
  /// Loads all campaigns (Offers & Ads) for a specific salon.
  /// Used by Owner Dashboard and Specific Salon pages.
  Future<void> loadCampaigns(int salonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final offersData = await _offersService.getSalonOffers(salonId);
      final adsData = await _offersService.getSalonAdCampaigns(salonId);
      
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

  /// Alias for loadCampaigns used by generic salon preview widgets.
  /// If [salonId] is null, it attempts to load featured offers (currently fallback to salon 1).
  Future<void> loadOffers({int? salonId}) async {
    await loadCampaigns(salonId ?? 1); 
  }

  Future<void> createOffer(int salonId, OfferModel offer) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _offersService.createOffer(salonId, offer.toMap());
      await loadCampaigns(salonId);
    } catch (e) {
      _error = 'Failed to create offer: $e';
      notifyListeners();
    }
  }

  Future<void> createAdCampaign(int salonId, AdCampaignModel ad) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _offersService.createAdCampaign(salonId, ad.toMap());
      await loadCampaigns(salonId);
    } catch (e) {
      _error = 'Failed to create ad campaign: $e';
      notifyListeners();
    }
  }

  Future<void> deleteOffer(int salonId, int offerId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _offersService.deleteOffer(salonId, offerId);
      await loadCampaigns(salonId);
    } catch (e) {
      _error = 'Failed to delete offer: $e';
      notifyListeners();
    }
  }

  Future<void> deleteAdCampaign(int salonId, int adId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _offersService.deleteAdCampaign(salonId, adId);
      await loadCampaigns(salonId);
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
