import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class AppErrorHandler {
  static String getErrorMessage(dynamic error) {
    if (error == null) return 'An unexpected error occurred. Please try again.';

    if (isNetworkError(error)) {
      return 'You appear to be offline. Please check your internet connection.';
    }

    if (error is AuthException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('invalid login credentials') ||
          msg.contains('invalid credential')) {
        return 'Invalid email or password. Please try again.';
      }
      if (msg.contains('user already registered') ||
          msg.contains('already registered')) {
        return 'An account with this email already exists.';
      }
      if (msg.contains('password should be at least')) {
        return 'Password must be at least 6 characters long.';
      }
      if (msg.contains('rate limit')) {
        return 'Too many attempts. Please wait a moment and try again.';
      }
      return error.message;
    }

    if (error is PostgrestException) {
      final code = error.code;
      final msg = error.message.toLowerCase();

      if (code == '23505' || msg.contains('duplicate key')) {
        return 'This information is already in use. Please use a unique value.';
      }
      if (code == 'PGRST116' || msg.contains('not found')) {
        return 'The requested content was not found.';
      }
      if (msg.contains('jwt expired') || msg.contains('invalid token')) {
        return 'Your session has expired. Please log in again.';
      }
      if (code == '42P01' || msg.contains('relation') || msg.contains('syntax')) {
        return 'Database operation failed. Please try again.';
      }
      return error.message.isNotEmpty ? error.message : 'Database operation failed. Please try again.';
    }

    if (error is StorageException) {
      final msg = error.message.toLowerCase();
      if (msg.contains('payload too large') || msg.contains('entity too large')) {
        return 'File size is too large. Please select a smaller media file.';
      }
      return error.message.isNotEmpty ? error.message : 'Storage upload failed.';
    }

    if (error is TimeoutException) {
      return 'Connection timed out. The server took too long to respond.';
    }

    if (error is FormatException) {
      return 'Unable to process server response. Please try again.';
    }

    if (error is String) {
      return error.trim().isNotEmpty
          ? error
          : 'An unexpected error occurred. Please try again.';
    }

    final errStr = error.toString();
    if (errStr.startsWith('Exception: ')) {
      final inner = errStr.replaceFirst('Exception: ', '').trim();
      if (inner.toLowerCase().contains('random') ||
          inner.toLowerCase().contains('unexpected') ||
          inner.isEmpty) {
        return 'An unexpected error occurred. Please try again.';
      }
      return inner;
    }

    return 'An unexpected error occurred. Please try again.';
  }

  static bool isNetworkError(dynamic error) => isOfflineError(error);

  static bool isOfflineError(dynamic error) {
    if (error == null) return false;

    if (error is SocketException) return true;
    if (error is http.ClientException) return true;
    if (error is HandshakeException) return true;
    if (error is TimeoutException) return true;

    final errStr = error.toString().toLowerCase();
    return errStr.contains('socketexception') ||
        errStr.contains('failed host lookup') ||
        errStr.contains('network is unreachable') ||
        errStr.contains('connection refused') ||
        errStr.contains('connection reset') ||
        errStr.contains('connection closed') ||
        errStr.contains('clientexception') ||
        errStr.contains('xmlhttprequest error') ||
        errStr.contains('offline') ||
        errStr.contains('no internet') ||
        errStr.contains('network error');
  }
}

class AppSnackBar {
  static void showError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    if (!context.mounted) return;

    final isOffline = AppErrorHandler.isOfflineError(error);
    final message = isOffline
        ? 'You are offline. Please check your internet connection.'
        : AppErrorHandler.getErrorMessage(error);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isOffline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
              color: isOffline ? Colors.amberAccent : Colors.redAccent,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: isOffline
                ? Colors.amberAccent.withValues(alpha: 0.3)
                : Colors.redAccent.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.blueAccent,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static void showOffline(BuildContext context, {VoidCallback? onRetry}) {
    showError(context, 'You are offline. Please check your internet connection.',
        onRetry: onRetry);
  }

  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.greenAccent,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E1E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: Colors.greenAccent.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
