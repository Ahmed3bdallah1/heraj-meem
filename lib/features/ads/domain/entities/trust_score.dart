class TrustScore {
  final int verifiedLevel;
  final double score;

  const TrustScore({
    required this.verifiedLevel,
    required this.score,
  });

  factory TrustScore.fromJson(Map<String, dynamic> json) {
    final rawLevel = json['verifiedLevel'];
    final rawScore = json['score'];
    return TrustScore(
      verifiedLevel: rawLevel is int
          ? rawLevel
          : int.tryParse(rawLevel?.toString() ?? '') ?? 0,
      score: rawScore is num
          ? rawScore.toDouble()
          : double.tryParse(rawScore?.toString() ?? '') ?? 0,
    );
  }

  static TrustScore? maybeFrom(dynamic raw) {
    if (raw is! Map) return null;
    return TrustScore.fromJson(Map<String, dynamic>.from(raw));
  }

  Map<String, dynamic> toJson() {
    return {
      'verifiedLevel': verifiedLevel,
      'score': score,
    };
  }
}
