import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/models/auth_response.dart';
import 'package:mobile/data/models/auth_tokens.dart';
import 'package:mobile/data/models/login_request.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/repositories/auth_repository.dart';
import 'package:mobile/domain/usecases/auth/login_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'login_usecase_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase -', () {
    const tLoginRequest = LoginRequest(email: 'test@example.com', password: 'password123');

    final tUser = User(
      id: '1',
      email: 'test@example.com',
      username: 'testuser',
      avatarUrl: null,
      isAway: false,
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

    test('should call repository login with correct parameters', () async {
      // arrange
      when(mockRepository.login(any)).thenAnswer((_) async => tAuthResponse);

      // act
      final result = await useCase(tLoginRequest);

      // assert
      expect(result, tAuthResponse);
      verify(mockRepository.login(tLoginRequest));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository throws', () async {
      // arrange
      when(mockRepository.login(any)).thenThrow(Exception('Invalid credentials'));

      // act & assert
      expect(() => useCase(tLoginRequest), throwsA(isA<Exception>()));
      verify(mockRepository.login(tLoginRequest));
    });
  });
}
