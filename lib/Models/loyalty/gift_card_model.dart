class GiftCard {
  final int id;
  final double price;
  final String description;
  final int expirationDays;
  final DateTime createdAt;

  GiftCard({
    required this.id,
    required this.price,
    required this.description,
    required this.expirationDays,
    required this.createdAt,
  });

  factory GiftCard.fromJson(Map<String, dynamic> json) {
    return GiftCard(
      id: json['id'] ?? 0,
      price: double.tryParse((json['price'] ?? 0).toString()) ?? 0.0,
      description: json['description'] ?? '',
      expirationDays: json['expiration_days'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class UserGiftCard {
  final int id;
  final int giftCardId;
  final GiftCard? giftCardDetails;
  final String code;
  final double balance;
  final bool isActive;
  final String? receiverPhone;
  final String? message;
  final DateTime expiresAt;
  final DateTime purchasedAt;

  UserGiftCard({
    required this.id,
    required this.giftCardId,
    this.giftCardDetails,
    required this.code,
    required this.balance,
    required this.isActive,
    this.receiverPhone,
    this.message,
    required this.expiresAt,
    required this.purchasedAt,
  });

  factory UserGiftCard.fromJson(Map<String, dynamic> json) {
    return UserGiftCard(
      id: json['id'] ?? 0,
      giftCardId: json['gift_card'] ?? 0,
      giftCardDetails: json['gift_card_details'] != null
          ? GiftCard.fromJson(json['gift_card_details'])
          : null,
      code: json['code'] ?? '',
      balance: double.tryParse((json['balance'] ?? 0).toString()) ?? 0.0,
      isActive: json['is_active'] ?? false,
      receiverPhone: json['receiver_phone'],
      message: json['message'],
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at']) ?? DateTime.now()
          : DateTime.now(),
      purchasedAt: json['purchased_at'] != null
          ? DateTime.tryParse(json['purchased_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
