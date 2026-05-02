import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Helpers/logger.dart';

class UnifiedService {
  static final UnifiedService _instance = UnifiedService._internal();
  factory UnifiedService() => _instance;
  UnifiedService._internal();

  // Core service instances
  final FilterService _filterService = FilterService();
  final SearchService _searchService = SearchService();
  final SocialSharingService _sharingService = SocialSharingService();

  // Public accessors
  FilterService get filter => _filterService;
  SearchService get search => _searchService;
  SocialSharingService get sharing => _sharingService;
}

class FilterService {
  static final FilterService _instance = FilterService._internal();
  factory FilterService() => _instance;
  FilterService._internal();

  // Default filter configurations
  Map<String, dynamic> getDefaultFilters(FilterType type) {
    switch (type) {
      case FilterType.salon:
        return {
          'rating': null,
          'price_range': null,
          'distance': null,
          'services': [],
          'availability': null,
          'sort_by': 'rating',
          'sort_order': 'desc',
          'category': null,
        };
      case FilterType.appointment:
        return {
          'status': null,
          'date_range': null,
          'salon_id': null,
          'expert_id': null,
          'sort_by': 'date',
          'sort_order': 'desc',
        };
      case FilterType.staff:
        return {
          'role': null,
          'status': null,
          'rating': null,
          'specialties': [],
          'sort_by': 'name',
          'sort_order': 'asc',
        };
    }
  }

  // Main filter application method
  List<dynamic> applyFilters(List<dynamic> items, Map<String, dynamic> filters, FilterType type) {
    if (items.isEmpty) return items;

    var filteredItems = List<dynamic>.from(items);

    // Apply common filters
    if (filters['rating'] != null) {
      final minRating = filters['rating'] as double;
      filteredItems = filteredItems.where((item) {
        final rating = (item['avgRating'] ?? 0.0) as double;
        return rating >= minRating;
      }).toList();
    }

    // Type-specific filtering
    switch (type) {
      case FilterType.salon:
        filteredItems = _applySalonFilters(filteredItems, filters);
        break;
      case FilterType.appointment:
        filteredItems = _applyAppointmentFilters(filteredItems, filters);
        break;
      case FilterType.staff:
        filteredItems = _applyStaffFilters(filteredItems, filters);
        break;
    }

    // Apply sorting
    filteredItems = _applySorting(filteredItems, filters, type);

    AppLogger.debug('Applied $type filters: ${filters.length} filters, ${filteredItems.length} results');
    return filteredItems;
  }

  List<dynamic> _applySalonFilters(List<dynamic> items, Map<String, dynamic> filters) {
    var filteredItems = items;

    if (filters['price_range'] != null) {
      final priceRange = filters['price_range'] as Map<String, double>;
      final minPrice = priceRange['min'] ?? 0;
      final maxPrice = priceRange['max'] ?? double.infinity;

      filteredItems = filteredItems.where((item) {
        final price = (item['averagePrice'] ?? 0.0) as double;
        return price >= minPrice && price <= maxPrice;
      }).toList();
    }

    if (filters['services'] != null && (filters['services'] as List).isNotEmpty) {
      final requiredServices = filters['services'] as List<String>;
      filteredItems = filteredItems.where((item) {
        final salonServices = (item['services'] ?? []) as List;
        return requiredServices.every((requiredService) =>
          salonServices.any((salonService) =>
            _containsIgnoreCase(salonService.toString(), requiredService)
          )
        );
      }).toList();
    }

    if (filters['availability'] == true) {
      filteredItems = filteredItems.where((item) => _isSalonOpenNow(item)).toList();
    }

    if (filters['category'] != null) {
      final category = filters['category'] as String;
      filteredItems = filteredItems.where((item) {
        return _containsIgnoreCase(item['category'] ?? '', category);
      }).toList();
    }

    return filteredItems;
  }

