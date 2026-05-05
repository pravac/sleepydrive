import 'package:flutter_test/flutter_test.dart';
import 'package:drowsiness_guide/services/user_role_service.dart';

void main() {
  group('UserProfile.fromJson', () {
    test('maps backend fields', () {
      final p = UserProfile.fromJson({
        'uid': 'u1',
        'role': 'driver',
        'email': 'e@e.com',
        'display_name': 'Bob Smith',
        'fleet_id': 'fid',
        'fleet_name': 'Fleet A',
        'fleet_invite_code': 'ABC',
        'device_id': 'jet-1',
      });

      expect(p.uid, 'u1');
      expect(p.role, 'driver');
      expect(p.email, 'e@e.com');
      expect(p.displayName, 'Bob Smith');
      expect(p.fleetId, 'fid');
      expect(p.fleetName, 'Fleet A');
      expect(p.fleetInviteCode, 'ABC');
      expect(p.deviceId, 'jet-1');
    });
  });

  group('FleetDashboardData.fromJson', () {
    test('parses fleet and drivers list', () {
      final data = FleetDashboardData.fromJson({
        'fleet': {
          'id': 'f1',
          'name': 'My Fleet',
          'invite_code': 'INV99',
        },
        'drivers': [
          {
            'uid': 'd1',
            'email': 'd@d.com',
            'online': true,
            'alert_count': 2,
          },
        ],
      });

      expect(data.fleet.id, 'f1');
      expect(data.fleet.name, 'My Fleet');
      expect(data.fleet.inviteCode, 'INV99');
      expect(data.drivers, hasLength(1));
      expect(data.drivers.first.uid, 'd1');
      expect(data.drivers.first.online, true);
      expect(data.drivers.first.alertCount, 2);
    });
  });

  group('FleetAlert.fromJson', () {
    test('parses alert payload', () {
      final a = FleetAlert.fromJson({
        'level': '2',
        'message': 'Eyes closed',
        'metadata': {'fatigue_risk_percent': 85},
      });

      expect(a.level, 2);
      expect(a.message, 'Eyes closed');
      expect(a.fatigueRiskPercent, 85);
    });
  });
}
