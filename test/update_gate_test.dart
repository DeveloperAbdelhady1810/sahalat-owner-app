import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sahalat_owner/services/app_update_guard.dart';

/// The minimum-version gate: the app body is shown unless the server says `update_required`;
/// a failed or unreadable answer never blocks the app.
Future<void> _pumpGuard(WidgetTester tester, MockClientHandler handler) async {
  PackageInfo.setMockInitialValues(
    appName: 'test', packageName: 'test.app', version: '1.0.0', buildNumber: '1', buildSignature: '');
  await http.runWithClient(() async {
    await tester.pumpWidget(const MaterialApp(
      home: AppUpdateGuard(app: 'owner', baseApiUrl: 'http://test.invalid/api', child: Text('APP BODY')),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }, () => MockClient(handler));
}

http.Response _json(Object body, [int status = 200]) => http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

void main() {
  testWidgets('shows the app when no update is required', (tester) async {
    await _pumpGuard(tester, (_) async => _json({'update_required': false}));
    expect(find.text('APP BODY'), findsOneWidget);
    expect(find.text('تحديث مطلوب'), findsNothing);
  });

  testWidgets('covers the app with the update screen, using the server message and an https store button', (tester) async {
    await _pumpGuard(tester, (_) async => _json({
          'update_required': true,
          'update_message': 'يرجى تحديث التطبيق',
          'store_url': {'owner': 'https://play.example/store'},
        }));
    expect(find.text('تحديث مطلوب'), findsOneWidget);
    expect(find.text('يرجى تحديث التطبيق'), findsOneWidget);
    expect(find.text('تحديث الآن'), findsOneWidget);
    expect(find.text('APP BODY'), findsNothing);
  });

  testWidgets('an http (not https) store link is ignored: no store button', (tester) async {
    await _pumpGuard(tester, (_) async => _json({'update_required': true, 'store_url': {'owner': 'http://insecure.example'}}));
    expect(find.text('تحديث مطلوب'), findsOneWidget);
    expect(find.text('تحديث الآن'), findsNothing);
  });

  testWidgets('a failed or unreadable answer never blocks the app', (tester) async {
    await _pumpGuard(tester, (_) async => throw http.ClientException('offline'));
    expect(find.text('APP BODY'), findsOneWidget);
    await _pumpGuard(tester, (_) async => http.Response('<html>502</html>', 502));
    expect(find.text('APP BODY'), findsOneWidget);
    await _pumpGuard(tester, (_) async => http.Response('not json', 200));
    expect(find.text('APP BODY'), findsOneWidget);
  });
}
