import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_cuaca/main.dart';

void main() {
  testWidgets('App renders Info Cuaca AppBar title test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Info Cuaca'), findsOneWidget);
  });
}
