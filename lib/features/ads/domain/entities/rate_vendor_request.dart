class RateVendorRequest {
  final String revieweeId;
  final String adId;
  final int rating;
  final String comment;

  const RateVendorRequest({
    required this.revieweeId,
    required this.adId,
    required this.rating,
    required this.comment,
  });

  factory RateVendorRequest.fromJson(Map<String, dynamic> json) {
    return RateVendorRequest(
      revieweeId: json['revieweeId']?.toString() ?? '',
      adId: json['adId']?.toString() ?? '',
      rating: json['rating'] is int
          ? json['rating'] as int
          : int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'revieweeId': revieweeId,
        'adId': adId,
        'rating': rating,
        'comment': comment,
      };
}