  List<dynamic> _applyAppointmentFilters(List<dynamic> items, Map<String, dynamic> filters) {
    var filteredItems = items;

    if (filters['status'] != null) {
      final status = filters['status'] as String;
      filteredItems = filteredItems.where((item) {
        return _equalsIgnoreCase(item['status'] ?? '', status);
      }).toList();
    }

    if (filters['date_range'] != null) {
      final dateRange = filters['date_range'] as Map<String, DateTime>;
      final startDate = dateRange['start'];
      final endDate = dateRange['end'];

      if (startDate != null && endDate != null) {
        filteredItems = filteredItems.where((item) {
          final appointmentDate = DateTime.parse(item['start_time'] as String);
          return appointmentDate.isAfter(startDate) && appointmentDate.isBefore(endDate);
        }).toList();
      }
    }

    if (filters['salon_id'] != null) {
      final salonId = filters['salon_id'] as int;
      filteredItems = filteredItems.where((item) {
        final itemSalonId = (item['salon'] ?? item['salon_id']) as int;
        return itemSalonId == salonId;
      }).toList();
    }

    if (filters['expert_id'] != null) {
      final expertId = filters['expert_id'] as int;
      filteredItems = filteredItems.where((item) {
        final itemExpertId = (item['expert'] ?? item['expert_id']) as int?;
        return itemExpertId == expertId;
      }).toList();
    }

    return filteredItems;
  }

  List<dynamic> _applyStaffFilters(List<dynamic> items, Map<String, dynamic> filters) {
    var filteredItems = items;

    if (filters['role'] != null) {
      final role = filters['role'] as String;
      filteredItems = filteredItems.where((item) {
        return _equalsIgnoreCase(item['role'] ?? '', role);
      }).toList();
    }

    if (filters['status'] != null) {
      final status = filters['status'] as String;
      filteredItems = filteredItems.where((item) {
        return _equalsIgnoreCase(item['status'] ?? '', status);
      }).toList();
    }

    if (filters['specialties'] != null && (filters['specialties'] as List).isNotEmpty) {
      final requiredSpecialties = filters['specialties'] as List<String>;
      filteredItems = filteredItems.where((item) {
        final staffSpecialties = (item['specialties'] ?? []) as List;
        return requiredSpecialties.every((requiredSpecialty) =>
          staffSpecialties.any((specialty) =>
            _containsIgnoreCase(specialty.toString(), requiredSpecialty)
          )
        );
      }).toList();
    }

    return filteredItems;
  }

  List<dynamic> _applySorting(List<dynamic> items, Map<String, dynamic> filters, FilterType type) {
    final sortBy = filters['sort_by'] ?? _getDefaultSortBy(type);
    final sortOrder = filters['sort_order'] ?? _getDefaultSortOrder(type);

    items.sort((a, b) {
      final aValue = _getSortValue(a, sortBy, type);
      final bValue = _getSortValue(b, sortBy, type);

      int comparison = _compareValues(aValue, bValue);
      return sortOrder == 'desc' ? -comparison : comparison;
    });

    return items;
  }

  dynamic _getSortValue(dynamic item, String sortBy, FilterType type) {
    switch (type) {
      case FilterType.salon:
        switch (sortBy) {
          case 'rating': return item['avgRating'] ?? 0.0;
          case 'distance': return item['distance'] ?? double.infinity;
          case 'name': return (item['salonName'] ?? item['name'] ?? '').toString().toLowerCase();
          case 'price': return item['averagePrice'] ?? 0.0;
          default: return 0;
        }
      case FilterType.appointment:
        switch (sortBy) {
          case 'date': return DateTime.parse(item['start_time'] as String);
          case 'price': return (item['total_amount'] ?? 0.0) as double;
          case 'status': return (item['status'] ?? '').toString();
          default: return 0;
        }
      case FilterType.staff:
        switch (sortBy) {
          case 'name': return (item['name'] ?? '').toString().toLowerCase();
          case 'rating': return item['rating'] ?? 0.0;
          case 'join_date': return item['joinDate'] ?? '';
          default: return 0;
        }
    }
  }

