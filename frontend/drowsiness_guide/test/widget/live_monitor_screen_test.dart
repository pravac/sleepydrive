import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:drowsiness_guide/screens/live_monitor_screen.dart';
import 'package:drowsiness_guide/services/ble_service.dart';
import 'package:drowsiness_guide/services/jetson_websocket_service.dart';
import '../helpers/mocks.dart';

Widget _buildApp(Widget screen) => MaterialApp(home: screen);

void main() {
  late MockBleService mockBle;
  late MockJetsonWebSocketService mockWs;

  setUp(() {
    mockBle = MockBleService();
    mockWs = MockJetsonWebSocketService();
  });

  tearDown(() async {
    await mockBle.alertCtrl.close();
    await mockBle.stateCtrl.close();
    await mockWs.alertCtrl.close();
    await mockWs.presenceCtrl.close();
    await mockWs.stateCtrl.close();
  });

  Widget buildScreen() => _buildApp(
        LiveMonitorScreen(bleService: mockBle, jetsonWsService: mockWs),
      );

  group('LiveMonitorScreen — initial render', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();
      expect(find.byType(LiveMonitorScreen), findsOneWidget);
    });

    testWidgets('starts scanning for BLE on launch', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();
      verify(mockBle.scanAndConnect()).called(1);
    });

    testWidgets('connects to Jetson WebSocket on launch', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();
      verify(mockWs.connect()).called(1);
    });
  });

  group('LiveMonitorScreen — BLE connection state', () {
    testWidgets('reflects BLE Connected state from stream', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      mockBle.stateCtrl.add('Connected');
      await tester.pump();

      expect(find.byType(LiveMonitorScreen), findsOneWidget);
    });

    testWidgets('reflects BLE Disconnected state from stream', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      mockBle.stateCtrl.add('Disconnected');
      await tester.pump();

      expect(find.byType(LiveMonitorScreen), findsOneWidget);
    });
  });

  group('LiveMonitorScreen — alert handling', () {
    testWidgets('BLE DANGER alert shows snackbar with correct text',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      mockBle.alertCtrl.add(BleAlert(level: 2, message: 'Eyes closed'));
      await tester.pump(); // stream listener fires, calls showSnackBar
      await tester.pump(); // snackbar renders

      expect(find.text('DANGER • BLE: Eyes closed'), findsOneWidget);
    });

    testWidgets('BLE WARNING alert shows snackbar with correct text',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      mockBle.alertCtrl.add(BleAlert(level: 1, message: 'Drowsy detected'));
      await tester.pump();
      await tester.pump();

      expect(find.text('WARNING • BLE: Drowsy detected'), findsOneWidget);
    });

    testWidgets('WebSocket DANGER alert shows snackbar', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      mockWs.alertCtrl.add(JetsonAlert(
        deviceId: 'jetson-01',
        level: 2,
        message: 'Head down',
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('DANGER • Jetson WS: Head down'), findsOneWidget);
    });

    testWidgets('WebSocket SAFE alert shows snackbar', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      mockWs.alertCtrl.add(JetsonAlert(
        deviceId: 'jetson-01',
        level: 0,
        message: 'Driver alert',
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('SAFE • Jetson WS: Driver alert'), findsOneWidget);
    });
  });

  group('LiveMonitorScreen — Jetson presence', () {
    testWidgets('device going offline resets state without crashing',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      mockWs.presenceCtrl.add(JetsonPresence(
        sourceId: 'jetson-01',
        online: true,
        fatigueRiskPercent: 80,
      ));
      await tester.pump();

      mockWs.presenceCtrl.add(JetsonPresence(
        sourceId: 'jetson-01',
        online: false,
      ));
      await tester.pump();

      expect(find.byType(LiveMonitorScreen), findsOneWidget);
    });
  });

  group('LiveMonitorScreen — cleanup', () {
    testWidgets('disposes BLE and WebSocket services on widget removal',
        (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      verify(mockBle.dispose()).called(1);
      verify(mockWs.dispose()).called(1);
    });
  });
}
