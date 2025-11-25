import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/presentation/screens/auth/register_screen.dart';

void main() {
  group('RegisterScreen -', () {
    Widget createWidgetUnderTest() {
      return const ProviderScope(child: MaterialApp(home: RegisterScreen()));
    }

    testWidgets('should display text fields for registration', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - should have 4 text fields (email, username, password, confirm password)
      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('should display register button', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert - should have at least one elevated button
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('should have form for validation', (tester) async {
      // arrange
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(Form), findsOneWidget);
    });
  });
}
