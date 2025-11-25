// This is a basic Flutter widget test for TaskFlow mobile app.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/main.dart';

void main() {
  testWidgets('App starts and displays initial screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: TaskFlowApp()));

    // Verify app starts (may be splash screen or login screen)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
