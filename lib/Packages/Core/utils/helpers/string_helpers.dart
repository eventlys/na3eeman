import 'dart:math';

class StringHelpers {
  const StringHelpers._();

  static String truncateWithEllipsis(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static String capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
    }).join(' ');
  }

  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 2) return email;
    final maskedUsername = '${username[0]}${'*' * (username.length - 2)}${username[username.length - 1]}';
    return '$maskedUsername@$domain';
  }

  static String maskPhoneNumber(String phone) {
    if (phone.length < 4) return phone;
    final visibleDigits = phone.substring(phone.length - 4);
    return '***$visibleDigits';
  }

  static String formatFileSize(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String pluralize(int count, String singular, [String? plural]) {
    if (count == 1) return singular;
    return plural ?? '${singular}s';
  }

  static String formatList(List<String> items, {String separator = ', ', String lastSeparator = ' and '}) {
    if (items.isEmpty) return '';
    if (items.length == 1) return items.first;
    if (items.length == 2) return '${items.first}$lastSeparator${items.last}';
    final allExceptLast = items.sublist(0, items.length - 1).join(separator);
    return '$allExceptLast$lastSeparator${items.last}';
  }

  static String generateId({int length = 8, String prefix = ''}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final id = String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
    return prefix.isEmpty ? id : '$prefix$id';
  }
}
