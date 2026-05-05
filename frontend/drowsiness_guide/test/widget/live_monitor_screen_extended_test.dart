import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drowsiness_guide/screens/live_monitor_screen.dart';
import '../helpers/mocks.dart';

Widget _buildApp(Widget screen) => MaterialApp(
      home: screen,
      routes: {
        '/map': (_) => const Scaffold(body: Text('MapStub')),
      },
    );

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

  testWidgets('bottom bar navigates to map route', (tester) async {
    await tester.pumpWidget(
      _buildApp(
        LiveMonitorScreen(bleService: mockBle, jetsonWsService: mockWs),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('DROWSINESS DETECTED'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('MapStub'), findsOneWidget);
  });
}