  int _compareValues(dynamic a, dynamic b) {
    if (a is String && b is String) return a.compareTo(b);
    if (a is num && b is num) return a.compareTo(b);
    if (a is DateTime && b is DateTime) return a.compareTo(b);
    return 0;
  }

  String _getDefaultSortBy(FilterType type) {
    switch (type) {
      case FilterType.salon: return 'rating';
      case FilterType.appointment: return 'date';
      case FilterType.staff: return 'name';
    }
  }

  String _getDefaultSortOrder(FilterType type) {
    switch (type) {
      case FilterType.salon: return 'desc';
      case FilterType.appointment: return 'desc';
      case FilterType.staff: return 'asc';
    }
  }

  bool _isSalonOpenNow(Map<String, dynamic> salon) {
    try {
      final workingHours = salon['workingHours'] as String?;
      if (workingHours == null) return true;

      final now = DateTime.now();
      final currentHour = now.hour;

      final parts = workingHours.split(' - ');
      if (parts.length == 2) {
        final openTime = _parseTime(parts[0]);
        final closeTime = _parseTime(parts[1]);
        return currentHour >= openTime && currentHour < closeTime;
      }

      return true;
    } catch (e) {
      AppLogger.error('Error checking salon availability', error: e);
      return true;
    }
  }

  int _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length == 2) return int.parse(parts[0]);
      return 8;
    } catch (e) {
      return 8;
    }
  }

  bool _containsIgnoreCase(String source, String target) {
    return source.toLowerCase().contains(target.toLowerCase());
  }

  bool _equalsIgnoreCase(String a, String b) {
    return a.toLowerCase() == b.toLowerCase();
  }

  // Extract available filter options from data
  Map<String, List<dynamic>> getAvailableFilters(List<dynamic> items, FilterType type) {
    final filters = <String, List<dynamic>>{};

    switch (type) {
      case FilterType.salon:
        _extractSalonFilters(filters, items);
        break;
      case FilterType.appointment:
        _extractAppointmentFilters(filters, items);
        break;
      case FilterType.staff:
        _extractStaffFilters(filters, items);
        break;
    }

    return filters;
  }

  void _extractSalonFilters(Map<String, List<dynamic>> filters, List<dynamic> items) {
    final ratings = items.map((item) => (item['avgRating'] ?? 0.0) as double).toSet().toList();
    ratings.sort();
    filters['ratings'] = ratings;

    final allServices = <String>{};
    for (final item in items) {
      final services = (item['services'] ?? []) as List;
      for (final service in services) {
        if (service is String) allServices.add(service);
      }
    }
    filters['services'] = allServices.toList()..sort();

    final prices = items.map((item) => (item['averagePrice'] ?? 0.0) as double).toList();
    if (prices.isNotEmpty) {
      final minPrice = prices.reduce((a, b) => a < b ? a : b);
      final maxPrice = prices.reduce((a, b) => a > b ? a : b);
      filters['price_range'] = [minPrice, maxPrice];
    }

    final categories = items.map((item) => (item['category'] ?? '').toString())
        .where((cat) => cat.isNotEmpty).toSet().toList();
    filters['categories'] = categories..sort();
  }

  void _extractAppointmentFilters(Map<String, List<dynamic>> filters, List<dynamic> items) {
    final statuses = items.map((item) => (item['status'] ?? '').toString())
        .where((status) => status.isNotEmpty).toSet().toList();
    filters['statuses'] = statuses..sort();

    final salonIds = items.map((item) => (item['salon'] ?? item['salon_id']) as int).toSet().toList();
    filters['salon_ids'] = salonIds..sort();

    final expertIds = items.map((item) => (item['expert'] ?? item['expert_id']) as int).toSet().toList();
    filters['expert_ids'] = expertIds..sort();
  }

  void _extractStaffFilters(Map<String, List<dynamic>> filters, List<dynamic> items) {
    final roles = items.map((item) => (item['role'] ?? '').toString())
        .where((role) => role.isNotEmpty).toSet().toList();
    filters['roles'] = roles..sort();

    final statuses = items.map((item) => (item['status'] ?? '').toString())
        .where((status) => status.isNotEmpty).toSet().toList();
    filters['statuses'] = statuses..sort();

    final allSpecialties = <String>{};
    for (final item in items) {
      final specialties = (item['specialties'] ?? []) as List;
      for (final specialty in specialties) {
        if (specialty is String) allSpecialties.add(specialty);
      }
    }
    filters['specialties'] = allSpecialties.toList()..sort();
  }
}

