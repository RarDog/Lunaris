import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/app/motion.dart';
import 'package:gel_rule_app/backend/services/settings_service.dart';

void main() {
  test('app settings json roundtrip keeps motion settings', () {
    final settings = AppSettings.defaults.copyWith(
      motionRefreshMode: MotionRefreshMode.hz144.name,
      autoBatterySaver60Hz: false,
    );

    final restored = AppSettings.fromJson(settings.toJson());

    expect(restored.motionRefreshMode, MotionRefreshMode.hz144.name);
    expect(restored.autoBatterySaver60Hz, isFalse);
  });

  test('battery saver forces effective 60hz below 20 percent', () {
    final motion = resolveMotionSettings(
      settings: AppSettings.defaults.copyWith(
        motionRefreshMode: MotionRefreshMode.hz165.name,
        autoBatterySaver60Hz: true,
      ),
      detectedHz: 165,
      device: const DeviceMotionInfo(
        batteryLevel: 12,
        supportedRefreshRates: [60, 120, 165],
      ),
    );

    expect(motion.batterySaverActive, isTrue);
    expect(motion.effectiveHz, 60);
  });

  test('unsupported requested refresh uses nearest supported mode', () {
    final motion = resolveMotionSettings(
      settings: AppSettings.defaults.copyWith(
        motionRefreshMode: MotionRefreshMode.hz144.name,
      ),
      detectedHz: 144,
      device: const DeviceMotionInfo(
        supportedRefreshRates: [60, 120],
      ),
    );

    expect(motion.effectiveHz, 120);
  });
}
