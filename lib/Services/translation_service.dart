// Translation Service for Na3eeman
// Comprehensive Arabic-English bilingual support

class TranslationService {
  // Translation dictionary ported from backend translations.py
  static const Map<String, Map<String, String>> _translations = {
    // Appointment States
    'appointment_confirmed': {
      'en': 'Appointment Confirmed',
      'ar': 'تم تأكيد الموعد',
    },
    'appointment_cancelled': {
      'en': 'Appointment Cancelled',
      'ar': 'تم إلغاء الموعد',
    },
    'appointment_completed': {
      'en': 'Appointment Completed',
      'ar': 'تم إنجاز الموعد',
    },
    'appointment_no_show': {
      'en': 'Customer Did Not Show',
      'ar': 'الزبون لم يحضر',
    },

    // Payment Methods
    'payment_cash': {'en': 'Cash', 'ar': 'نقداً'},
    'payment_card': {'en': 'Credit/Debit Card', 'ar': 'بطاقة ائتمانية'},
    'payment_wallet': {'en': 'Mobile Wallet', 'ar': 'محفظة إلكترونية'},

    // Common UI Elements
    'book_now': {'en': 'Book Now', 'ar': 'احجز الآن'},
    'cancel': {'en': 'Cancel', 'ar': 'إلغاء'},
    'confirm': {'en': 'Confirm', 'ar': 'تأكيد'},
    'view_details': {'en': 'View Details', 'ar': 'عرض التفاصيل'},
    'back': {'en': 'Back', 'ar': 'رجوع'},
    'next': {'en': 'Next', 'ar': 'التالي'},
    'save': {'en': 'Save', 'ar': 'حفظ'},
    'edit': {'en': 'Edit', 'ar': 'تعديل'},
    'delete': {'en': 'Delete', 'ar': 'حذف'},
    'all': {'en': 'All', 'ar': 'الكل'},

    // Common Services
    'service_haircut': {'en': 'Haircut', 'ar': 'حلاقة'},
    'service_beard_trim': {'en': 'Beard Trim', 'ar': 'تهذيب لحية'},
    'service_fade': {'en': 'Fade', 'ar': 'فيد'},
    'service_massage': {'en': 'Massage', 'ar': 'مساج'},
    'service_hammam': {'en': 'Turkish Bath', 'ar': 'حمام تركي'},
    'service_manicure': {'en': 'Manicure', 'ar': 'مانيكير'},
    'service_pedicure': {'en': 'Pedicure', 'ar': 'بديكير'},
    'service_makeup': {'en': 'Makeup', 'ar': 'مكياج'},

    // Time-related
    'minutes': {'en': 'minutes', 'ar': 'دقيقة'},
    'hours': {'en': 'hours', 'ar': 'ساعة'},
    'days': {'en': 'days', 'ar': 'يوم'},
    'opening_time': {'en': 'Opening Time', 'ar': 'وقت الافتتاح'},
    'closing_time': {'en': 'Closing Time', 'ar': 'وقت الإغلاق'},

    // Days of the week
    'monday': {'en': 'Monday', 'ar': 'الاثنين'},
    'tuesday': {'en': 'Tuesday', 'ar': 'الثلاثاء'},
    'wednesday': {'en': 'Wednesday', 'ar': 'الأربعاء'},
    'thursday': {'en': 'Thursday', 'ar': 'الخميس'},
    'friday': {'en': 'Friday', 'ar': 'الجمعة'},
    'saturday': {'en': 'Saturday', 'ar': 'السبت'},
    'sunday': {'en': 'Sunday', 'ar': 'الأحد'},

    // Error Messages
    'error_required_field': {
      'en': 'This field is required',
      'ar': 'هذا الحقل مطلوب',
    },
    'error_invalid_phone': {
      'en': 'Invalid phone number',
      'ar': 'رقم هاتف غير صحيح',
    },
    'error_booking_past': {
      'en': 'Cannot book in the past',
      'ar': 'لا يمكن الحجز في الماضي',
    },
    'error_slot_taken': {
      'en': 'This time slot is not available',
      'ar': 'هذا الوقت غير متاح',
    },
    'error_female_only': {
      'en': 'This salon is for women only',
      'ar': 'هذا الصالون للنساء فقط',
    },

    // Success Messages
    'success_booking_created': {
      'en': 'Booking confirmed! Check WhatsApp for details.',
      'ar': 'تم تأكيد الحجز! تحقق من الواتساب للتفاصيل.',
    },
    'success_profile_updated': {
      'en': 'Profile updated successfully',
      'ar': 'تم تحديث الملف الشخصي بنجاح',
    },
    'success_payment_confirmed': {
      'en': 'Payment confirmed',
      'ar': 'تم تأكيد الدفع',
    },

    // Event Types
    'event_wedding': {'en': 'Wedding', 'ar': 'عرس'},
    'event_engagement': {'en': 'Engagement', 'ar': 'خطوبة'},
    'event_birthday': {'en': 'Birthday', 'ar': 'عيد ميلاد'},
    'event_eid': {'en': 'Eid', 'ar': 'عيد'},

    // Spa-specific
    'has_sauna': {'en': 'Has Sauna', 'ar': 'يوجد ساونا'},
    'has_steam': {'en': 'Has Steam Room', 'ar': 'يوجد غرفة بخار'},
    'has_jacuzzi': {'en': 'Has Jacuzzi', 'ar': 'يوجد جاكوزي'},
    'provides_towels': {'en': 'Towels Provided', 'ar': 'مناشف متوفرة'},
    'traditional_hammam': {
      'en': 'Traditional Turkish Bath',
      'ar': 'حمام تركي تقليدي',
    },

    // Loyalty & Points
    'loyalty_points': {'en': 'Loyalty Points', 'ar': 'نقاط الولاء'},
    'points_earned': {'en': 'Points Earned', 'ar': 'نقاط مكتسبة'},
    'points_balance': {'en': 'Points Balance', 'ar': 'رصيد النقاط'},

    // Pricing
    'price': {'en': 'Price', 'ar': 'السعر'},
    'total': {'en': 'Total', 'ar': 'الإجمالي'},
    'discount': {'en': 'Discount', 'ar': 'خصم'},
    'deposit': {'en': 'Deposit', 'ar': 'دفعة مقدمة'},
    'remaining': {'en': 'Remaining', 'ar': 'المتبقي'},

    // Screen titles
    'find_salon': {'en': 'Find Salon', 'ar': 'ابحث عن صالون'},
    'salon_details': {'en': 'Salon Details', 'ar': 'تفاصيل الصالون'},
    'services': {'en': 'Services', 'ar': 'الخدمات'},
    'packages': {'en': 'Packages', 'ar': 'الباقات'},
    'amenities': {'en': 'Amenities', 'ar': 'المرافق'},
    'portfolio': {'en': 'Portfolio', 'ar': 'الأعمال السابقة'},
    'available_amenities': {
      'en': 'Available Amenities',
      'ar': 'المرافق المتوفرة',
    },

    // Jordanian common phrases
    'welcome': {'en': 'Welcome', 'ar': 'أهلاً وسهلاً'},
    'thank_you': {'en': 'Thank you', 'ar': 'شكراً'},
    'youre_welcome': {'en': "You're welcome", 'ar': 'عفواً'},
    'please_wait': {'en': 'Please wait', 'ar': 'يرجى الانتظار'},
    'congratulations_wedding': {
      'en': 'Congratulations on your wedding!',
      'ar': 'مبروك العرس!',
    },
  };

