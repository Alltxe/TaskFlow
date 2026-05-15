class TaskAttachment {
  final String id;
  final String url;
  final String filename;
  final int fileSize;
  final String mimeType;
  final DateTime uploadedAt;
  final String taskId;
  final String groupId;
  final String uploadedById;

  const TaskAttachment({
    required this.id,
    required this.url,
    required this.filename,
    required this.fileSize,
    required this.mimeType,
    required this.uploadedAt,
    required this.taskId,
    required this.groupId,
    required this.uploadedById,
  });

  factory TaskAttachment.fromJson(Map<String, dynamic> json) {
    return TaskAttachment(
      id: json['id'] as String,
      url: json['url'] as String,
      filename: json['filename'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      mimeType: json['mimeType'] as String,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      taskId: json['taskId'] as String,
      groupId: json['groupId'] as String,
      uploadedById: json['uploadedById'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'url': url,
        'filename': filename,
        'fileSize': fileSize,
        'mimeType': mimeType,
        'uploadedAt': uploadedAt.toIso8601String(),
        'taskId': taskId,
        'groupId': groupId,
        'uploadedById': uploadedById,
      };

  bool get isImage =>
      mimeType.startsWith('image/');

  bool get isPdf => mimeType == 'application/pdf';

  String get fileSizeFormatted {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}
