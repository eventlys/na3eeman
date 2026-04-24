// Salon Extensions Models for Na3eeman
// Supports female salons, men's spas, and Turkish baths

/// Salon Type Enum
enum SalonType {
  barbershop,
  beautySalon,
  mensSpa,
  turkishBath,
  hybridBarberSpa,
  nailSalon,
  wellnessCenter;

  String toBackendString() {
    switch (this) {
      case SalonType.barbershop:
        return 'BARBERSALON';
      case SalonType.beautySalon:
        return 'BEAUTY_SALON';
      case SalonType.mensSpa:
        return 'MENS_SPA';
      case SalonType.turkishBath:
        return 'TURKISH_BATH';
      case SalonType.hybridBarberSpa:
        return 'HYBRID_BARBER_SPA';
      case SalonType.nailSalon:
        return 'NAIL_SALON';
      case SalonType.wellnessCenter:
        return 'WELLNESS_CENTER';
    }
  }

  static SalonType fromBackendString(String value) {
    switch (value) {
      case 'BARBERSALON':
        return SalonType.barbershop;
      case 'BEAUTY_SALON':
        return SalonType.beautySalon;
      case 'MENS_SPA':
        return SalonType.mensSpa;
      case 'TURKISH_BATH':
        return SalonType.turkishBath;
      case 'HYBRID_BARBER_SPA':
        return SalonType.hybridBarberSpa;
      case 'NAIL_SALON':
        return SalonType.nailSalon;
      case 'WELLNESS_CENTER':
        return SalonType.wellnessCenter;
      default:
        return SalonType.barbershop;
    }
  }

  String getDisplayName(String language) {
    if (language == 'ar') {
      switch (this) {
        case SalonType.barbershop:
          return 'صالون حلاقة رجالي';
        case SalonType.beautySalon:
          return 'صالون تجميل نسائي';
        case SalonType.mensSpa:
          return 'سبا رجالي';
        case SalonType.turkishBath:
          return 'حمام تركي';
        case SalonType.hybridBarberSpa:
          return 'حلاقة + سبا';
        case SalonType.nailSalon:
          return 'صالون أظافر';
        case SalonType.wellnessCenter:
          return 'مركز صحي';
      }
    } else {
      switch (this) {
        case SalonType.barbershop:
          return 'Barbersalon';
        case SalonType.beautySalon:
          return 'Beauty Salon';
        case SalonType.mensSpa:
          return "Men's Spa";
        case SalonType.turkishBath:
          return 'Turkish Bath';
        case SalonType.hybridBarberSpa:
          return 'Barbersalon + Spa';
        case SalonType.nailSalon:
          return 'Nail Salon';
        case SalonType.wellnessCenter:
          return 'Wellness Center';
      }
    }
  }
}

/// Gender Served Enum
enum GenderServed {
  male,
  female,
  mixed;

  String toBackendString() {
    switch (this) {
      case GenderServed.male:
        return 'MALE';
      case GenderServed.female:
        return 'FEMALE';
      case GenderServed.mixed:
        return 'MIXED';
    }
  }

  static GenderServed fromBackendString(String value) {
    switch (value) {
      case 'MALE':
        return GenderServed.male;
      case 'FEMALE':
        return GenderServed.female;
      case 'MIXED':
        return GenderServed.mixed;
      default:
        return GenderServed.male;
    }
  }

  String getDisplayName(String language) {
    if (language == 'ar') {
      switch (this) {
        case GenderServed.male:
          return 'رجالي';
        case GenderServed.female:
          return 'نسائي';
        case GenderServed.mixed:
          return 'مختلط';
      }
    } else {
      switch (this) {
        case GenderServed.male:
          return 'Male Only';
        case GenderServed.female:
          return 'Female Only';
        case GenderServed.mixed:
          return 'Mixed';
      }
    }
  }
}

/// Service Category for Female Salons
class ServiceCategory {
  final String id;
  final String name;
  final String nameArabic;
  final String description;
  final int avgDurationMinutes;
  final bool requiresSpecialist;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.nameArabic,
    this.description = '',
    required this.avgDurationMinutes,
    this.requiresSpecialist = false,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      nameArabic: json['name_arabic'] ?? '',
      description: json['description'] ?? '',
      avgDurationMinutes: json['avg_duration_minutes'] ?? 30,
      requiresSpecialist: json['requires_specialist'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_arabic': nameArabic,
      'description': description,
      'avg_duration_minutes': avgDurationMinutes,
      'requires_specialist': requiresSpecialist,
    };
  }
}