enum FilterType { salon, appointment, staff }

class SortOptions {
  static const List<Map<String, dynamic>> salonSortOptions = [
    {'key': 'rating_desc', 'name': 'Highest Rating', 'sort_by': 'rating', 'sort_order': 'desc'},
    {'key': 'rating_asc', 'name': 'Lowest Rating', 'sort_by': 'rating', 'sort_order': 'asc'},
    {'key': 'name_asc', 'name': 'Name A-Z', 'sort_by': 'name', 'sort_order': 'asc'},
    {'key': 'name_desc', 'name': 'Name Z-A', 'sort_by': 'name', 'sort_order': 'desc'},
    {'key': 'distance_asc', 'name': 'Nearest First', 'sort_by': 'distance', 'sort_order': 'asc'},
  ];

  static const List<Map<String, dynamic>> appointmentSortOptions = [
    {'key': 'date_desc', 'name': 'Newest First', 'sort_by': 'date', 'sort_order': 'desc'},
    {'key': 'date_asc', 'name': 'Oldest First', 'sort_by': 'date', 'sort_order': 'asc'},
    {'key': 'price_desc', 'name': 'Highest Price', 'sort_by': 'price', 'sort_order': 'desc'},
    {'key': 'price_asc', 'name': 'Lowest Price', 'sort_by': 'price', 'sort_order': 'asc'},
  ];

  static const List<Map<String, dynamic>> staffSortOptions = [
    {'key': 'name_asc', 'name': 'Name A-Z', 'sort_by': 'name', 'sort_order': 'asc'},
    {'key': 'name_desc', 'name': 'Name Z-A', 'sort_by': 'name', 'sort_order': 'desc'},
    {'key': 'rating_desc', 'name': 'Highest Rating', 'sort_by': 'rating', 'sort_order': 'desc'},
    {'key': 'join_date_desc', 'name': 'Newest First', 'sort_by': 'join_date', 'sort_order': 'desc'},
  ];
}

class FilterStateManager with ChangeNotifier {
  Map<String, dynamic> _currentFilters = {};
  List<dynamic> _allItems = [];
  List<dynamic> _filteredItems = [];
  FilterType _filterType = FilterType.salon;

  Map<String, dynamic> get currentFilters => Map.from(_currentFilters);
  List<dynamic> get filteredItems => List.from(_filteredItems);
  List<dynamic> get allItems => List.from(_allItems);
  FilterType get filterType => _filterType;

  void initialize(List<dynamic> items, FilterType type, [Map<String, dynamic>? initialFilters]) {
    _allItems = List.from(items);
    _filterType = type;
    _currentFilters = initialFilters ?? FilterService().getDefaultFilters(type);
    _applyFilters();
  }

  void updateFilter(String key, dynamic value) {
    _currentFilters[key] = value;
    _applyFilters();
    notifyListeners();
  }

  void updateFilters(Map<String, dynamic> newFilters) {
    _currentFilters.addAll(newFilters);
    _applyFilters();
    notifyListeners();
  }

