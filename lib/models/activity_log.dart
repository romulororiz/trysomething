/// A single activity log entry from the server.
class ActivityLogEntry {
  final String id;
  final String? hobbyId;
  final String action;
  final DateTime createdAt;

  const ActivityLogEntry({
    required this.id,
    this.hobbyId,
    required this.action,
    required this.createdAt,
  });

  factory ActivityLogEntry.fromJson(Map<String, dynamic> json) {
    return ActivityLogEntry(
      id: json['id'] as String,
      hobbyId: json['hobbyId'] as String?,
      action: json['action'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
