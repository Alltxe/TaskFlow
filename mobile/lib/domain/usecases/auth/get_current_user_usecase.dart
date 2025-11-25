import 'package:taskflow/data/models/user.dart';
import 'package:taskflow/data/repositories/auth_repository.dart';

/// Use case for getting current user
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() async {
    return await repository.getCurrentUser();
  }
}
