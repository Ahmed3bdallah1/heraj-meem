class PaymentPaginatedModel {
  final bool success;
  final List<PaymentModel> payments;
  final PaymentPagination? pagination;

  PaymentPaginatedModel({
    required this.success,
    required this.payments,
    this.pagination,
  });

  factory PaymentPaginatedModel.fromJson(Map<String, dynamic> json) {
    return PaymentPaginatedModel(
      success: json['success'] ?? true,
      payments: (json['payments'] as List?)
          ?.map((item) => PaymentModel.fromJson(item))
          .toList() ?? [],
      pagination: json['pagination'] != null && json['pagination'] is Map<String, dynamic>
          ? PaymentPagination.fromJson(json['pagination'])
          : null,
    );
  }
}

class PaymentPagination {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaymentPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaymentPagination.fromJson(Map<String, dynamic> json) {
    return PaymentPagination(
      page: json['page'] is int ? json['page'] : (int.tryParse(json['page']?.toString() ?? '1') ?? 1),
      limit: json['limit'] is int ? json['limit'] : (int.tryParse(json['limit']?.toString() ?? '20') ?? 20),
      total: json['total'] is int ? json['total'] : (int.tryParse(json['total']?.toString() ?? '0') ?? 0),
      pages: json['pages'] is int ? json['pages'] : (int.tryParse(json['pages']?.toString() ?? '1') ?? 1),
    );
  }
}

class PaymentModel {
  final String id;
  final String orderId;
  final String type;
  final String planId;
  final String planName;
  final double amount;
  final String status;
  final String? paymentType;
  final String createdAt;

  PaymentModel({
    required this.id,
    required this.orderId,
    required this.type,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.status,
    this.paymentType,
    required this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['_id']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      planId: json['planId']?.toString() ?? '',
      planName: json['planName']?.toString() ?? '',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : 0.0,
      status: json['status']?.toString() ?? '',
      paymentType: json['paymentType']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderId': orderId,
      'type': type,
      'planId': planId,
      'planName': planName,
      'amount': amount,
      'status': status,
      'paymentType': paymentType,
      'createdAt': createdAt,
    };
  }
}

