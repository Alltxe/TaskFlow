import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Test -', () {
    testWidgets('Complete registration and login flow', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Should start on splash screen, then navigate to login
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify we're on login screen
      expect(find.text('Login'), findsWidgets);

      // Navigate to register screen
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify we're on register screen
      expect(find.text('Create Account'), findsOneWidget);

      // Fill registration form
      final emailField = find.byType(TextFormField).at(0);
      final usernameField = find.byType(TextFormField).at(1);
      final passwordField = find.byType(TextFormField).at(2);
      final confirmPasswordField = find.byType(TextFormField).at(3);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(usernameField, 'testuser');
      await tester.enterText(passwordField, 'password123');
      await tester.enterText(confirmPasswordField, 'password123');

      // Submit registration
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pumpAndSettle();

      // Note: This will fail without a real backend, but tests the UI flow
      // In real test, you'd mock the backend or use a test backend
    });

    testWidgets('Login with existing account', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should be on login screen
      expect(find.text('Login'), findsWidgets);

      // Fill login form
      final emailField = find.byType(TextFormField).at(0);
      final passwordField = find.byType(TextFormField).at(1);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'password123');

      // Submit login
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Note: This will fail without a real backend
    });

    testWidgets('Form validation on login screen', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Try to submit empty form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      // Verify validation errors appear
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('Form validation on register screen', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to register
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      // Verify validation errors
      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter a username'), findsOneWidget);
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('Password mismatch validation', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to register
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Fill form with mismatched passwords
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'testuser');
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(find.byType(TextFormField).at(3), 'password456');

      // Submit form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign Up'));
      await tester.pump();

      // Verify error
      expect(find.text('Passwords do not match'), findsOneWidget);
    });
  });
}
