import 'package:flutter/material.dart';
import '../../Models/shop/offer_model.dart';
import '../../Services/business_service.dart';

class OffersProvider with ChangeNotifier {
  final OffersService _offersService = OffersService();

  List<OfferModel> _offers = [];
  bool _isLoading = false;
  String? _error;

  List<OfferModel> get offers => _offers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOffers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _offersService.getBarberOffers();
      final offersList = response['offers'] as List? ?? [];
      
      if (offersList.isEmpty) {
        _offers = _getMockOffers();
      } else {
        _offers = offersList.map((e) => OfferModel.fromMap(e as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      _offers = _getMockOffers(); // Fallback to mock data on error too
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOffer(OfferModel offer) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _offersService.createOffer(offer.toMap());
      await loadOffers();
    } catch (e) {
      _error = 'Failed to create offer: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<OfferModel> _getMockOffers() {
    return [
      OfferModel(
        id: 1,
        title: 'Summer Glow Package ☀️',
        description: 'Complete grooming session with face scrub, premium haircut & styling, and relaxing head massage.',
        price: '25.00',
        originalPrice: '40.00',
        validityPeriod: 'Valid until June 30, 2026',
        shopId: 1,
        shopName: 'Elite Grooming Lounge',
        includedServices: ['Premium Haircut', 'Face Scrub & Steam', 'Head Massage'],
      ),
      OfferModel(
        id: 2,
        title: 'Complete Bridal Glow 💅',
        description: 'Ensure look perfection with nails spa, hair styles treatments, and professional makeup options.',
        price: '150.00',
        originalPrice: '200.00',
        validityPeriod: 'Valid until June 15, 2026',
        shopId: 2,
        shopName: 'Rose Beauty Center',
        includedServices: ['Nails Spa', 'Hair Treatments', 'Bridal Makeup Setup'],
      ),
    ];
  }
}

