import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger();

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[GelRule] $message');
      if (error != null) debugPrint('  error: $error');
      if (stackTrace != null) debugPrint('  stack: $stackTrace');
    }
  }
}
