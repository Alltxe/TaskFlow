import 'package:mobile/core/errors/exceptions.dart';
import 'package:mobile/data/datasources/auth_local_datasource.dart';
import 'package:mobile/data/datasources/auth_remote_datasource.dart';
import 'package:mobile/data/models/auth_response.dart';
import 'package:mobile/data/models/auth_tokens.dart';
import 'package:mobile/data/models/login_request.dart';
import 'package:mobile/data/models/register_request.dart';
import 'package:mobile/data/models/user.dart';
import 'package:mobile/data/repositories/auth_repository.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({required this.remoteDataSource, required this.localDataSource});

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await remoteDataSource.login(request);

      // Save tokens and user to local storage
      await localDataSource.saveTokens(response.tokens);
      await localDataSource.saveUser(response.user);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await remoteDataSource.register(request);

      // Save tokens and user to local storage
      await localDataSource.saveTokens(response.tokens);
      await localDataSource.saveUser(response.user);

      return response;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      // Clear all local data
      await localDataSource.clearAll();
    } catch (e) {
      throw CacheException(message: 'Failed to logout: ${e.toString()}');
    }
  }

  @override
  Future<AuthTokens> refreshToken() async {
    try {
      // Get current refresh token
      final tokens = await localDataSource.getTokens();
      if (tokens == null) {
        throw const AuthException(message: 'No refresh token found');
      }

      // Check if refresh token is expired
      final isRefreshExpired = await localDataSource.isRefreshTokenExpired();
      if (isRefreshExpired) {
        // Clear all data and throw exception
        await localDataSource.clearAll();
        throw const AuthException(message: 'Refresh token expired');
      }

      // Request new tokens
      final newTokens = await remoteDataSource.refreshToken(tokens.refreshToken);

      // Save new tokens
      await localDataSource.saveTokens(newTokens);

      return newTokens;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      return await localDataSource.getUser();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final tokens = await localDataSource.getTokens();
      if (tokens == null) return false;

      // Check if refresh token is expired
      final isRefreshExpired = await localDataSource.isRefreshTokenExpired();
      if (isRefreshExpired) {
        // Clear all data
        await localDataSource.clearAll();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> needsTokenRefresh() async {
    try {
      return await localDataSource.isAccessTokenExpired();
    } catch (e) {
      return true;
    }
  }
}
