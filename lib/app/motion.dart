import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../backend/backend.dart';

enum MotionRefreshMode {
  auto('Auto'),
  hz60('60 Hz'),
  hz120('120 Hz'),
  hz144('144 Hz'),
  hz165('165 Hz');

  const MotionRefreshMode(this.label);

  final String label;

  int? get targetHz => switch (this) {
        MotionRefreshMode.auto => null,
        MotionRefreshMode.hz60 => 60,
        MotionRefreshMode.hz120 => 120,
        MotionRefreshMode.hz144 => 144,
        MotionRefreshMode.hz165 => 165,
      };

  static MotionRefreshMode fromName(String value) {
    return MotionRefreshMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => MotionRefreshMode.auto,
    );
  }
}

class DeviceMotionInfo {
  const DeviceMotionInfo({
    this.batteryLevel,
    this.supportedRefreshRates = const [],
  });

  final int? batteryLevel;
  final List<double> supportedRefreshRates;
}

class EffectiveMotionSettings {
  const EffectiveMotionSettings({
    required this.mode,
    required this.effectiveHz,
    required this.detectedHz,
    required this.batteryLevel,
    required this.batterySaverActive,
    required this.supportedRefreshRates,
  });

  final MotionRefreshMode mode;
  final double effectiveHz;
  final double detectedHz;
  final int? batteryLevel;
  final bool batterySaverActive;
  final List<double> supportedRefreshRates;

  double get durationScale => (60 / effectiveHz).clamp(0.72, 1.18).toDouble();

  Duration scale(int milliseconds) {
    return Duration(milliseconds: (milliseconds * durationScale).round());
  }
}

class DeviceMotionService {
  DeviceMotionService();

  static const _channel = MethodChannel('rulegel/device');

  Future<DeviceMotionInfo> readInfo() async {
    final battery = await _safe<int>('getBatteryLevel');
    final rates = await _safe<List<dynamic>>('getSupportedRefreshRates');
    final supported = rates
            ?.map((value) => (value as num).toDouble())
            .where((value) => value > 0)
            .toSet()
            .toList() ??
        <double>[];
    supported.sort();
    return DeviceMotionInfo(
      batteryLevel: battery,
      supportedRefreshRates: supported,
    );
  }

  Future<void> setPreferredRefreshRate(double hz) async {
    if (!Platform.isAndroid) return;
    await _safe<void>('setPreferredRefreshRate', {'hz': hz});
  }

  Future<T?> _safe<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}

final deviceMotionServiceProvider = Provider<DeviceMotionService>((ref) {
  return DeviceMotionService();
});

final motionDeviceInfoProvider = FutureProvider<DeviceMotionInfo>((ref) {
  return ref.watch(deviceMotionServiceProvider).readInfo();
});

EffectiveMotionSettings resolveMotionSettings({
  required AppSettings settings,
  required double detectedHz,
  DeviceMotionInfo? device,
}) {
  final mode = MotionRefreshMode.fromName(settings.motionRefreshMode);
  final batteryLevel = device?.batteryLevel;
  final batterySaverActive = settings.autoBatterySaver60Hz &&
      batteryLevel != null &&
      batteryLevel < 20;
  final requestedHz = batterySaverActive
      ? 60.0
      : mode.targetHz?.toDouble() ??
          (detectedHz.isFinite && detectedHz > 0 ? detectedHz : 60.0);
  final supported = device?.supportedRefreshRates ?? const <double>[];
  final effectiveHz = supported.isEmpty
      ? requestedHz
      : _nearestSupported(requestedHz, supported);
  return EffectiveMotionSettings(
    mode: mode,
    effectiveHz: effectiveHz,
    detectedHz: detectedHz.isFinite && detectedHz > 0 ? detectedHz : 60.0,
    batteryLevel: batteryLevel,
    batterySaverActive: batterySaverActive,
    supportedRefreshRates: supported,
  );
}

double _nearestSupported(double target, List<double> supported) {
  var best = supported.first;
  var bestDistance = (best - target).abs();
  for (final value in supported.skip(1)) {
    final distance = (value - target).abs();
    if (distance < bestDistance) {
      best = value;
      bestDistance = distance;
    }
  }
  return best;
}

class AppMotionScope extends InheritedWidget {
  const AppMotionScope({
    required this.settings,
    required super.child,
    super.key,
  });

  final EffectiveMotionSettings settings;

  static EffectiveMotionSettings of(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<AppMotionScope>()
            ?.settings ??
        const EffectiveMotionSettings(
          mode: MotionRefreshMode.auto,
          effectiveHz: 60,
          detectedHz: 60,
          batteryLevel: null,
          batterySaverActive: false,
          supportedRefreshRates: [],
        );
  }

  @override
  bool updateShouldNotify(covariant AppMotionScope oldWidget) {
    return settings.effectiveHz != oldWidget.settings.effectiveHz ||
        settings.batterySaverActive != oldWidget.settings.batterySaverActive ||
        settings.mode != oldWidget.settings.mode;
  }
}

class AppMotion {
  const AppMotion._();

  static Duration duration(BuildContext context, int milliseconds) {
    return AppMotionScope.of(context).scale(milliseconds);
  }
}
