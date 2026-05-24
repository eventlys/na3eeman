import 'package:flutter/material.dart';
import '../../Models/salon/offer_model.dart';
import '../../Models/salon/ad_campaign_model.dart';
import '../../Models/salon/package_model.dart';
import '../../Services/business_service.dart';

class OffersProvider with ChangeNotifier {
  final OffersService _offersService = OffersService();

  List<OfferModel> _offers = [];
  List<AdCampaignModel> _adCampaigns = [];
  List<PackageModel> _packages = [];
  bool _isLoading = false;
  String? _error;

  List<OfferModel> get offers => _offers;
  List<AdCampaignModel> get adCampaigns => _adCampaigns;
  List<PackageModel> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCampaigns(int salonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final offersData = await _offersService.getSalonOffers(salonId);
      final adsData = await _offersService.getSalonAdCampaigns(salonId);
      final packagesData = await _offersService.getSalonPackages(salonId);

      _offers = offersData
          .map((e) => OfferModel.fromMap(e as Map<String, dynamic>))
          .toList();
      _adCampaigns = adsData
          .map((e) => AdCampaignModel.fromMap(e as Map<String, dynamic>))
          .toList();
      _packages = packagesData
          .map((e) => PackageModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = 'Failed to load campaigns: $e';
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

  Future<void> toggleOfferStatus(
    int salonId,
    int offerId,
    bool isActive,
  ) async {
    final index = _offers.indexWhere((o) => o.id == offerId);
    if (index == -1) return;

    final originalOffer = _offers[index];
    _offers[index] = originalOffer.copyWith(isActive: isActive);
    notifyListeners();

    try {
      await _offersService.updateOffer(salonId, offerId, {
        'is_active': isActive,
      });
    } catch (e) {
      _offers[index] = originalOffer;
      _error = 'Failed to toggle offer: $e';
      notifyListeners();
    }
  }

  Future<void> toggleAdStatus(int salonId, int adId, bool isActive) async {
    final index = _adCampaigns.indexWhere((a) => a.id == adId);
    if (index == -1) return;

    final originalAd = _adCampaigns[index];
    _adCampaigns[index] = originalAd.copyWith(isActive: isActive);
    notifyListeners();

    try {
      await _offersService.updateAdCampaign(salonId, adId, {
        'is_active': isActive,
      });
    } catch (e) {
      _adCampaigns[index] = originalAd;
      _error = 'Failed to toggle ad: $e';
      notifyListeners();
    }
  }

  Future<void> createPackage(int salonId, PackageModel package) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _offersService.createPackage(salonId, package.toMap());
      await loadCampaigns(salonId);
    } catch (e) {
      _error = 'Failed to create package: $e';
      notifyListeners();
    }
  }

  Future<void> deletePackage(int salonId, int packageId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _offersService.deletePackage(salonId, packageId);
      await loadCampaigns(salonId);
    } catch (e) {
      _error = 'Failed to delete package: $e';
      notifyListeners();
    }
  }

  Future<void> togglePackageStatus(
    int salonId,
    int packageId,
    bool isActive,
  ) async {
    final index = _packages.indexWhere((p) => p.id == packageId);
    if (index == -1) return;

    final originalPackage = _packages[index];
    _packages[index] = originalPackage.copyWith(isActive: isActive);
    notifyListeners();

    try {
      await _offersService.updatePackage(salonId, packageId, {
        'is_active': isActive,
      });
    } catch (e) {
      _packages[index] = originalPackage;
      _error = 'Failed to toggle package: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
