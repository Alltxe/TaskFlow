import 'package:taskflow/data/models/auth_tokens.dart';
import 'package:taskflow/data/repositories/auth_repository.dart';

/// Use case for refreshing access token
class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<AuthTokens> call() async {
    return await repository.refreshToken();
  }
}
