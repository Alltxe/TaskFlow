class GroupPreview {
  final String id;
  final String name;
  final String? description;
  final int memberCount;
  final bool requiresApproval;

  const GroupPreview({
    required this.id,
    required this.name,
    this.description,
    required this.memberCount,
    required this.requiresApproval,
  });

  factory GroupPreview.fromJson(Map<String, dynamic> json) {
    return GroupPreview(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      memberCount: (json['memberCount'] as num).toInt(),
      requiresApproval: json['requiresApproval'] as bool,
    );
  }
}
