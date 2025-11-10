import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/auth_response.dart';
import 'package:mobile/data/models/auth_tokens.dart';
import 'package:mobile/data/models/register_request.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/domain/usecases/auth/register_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'register_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  group('RegisterUseCase -', () {
    const tRegisterRequest = RegisterRequest(
      email: 'test@example.com',
      username: 'testuser',
      password: 'password123',
    );

    final tUser = User(
      id: '1',
      email: 'test@example.com',
      username: 'testuser',
      avatarUrl: null,
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final tAuthTokens = AuthTokens(
      accessToken: 'access_token',
      refreshToken: 'refresh_token',
      accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
    );

    final tAuthResponse = AuthResponse(user: tUser, tokens: tAuthTokens);

    test('should call repository register with correct parameters', () async {
      // arrange
      when(mockRepository.register(any)).thenAnswer((_) async => tAuthResponse);

      // act
      final result = await useCase(tRegisterRequest);

      // assert
      expect(result, tAuthResponse);
      verify(mockRepository.register(tRegisterRequest));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository throws', () async {
      // arrange
      when(mockRepository.register(any)).thenThrow(Exception('Email already exists'));

      // act & assert
      expect(() => useCase(tRegisterRequest), throwsA(isA<Exception>()));
      verify(mockRepository.register(tRegisterRequest));
    });
  });
}
