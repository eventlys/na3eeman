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
      id: json['id'],
      price: double.parse(json['price'].toString()),
      description: json['description'],
      expirationDays: json['expiration_days'],
      createdAt: DateTime.parse(json['created_at']),
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
      id: json['id'],
      giftCardId: json['gift_card'],
      giftCardDetails: json['gift_card_details'] != null
          ? GiftCard.fromJson(json['gift_card_details'])
          : null,
      code: json['code'],
      balance: double.parse(json['balance'].toString()),
      isActive: json['is_active'],
      receiverPhone: json['receiver_phone'],
      message: json['message'],
      expiresAt: DateTime.parse(json['expires_at']),
      purchasedAt: DateTime.parse(json['purchased_at']),
    );
  }
}
