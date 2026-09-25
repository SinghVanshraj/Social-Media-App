import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:social_media_app/core/utils/error_handler.dart';
import 'package:social_media_app/core/widgets/responsive_wrapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('AppErrorHandler Tests', () {
    test('Correctly identifies SocketException as network error', () {
      final error = const SocketException('Failed host lookup');
      expect(AppErrorHandler.isNetworkError(error), isTrue);
      expect(
        AppErrorHandler.getErrorMessage(error),
        'You appear to be offline. Please check your internet connection.',
      );
    });

    test('Maps AuthException to clean user message', () {
      final error = const AuthException('Invalid login credentials');
      expect(AppErrorHandler.isNetworkError(error), isFalse);
      expect(
        AppErrorHandler.getErrorMessage(error),
        'Invalid email or password. Please try again.',
      );
    });

    test('Maps generic PostgrestException gracefully', () {
      final error = const PostgrestException(
        message: 'relation does not exist',
        code: '42P01',
      );
      expect(
        AppErrorHandler.getErrorMessage(error),
        'Database operation failed. Please try again.',
      );
    });

    test('Maps unknown exception to generic fallback message', () {
      final error = Exception('Random unexpected error');
      expect(
        AppErrorHandler.getErrorMessage(error),
        'An unexpected error occurred. Please try again.',
      );
    });
  });

  group('Breakpoints & Responsive Tokens Tests', () {
    test('Breakpoints have correct ordering and constraints', () {
      expect(Breakpoints.mobileMax, lessThan(Breakpoints.tabletMax));
      expect(Breakpoints.maxFormWidth, 480.0);
      expect(Breakpoints.maxFeedWidth, 640.0);
      expect(Breakpoints.maxProfileWidth, 720.0);
      expect(Breakpoints.maxModalWidth, 580.0);
      expect(Breakpoints.maxContentWidth, 800.0);
    });
  });
}
