// lib/Services/use_cases/salon_use_cases.dart
import '../repositories/salon_repository.dart';
import '../../Helpers/error_handler.dart';

class GetSalonsUseCase {
  final SalonRepository _repository;

  GetSalonsUseCase(this._repository);

  Future<List<dynamic>> execute({
    int page = 1,
    int limit = 20,
    String? search,
    double? minRating,
    String? location,
    bool? openNow,
  })
  async {
    if (page < 1) throw AppError('Page must be greater than 0');
    if (limit < 1 || limit > 100) throw AppError('Limit must be between 1 and 100');

    if (minRating != null && (minRating < 0 || minRating > 5)) {
      throw AppError('Rating must be between 0 and 5');
    }

    return await _repository.getSalons(
      page: page,
      limit: limit,
      search: search,
      minRating: minRating,
      location: location,
      openNow: openNow,
    );
  }
}

class SearchSalonsUseCase {
  final SalonRepository _repository;

  SearchSalonsUseCase(this._repository);

  Future<List<dynamic>> execute(String query) async {
    if (query.isEmpty) throw AppError('Search query cannot be empty');
    if (query.length < 2) throw AppError('Search query must be at least 2 characters');

    return await _repository.searchSalons(query);
  }
}

class GetSalonDetailsUseCase {
  final SalonRepository _repository;

  GetSalonDetailsUseCase(this._repository);

  Future<dynamic> execute(int salonId) async {
    if (salonId <= 0) throw AppError('Invalid salon ID');

    return await _repository.getSalonDetails(salonId);
  }
}

class GetSalonServicesUseCase {
  final SalonRepository _repository;

  GetSalonServicesUseCase(this._repository);

  Future<List<dynamic>> execute(int salonId) async {
    if (salonId <= 0) throw AppError('Invalid salon ID');

    return await _repository.getSalonServices(salonId);
  }
}

class SubmitReviewUseCase {
  final SalonRepository _repository;

  SubmitReviewUseCase(this._repository);

  Future<dynamic> execute({
    required int salonId,
    required int customerId,
    required int rating,
    required String comment,
    int? appointmentId,
    List<String>? photos,
  }) async {
    if (salonId <= 0) throw AppError('Invalid salon ID');
    if (customerId <= 0) throw AppError('Invalid customer ID');
    if (rating < 1 || rating > 5) throw AppError('Rating must be between 1 and 5');
    if (comment.isEmpty) throw AppError('Comment cannot be empty');
    if (comment.length < 10) throw AppError('Comment must be at least 10 characters');

    return await _repository.submitReview(
      salonId: salonId,
      customerId: customerId,
      rating: rating,
      comment: comment,
      appointmentId: appointmentId,
      photos: photos,
    );
  }
}

class GetNearbySalonsUseCase {
  final SalonRepository _repository;

  GetNearbySalonsUseCase(this._repository);

  Future<List<dynamic>> execute(double lat, double lng, double radiusKm) async {
    if (lat < -90 || lat > 90) throw AppError('Invalid latitude');
    if (lng < -180 || lng > 180) throw AppError('Invalid longitude');
    if (radiusKm <= 0 || radiusKm > 100) throw AppError('Radius must be between 0 and 100 km');

    return await _repository.getNearbySalons(lat, lng, radiusKm);
  }
}
