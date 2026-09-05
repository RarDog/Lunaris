import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Optimize image cache to prevent memory bloat and OOM crashes
  PaintingBinding.instance.imageCache.maximumSizeBytes = 180 * 1024 * 1024; // 180 MB
  PaintingBinding.instance.imageCache.maximumSize = 120; // 120 images
  runApp(const ProviderScope(child: GelRuleApp()));
}
