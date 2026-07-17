// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

// Context extensions for easy access to theme, media query, etc.
extension ContextExtensions on BuildContext {
  // Theme access
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // Media query access
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
  double get statusBarHeight => mediaQuery.padding.top;
  double get bottomPadding => mediaQuery.padding.bottom;
  double get safeAreaHeight => screenHeight - statusBarHeight - bottomPadding;

  // Navigation
  NavigatorState get navigator => Navigator.of(this);
  void pop<T>([T? result]) => navigator.pop(result);
  Future<T?> push<T>(Route<T> route) => navigator.push(route);
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) =>
      navigator.pushNamed<T>(routeName, arguments: arguments);

  // Focus management
  void unfocus() => FocusScope.of(this).unfocus();
  void requestFocus(FocusNode node) => FocusScope.of(this).requestFocus(node);

  // Scaffold and dialogs
  ScaffoldState get scaffold => Scaffold.of(this);
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);
  void showSnackBar(SnackBar snackBar) =>
      scaffoldMessenger.showSnackBar(snackBar);
  void removeCurrentSnackBar() => scaffoldMessenger.removeCurrentSnackBar();
  void hideCurrentSnackBar() => scaffoldMessenger.hideCurrentSnackBar();

  // Localizations
  bool get isRTL => Directionality.of(this) == TextDirection.rtl;
  TextDirection get textDirection => Directionality.of(this);

  // Responsive helpers
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;
  double responsiveValue({double? mobile, double? tablet, double? desktop}) {
    if (isMobile && mobile != null) return mobile;
    if (isTablet && tablet != null) return tablet;
    if (isDesktop && desktop != null) return desktop;
    return mobile ?? tablet ?? desktop ?? 0;
  }
}

// String extensions
extension StringExtensions on String {
  // Validation
  bool get isNullOrEmpty => isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  bool get isEmail => RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  ).hasMatch(this);
  bool get isPhoneNumber => RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(this);
  bool get isURL =>
      RegExp(r'^(https?://)?([\w-]+\.)+[\w-]+(/[\w-./?%&=]*)?$').hasMatch(this);
  bool get isNumeric => double.tryParse(this) != null;

  // Formatting
  String get capitalize =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1).toLowerCase()}' : '';
  String get titleCase => split(' ').map((str) => str.capitalize).join(' ');
  String get removeExtraSpaces => replaceAll(RegExp(r'\s+'), ' ').trim();
  String get sanitizeFilename =>
      replaceAll(RegExp(r'[^\w\s.-]'), '').replaceAll(' ', '_');

  // Truncation
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  String truncateWords(int maxWords, {String suffix = '...'}) {
    final words = split(' ');
    if (words.length <= maxWords) return this;
    return '${words.take(maxWords).join(' ')}$suffix';
  }

  // Parsing
  DateTime? toDateTime() => DateTime.tryParse(this);
  int? toInt() => int.tryParse(this);
  double? toDouble() => double.tryParse(this);

  // Masking
  String maskEmail() {
    if (!isEmail) return this;
    final parts = split('@');
    if (parts[0].length <= 2) return this;
    return '${parts[0][0]}***${parts[0][parts[0].length - 1]}@${parts[1]}';
  }

  String maskPhone() {
    if (length < 4) return this;
    return '***${substring(length - 4)}';
  }

  // Localization placeholder replacement
  String replacePlaceholders(Map<String, String> placeholders) {
    var result = this;
    placeholders.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });
    return result;
  }
}

