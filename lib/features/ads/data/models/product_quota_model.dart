class ProductQuotaModel {
  final int used;
  final int max;
  final int remaining;
  final QuotaByStatus byStatus;

  ProductQuotaModel({
    required this.used,
    required this.max,
    required this.remaining,
    required this.byStatus,
  });

  factory ProductQuotaModel.fromJson(Map<String, dynamic> json) {
    return ProductQuotaModel(
      used: json['used'] is int
          ? json['used']
          : (int.tryParse(json['used']?.toString() ?? '0') ?? 0),
      max: json['max'] is int
          ? json['max']
          : (int.tryParse(json['max']?.toString() ?? '0') ?? 0),
      remaining: json['remaining'] is int
          ? json['remaining']
          : (int.tryParse(json['remaining']?.toString() ?? '0') ?? 0),
      byStatus: json['byStatus'] != null
          ? QuotaByStatus.fromJson(json['byStatus'])
          : QuotaByStatus(pending: 0, approved: 0, rejected: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'used': used,
      'max': max,
      'remaining': remaining,
      'byStatus': byStatus.toJson(),
    };
  }

  bool get canAddProduct => remaining > 0;
  bool get hasReachedLimit => remaining <= 0;
}

class QuotaByStatus {
  final int pending;
  final int approved;
  final int rejected;

  QuotaByStatus({
    required this.pending,
    required this.approved,
    required this.rejected,
  });

  factory QuotaByStatus.fromJson(Map<String, dynamic> json) {
    return QuotaByStatus(
      pending: json['pending'] is int
          ? json['pending']
          : (int.tryParse(json['pending']?.toString() ?? '0') ?? 0),
      approved: json['approved'] is int
          ? json['approved']
          : (int.tryParse(json['approved']?.toString() ?? '0') ?? 0),
      rejected: json['rejected'] is int
          ? json['rejected']
          : (int.tryParse(json['rejected']?.toString() ?? '0') ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }
}
