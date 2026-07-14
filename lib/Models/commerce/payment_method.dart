import 'package:flutter/material.dart';

enum PaymentMethod { cash, cliq, subscription }

extension PaymentMethodExtension on PaymentMethod {
  String get value {
    switch (this) {
      case PaymentMethod.cash:
        return 'CASH';
      case PaymentMethod.cliq:
        return 'CLIQ';
      // case PaymentMethod.visa:
      //   return 'VISA';
      case PaymentMethod.subscription:
        return 'SUBSCRIPTION';
    }
  }

  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.cliq:
        return 'CliQ';
      // case PaymentMethod.visa:
      //   return 'Credit Card';
      case PaymentMethod.subscription:
        return 'Subscription';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.money;
      case PaymentMethod.cliq:
        return Icons.account_balance_wallet;
      // case PaymentMethod.visa:
      //   return Icons.credit_card;
      case PaymentMethod.subscription:
        return Icons.subscriptions;
    }
  }

  static PaymentMethod fromString(String value) {
    switch (value.toUpperCase()) {
      case 'CASH':
        return PaymentMethod.cash;
      case 'CLIQ':
        return PaymentMethod.cliq;
      // case 'VISA':
      //   return PaymentMethod.visa;
      case 'SUBSCRIPTION':
        return PaymentMethod.subscription;
      default:
        return PaymentMethod.cash;
    }
  }
}

class PaymentIntent {
  final String id;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final String status;
  final DateTime createdAt;

  PaymentIntent({
    required this.id,
    required this.amount,
    this.currency = 'USD',
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    return PaymentIntent(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      paymentMethod: PaymentMethodExtension.fromString(
        json['payment_method'] as String,
      ),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod.value,
    };
  }
}

class PaymentCard {
  final String cardNumber;
  final int expMonth;
  final int expYear;
  final String cvc;
  final String cardHolderName;

  PaymentCard({
    required this.cardNumber,
    required this.expMonth,
    required this.expYear,
    required this.cvc,
    required this.cardHolderName,
  });

  Map<String, dynamic> toJson() {
    return {
      'card_number': cardNumber,
      'exp_month': expMonth,
      'exp_year': expYear,
      'cvc': cvc,
      'card_holder_name': cardHolderName,
    };
  }

  String get maskedCardNumber {
    if (cardNumber.length < 4) return cardNumber;
    return '**** ${cardNumber.substring(cardNumber.length - 4)}';
  }
}
