import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat dateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat timeFormat = DateFormat('HH:mm');
  static final NumberFormat currencyFormat = NumberFormat.currency(symbol: '\$');
  static final NumberFormat percentFormat = NumberFormat.percentPattern();

  static String formatCurrency(double amount) {
    return currencyFormat.format(amount);
  }

  static String formatDate(DateTime date) {
    return dateFormat.format(date);
  }

  static String formatPercent(double value) {
    return percentFormat.format(value);
  }
}

