import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/presentation/providers/auth/auth_notifier.dart';
import 'package:mobile/presentation/providers/auth/auth_state.dart';
import 'package:mobile/presentation/screens/auth/login_screen.dart';
import 'package:mobile/presentation/screens/auth/register_screen.dart';
import 'package:mobile/presentation/screens/auth/splash_screen.dart';
import 'package:mobile/presentation/screens/home/home_screen.dart';

/// Router configuration for the app
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState is AuthStateAuthenticated;
      final isLoading = authState is AuthStateInitial || authState is AuthStateLoading;
      final isOnSplash = state.matchedLocation == '/';
      final isOnAuth = state.matchedLocation == '/login' || state.matchedLocation == '/register';

      // If loading, stay on splash
      if (isLoading && !isOnSplash) {
        return '/';
      }

      // If authenticated, redirect to home
      if (isAuthenticated && (isOnSplash || isOnAuth)) {
        return '/home';
      }

      // If not authenticated and not loading, redirect to login
      if (!isAuthenticated && !isLoading && !isOnAuth && !isOnSplash) {
        return '/login';
      }

      // If not authenticated and done loading on splash, go to login
      if (!isAuthenticated && !isLoading && isOnSplash) {
        return '/login';
      }

      return null; // No redirect
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.uri}'))),
  );
});
