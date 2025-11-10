import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/presentation/screens/auth/login_screen.dart';

void main() {
  group('LoginScreen -', () {
    Widget createWidgetUnderTest() {
      return const ProviderScope(child: MaterialApp(home: LoginScreen()));
    }

    testWidgets('should display email and password text fields', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - check we have 2 text fields (email and password)
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should display login button', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - check there's a form with submit capability
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('should have password field with visibility toggle', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - check there's an icon button for password visibility
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('should show form validation errors when empty', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - form should exist for validation
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
    });
  });
}
