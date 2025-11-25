import 'package:taskflow/data/repositories/auth_repository.dart';

/// Use case for checking authentication status
class CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCase(this.repository);

  Future<bool> call() async {
    return await repository.isAuthenticated();
  }
}
