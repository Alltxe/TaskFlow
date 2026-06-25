class RotationScheduleEntry {
  final String taskId;
  final String taskTitle;
  final String userId;
  final String username;
  final String? avatarUrl;
  final DateTime scheduledDate;
  final String rotationType;
  final String priority;
  final int points;

  const RotationScheduleEntry({
    required this.taskId,
    required this.taskTitle,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.scheduledDate,
    required this.rotationType,
    required this.priority,
    required this.points,
  });

  factory RotationScheduleEntry.fromJson(Map<String, dynamic> json) =>
      RotationScheduleEntry(
        taskId: json['taskId'],
        taskTitle: json['taskTitle'],
        userId: json['userId'],
        username: json['username'],
        avatarUrl: json['avatarUrl'],
        scheduledDate: DateTime.parse(json['scheduledDate']),
        rotationType: json['rotationType'],
        priority: json['priority'],
        points: json['points'],
      );
}

class RotationHistoryEntry {
  final String taskId;
  final String taskTitle;
  final String userId;
  final String username;
  final String? avatarUrl;
  final DateTime assignedAt;
  final DateTime? completedAt;
  final String status;
  final String rotationType;
  final int pointsEarned;

  const RotationHistoryEntry({
    required this.taskId,
    required this.taskTitle,
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.assignedAt,
    this.completedAt,
    required this.status,
    required this.rotationType,
    required this.pointsEarned,
  });

  factory RotationHistoryEntry.fromJson(Map<String, dynamic> json) =>
      RotationHistoryEntry(
        taskId: json['taskId'],
        taskTitle: json['taskTitle'],
        userId: json['userId'],
        username: json['username'],
        avatarUrl: json['avatarUrl'],
        assignedAt: DateTime.parse(json['assignedAt']),
        completedAt: json['completedAt'] != null
            ? DateTime.parse(json['completedAt'])
            : null,
        status: json['status'],
        rotationType: json['rotationType'],
        pointsEarned: json['pointsEarned'],
      );
}

class RotationHistoryResult {
  final List<RotationHistoryEntry> items;
  final int total;

  const RotationHistoryResult({required this.items, required this.total});
}

class RotationPattern {
  final String rotationType;
  final List<String> currentCycle;
  final int? currentCycleIndex;

  const RotationPattern({
    required this.rotationType,
    required this.currentCycle,
    this.currentCycleIndex,
  });

  factory RotationPattern.fromJson(Map<String, dynamic> json) =>
      RotationPattern(
        rotationType: json['rotationType'],
        currentCycle: List<String>.from(json['currentCycle'] ?? []),
        currentCycleIndex: json['currentCycleIndex'],
      );
}
