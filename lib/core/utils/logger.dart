import 'package:flutter/foundation.dart';

class AppLogger {
  const AppLogger();

  static final List<String> _lines = <String>[];

  static List<String> get lines => List.unmodifiable(_lines);

  static void clear() => _lines.clear();

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    final line = '[${DateTime.now().toIso8601String()}] $message'
        '${error == null ? '' : ' error=$error'}';
    _lines.add(line);
    if (_lines.length > 200) _lines.removeRange(0, _lines.length - 200);
    if (kDebugMode) {
      debugPrint('[GelRule] $message');
      if (error != null) debugPrint('  error: $error');
      if (stackTrace != null) debugPrint('  stack: $stackTrace');
    }
  }
}
