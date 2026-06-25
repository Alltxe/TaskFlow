/// Task Priority Levels (PRD 3.4.2)
enum TaskPriority {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  critical('CRITICAL');

  const TaskPriority(this.value);
  final String value;

  static TaskPriority fromString(String value) {
    return TaskPriority.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

/// Task Status States (PRD 3.4.9, GraphQL API)
enum TaskStatus {
  pending('PENDING'), // Assigned, not started
  awaitingApproval('AWAITING_APPROVAL'), // Completed, pending admin review
  completed('COMPLETED'), // Approved and points awarded
  overdue('OVERDUE'), // Deadline passed
  cancelled('CANCELLED'); // Cancelled task

  const TaskStatus(this.value);
  final String value;

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => TaskStatus.pending,
    );
  }
}

/// Rotation Types (GraphQL API)
enum RotationType {
  roundRobin('ROUND_ROBIN'), // Cyclic rotation (oldest completion first)
  random('RANDOM'), // Random assignment
  weightedRandom('WEIGHTED_RANDOM'), // Weighted random assignment
  loadBalancing('LOAD_BALANCING'), // Weight-based balancing
  disabled('DISABLED'); // Manual assignment only (Up-for-Grabs pool)

  const RotationType(this.value);
  final String value;

  static RotationType fromString(String value) {
    return RotationType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => RotationType.roundRobin,
    );
  }
}
