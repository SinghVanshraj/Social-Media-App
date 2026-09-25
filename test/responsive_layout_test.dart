import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:social_media_app/core/services/connectivity_service.dart';
import 'package:social_media_app/core/widgets/error_offline_widgets.dart';
import 'package:social_media_app/core/widgets/responsive_wrapper.dart';

void main() {
  group('ResponsiveLayout Tests', () {
    testWidgets('Renders mobile layout on narrow width', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: (context, constraints) => const Text('Mobile Layout'),
              tablet: (context, constraints) => const Text('Tablet Layout'),
              desktop: (context, constraints) => const Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Mobile Layout'), findsOneWidget);
      expect(find.text('Tablet Layout'), findsNothing);
      expect(find.text('Desktop Layout'), findsNothing);
    });

    testWidgets('Renders tablet layout on intermediate width', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: (context, constraints) => const Text('Mobile Layout'),
              tablet: (context, constraints) => const Text('Tablet Layout'),
              desktop: (context, constraints) => const Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Tablet Layout'), findsOneWidget);
      expect(find.text('Mobile Layout'), findsNothing);
    });

    testWidgets('Renders desktop layout on large width', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayout(
              mobile: (context, constraints) => const Text('Mobile Layout'),
              tablet: (context, constraints) => const Text('Tablet Layout'),
              desktop: (context, constraints) => const Text('Desktop Layout'),
            ),
          ),
        ),
      );

      expect(find.text('Desktop Layout'), findsOneWidget);
      expect(find.text('Mobile Layout'), findsNothing);
    });
  });

  group('OfflineBanner & AppOfflineView Tests', () {
    testWidgets('AppOfflineView displays offline text and triggers retry', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppOfflineView(
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text("You're Offline"), findsOneWidget);
      expect(find.text('Check Connection & Retry'), findsOneWidget);

      await tester.tap(find.text('Check Connection & Retry'));
      await tester.pump();

      expect(retried, isTrue);
    });

    testWidgets('OfflineBanner displays child content when online', (tester) async {
      final testService = ConnectivityService(autoStart: false);
      addTearDown(() => testService.dispose());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityServiceProvider.overrideWithValue(testService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: OfflineBanner(
                child: Text('Main Feed Content'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Main Feed Content'), findsOneWidget);
    });

    testWidgets('OfflineBanner persists while offline and dismisses when online', (tester) async {
      final testService = ConnectivityService(autoStart: false);
      addTearDown(() => testService.dispose());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectivityServiceProvider.overrideWithValue(testService),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: OfflineBanner(
                child: Text('Main Feed Content'),
              ),
            ),
          ),
        ),
      );

      // Trigger offline
      testService.markOffline();
      await tester.pumpAndSettle();

      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.text('Offline mode active. Reconnecting...'), findsOneWidget);

      // Trigger online recovery
      testService.markOnline();
      await tester.pumpAndSettle();

      final animatedSlideFinder = find.byType(AnimatedSlide);
      expect(animatedSlideFinder, findsOneWidget);
      final AnimatedSlide slideWidget = tester.widget(animatedSlideFinder);
      expect(slideWidget.offset, const Offset(0, -1.5));
    });
  });
}
