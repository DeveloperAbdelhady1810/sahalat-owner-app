// Copyright © 2025 Quadro Tech. All rights reserved.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Minimum-version check. At start-up (and every time the app comes back to the foreground) it asks the server
///   GET <api>/app-config?app=<user|delivery|seller|owner>&version=<installed version>
/// and, when the answer says `update_required`, covers the whole app with a screen that cannot be dismissed:
/// the message and the store link come from the response (they are set by IT in Settings -> Minimum app versions).
/// A failed / slow / unreadable answer NEVER blocks the app (offline users keep working).
class AppUpdateGuard extends StatefulWidget {
  final String app;
  final String baseApiUrl;
  final Widget child;

  const AppUpdateGuard({super.key, required this.app, required this.baseApiUrl, required this.child});

  @override
  State<AppUpdateGuard> createState() => _AppUpdateGuardState();
}

class _AppUpdateGuardState extends State<AppUpdateGuard> with WidgetsBindingObserver {
  bool _required = false;
  String _message = 'يتوفر إصدار جديد من التطبيق، يرجى التحديث للمتابعة';
  String? _storeUrl;
  DateTime _lastCheck = DateTime.fromMillisecondsSinceEpoch(0);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // coming back from the store / background: ask again (not more than once a minute)
    if (state == AppLifecycleState.resumed && DateTime.now().difference(_lastCheck).inSeconds > 60) {
      _check();
    }
  }

  Future<void> _check() async {
    _lastCheck = DateTime.now();
    try {
      final info = await PackageInfo.fromPlatform();
      final uri = Uri.parse('${widget.baseApiUrl}/app-config').replace(queryParameters: {'app': widget.app, 'version': info.version});
      final res = await http.get(uri, headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return;
      final data = jsonDecode(res.body);
      if (data is! Map) return;
      final required = data['update_required'] == true;
      final store = data['store_url'];
      final url = store is Map ? store[widget.app]?.toString() : null;
      final msg = data['update_message']?.toString();
      if (!mounted) return;
      setState(() {
        _required = required;
        if (msg != null && msg.trim().isNotEmpty) _message = msg;
        _storeUrl = (url != null && url.startsWith('https://')) ? url : null;
      });
    } catch (_) {
      // offline / server down / unexpected answer: never block the app because of the check itself
    }
  }

  Future<void> _openStore() async {
    final url = _storeUrl;
    if (url == null) return;
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (!_required) return widget.child;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.system_update, size: 72, color: Color(0xFF2E7D32)),
                    const SizedBox(height: 24),
                    const Text('تحديث مطلوب', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Text(_message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.6)),
                    const SizedBox(height: 28),
                    if (_storeUrl != null)
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(onPressed: _openStore, child: const Text('تحديث الآن', style: TextStyle(fontSize: 16))),
                      ),
                    const SizedBox(height: 12),
                    TextButton(onPressed: _check, child: const Text('تحققت من التحديث، إعادة المحاولة')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