/// Service Chain Item (part of a package)
class ServiceChainItem {
  final int order;
  final String serviceName;
  final String serviceNameArabic;
  final int durationMinutes;

  ServiceChainItem({
    required this.order,
    required this.serviceName,
    required this.serviceNameArabic,
    required this.durationMinutes,
  });

  factory ServiceChainItem.fromJson(Map<String, dynamic> json) {
    return ServiceChainItem(
      order: json['order'] ?? 0,
      serviceName: json['service_name'] ?? json['service_name_arabic'] ?? '',
      serviceNameArabic: json['service_name_arabic'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 30,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order,
      'service_name': serviceName,
      'service_name_arabic': serviceNameArabic,
      'duration_minutes': durationMinutes,
    };
  }
}

/// Service Chain (Package for Female Salons)
class ServiceChain {
  final String id;
  final String salonId;
  final String name;
  final String nameArabic;
  final String description;
  final String descriptionArabic;
  final double price;
  final Duration totalDuration;
  final String eventType; // WEDDING, ENGAGEMENT, EID, EVERYDAY
  final List<ServiceChainItem> items;
  final bool isActive;

  ServiceChain({
    required this.id,
    required this.salonId,
    required this.name,
    required this.nameArabic,
    this.description = '',
    this.descriptionArabic = '',
    required this.price,
    required this.totalDuration,
    this.eventType = 'EVERYDAY',
    required this.items,
    this.isActive = true,
  });

  factory ServiceChain.fromJson(Map<String, dynamic> json) {
    List<ServiceChainItem> items = [];
    if (json['services'] != null) {
      items = (json['services'] as List)
          .map((item) => ServiceChainItem.fromJson(item))
          .toList();
    }

    return ServiceChain(
      id: json['id']?.toString() ?? '',
      salonId: json['salon_id']?.toString() ?? '',
      name: json['name'] ?? '',
      nameArabic: json['name_arabic'] ?? '',
      description: json['description'] ?? '',
      descriptionArabic: json['description_arabic'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      totalDuration: Duration(minutes: json['duration_minutes'] ?? 60),
      eventType: json['event_type'] ?? 'EVERYDAY',
      items: items,
      isActive: json['is_active'] ?? true,
    );
  }

  String getEventTypeDisplay(String language) {
    if (language == 'ar') {
      switch (eventType) {
        case 'WEDDING':
          return 'عرس';
        case 'ENGAGEMENT':
          return 'خطوبة';
        case 'EID':
          return 'عيد';
        case 'BIRTHDAY':
          return 'عيد ميلاد';
        default:
          return '';
      }
    } else {
      switch (eventType) {
        case 'WEDDING':
          return 'Wedding';
        case 'ENGAGEMENT':
          return 'Engagement';
        case 'EID':
          return 'Eid';
        case 'BIRTHDAY':
          return 'Birthday';
        default:
          return '';
      }
    }
  }
}

/// Spa Package Item
class SpaPackageItem {
  final int order;
  final String serviceName;
  final String serviceNameArabic;
  final int durationMinutes;

  SpaPackageItem({
    required this.order,
    required this.serviceName,
    required this.serviceNameArabic,
    required this.durationMinutes,
  });

  factory SpaPackageItem.fromJson(Map<String, dynamic> json) {
    return SpaPackageItem(
      order: json['order'] ?? 0,
      serviceName: json['service_name'] ?? '',
      serviceNameArabic: json['service_name_arabic'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 30,
    );
  }
}

/// Spa Package (Men's Spa / Turkish Bath)
class SpaPackage {
  final String id;
  final String salonId;
  final String name;
  final String nameArabic;
  final String description;
  final String descriptionArabic;
  final double price;
  final Duration totalDuration;
  final String packageType; // TRADITIONAL, MODERN, LUXURY, ATHLETIC, RELAXATION
  final bool isFeatured;
  final List<SpaPackageItem> items;
  final double? savingsJod;

  SpaPackage({
    required this.id,
    required this.salonId,
    required this.name,
    required this.nameArabic,
    this.description = '',
    this.descriptionArabic = '',
    required this.price,
    required this.totalDuration,
    this.packageType = 'TRADITIONAL',
    this.isFeatured = false,
    required this.items,
    this.savingsJod,
  });

