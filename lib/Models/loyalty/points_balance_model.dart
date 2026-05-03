class LoyaltyBalance {
  final int points;
  final int freeHaircutCounter;
  final int freeHaircutsAvailable;
  final String freeHaircutProgress;
  final bool hasPendingPenalty;
  final List<PointTransaction> transactions;

  LoyaltyBalance({
    required this.points,
    required this.freeHaircutCounter,
    required this.freeHaircutsAvailable,
    required this.freeHaircutProgress,
    required this.hasPendingPenalty,
    required this.transactions,
  });

  factory LoyaltyBalance.fromJson(Map<String, dynamic> json) {
    return LoyaltyBalance(
      points: json['points'] as int? ?? 0,
      freeHaircutCounter: json['free_haircut_counter'] as int? ?? 0,
      freeHaircutsAvailable: json['free_haircuts_available'] as int? ?? 0,
      freeHaircutProgress: json['free_haircut_progress'] as String? ?? '0/0',
      hasPendingPenalty: json['has_pending_penalty'] as bool? ?? false,
      transactions: json['transactions'] != null
          ? (json['transactions'] as List).map((t) => PointTransaction.fromJson(t)).toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points,
      'free_haircut_counter': freeHaircutCounter,
      'free_haircuts_available': freeHaircutsAvailable,
      'free_haircut_progress': freeHaircutProgress,
      'has_pending_penalty': hasPendingPenalty,
      'transactions': transactions.map((t) => t.toJson()).toList(),
    };
  }
}

class PointTransaction {
  final String id;
  final int points;
  final String source; // 'INVITE', 'RATING', 'EARLY', 'TIP', 'FREE_CUT', 'ADMIN'
  final DateTime timestamp;
  final String formattedSource;
  final Map<String, dynamic>? metadata;

  PointTransaction({
    required this.id,
    required this.points,
    required this.source,
    required this.timestamp,
    required this.formattedSource,
    this.metadata,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id']?.toString() ?? '',
      points: json['points'] as int,
      source: json['source'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      formattedSource: json['formatted_source'] as String? ?? json['source'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points,
      'source': source,
      'timestamp': timestamp.toIso8601String(),
      'formatted_source': formattedSource,
      'metadata': metadata,
    };
  }
}
