import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:taskflow/core/errors/exceptions.dart';
import 'package:taskflow/data/models/auth_tokens.dart';
import 'package:taskflow/data/models/user.dart';

/// Local data source for authentication using secure storage
class AuthLocalDataSource {
  final FlutterSecureStorage storage;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _accessTokenExpiresAtKey = 'access_token_expires_at';
  static const String _refreshTokenExpiresAtKey = 'refresh_token_expires_at';
  static const String _userKey = 'user';

  AuthLocalDataSource(this.storage);

  /// Save authentication tokens to secure storage
  Future<void> saveTokens(AuthTokens tokens) async {
    try {
      await Future.wait([
        storage.write(key: _accessTokenKey, value: tokens.accessToken),
        storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
        storage.write(
          key: _accessTokenExpiresAtKey,
          value: tokens.accessTokenExpiresAt.toIso8601String(),
        ),
        storage.write(
          key: _refreshTokenExpiresAtKey,
          value: tokens.refreshTokenExpiresAt.toIso8601String(),
        ),
      ]);
    } catch (e) {
      throw CacheException(message: 'Failed to save tokens: ${e.toString()}');
    }
  }

  /// Get authentication tokens from secure storage
  Future<AuthTokens?> getTokens() async {
    try {
      final accessToken = await storage.read(key: _accessTokenKey);
      final refreshToken = await storage.read(key: _refreshTokenKey);
      final accessTokenExpiresAt = await storage.read(key: _accessTokenExpiresAtKey);
      final refreshTokenExpiresAt = await storage.read(key: _refreshTokenExpiresAtKey);

      if (accessToken == null ||
          refreshToken == null ||
          accessTokenExpiresAt == null ||
          refreshTokenExpiresAt == null) {
        return null;
      }

      return AuthTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiresAt: DateTime.parse(accessTokenExpiresAt),
        refreshTokenExpiresAt: DateTime.parse(refreshTokenExpiresAt),
      );
    } catch (e) {
      throw CacheException(message: 'Failed to get tokens: ${e.toString()}');
    }
  }

  /// Delete authentication tokens from secure storage
  Future<void> deleteTokens() async {
    try {
      await Future.wait([
        storage.delete(key: _accessTokenKey),
        storage.delete(key: _refreshTokenKey),
        storage.delete(key: _accessTokenExpiresAtKey),
        storage.delete(key: _refreshTokenExpiresAtKey),
      ]);
    } catch (e) {
      throw CacheException(message: 'Failed to delete tokens: ${e.toString()}');
    }
  }

  /// Save user data to secure storage
  Future<void> saveUser(User user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await storage.write(key: _userKey, value: userJson);
    } catch (e) {
      throw CacheException(message: 'Failed to save user: ${e.toString()}');
    }
  }

  /// Get user data from secure storage
  Future<User?> getUser() async {
    try {
      final userJson = await storage.read(key: _userKey);
      if (userJson == null) return null;

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User.fromJson(userMap);
    } catch (e) {
      throw CacheException(message: 'Failed to get user: ${e.toString()}');
    }
  }

  /// Delete user data from secure storage
  Future<void> deleteUser() async {
    try {
      await storage.delete(key: _userKey);
    } catch (e) {
      throw CacheException(message: 'Failed to delete user: ${e.toString()}');
    }
  }

  /// Check if access token is expired
  Future<bool> isAccessTokenExpired() async {
    try {
      final expiresAtStr = await storage.read(key: _accessTokenExpiresAtKey);
      if (expiresAtStr == null) return true;

      final expiresAt = DateTime.parse(expiresAtStr);
      return DateTime.now().isAfter(expiresAt);
    } catch (e) {
      return true;
    }
  }

  /// Check if refresh token is expired
  Future<bool> isRefreshTokenExpired() async {
    try {
      final expiresAtStr = await storage.read(key: _refreshTokenExpiresAtKey);
      if (expiresAtStr == null) return true;

      final expiresAt = DateTime.parse(expiresAtStr);
      return DateTime.now().isAfter(expiresAt);
    } catch (e) {
      return true;
    }
  }

  /// Clear all authentication data
  Future<void> clearAll() async {
    try {
      await Future.wait([deleteTokens(), deleteUser()]);
    } catch (e) {
      throw CacheException(message: 'Failed to clear all data: ${e.toString()}');
    }
  }
}
