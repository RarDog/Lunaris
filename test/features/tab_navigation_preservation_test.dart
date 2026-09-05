import 'package:flutter_test/flutter_test.dart';
import 'package:gel_rule_app/backend/backend.dart';
import 'package:gel_rule_app/shared/widgets/app_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Tab Navigation & State Preservation Tests', () {
    test('AppShell branchIndexForLocation and locationForBranchIndex map correctly', () {
      expect(AppShell.branchIndexForLocation('/'), 0);
      expect(AppShell.branchIndexForLocation('/?q=test'), 0);
      expect(AppShell.branchIndexForLocation('/search'), 1);
      expect(AppShell.branchIndexForLocation('/favorites'), 2);
      expect(AppShell.branchIndexForLocation('/viewed'), 3);
      expect(AppShell.branchIndexForLocation('/collections'), 4);
      expect(AppShell.branchIndexForLocation('/collections/123'), 4);
      expect(AppShell.branchIndexForLocation('/artists'), 5);
      expect(AppShell.branchIndexForLocation('/artists/pawchive/patreon/99'), 5);
      expect(AppShell.branchIndexForLocation('/providers'), 6);
      expect(AppShell.branchIndexForLocation('/settings'), 7);
      expect(AppShell.branchIndexForLocation('/settings/hidden'), 7);

      expect(AppShell.locationForBranchIndex(0), '/');
      expect(AppShell.locationForBranchIndex(1), '/search');
      expect(AppShell.locationForBranchIndex(2), '/favorites');
      expect(AppShell.locationForBranchIndex(3), '/viewed');
      expect(AppShell.locationForBranchIndex(4), '/collections');
      expect(AppShell.locationForBranchIndex(5), '/artists');
      expect(AppShell.locationForBranchIndex(6), '/providers');
      expect(AppShell.locationForBranchIndex(7), '/settings');
    });

    test('AppSettings preserves lastActiveLocation in JSON serialization', () {
      const defaults = AppSettings.defaults;
      expect(defaults.lastActiveLocation, '/');

      final updated = defaults.copyWith(lastActiveLocation: '/artists/pawchive/patreon/12345');
      expect(updated.lastActiveLocation, '/artists/pawchive/patreon/12345');

      final json = updated.toJson();
      expect(json['lastActiveLocation'], '/artists/pawchive/patreon/12345');

      final restored = AppSettings.fromJson(json);
      expect(restored.lastActiveLocation, '/artists/pawchive/patreon/12345');
    });
  });
}
