// lib/Services/use_cases/shop_use_cases.dart
import '../repositories/shop_repository.dart';
import '../../Helpers/error_handler.dart';

class GetShopsUseCase {
  final ShopRepository _repository;

  GetShopsUseCase(this._repository);

  Future<List<dynamic>> execute({
    int page = 1,
    int limit = 20,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
  }) async {
    if (page < 1) throw AppError('Page must be greater than 0');
    if (limit < 1 || limit > 100) throw AppError('Limit must be between 1 and 100');

    if (minRating != null && (minRating < 0 || minRating > 5)) {
      throw AppError('Rating must be between 0 and 5');
    }

    return await _repository.getShops(
      page: page,
      limit: limit,
      search: search,
      minRating: minRating,
      location: location,
      openNow: openNow,
    );
  }
}

class SearchShopsUseCase {
  final ShopRepository _repository;

  SearchShopsUseCase(this._repository);

  Future<List<dynamic>> execute(String query) async {
    if (query.isEmpty) throw AppError('Search query cannot be empty');
    if (query.length < 2) throw AppError('Search query must be at least 2 characters');

    return await _repository.searchShops(query);
  }
}

class GetShopDetailsUseCase {
  final ShopRepository _repository;

  GetShopDetailsUseCase(this._repository);

  Future<dynamic> execute(int shopId) async {
    if (shopId <= 0) throw AppError('Invalid shop ID');

    return await _repository.getShopDetails(shopId);
  }
}

class GetShopServicesUseCase {
  final ShopRepository _repository;

  GetShopServicesUseCase(this._repository);

  Future<List<dynamic>> execute(int shopId) async {
    if (shopId <= 0) throw AppError('Invalid shop ID');

    return await _repository.getShopServices(shopId);
  }
}

class SubmitReviewUseCase {
  final ShopRepository _repository;

  SubmitReviewUseCase(this._repository);

  Future<dynamic> execute({
    required int shopId,
    required int customerId,
    required int rating,
    required String comment,
    int? appointmentId,
    List<String>? photos,
  }) async {
    if (shopId <= 0) throw AppError('Invalid shop ID');
    if (customerId <= 0) throw AppError('Invalid customer ID');
    if (rating < 1 || rating > 5) throw AppError('Rating must be between 1 and 5');
    if (comment.isEmpty) throw AppError('Comment cannot be empty');
    if (comment.length < 10) throw AppError('Comment must be at least 10 characters');

    return await _repository.submitReview(
      shopId: shopId,
      customerId: customerId,
      rating: rating,
      comment: comment,
      appointmentId: appointmentId,
      photos: photos,
    );
  }
}

class GetNearbyShopsUseCase {
  final ShopRepository _repository;

  GetNearbyShopsUseCase(this._repository);

  Future<List<dynamic>> execute(double lat, double lng, double radiusKm) async {
    if (lat < -90 || lat > 90) throw AppError('Invalid latitude');
    if (lng < -180 || lng > 180) throw AppError('Invalid longitude');
    if (radiusKm <= 0 || radiusKm > 100) throw AppError('Radius must be between 0 and 100 km');

    return await _repository.getNearbyShops(lat, lng, radiusKm);
  }
}
