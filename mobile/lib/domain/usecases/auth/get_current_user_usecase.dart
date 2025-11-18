import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

/// Use case for getting current user
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  Future<User?> call() async {
    return await repository.getCurrentUser();
  }
}
