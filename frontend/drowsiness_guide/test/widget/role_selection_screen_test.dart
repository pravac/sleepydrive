import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drowsiness_guide/screens/role_selection_screen.dart';
import '../helpers/mocks.dart';

void _suppressFontOverflow() {
  final original = FlutterError.onError!;
  FlutterError.onError = (details) {
    if (details.exception.toString().contains('overflowed')) return;
    original(details);
  };
  addTearDown(() => FlutterError.onError = original);
}

Widget _app(RoleSelectionScreen screen) => MaterialApp(
      home: screen,
      routes: {
        '/dashboard': (_) => const Scaffold(body: Text('Driver OK')),
        '/fleet-dashboard': (_) => const Scaffold(body: Text('Fleet OK')),
      },
    );

void main() {
  late MockAuthService mockAuth;
  late MockUserRoleService mockRole;

  setUp(() {
    mockAuth = MockAuthService();
    mockRole = MockUserRoleService();
  });

  group('RoleSelectionScreen', () {
    testWidgets('renders title, keys on role cards, and role choices',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(800, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      _suppressFontOverflow();
      await tester.pumpWidget(
        _app(
          RoleSelectionScreen(
            email: 'a@b.com',
            password: 'secret12',
            authService: mockAuth,
            userRoleService: mockRole,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Choose your role'), findsOneWidget);
      expect(find.byKey(const ValueKey('role_card_driver')), findsOneWidget);
      expect(find.byKey(const ValueKey('role_card_operator')), findsOneWidget);
      expect(find.text('Fleet Driver'), findsOneWidget);
      expect(find.text('Fleet Operator'), findsOneWidget);
    });
  });
}
