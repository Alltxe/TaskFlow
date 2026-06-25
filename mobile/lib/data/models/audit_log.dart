class AuditLogUser {
  final String id;
  final String username;
  final String email;

  const AuditLogUser({
    required this.id,
    required this.username,
    required this.email,
  });

  factory AuditLogUser.fromJson(Map<String, dynamic> json) {
    return AuditLogUser(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }
}

class AuditLog {
  final String id;
  final String action;
  final String entityType;
  final String? entityId;
  final DateTime performedAt;
  final String? userId;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final AuditLogUser? user;
  final AuditLogUser? performedBy;

  const AuditLog({
    required this.id,
    required this.action,
    required this.entityType,
    this.entityId,
    required this.performedAt,
    this.userId,
    this.oldValues,
    this.newValues,
    this.user,
    this.performedBy,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] as String,
      action: json['action'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String?,
      performedAt: _parseDateTime(json['performedAt']),
      userId: json['userId'] as String?,
      oldValues: _parseJsonMap(json['oldValues']),
      newValues: _parseJsonMap(json['newValues']),
      user: json['user'] != null ? AuditLogUser.fromJson(json['user'] as Map<String, dynamic>) : null,
      performedBy: json['performedBy'] != null
          ? AuditLogUser.fromJson(json['performedBy'] as Map<String, dynamic>)
          : null,
    );
  }

  static Map<String, dynamic>? _parseJsonMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.parse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    if (value is num) {
      return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    }
    throw FormatException('Invalid performedAt: $value');
  }
}

class AuditLogList {
  final List<AuditLog> logs;
  final int total;
  final int limit;
  final int offset;

  const AuditLogList({
    required this.logs,
    required this.total,
    required this.limit,
    required this.offset,
  });

  factory AuditLogList.fromJson(Map<String, dynamic> json) {
    final logsData = json['logs'] as List<dynamic>? ?? [];
    return AuditLogList(
      logs: logsData.map((e) => AuditLog.fromJson(e as Map<String, dynamic>)).toList(),
      total: (json['total'] as num?)?.toInt() ?? logsData.length,
      limit: (json['limit'] as num?)?.toInt() ?? logsData.length,
      offset: (json['offset'] as num?)?.toInt() ?? 0,
    );
  }
}

class GetAuditLogsInput {
  final String? entityType;
  final String? action;
  final String? userId;
  final String? startDate;
  final String? endDate;
  final int limit;
  final int offset;

  const GetAuditLogsInput({
    this.entityType,
    this.action,
    this.userId,
    this.startDate,
    this.endDate,
    this.limit = 50,
    this.offset = 0,
  });

  Map<String, dynamic> toJson() => {
        if (entityType != null) 'entityType': entityType,
        if (action != null) 'action': action,
        if (userId != null) 'userId': userId,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        'limit': limit,
        'offset': offset,
      };
}
