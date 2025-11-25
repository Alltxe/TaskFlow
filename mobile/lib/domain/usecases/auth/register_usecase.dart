import 'package:taskflow/data/models/auth_response.dart';
import 'package:taskflow/data/models/register_request.dart';
import 'package:taskflow/data/repositories/auth_repository.dart';

/// Use case for user registration
class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<AuthResponse> call(RegisterRequest request) async {
    return await repository.register(request);
  }
}