  void resetFilters() {
    _currentFilters = FilterService().getDefaultFilters(_filterType);
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredItems = FilterService().applyFilters(_allItems, _currentFilters, _filterType);
  }

  void updateItems(List<dynamic> newItems) {
    _allItems = List.from(newItems);
    _applyFilters();
    notifyListeners();
  }

  int get resultCount => _filteredItems.length;

  bool get hasActiveFilters {
    final defaultFilters = FilterService().getDefaultFilters(_filterType);
    return _currentFilters.entries.any((entry) {
      final key = entry.key;
      final value = entry.value;
      final defaultValue = defaultFilters[key];

      if (value is List && defaultValue is List) return value.isNotEmpty;
      return value != defaultValue;
    });
  }
}

class SearchService {
  static final SearchService _instance = SearchService._internal();
  factory SearchService() => _instance;
  SearchService._internal();

  final Map<String, List<dynamic>> _searchIndex = {};
  final SearchHistoryManager _historyManager = SearchHistoryManager();

  void indexData(List<dynamic> data, SearchIndexType type) {
    _searchIndex[type.name] = data;
    AppLogger.debug('Indexed ${data.length} ${type.name} for search');
  }

  List<dynamic> search(String query, SearchIndexType type, {List<dynamic>? customData}) {
    final searchData = customData ?? _searchIndex[type.name] ?? [];
    if (query.isEmpty) return searchData;

    _historyManager.addToHistory(query);
    final searchTerms = query.toLowerCase().split(' ').where((term) => term.isNotEmpty).toList();

    return searchData.where((item) {
      return _matchesAllTerms(item, searchTerms, type);
    }).toList();
  }

  bool _matchesAllTerms(dynamic item, List<String> terms, SearchIndexType type) {
    final searchFields = _getSearchFields(item, type);

    for (final term in terms) {
      if (!searchFields.any((field) => field.toLowerCase().contains(term))) {
        return false;
      }
    }
    return true;
  }

  List<String> _getSearchFields(dynamic item, SearchIndexType type) {
    final fields = <String>[];

    switch (type) {
      case SearchIndexType.salons:
        fields.addAll([
          item['salonName'] ?? item['name'] ?? '',
          item['location'] ?? '',
          item['salonDescription'] ?? item['description'] ?? '',
        ]);
        fields.addAll((item['services'] ?? []).map((service) => service.toString()));
        break;

      case SearchIndexType.services:
        fields.addAll([
          item['name'] ?? '',
          item['description'] ?? '',
          item['category'] ?? '',
        ]);
        break;

      case SearchIndexType.appointments:
        fields.addAll([
          item['customerName'] ?? '',
          item['salonName'] ?? '',
          item['status'] ?? '',
        ]);
        fields.addAll((item['services'] ?? []).map((service) => service.toString()));
        break;

      case SearchIndexType.staff:
        fields.addAll([
          item['name'] ?? '',
          item['email'] ?? '',
          item['role'] ?? '',
        ]);
        fields.addAll((item['specialties'] ?? []).map((specialty) => specialty.toString()));
        break;
    }

    return fields.where((field) => field.isNotEmpty).map((field) => field.toString().toLowerCase()).toList();
  }

  List<String> getSearchSuggestions(String query, {int maxSuggestions = 5}) {
    final suggestions = <String>{};
    final searchData = _searchIndex['salons'] ?? [];

    if (query.isEmpty) {
      return _historyManager.getSearchHistory().take(maxSuggestions).toList();
    }

    final queryLower = query.toLowerCase();

    // History matches
    final historyMatches = _historyManager.getSearchHistory()
        .where((item) => item.toLowerCase().contains(queryLower))
        .take(maxSuggestions ~/ 2);
    suggestions.addAll(historyMatches);

    // Data matches
    for (final salon in searchData) {
      _addSuggestion(suggestions, salon['salonName'] ?? '', queryLower, maxSuggestions);
      _addSuggestion(suggestions, salon['location'] ?? '', queryLower, maxSuggestions);

      final services = salon['services'] ?? [];
      for (final service in services) {
        _addSuggestion(suggestions, service.toString(), queryLower, maxSuggestions);
      }

      if (suggestions.length >= maxSuggestions) break;
    }

    return suggestions.take(maxSuggestions).toList();
  }