  factory SpaPackage.fromJson(Map<String, dynamic> json) {
    List<SpaPackageItem> items = [];
    if (json['services'] != null) {
      items = (json['services'] as List)
          .map((item) => SpaPackageItem.fromJson(item))
          .toList();
    }

    return SpaPackage(
      id: json['id']?.toString() ?? '',
      salonId: json['salon_id']?.toString() ?? '',
      name: json['name'] ?? '',
      nameArabic: json['name_arabic'] ?? '',
      description: json['description'] ?? '',
      descriptionArabic: json['description_arabic'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      totalDuration: Duration(minutes: json['duration_minutes'] ?? 90),
      packageType: json['package_type'] ?? 'TRADITIONAL',
      isFeatured: json['is_featured'] ?? false,
      items: items,
      savingsJod: json['savings_jod']?.toDouble(),
    );
  }

  String getPackageTypeDisplay(String language) {
    if (language == 'ar') {
      switch (packageType) {
        case 'TRADITIONAL':
          return 'تقليدي';
        case 'MODERN':
          return 'حديث';
        case 'LUXURY':
          return 'فاخر';
        case 'ATHLETIC':
          return 'رياضي';
        case 'RELAXATION':
          return 'استرخاء';
        default:
          return '';
      }
    } else {
      switch (packageType) {
        case 'TRADITIONAL':
          return 'Traditional';
        case 'MODERN':
          return 'Modern';
        case 'LUXURY':
          return 'Luxury';
        case 'ATHLETIC':
          return 'Athletic';
        case 'RELAXATION':
          return 'Relaxation';
        default:
          return '';
      }
    }
  }
}

/// Spa Amenities
class SpaAmenities {
  final bool hasSauna;
  final bool hasSteamRoom;
  final bool hasJacuzzi;
  final bool hasColdPlunge;
  final bool hasRelaxationArea;
  final bool hasPrivateRooms;
  final bool hasVipSection;
  final bool hasTraditionalMarbleSlab;
  final bool providesKeseScrub;
  final bool providesFoamMassage;
  final bool providesTowels;
  final bool providesRobes;
  final bool providesSlippers;
  final bool providesToiletries;
  final bool requiresSwimsuit;

  SpaAmenities({
    this.hasSauna = false,
    this.hasSteamRoom = false,
    this.hasJacuzzi = false,
    this.hasColdPlunge = false,
    this.hasRelaxationArea = true,
    this.hasPrivateRooms = false,
    this.hasVipSection = false,
    this.hasTraditionalMarbleSlab = false,
    this.providesKeseScrub = false,
    this.providesFoamMassage = false,
    this.providesTowels = true,
    this.providesRobes = false,
    this.providesSlippers = true,
    this.providesToiletries = true,
    this.requiresSwimsuit = false,
  });

  factory SpaAmenities.fromJson(Map<String, dynamic> json) {
    return SpaAmenities(
      hasSauna: json['has_sauna'] ?? false,
      hasSteamRoom: json['has_steam_room'] ?? false,
      hasJacuzzi: json['has_jacuzzi'] ?? false,
      hasColdPlunge: json['has_cold_plunge'] ?? false,
      hasRelaxationArea: json['has_relaxation_area'] ?? true,
      hasPrivateRooms: json['has_private_rooms'] ?? false,
      hasVipSection: json['has_vip_section'] ?? false,
      hasTraditionalMarbleSlab: json['has_traditional_marble_slab'] ?? false,
      providesKeseScrub: json['provides_kese_scrub'] ?? false,
      providesFoamMassage: json['provides_foam_massage'] ?? false,
      providesTowels: json['provides_towels'] ?? true,
      providesRobes: json['provides_robes'] ?? false,
      providesSlippers: json['provides_slippers'] ?? true,
      providesToiletries: json['provides_toiletries'] ?? true,
      requiresSwimsuit: json['requires_swimsuit'] ?? false,
    );
  }

