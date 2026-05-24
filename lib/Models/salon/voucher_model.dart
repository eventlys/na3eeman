class Voucher {
  final int id;
  final String code;
  final String voucherType; // 'SERVICE' or 'VALUE'
  final int? serviceId;
  final String? serviceName;
  final double? fixedAmount;
  final String purchaserEmail;
  final String? receiverEmail;
  final bool isRedeemed;
  final DateTime? redeemedAt;
  final DateTime expiresAt;
  final DateTime createdAt;

  Voucher({
    required this.id,
    required this.code,
    required this.voucherType,
    this.serviceId,
    this.serviceName,
    this.fixedAmount,
    required this.purchaserEmail,
    this.receiverEmail,
    required this.isRedeemed,
    this.redeemedAt,
    required this.expiresAt,
    required this.createdAt,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      code: json['code'],
      voucherType: json['voucher_type'] ?? 'VALUE',
      serviceId: json['service'],
      serviceName: json['service_name'],
      fixedAmount: json['fixed_amount'] != null
          ? double.parse(json['fixed_amount'].toString())
          : null,
      purchaserEmail: json['purchaser_email'] ?? '',
      receiverEmail: json['receiver_email'],
      isRedeemed: json['is_redeemed'] ?? false,
      redeemedAt: json['redeemed_at'] != null
          ? DateTime.parse(json['redeemed_at'])
          : null,
      expiresAt: DateTime.parse(json['expires_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
