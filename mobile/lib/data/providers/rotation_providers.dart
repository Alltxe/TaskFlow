import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/datasources/rotation_remote_datasource.dart';
import 'package:taskflow/data/models/rotation.dart';

final rotationRemoteDataSourceProvider =
    Provider<RotationRemoteDataSource>((_) => RotationRemoteDataSource());

final rotationScheduleProvider =
    FutureProvider.family<List<RotationScheduleEntry>, String>((ref, groupId) async {
  final ds = ref.watch(rotationRemoteDataSourceProvider);
  return ds.getRotationSchedule(groupId);
});

final rotationHistoryProvider =
    FutureProvider.family<RotationHistoryResult, String>((ref, groupId) async {
  final ds = ref.watch(rotationRemoteDataSourceProvider);
  return ds.getRotationHistory(groupId);
});

final rotationPatternProvider =
    FutureProvider.family<RotationPattern, String>((ref, groupId) async {
  final ds = ref.watch(rotationRemoteDataSourceProvider);
  return ds.getRotationPattern(groupId);
});
