import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/errors/failure.dart';
import '../../core/utils/result.dart';
import 'settings_service.dart';

class BackupService {
  BackupService(this._settingsService);

  final SettingsService _settingsService;

  Future<String> createBackupJson() async {
    final result = await _settingsService.getSettings();
    final settings =
        result is Success<AppSettings> ? result.data : AppSettings.defaults;
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert({
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'settings': settings.toJson(),
    });
  }

  Future<Result<AppSettings>> restoreFromJson(String jsonContent) async {
    try {
      final decoded = jsonDecode(jsonContent);
      if (decoded is! Map<String, dynamic>) {
        return const Error(Failure(
          code: 'invalid_json',
          message: 'Неверный формат JSON файла',
        ));
      }
      final rawSettings = decoded['settings'] is Map<String, dynamic>
          ? decoded['settings'] as Map<String, dynamic>
          : decoded;
      final settings = AppSettings.fromJson(rawSettings);
      await _settingsService.updateSettings(settings);
      return Success(settings);
    } catch (e) {
      return Error(Failure(
        code: 'import_error',
        message: 'Ошибка импорта настроек: $e',
      ));
    }
  }

  Future<bool> exportBackup() async {
    final json = await createBackupJson();
    final fileName =
        'prisma_backup_${DateTime.now().millisecondsSinceEpoch}.json';

    if (Platform.isAndroid) {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(json);
      await Share.shareXFiles([XFile(file.path)], text: 'Prisma Backup');
      return true;
    }

    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: [
        const XTypeGroup(label: 'JSON files', extensions: ['json']),
      ],
    );
    if (location == null) return false;
    final file = File(location.path);
    await file.writeAsString(json);
    return true;
  }

  Future<Result<AppSettings>?> importBackup() async {
    const typeGroup = XTypeGroup(
      label: 'JSON files',
      extensions: ['json'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return null;
    final content = await file.readAsString();
    return restoreFromJson(content);
  }
}
