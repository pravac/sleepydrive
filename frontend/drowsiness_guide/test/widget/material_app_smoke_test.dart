import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MaterialApp renders scaffold body', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('test_ready'))),
    );
    expect(find.text('test_ready'), findsOneWidget);
  });
}