  List<AmenityItem> getAmenityList(String language) {
    List<AmenityItem> amenities = [];

    if (hasSauna) {
      amenities.add(AmenityItem(nameEn: 'Sauna', nameAr: 'ساونا', icon: '🧖'));
    }
    if (hasSteamRoom) {
      amenities.add(
        AmenityItem(nameEn: 'Steam Room', nameAr: 'غرفة بخار', icon: '💨'),
      );
    }
    if (hasJacuzzi) {
      amenities.add(
        AmenityItem(nameEn: 'Jacuzzi', nameAr: 'جاكوزي', icon: '🛁'),
      );
    }
    if (hasColdPlunge) {
      amenities.add(
        AmenityItem(nameEn: 'Cold Plunge', nameAr: 'مسبح بارد', icon: '❄️'),
      );
    }
    if (hasRelaxationArea) {
      amenities.add(
        AmenityItem(
          nameEn: 'Relaxation Area',
          nameAr: 'منطقة استرخاء',
          icon: '🛋️',
        ),
      );
    }
    if (hasPrivateRooms) {
      amenities.add(
        AmenityItem(nameEn: 'Private Rooms', nameAr: 'غرف خاصة', icon: '🚪'),
      );
    }
    if (hasVipSection) {
      amenities.add(
        AmenityItem(nameEn: 'VIP Section', nameAr: 'قسم VIP', icon: '👑'),
      );
    }
    if (hasTraditionalMarbleSlab) {
      amenities.add(
        AmenityItem(
          nameEn: 'Traditional Marble Slab',
          nameAr: 'حجر رخامي تقليدي',
          icon: '🪨',
        ),
      );
    }
    if (providesKeseScrub) {
      amenities.add(
        AmenityItem(nameEn: 'Kese Scrubbing', nameAr: 'تكييس', icon: '🧽'),
      );
    }
    if (providesFoamMassage) {
      amenities.add(
        AmenityItem(nameEn: 'Foam Massage', nameAr: 'مساج بالفوم', icon: '🫧'),
      );
    }
    if (providesTowels) {
      amenities.add(
        AmenityItem(
          nameEn: 'Towels Provided',
          nameAr: 'مناشف متوفرة',
          icon: '🧺',
        ),
      );
    }
    if (providesRobes) {
      amenities.add(
        AmenityItem(
          nameEn: 'Robes Provided',
          nameAr: 'أرواب متوفرة',
          icon: '👘',
        ),
      );
    }
    if (providesSlippers) {
      amenities.add(
        AmenityItem(
          nameEn: 'Slippers Provided',
          nameAr: 'شباشب متوفرة',
          icon: '🩴',
        ),
      );
    }
    if (providesToiletries) {
      amenities.add(
        AmenityItem(
          nameEn: 'Toiletries Provided',
          nameAr: 'مستلزمات نظافة متوفرة',
          icon: '🧴',
        ),
      );
    }

    return amenities;
  }
}

class AmenityItem {
  final String nameEn;
  final String nameAr;
  final String icon;

  AmenityItem({required this.nameEn, required this.nameAr, required this.icon});

  String getName(String language) {
    return language == 'ar' ? nameAr : nameEn;
  }
}

/// Event Booking (Weddings, Engagements)
class EventBooking {
  final String id;
  final String appointmentId;
  final String eventType;
  final DateTime eventDate;
  final String? eventTime;
  final int numberOfPeople;
  final String specialRequests;
  final bool requiresDeposit;
  final double depositAmount;
  final bool hasTrialSession;
  final DateTime? trialSessionDate;
  final bool depositPaid;

  EventBooking({
    required this.id,
    required this.appointmentId,
    required this.eventType,
    required this.eventDate,
    this.eventTime,
    this.numberOfPeople = 1,
    this.specialRequests = '',
    this.requiresDeposit = false,
    this.depositAmount = 0.0,
    this.hasTrialSession = false,
    this.trialSessionDate,
    this.depositPaid = false,
  });

  factory EventBooking.fromJson(Map<String, dynamic> json) {
    return EventBooking(
      id: json['id']?.toString() ?? '',
      appointmentId: json['appointment_id']?.toString() ?? '',
      eventType: json['event_type'] ?? 'WEDDING',
      eventDate: DateTime.parse(json['event_date']),
      eventTime: json['event_time'],
      numberOfPeople: json['number_of_people'] ?? 1,
      specialRequests: json['special_requests'] ?? '',
      requiresDeposit: json['requires_deposit'] ?? false,
      depositAmount: (json['deposit_amount'] ?? 0).toDouble(),
      hasTrialSession: json['has_trial_session'] ?? false,
      trialSessionDate: json['trial_session_date'] != null
          ? DateTime.parse(json['trial_session_date'])
          : null,
      depositPaid: json['deposit_paid'] ?? false,
    );
  }
}