// DateTime extensions
extension DateTimeExtensions on DateTime {
  // Formatting
  String format(String pattern, [String? locale]) =>
      intl.DateFormat(pattern, locale).format(this);
  String get yyyyMMdd => format('yyyy-MM-dd');
  String get ddMMyyyy => format('dd/MM/yyyy');
  String get hhmm => format('HH:mm');
  String get hhmma => format('hh:mm a');
  String get fullDate => format('EEEE, MMMM d, yyyy');
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    }
    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
    return '${(difference.inDays / 365).floor()}y ago';
  }

  // Comparison
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  bool get isPast => isBefore(DateTime.now());
  bool get isFuture => isAfter(DateTime.now());

  // Manipulation
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
  DateTime get startOfWeek {
    final weekDay = weekday;
    return subtract(Duration(days: weekDay - 1));
  }

  DateTime get endOfWeek => startOfWeek.add(const Duration(days: 6));
  DateTime get startOfMonth => DateTime(year, month, 1);
  DateTime get endOfMonth => DateTime(year, month + 1, 0);

  // Age calculation
  int get age {
    final now = DateTime.now();
    var age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  // Week number
  int get weekNumber {
    final firstDay = DateTime(year, 1, 1);
    final firstMonday = firstDay.add(
      Duration(days: (8 - firstDay.weekday) % 7),
    );
    if (isBefore(firstMonday)) {
      return DateTime(year - 1, 12, 28).weekNumber;
    }
    final diff = difference(firstMonday).inDays;
    return (diff ~/ 7) + 1;
  }
}

// Number extensions
extension NumberExtensions on num {
  // Formatting
  String formatCurrency({String symbol = '\$', int decimalDigits = 2}) {
    final formatter = intl.NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  String formatPercent({int decimalDigits = 1}) {
    final formatter = intl.NumberFormat.decimalPercentPattern(
      decimalDigits: decimalDigits,
    );
    return formatter.format(this / 100);
  }

  String formatCompact() {
    return intl.NumberFormat.compact().format(this);
  }

  String formatDecimal([int decimalDigits = 2]) {
    return intl.NumberFormat.decimalPatternDigits(
      decimalDigits: decimalDigits,
    ).format(this);
  }

  // Clamping
  num clampNum(num min, num max) =>
      this < min ? min : (this > max ? max : this);

  // Percentage calculation
  num percentOf(num total) => total == 0 ? 0 : (this / total * 100);

  // Responsive sizing helper
  double responsiveSize(
    BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    return context.responsiveValue(
      mobile: mobile ?? toDouble(),
      tablet: tablet ?? toDouble(),
      desktop: desktop ?? toDouble(),
    );
  }

  // Duration creation
  Duration get milliseconds => Duration(microseconds: (this * 1000).round());
  Duration get seconds => Duration(milliseconds: (this * 1000).round());
  Duration get minutes => Duration(seconds: (this * 60).round());
  Duration get hours => Duration(minutes: (this * 60).round());
  Duration get days => Duration(hours: (this * 24).round());
}

// List extensions
extension ListExtensions<T> on List<T> {
  // Safe access
  T? get firstOrNull => isEmpty ? null : first;
  T? get lastOrNull => isEmpty ? null : last;
  T? elementAtOrNull(int index) =>
      (index >= 0 && index < length) ? this[index] : null;

  // Manipulation
  List<T> separated(T separator) {
    if (length <= 1) return List.from(this);
    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }

  List<T> distinct() => toSet().toList();

  List<R> mapIndexed<R>(R Function(int index, T element) mapper) {
    final result = <R>[];
    for (var i = 0; i < length; i++) {
      result.add(mapper(i, this[i]));
    }
    return result;
  }

  // Grouping
  Map<K, List<T>> groupBy<K>(K Function(T element) keySelector) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }

  // Validation
  bool none(bool Function(T element) test) => !any(test);
  bool all(bool Function(T element) test) => every(test);

  // Chunking
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }

  // Random
  T get random => this[(DateTime.now().microsecondsSinceEpoch % length).abs()];
}

