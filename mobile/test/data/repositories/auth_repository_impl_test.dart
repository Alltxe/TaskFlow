import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/data/datasources/auth_local_datasource.dart';
import 'package:taskflow/data/datasources/auth_remote_datasource.dart';
import 'package:taskflow/data/models/auth_response.dart';
import 'package:taskflow/data/models/auth_tokens.dart';
import 'package:taskflow/data/models/login_request.dart';
import 'package:taskflow/data/models/register_request.dart';
import 'package:taskflow/data/models/user.dart';
import 'package:taskflow/data/repositories/auth_repository_impl.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repository_impl_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource, AuthLocalDataSource])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('AuthRepositoryImpl -', () {
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

    group('login', () {
      const tLoginRequest = LoginRequest(email: 'test@example.com', password: 'password123');

      test('should call remote datasource and save tokens/user locally', () async {
        // arrange
        when(mockRemoteDataSource.login(any)).thenAnswer((_) async => tAuthResponse);
        when(mockLocalDataSource.saveTokens(any)).thenAnswer((_) async => {});
        when(mockLocalDataSource.saveUser(any)).thenAnswer((_) async => {});

        // act
        final result = await repository.login(tLoginRequest);

        // assert
        expect(result, tAuthResponse);
        verify(mockRemoteDataSource.login(tLoginRequest));
        verify(mockLocalDataSource.saveTokens(tAuthTokens));
        verify(mockLocalDataSource.saveUser(tUser));
      });

      test('should throw exception when remote datasource fails', () async {
        // arrange
        when(mockRemoteDataSource.login(any)).thenThrow(Exception('Invalid credentials'));

        // act & assert
        expect(() => repository.login(tLoginRequest), throwsA(isA<Exception>()));
        verifyNever(mockLocalDataSource.saveTokens(any));
        verifyNever(mockLocalDataSource.saveUser(any));
      });
    });

    group('register', () {
      const tRegisterRequest = RegisterRequest(
        email: 'test@example.com',
        username: 'testuser',
        password: 'password123',
      );

      test('should call remote datasource and save tokens/user locally', () async {
        // arrange
        when(mockRemoteDataSource.register(any)).thenAnswer((_) async => tAuthResponse);
        when(mockLocalDataSource.saveTokens(any)).thenAnswer((_) async => {});
        when(mockLocalDataSource.saveUser(any)).thenAnswer((_) async => {});

        // act
        final result = await repository.register(tRegisterRequest);

        // assert
        expect(result, tAuthResponse);
        verify(mockRemoteDataSource.register(tRegisterRequest));
        verify(mockLocalDataSource.saveTokens(tAuthTokens));
        verify(mockLocalDataSource.saveUser(tUser));
      });

      test('should throw exception when remote datasource fails', () async {
        // arrange
        when(mockRemoteDataSource.register(any)).thenThrow(Exception('Email already exists'));

        // act & assert
        expect(() => repository.register(tRegisterRequest), throwsA(isA<Exception>()));
        verifyNever(mockLocalDataSource.saveTokens(any));
        verifyNever(mockLocalDataSource.saveUser(any));
      });
    });

    group('logout', () {
      test('should clear all local data', () async {
        // arrange
        when(mockLocalDataSource.clearAll()).thenAnswer((_) async => {});

        // act
        await repository.logout();

        // assert
        verify(mockLocalDataSource.clearAll());
      });
    });

    group('refreshToken', () {
      test(
        'should call remote datasource with current refresh token and save new tokens',
        () async {
          // arrange
          when(mockLocalDataSource.getTokens()).thenAnswer((_) async => tAuthTokens);
          when(mockLocalDataSource.isRefreshTokenExpired()).thenAnswer((_) async => false);
          when(mockRemoteDataSource.refreshToken(any)).thenAnswer((_) async => tAuthTokens);
          when(mockLocalDataSource.saveTokens(any)).thenAnswer((_) async => {});

          // act
          final result = await repository.refreshToken();

          // assert
          expect(result, tAuthTokens);
          verify(mockLocalDataSource.getTokens());
          verify(mockLocalDataSource.isRefreshTokenExpired());
          verify(mockRemoteDataSource.refreshToken(tAuthTokens.refreshToken));
          verify(mockLocalDataSource.saveTokens(tAuthTokens));
        },
      );

      test('should throw exception when no refresh token exists', () async {
        // arrange
        when(mockLocalDataSource.getTokens()).thenAnswer((_) async => null);

        // act & assert
        expect(() => repository.refreshToken(), throwsA(isA<Exception>()));
        verifyNever(mockRemoteDataSource.refreshToken(any));
      });

      test('should throw exception when remote datasource fails', () async {
        // arrange
        when(mockLocalDataSource.getTokens()).thenAnswer((_) async => tAuthTokens);
        when(mockLocalDataSource.isRefreshTokenExpired()).thenAnswer((_) async => false);
        when(mockRemoteDataSource.refreshToken(any)).thenThrow(Exception('Invalid refresh token'));

        // act & assert
        expect(() => repository.refreshToken(), throwsA(isA<Exception>()));
        verifyNever(mockLocalDataSource.saveTokens(any));
      });
    });

    group('getCurrentUser', () {
      test('should return user from local datasource', () async {
        // arrange
        when(mockLocalDataSource.getUser()).thenAnswer((_) async => tUser);

        // act
        final result = await repository.getCurrentUser();

        // assert
        expect(result, tUser);
        verify(mockLocalDataSource.getUser());
      });

      test('should return null when no user exists', () async {
        // arrange
        when(mockLocalDataSource.getUser()).thenAnswer((_) async => null);

        // act
        final result = await repository.getCurrentUser();

        // assert
        expect(result, null);
      });
    });

    group('isAuthenticated', () {
      test('should return true when valid tokens exist', () async {
        // arrange
        when(mockLocalDataSource.getTokens()).thenAnswer((_) async => tAuthTokens);
        when(mockLocalDataSource.isRefreshTokenExpired()).thenAnswer((_) async => false);

        // act
        final result = await repository.isAuthenticated();

        // assert
        expect(result, true);
      });

      test('should return false when refresh token is expired', () async {
        // arrange
        when(mockLocalDataSource.getTokens()).thenAnswer((_) async => tAuthTokens);
        when(mockLocalDataSource.isRefreshTokenExpired()).thenAnswer((_) async => true);
        when(mockLocalDataSource.clearAll()).thenAnswer((_) async => {});

        // act
        final result = await repository.isAuthenticated();

        // assert
        expect(result, false);
        verify(mockLocalDataSource.clearAll());
      });

      test('should return false when no tokens exist', () async {
        // arrange
        when(mockLocalDataSource.getTokens()).thenAnswer((_) async => null);

        // act
        final result = await repository.isAuthenticated();

        // assert
        expect(result, false);
      });
    });
  });
}
