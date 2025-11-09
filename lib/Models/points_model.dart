class PointsModel {
  final int totalPoints;
  final List<PointsTransaction> transactions;
  final Set<PointsType> completedOneTimeActions;

  PointsModel({
    required this.totalPoints,
    required this.transactions,
    required this.completedOneTimeActions,
  });

  PointsModel copyWith({
    int? totalPoints,
    List<PointsTransaction>? transactions,
    Set<PointsType>? completedOneTimeActions,
  }) {
    return PointsModel(
      totalPoints: totalPoints ?? this.totalPoints,
      transactions: transactions ?? this.transactions,
      completedOneTimeActions: completedOneTimeActions ?? this.completedOneTimeActions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPoints': totalPoints,
      'transactions': transactions.map((t) => t.toJson()).toList(),
      'completedOneTimeActions': completedOneTimeActions.map((e) => e.toString()).toList(),
    };
  }

  factory PointsModel.fromJson(Map<String, dynamic> json) {
    return PointsModel(
      totalPoints: json['totalPoints'] ?? 0,
      transactions: (json['transactions'] as List? ?? [])
          .map((t) => PointsTransaction.fromJson(t))
          .toList(),
      completedOneTimeActions: (json['completedOneTimeActions'] as List? ?? [])
          .map((e) => PointsType.values.firstWhere((type) => type.toString() == e))
          .toSet(),
    );
  }
}

class PointsTransaction {
  final PointsType type;
  final int points;
  final DateTime date;
  final String description;

  PointsTransaction({
    required this.type,
    required this.points,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'points': points,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    return PointsTransaction(
      type: PointsType.values.firstWhere((type) => type.toString() == json['type']),
      points: json['points'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }
}

enum PointsType {
  inviteFriend,
  rateShop,
  arriveOnTime,
  shopFeedback,
  rateApp,
  appFeedback,
  makeAppointment,
}