  void _addSuggestion(Set<String> suggestions, String text, String query, int max) {
    if (text.toLowerCase().contains(query) && suggestions.length < max) {
      suggestions.add(text);
    }
  }

  Map<String, dynamic> getSearchAnalytics(String query, List<dynamic> results, SearchIndexType type) {
    return {
      'query': query,
      'result_count': results.length,
      'timestamp': DateTime.now().toIso8601String(),
      'search_type': type.name,
      'has_results': results.isNotEmpty,
    };
  }

  void clearIndex() {
    _searchIndex.clear();
    AppLogger.info('Search index cleared');
  }

  List<String> getSearchHistory() => _historyManager.getSearchHistory();
  void clearSearchHistory() => _historyManager.clearHistory();
}

enum SearchIndexType { salons, services, appointments, staff }

class DebouncedSearch {
  final Duration delay;
  Timer? _timer;

  DebouncedSearch({this.delay = const Duration(milliseconds: 300)});

  void run(String query, Function(String) onSearch) {
    _timer?.cancel();
    _timer = Timer(delay, () => onSearch(query));
  }

  void dispose() {
    _timer?.cancel();
  }
}

class SearchHistoryManager {
  static const int _maxHistoryItems = 10;
  final List<String> _searchHistory = [];

  void addToHistory(String query) {
    if (query.trim().isEmpty) return;

    _searchHistory.remove(query);
    _searchHistory.insert(0, query);

    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory.removeLast();
    }

    AppLogger.debug('Added to search history: $query');
  }

  List<String> getSearchHistory() => List.from(_searchHistory);
  void clearHistory() => _searchHistory.clear();
  void removeFromHistory(String query) => _searchHistory.remove(query);
}

class SocialSharingService {
  static final SocialSharingService _instance = SocialSharingService._internal();
  factory SocialSharingService() => _instance;
  SocialSharingService._internal();

  Future<void> shareApp() async {
    const shareText = 'Check out Na3eeman - The best expert salon app! '
        'Find the perfect expert, book appointments, and earn loyalty points. '
        'Download now and get your perfect haircut! ✂️';
    const shareUrl = 'https://na3eeman.com/download';

    await _shareContent('$shareText\n\n$shareUrl', 'App shared successfully', 'Failed to share app');
  }

  Future<void> shareSalon(String salonName, String salonId) async {
    final shareText = 'Check out $salonName on Na3eeman! '
        'They provide excellent haircut services with professional experts. '
        'Book your appointment now! 💈';
    final shareUrl = 'https://na3eeman.com/salon/$salonId';

    await _shareContent('$shareText\n\n$shareUrl', 'Salon shared: $salonName', 'Failed to share salon');
  }

  Future<void> shareAppointment(String appointmentId) async {
    final shareText = 'I just booked an appointment using Na3eeman! '
        'The app makes it so easy to find great experts and book appointments. '
        'You should try it too! 📅';
    final shareUrl = 'https://na3eeman.com/appointment/$appointmentId';

    await _shareContent('$shareText\n\n$shareUrl', 'Appointment shared: $appointmentId', 'Failed to share appointment');
  }

