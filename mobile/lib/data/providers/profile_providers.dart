import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskflow/data/datasources/profile_remote_datasource.dart';
import 'package:taskflow/data/repositories/profile_repository.dart';
import 'package:taskflow/data/repositories/profile_repository_impl.dart';
import 'package:taskflow/domain/usecases/profile/get_user_groups_usecase.dart';
import 'package:taskflow/domain/usecases/profile/get_user_profile_usecase.dart';
import 'package:taskflow/domain/usecases/profile/get_user_statistics_usecase.dart';
import 'package:taskflow/domain/usecases/profile/update_profile_usecase.dart';
import 'package:taskflow/domain/usecases/profile/upload_avatar_usecase.dart';

/// Provider for ProfileRemoteDataSource
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource();
});

/// Provider for ProfileRepository
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final remoteDataSource = ref.watch(profileRemoteDataSourceProvider);
  return ProfileRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// Provider for GetUserProfileUseCase
final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserProfileUseCase(repository);
});

/// Provider for GetUserStatisticsUseCase
final getUserStatisticsUseCaseProvider = Provider<GetUserStatisticsUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserStatisticsUseCase(repository);
});

/// Provider for GetUserGroupsUseCase
final getUserGroupsUseCaseProvider = Provider<GetUserGroupsUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return GetUserGroupsUseCase(repository);
});

/// Provider for UpdateProfileUseCase
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

/// Provider for UploadAvatarUseCase
final uploadAvatarUseCaseProvider = Provider<UploadAvatarUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UploadAvatarUseCase(repository);
});
