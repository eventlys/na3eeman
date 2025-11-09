import 'package:flutter/material.dart';

enum PaymentMethod { cash, cliq, visa }

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.cliq:
        return 'CliQ';
      case PaymentMethod.visa:
        return 'Visa';
    }
  }
  
  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.cliq:
        return Icons.account_balance_wallet;
      case PaymentMethod.visa:
        return Icons.credit_card;
    }
  }
}
