import 'package:mobile/data/models/auth_response.dart';
import 'package:mobile/data/models/login_request.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

/// Use case for user login
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthResponse> call(LoginRequest request) async {
    return await repository.login(request);
  }
}
