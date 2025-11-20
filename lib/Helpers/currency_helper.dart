import 'dart:math';

import 'package:intl/intl.dart';

import 'logger.dart';

class CurrencyHelper {
  static final CurrencyHelper _instance = CurrencyHelper._internal();

  factory CurrencyHelper() => _instance;

  CurrencyHelper._internal();

  // Default currency settings
  static const String defaultCurrency = 'USD';
  static const String defaultCurrencySymbol = '\$';
  static const int defaultDecimalDigits = 2;

  // Supported currencies with their symbols and decimal places
  static const Map<String, Map<String, dynamic>> supportedCurrencies = {
    'USD': {'symbol': '\$', 'decimalDigits': 2, 'name': 'US Dollar'},
    'EUR': {'symbol': '€', 'decimalDigits': 2, 'name': 'Euro'},
    'GBP': {'symbol': '£', 'decimalDigits': 2, 'name': 'British Pound'},
    'JPY': {'symbol': '¥', 'decimalDigits': 0, 'name': 'Japanese Yen'},
    'CAD': {'symbol': 'CA\$', 'decimalDigits': 2, 'name': 'Canadian Dollar'},
    'AUD': {'symbol': 'A\$', 'decimalDigits': 2, 'name': 'Australian Dollar'},
    'SAR': {'symbol': 'ر.س', 'decimalDigits': 2, 'name': 'Saudi Riyal'},
    'AED': {'symbol': 'د.إ', 'decimalDigits': 2, 'name': 'UAE Dirham'},
    'JOD': {'symbol': 'د.أ', 'decimalDigits': 3, 'name': 'Jordanian Dinar'},
  };

  // Current currency settings
  String _currentCurrency = defaultCurrency;
  NumberFormat? _currentFormatter;

  // Getters
  String get currentCurrency => _currentCurrency;
  String get currentCurrencySymbol => getCurrencySymbol(_currentCurrency);
  int get currentDecimalDigits => getDecimalDigits(_currentCurrency);

  // Initialize with a specific currency
  void initialize(String currencyCode) {
    if (supportedCurrencies.containsKey(currencyCode)) {
      _currentCurrency = currencyCode;
      _currentFormatter = _createFormatter(currencyCode);
    } else {
      _currentCurrency = defaultCurrency;
      _currentFormatter = _createFormatter(defaultCurrency);
      AppLogger.warning('Unsupported currency: $currencyCode, defaulting to $defaultCurrency');
    }
  }

  // Format amount with current currency
  String format(double amount, {bool showSymbol = true}) {
    if (_currentFormatter == null) {
      initialize(_currentCurrency);
    }

    try {
      var formatted = _currentFormatter!.format(amount);

      if (!showSymbol) {
        // Remove currency symbol if not needed
        final symbol = getCurrencySymbol(_currentCurrency);
        formatted = formatted.replaceAll(symbol, '').trim();
      }

      return formatted;
    } catch (e) {
      AppLogger.error('Failed to format currency: $amount $_currentCurrency', error: e);
      return _formatFallback(amount, showSymbol: showSymbol);
    }
  }

  // Format amount with specific currency
  String formatWithCurrency(double amount, String currencyCode, {bool showSymbol = true}) {
    try {
      final formatter = _createFormatter(currencyCode);
      var formatted = formatter.format(amount);

      if (!showSymbol) {
        final symbol = getCurrencySymbol(currencyCode);
        formatted = formatted.replaceAll(symbol, '').trim();
      }

      return formatted;
    } catch (e) {
      AppLogger.error('Failed to format currency: $amount $currencyCode', error: e);
      return _formatFallback(amount, currencyCode: currencyCode, showSymbol: showSymbol);
    }
  }

  // Parse currency string to double
  double parse(String currencyString, {String? currencyCode}) {
    try {
      final code = currencyCode ?? _currentCurrency;
      final formatter = _createFormatter(code);

      // Remove any non-numeric characters except decimal separator
      final cleaned = currencyString.replaceAll(RegExp(r'[^\d.,]'), '');

      return formatter.parse(cleaned).toDouble();
    } catch (e) {
      AppLogger.error('Failed to parse currency: $currencyString', error: e);
      return 0.0;
    }
  }

  // Get currency symbol
  String getCurrencySymbol(String currencyCode) {
    return supportedCurrencies[currencyCode]?['symbol'] ?? defaultCurrencySymbol;
  }

