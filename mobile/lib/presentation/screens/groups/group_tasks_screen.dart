import 'package:flutter/material.dart';
import 'package:mobile/presentation/screens/tasks/tasks_screen.dart';

/// Minimal wrapper — reuse the centralized tasks screen to show group tasks.
class GroupTasksScreen extends StatelessWidget {
  final String groupId;

  const GroupTasksScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) => TasksScreen(groupId: groupId);
}
