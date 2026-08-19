/// One match pick returned by `POST /api/match`.
///
/// `score` is the server's stage-1 heuristic score (same scale as the
/// client heuristic, so the existing match-% UI keeps working) and
/// `reason` is either jury-written (source "ai") or heuristic-derived.
class ServerMatch {
  final String hobbyId;
  final int rank;
  final int score;
  final String reason;

  const ServerMatch({
    required this.hobbyId,
    required this.rank,
    required this.score,
    required this.reason,
  });

  factory ServerMatch.fromJson(Map<String, dynamic> json) => ServerMatch(
        hobbyId: json['hobbyId'] as String,
        rank: (json['rank'] as num).toInt(),
        score: (json['score'] as num?)?.toInt() ?? 0,
        reason: json['reason'] as String? ?? '',
      );
}