  // Get decimal digits for currency
  int getDecimalDigits(String currencyCode) {
    return supportedCurrencies[currencyCode]?['decimalDigits'] ?? defaultDecimalDigits;
  }

  // Get currency name
  String getCurrencyName(String currencyCode) {
    return supportedCurrencies[currencyCode]?['name'] ?? currencyCode;
  }

  // Check if currency is supported
  bool isCurrencySupported(String currencyCode) {
    return supportedCurrencies.containsKey(currencyCode);
  }

  // Get all supported currencies
  List<String> getSupportedCurrencies() {
    return supportedCurrencies.keys.toList();
  }

  // Convert amount between currencies (basic implementation)
  double convertAmount(double amount, String fromCurrency, String toCurrency, double exchangeRate) {
    if (fromCurrency == toCurrency) return amount;

    return amount * exchangeRate;
  }

  // Format for display in lists (compact format)
  String formatCompact(double amount, {bool showSymbol = true}) {
    if (amount >= 1000) {
      final formatted = (amount / 1000).toStringAsFixed(1);
      return '${showSymbol ? currentCurrencySymbol : ''}$formatted';
    }

    return format(amount, showSymbol: showSymbol);
  }

  // Format for input fields
  String formatForInput(double amount, {bool showSymbol = false}) {
    return format(amount, showSymbol: showSymbol);
  }

  // Validate currency amount
  bool isValidAmount(double amount) {
    return amount >= 0 && amount <= 1000000000; // Reasonable upper limit
  }

  // Calculate percentage of amount
  double calculatePercentage(double amount, double percentage) {
    return (amount * percentage) / 100;
  }

  // Format percentage
  String formatPercentage(double percentage, {int decimalDigits = 1}) {
    return '${percentage.toStringAsFixed(decimalDigits)}%';
  }

  // Calculate tax amount
  double calculateTax(double amount, double taxRate) {
    return calculatePercentage(amount, taxRate);
  }

  // Calculate total with tax
  double calculateTotalWithTax(double amount, double taxRate) {
    return amount + calculateTax(amount, taxRate);
  }

  // Calculate discount amount
  double calculateDiscount(double amount, double discountPercentage) {
    return calculatePercentage(amount, discountPercentage);
  }

  // Calculate amount after discount
  double calculateAmountAfterDiscount(double amount, double discountPercentage) {
    return amount - calculateDiscount(amount, discountPercentage);
  }

  // Split amount equally
  List<double> splitAmountEqually(double totalAmount, int numberOfSplits) {
    if (numberOfSplits <= 0) return [];

    final splitAmount = totalAmount / numberOfSplits;
    final splits = List<double>.filled(numberOfSplits, splitAmount);

    // Adjust for rounding errors
    final adjustedTotal = splitAmount * numberOfSplits;
    if (adjustedTotal != totalAmount) {
      final difference = totalAmount - adjustedTotal;
      splits[0] += difference;
    }

    return splits;
  }

  // Private helper methods
  NumberFormat _createFormatter(String currencyCode) {
    final symbol = getCurrencySymbol(currencyCode);
    final decimalDigits = getDecimalDigits(currencyCode);

    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
  }

  String _formatFallback(double amount, {String? currencyCode, bool showSymbol = true}) {
    final code = currencyCode ?? _currentCurrency;
    final symbol = showSymbol ? getCurrencySymbol(code) : '';
    final decimalDigits = getDecimalDigits(code);

    final formattedAmount = amount.toStringAsFixed(decimalDigits);
    return '$symbol$formattedAmount';
  }

  // Round amount to currency decimal places
  double roundToCurrencyDecimal(double amount, {String? currencyCode}) {
    final digits = currencyCode != null ? getDecimalDigits(currencyCode) : currentDecimalDigits;
    final factor = pow(10, digits);
    return (amount * factor).round() / factor;
  }

  // Compare amounts with currency consideration
  int compareAmounts(double amount1, double amount2, {String? currency1, String? currency2}) {
    if (currency1 == currency2 || (currency1 == null && currency2 == null)) {
      return amount1.compareTo(amount2);
    }

    // For different currencies, we'd need exchange rates
    // For now, just compare the numeric values
    AppLogger.warning('Comparing amounts in different currencies without exchange rate');
    return amount1.compareTo(amount2);
  }
}
