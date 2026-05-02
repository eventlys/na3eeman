
enum DepositType { fixed, percent }

class SalonPaymentConfig {
  final int id;
  final int salonId;
  final bool allowCash;
  final bool allowOnline;
  final bool allowCliq;
  final bool allowPoints;
  final bool allowVouchers;
  final DepositType depositType;
  final double depositValue;
  final int cancellationWindowHours;
  final int noShowEnforcementThreshold;

  SalonPaymentConfig({
    required this.id,
    required this.salonId,
    this.allowCash = true,
    this.allowOnline = true,
    this.allowCliq = false,
    this.allowPoints = true,
    this.allowVouchers = true,
    this.depositType = DepositType.percent,
    this.depositValue = 0,
    this.cancellationWindowHours = 24,
    this.noShowEnforcementThreshold = 2,
  });

  factory SalonPaymentConfig.fromJson(Map<String, dynamic> json) {
    return SalonPaymentConfig(
      id: json['id'],
      salonId: json['salon'],
      allowCash: json['allow_cash'] ?? true,
      allowOnline: json['allow_online'] ?? true,
      allowCliq: json['allow_cliq'] ?? false,
      allowPoints: json['allow_points'] ?? true,
      allowVouchers: json['allow_vouchers'] ?? true,
      depositType: json['deposit_type'] == 'PERCENT' ? DepositType.percent : DepositType.fixed,
      depositValue: (json['deposit_value'] ?? 0).toDouble(),
      cancellationWindowHours: json['cancellation_window_hours'] ?? 24,
      noShowEnforcementThreshold: json['no_show_enforcement_threshold'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'allow_cash': allowCash,
      'allow_online': allowOnline,
      'allow_cliq': allowCliq,
      'allow_points': allowPoints,
      'allow_vouchers': allowVouchers,
      'deposit_type': depositType == DepositType.percent ? 'PERCENT' : 'FIXED',
      'deposit_value': depositValue,
      'cancellation_window_hours': cancellationWindowHours,
      'no_show_enforcement_threshold': noShowEnforcementThreshold,
    };
  }

  SalonPaymentConfig copyWith({
    bool? allowCash,
    bool? allowOnline,
    bool? allowCliq,
    bool? allowPoints,
    bool? allowVouchers,
    DepositType? depositType,
    double? depositValue,
    int? cancellationWindowHours,
    int? noShowEnforcementThreshold,
  }) {
    return SalonPaymentConfig(
      id: id,
      salonId: salonId,
      allowCash: allowCash ?? this.allowCash,
      allowOnline: allowOnline ?? this.allowOnline,
      allowCliq: allowCliq ?? this.allowCliq,
      allowPoints: allowPoints ?? this.allowPoints,
      allowVouchers: allowVouchers ?? this.allowVouchers,
      depositType: depositType ?? this.depositType,
      depositValue: depositValue ?? this.depositValue,
      cancellationWindowHours: cancellationWindowHours ?? this.cancellationWindowHours,
      noShowEnforcementThreshold: noShowEnforcementThreshold ?? this.noShowEnforcementThreshold,
    );
  }
}
