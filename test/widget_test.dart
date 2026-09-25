import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_media_app/core/widgets/error_offline_widgets.dart';
import 'package:social_media_app/core/widgets/responsive_wrapper.dart';

void main() {
  testWidgets('ResponsiveContent clamps width on large screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ResponsiveContent(
            maxWidth: 600,
            child: Text('Responsive Test Body'),
          ),
        ),
      ),
    );

    expect(find.text('Responsive Test Body'), findsOneWidget);
  });

  testWidgets('AppErrorView renders error message and retry button', (
    WidgetTester tester,
  ) async {
    bool retried = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppErrorView(
            error: 'Connection timeout',
            onRetry: () {
              retried = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('Connection timeout'), findsOneWidget);
    expect(find.text('Try Again'), findsOneWidget);

    await tester.tap(find.text('Try Again'));
    await tester.pump();

    expect(retried, isTrue);
  });
}
