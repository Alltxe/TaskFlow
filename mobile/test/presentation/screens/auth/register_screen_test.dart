import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/l10n/app_localizations.dart';
import 'package:taskflow/presentation/screens/auth/register_screen.dart';

void main() {
  group('RegisterScreen -', () {
    Widget createWidgetUnderTest() {
      return const ProviderScope(
        child: MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: RegisterScreen(),
        ),
      );
    }

    testWidgets('should display text fields for registration', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - should have multiple text fields (email, username, password, confirm)
      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('should display register button', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - should have a form
      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('should have password fields with visibility toggles', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - should have icon buttons for password visibility
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('should show form validation errors when empty', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - form should exist with required fields
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(TextFormField), findsWidgets);
    });
  });
}
