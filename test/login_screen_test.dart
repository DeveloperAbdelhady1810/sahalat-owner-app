import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sahalat_owner/screens/login_screen.dart';

void main() {
  testWidgets('the login screen renders its form without throwing', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsAtLeastNWidgets(2));   // account + password
    expect(find.byType(ElevatedButton), findsAtLeastNWidgets(1));
  });
}