// Color extensions
extension ColorExtensions on Color {
  // Manipulation
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }

  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color withOpacity(double opacity) => withAlpha((opacity * 255).round());

  // Conversion
  String toHex({bool withHash = true}) {
    final hex =
        '${withHash ? '#' : ''}'
        '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
    return hex;
  }

  // Material design colors
  Color get onColor {
    // Calculate luminance to determine if white or black text should be used
    final luminance = computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Gradient creation
  LinearGradient get toLinearGradient => LinearGradient(
    colors: [this, darken(0.2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  LinearGradient toLinearGradientWith(Color other) => LinearGradient(
    colors: [this, other],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// Widget extensions
extension WidgetExtensions on Widget {
  // Padding
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);
  Widget paddingSymmetric({double horizontal = 0, double vertical = 0}) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );
  Widget paddingOnly({
    double left = 0,
    double top = 0,
    double right = 0,
    double bottom = 0,
  }) => Padding(
    padding: EdgeInsets.only(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    ),
    child: this,
  );

  // Margin
  Widget marginAll(double value) =>
      Container(margin: EdgeInsets.all(value), child: this);
  Widget marginSymmetric({double horizontal = 0, double vertical = 0}) =>
      Container(
        margin: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        child: this,
      );

  // Alignment
  Widget align([AlignmentGeometry alignment = Alignment.center]) =>
      Align(alignment: alignment, child: this);
  Widget center() => Center(child: this);

  // Gestures
  Widget onTap(VoidCallback onTap, {bool opaque = true}) => GestureDetector(
    onTap: onTap,
    behavior: opaque ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
    child: this,
  );

  Widget onDoubleTap(VoidCallback onDoubleTap) =>
      GestureDetector(onDoubleTap: onDoubleTap, child: this);
  Widget onLongPress(VoidCallback onLongPress) =>
      GestureDetector(onLongPress: onLongPress, child: this);

  // Visibility
  Widget visible(bool visible, {bool maintainState = false}) => Visibility(
    visible: visible,
    maintainState: maintainState,
    maintainSize: maintainState,
    maintainAnimation: maintainState,
    maintainInteractivity: maintainState,
    child: this,
  );

  Widget opacity(double opacity) => Opacity(opacity: opacity, child: this);

  // Constraints
  Widget constrained({
    double? minWidth,
    double? maxWidth,
    double? minHeight,
    double? maxHeight,
  }) => ConstrainedBox(
    constraints: BoxConstraints(
      minWidth: minWidth ?? 0,
      maxWidth: maxWidth ?? double.infinity,
      minHeight: minHeight ?? 0,
      maxHeight: maxHeight ?? double.infinity,
    ),
    child: this,
  );

  Widget expanded([int flex = 1]) => Expanded(flex: flex, child: this);
  Widget flexible([int flex = 1, FlexFit fit = FlexFit.loose]) =>
      Flexible(flex: flex, fit: fit, child: this);

  // Sizing
  Widget sized({double? width, double? height}) =>
      SizedBox(width: width, height: height, child: this);
  Widget width(double width) => SizedBox(width: width, child: this);
  Widget height(double height) => SizedBox(height: height, child: this);

  // Transformation
  Widget rotate(double angle) => Transform.rotate(angle: angle, child: this);
  Widget scale(double scale) => Transform.scale(scale: scale, child: this);
  Widget translate({double x = 0, double y = 0}) =>
      Transform.translate(offset: Offset(x, y), child: this);

  // Decorations
  Widget decorate(Decoration decoration) =>
      DecoratedBox(decoration: decoration, child: this);
  Widget background(Color color) => DecoratedBox(
    decoration: BoxDecoration(color: color),
    child: this,
  );
  Widget rounded(double radius) =>
      ClipRRect(borderRadius: BorderRadius.circular(radius), child: this);
  Widget circular(double radius) => ClipOval(
    child: SizedBox(width: radius * 2, height: radius * 2, child: this),
  );

  // Tooltip
  Widget withTooltip(
    String message, {
    Decoration? decoration,
    double? height,
  }) => Tooltip(
    message: message,
    decoration: decoration,
    constraints: height != null ? BoxConstraints(minHeight: height) : null,
    child: this,
  );
}

// extension ObjectExtensions on Object {
//   bool get hasProperty => this != null;

//   bool hasMethod(String methodName) {
//     try {
//       final dynamic obj = this;
//       return obj[methodName] != null;
//     } catch (e) {
//       return false;
//     }
//   }
// }