  Future<void> openSocialMedia(String platform) async {
    final urls = {
      'facebook': 'https://facebook.com/na3eeman',
      'twitter': 'https://twitter.com/na3eeman',
      'instagram': 'https://instagram.com/na3eeman',
      'linkedin': 'https://linkedin.com/company/na3eeman',
      'tiktok': 'https://tiktok.com/@na3eeman',
    };

    final url = urls[platform.toLowerCase()];
    if (url != null) {
      final uri = Uri.tryParse(url);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        AppLogger.debug('Social media opened: $platform');
      } else {
        throw Exception('Could not launch $platform');
      }
    } else {
      throw Exception('Unsupported platform: $platform');
    }
  }

  Future<void> inviteFriends(String referralCode) async {
    final inviteText = '''
Join me on Na3eeman - The ultimate expert salon experience! ✂️

🌟 Why you'll love it:
• Find the best experts in your area
• Book appointments easily
• Earn loyalty points and free haircuts
• Get exclusive offers and discounts

Use my referral code: $referralCode
Get 50 bonus points when you sign up! 🎁

Download now: https://na3eeman.com/download

#Na3eeman #ExpertApp #HaircutApp
    ''';

    await _shareContent(inviteText, 'Friends invited with code: $referralCode', 'Failed to invite friends');
  }

  Future<void> shareLoyaltyAchievement(int points, String achievement) async {
    final shareText = 'I just earned $points loyalty points on Na3eeman for $achievement! '
        'The loyalty program is amazing - you get points for bookings, reviews, and more! '
        'Join me and start earning free haircuts! 🏆';
    const shareUrl = 'https://na3eeman.com/loyalty';

    await _shareContent('$shareText\n\n$shareUrl', 'Loyalty achievement shared: $points points', 'Failed to share loyalty achievement');
  }

  Future<void> shareReview(String salonName, int rating) async {
    final stars = '⭐' * rating;
    final shareText = 'I just rated $salonName $rating stars on Na3eeman! $stars\n\n'
        'The app makes it so easy to find and review great expert salons. '
        'Check it out if you\'re looking for a fresh cut! 💈';
    const shareUrl = 'https://na3eeman.com';

    await _shareContent('$shareText\n\n$shareUrl', 'Review shared for: $salonName', 'Failed to share review');
  }

  Future<void> sharePromoCode(String promoCode, String description) async {
    final shareText = '🚨 Exclusive Na3eeman Promo Code! 🚨\n\n'
        'Use code: $promoCode\n'
        '$description\n\n'
        'Download the app and enjoy your discount! '
        'Perfect haircuts are just a tap away! ✂️';
    const shareUrl = 'https://na3eeman.com/download';

    await _shareContent('$shareText\n\n$shareUrl', 'Promo code shared: $promoCode', 'Failed to share promo code');
  }

  Future<void> shareViaEmail({required String recipient, required String subject, required String body}) async {
    try {
      final uri = Uri(
        scheme: 'mailto',
        path: recipient,
        queryParameters: {'subject': subject, 'body': body},
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        AppLogger.debug('Email shared to: $recipient');
      } else {
        throw Exception('Could not launch email');
      }
    } catch (e) {
      AppLogger.error('Failed to share via email: $e');
      rethrow;
    }
  }

  Future<void> shareViaSMS({required String recipient, required String message}) async {
    try {
      final uri = Uri(
        scheme: 'sms',
        path: recipient,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        AppLogger.debug('SMS shared to: $recipient');
      } else {
        throw Exception('Could not launch SMS');
      }
    } catch (e) {
      AppLogger.error('Failed to share via SMS: $e');
      rethrow;
    }
  }

  Future<bool> isSharingAvailable() async {
    try {
      await Share.share('test', subject: 'test');
      return true;
    } catch (e) {
      return false;
    }
  }

  void logShareEvent(String type, {String? itemId, String? platform}) {
    AppLogger.debug('Share event logged', extra: {
      'type': type,
      'item_id': itemId,
      'platform': platform,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _shareContent(String content, String successMessage, String errorMessage) async {
    try {
      await Share.share(content);
      AppLogger.debug(successMessage);
    } catch (e) {
      AppLogger.error('$errorMessage: $e');
      rethrow;
    }
  }
}
