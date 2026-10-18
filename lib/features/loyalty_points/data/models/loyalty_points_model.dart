class LoyaltyPointsModel {
  final int balance;
  final List<LoyaltyPointsHistoryItem> history;

  LoyaltyPointsModel({
    required this.balance,
    required this.history,
  });

  factory LoyaltyPointsModel.fromJson(Map<String, dynamic> json) {
    return LoyaltyPointsModel(
      balance: json['balance'] ?? json['points'] ?? json['loyalty_points'] ?? 0,
      history: json['history'] != null
          ? (json['history'] as List)
              .map((item) => LoyaltyPointsHistoryItem.fromJson(item))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'history': history.map((item) => item.toJson()).toList(),
    };
  }
}

class LoyaltyPointsHistoryItem {
  final int id;
  final int points; // Points amount (positive for earned, negative for spent)
  final String type; // Type of transaction (e.g., 'earned', 'spent', 'purchase', 'reward')
  final String? description; // Description of the transaction
  final String createdAt; // Date and time of the transaction
  final String? orderId; // Optional order ID if related to an order

  LoyaltyPointsHistoryItem({
    required this.id,
    required this.points,
    required this.type,
    this.description,
    required this.createdAt,
    this.orderId,
  });

  factory LoyaltyPointsHistoryItem.fromJson(Map<String, dynamic> json) {
    return LoyaltyPointsHistoryItem(
      id: json['id'] ?? 0,
      points: json['points'] ?? json['amount'] ?? 0,
      type: json['type'] ?? json['transaction_type'] ?? 'unknown',
      description: json['description'] ?? json['note'],
      createdAt: json['created_at'] ?? json['date'] ?? '',
      orderId: json['order_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'points': points,
      'type': type,
      'description': description,
      'created_at': createdAt,
      'order_id': orderId,
    };
  }

  /// Check if points were earned (positive) or spent (negative)
  bool get isEarned => points > 0;
  bool get isSpent => points < 0;
}


