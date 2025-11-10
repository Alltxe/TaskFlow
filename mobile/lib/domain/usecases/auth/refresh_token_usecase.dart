import 'package:mobile/data/models/auth_tokens.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

/// Use case for refreshing access token
class RefreshTokenUseCase {
  final AuthRepository repository;

  RefreshTokenUseCase(this.repository);

  Future<AuthTokens> call() async {
    return await repository.refreshToken();
  }
}
