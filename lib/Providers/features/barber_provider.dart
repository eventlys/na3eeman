import 'package:flutter/material.dart';
import '../../Services/barber_service.dart';
import '../../Helpers/barber_list_helper.dart';

class BarberProvider with ChangeNotifier {
  final BarberService _barberService = BarberService();

  List<BarberDto> _barbers = [];
  BarberDto? _selectedBarber;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;

  // Getters
  List<BarberDto> get barbers => _barbers;
  BarberDto? get selectedBarber => _selectedBarber;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  // Methods
  Future<void> loadBarbers({
    bool refresh = false,
    String? search,
    int? salonId,
    bool? isActive,
  }) async {
    try {
      if (refresh) {
        _currentPage = 1;
        _hasMore = true;
        _barbers.clear();
      }

      if (!_hasMore && !refresh) return;

      _isLoading = true;
      _error = null;
      notifyListeners();

      final List<BarberDto> newBarbers = await _barberService.getBarbers(
        page: _currentPage,
        limit: 20,
        search: search,
        salonId: salonId,
        isActive: isActive,
      );

      if (refresh) {
        _barbers = newBarbers;
      } else {
        _barbers.addAll(newBarbers);
      }

      _hasMore =
          newBarbers.length == 20; // If we got less than limit, no more data
      _currentPage++;

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBarbers({
    String? search,
    int? salonId,
    bool? isActive,
  }) async {
    return loadBarbers(
      refresh: true,
      search: search,
      salonId: salonId,
      isActive: isActive,
    );
  }

  Future<BarberDto> getBarberById(String barberId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final BarberDto barber = await _barberService.getBarberById(barberId);
      _selectedBarber = barber;

      notifyListeners();
      return barber;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BarberDto> createBarber(Map<String, dynamic> barberData) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final BarberDto newBarber = await _barberService.createBarber(barberData);
      _barbers.insert(0, newBarber);

      notifyListeners();
      return newBarber;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<BarberDto> updateBarber(
    String barberId,
    Map<String, dynamic> barberData,
  ) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final BarberDto updatedBarber = await _barberService.updateBarber(
        barberId,
        barberData,
      );

      final int index = _barbers.indexWhere((barber) => barber.id == barberId);
      if (index != -1) {
        _barbers[index] = updatedBarber;
      }

      if (_selectedBarber?.id == barberId) {
        _selectedBarber = updatedBarber;
      }

      notifyListeners();
      return updatedBarber;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteBarber(String barberId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _barberService.deleteBarber(barberId);

      _barbers.removeWhere((barber) => barber.id == barberId);

      if (_selectedBarber?.id == barberId) {
        _selectedBarber = null;
      }

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectBarber(BarberDto? barber) {
    _selectedBarber = barber;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelection() {
    _selectedBarber = null;
    notifyListeners();
  }
}