  /// Get translation for a key
  ///
  /// Example:
  /// ```dart
  /// String text = TranslationService.translate('book_now', 'ar');
  /// // Returns: 'احجز الآن'
  /// ```
  static String translate(String key, String language) {
    if (_translations.containsKey(key)) {
      return _translations[key]![language] ?? key;
    }
    return key;
  }

  /// Format currency amount in JOD with proper formatting
  ///
  /// Example:
  /// ```dart
  /// String price = TranslationService.formatCurrency(25.500, 'ar');
  /// // Returns: '25.500 د.أ'
  /// ```
  static String formatCurrency(double amount, String language) {
    String formatted = amount.toStringAsFixed(3);
    return language == 'ar' ? '$formatted د.أ' : 'JOD $formatted';
  }

  /// Get weekday name in Arabic or English
  ///
  /// Args:
  ///   dayNumber: 1=Monday, 7=Sunday (ISO 8601 standard)
  ///   language: 'ar' or 'en'
  ///
  /// Example:
  /// ```dart
  /// String day = TranslationService.getWeekdayName(1, 'ar');
  /// // Returns: 'الاثنين'
  /// ```
  static String getWeekdayName(int dayNumber, String language) {
    const weekdays = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];

    if (dayNumber >= 1 && dayNumber <= 7) {
      return translate(weekdays[dayNumber - 1], language);
    }
    return dayNumber.toString();
  }

  /// Get month name in Arabic or English
  static String getMonthName(int monthNumber, String language) {
    const Map<int, Map<String, String>> months = {
      1: {'en': 'January', 'ar': 'يناير'},
      2: {'en': 'February', 'ar': 'فبراير'},
      3: {'en': 'March', 'ar': 'مارس'},
      4: {'en': 'April', 'ar': 'أبريل'},
      5: {'en': 'May', 'ar': 'مايو'},
      6: {'en': 'June', 'ar': 'يونيو'},
      7: {'en': 'July', 'ar': 'يوليو'},
      8: {'en': 'August', 'ar': 'أغسطس'},
      9: {'en': 'September', 'ar': 'سبتمبر'},
      10: {'en': 'October', 'ar': 'أكتوبر'},
      11: {'en': 'November', 'ar': 'نوفمبر'},
      12: {'en': 'December', 'ar': 'ديسمبر'},
    };

    return months[monthNumber]?[language] ?? monthNumber.toString();
  }

  /// Format date in Arabic or English
  ///
  /// Example:
  /// ```dart
  /// DateTime date = DateTime(2026, 2, 14);
  /// String formatted = TranslationService.formatDate(date, 'ar');
  /// // Returns: '14 فبراير 2026'
  /// ```
  static String formatDate(DateTime date, String language) {
    if (language == 'ar') {
      return '${date.day} ${getMonthName(date.month, language)} ${date.year}';
    } else {
      return '${getMonthName(date.month, language)} ${date.day}, ${date.year}';
    }
  }

  /// Format time in 12-hour format with AM/PM
  static String formatTime(DateTime time, String language) {
    int hour = time.hour;
    String period = hour >= 12
        ? (language == 'ar' ? 'مساءً' : 'PM')
        : (language == 'ar' ? 'صباحاً' : 'AM');
    int hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    String minute = time.minute.toString().padLeft(2, '0');

    return '$hour12:$minute $period';
  }

  /// Format duration in minutes/hours
  static String formatDuration(Duration duration, String language) {
    int totalMinutes = duration.inMinutes;

    if (totalMinutes < 60) {
      return '$totalMinutes ${translate('minutes', language)}';
    } else {
      int hours = totalMinutes ~/ 60;
      int minutes = totalMinutes % 60;

      if (minutes == 0) {
        return '$hours ${translate('hours', language)}';
      } else {
        return '$hours ${translate('hours', language)} $minutes ${translate('minutes', language)}';
      }
    }
  }
}
