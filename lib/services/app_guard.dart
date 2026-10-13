// Copyright © 2025 Quadro Tech. All rights reserved.

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// One place that catches what nobody else caught, so the app never ends on a grey / white screen:
///  * FlutterError.onError          errors thrown while building / laying out / painting
///  * PlatformDispatcher.onError    errors in async code that no try/catch handled
///  * runZonedGuarded               the same for code started in the app's zone
///  * ErrorWidget.builder           a friendly Arabic card instead of the red / grey error box (release builds)
/// Every error is written to a small local log file (cache folder, 200 KB max, last 2 runs) and to the console. NOTHING is sent anywhere
/// (a crash-reporting service such as Crashlytics is NOT used until the owner approves it).
class AppGuard {
  static File? _file;

  static Future<void> run(FutureOr<void> Function() body) async {
    await runZonedGuarded<Future<void>>(() async {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        _log('FlutterError', details.exception, details.stack);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        _log('PlatformDispatcher', error, stack);
        return true; // handled: the app keeps running
      };
      if (kReleaseMode) {
        ErrorWidget.builder = (details) => const _FriendlyError();
      }
      await body();
    }, (error, stack) => _log('Zone', error, stack));
  }

  static void _log(String where, Object error, StackTrace? stack) {
    debugPrint('[$where] $error');
    if (kDebugMode && stack != null) debugPrint('$stack');
    try {
      _file ??= File('${Directory.systemTemp.path}/sahalat_errors.log');
      final f = _file!;
      if (f.existsSync() && f.lengthSync() > 200 * 1024) {
        f.renameSync('${f.path}.old'); // keep the last two runs only
      }
      final line = '${DateTime.now().toIso8601String()} [$where] ${error.toString().split('\n').first}\n'
          '${(stack ?? StackTrace.empty).toString().split('\n').take(6).join('\n')}\n';
      f.writeAsStringSync(line, mode: FileMode.append, flush: true);
    } catch (_) {
      // logging must never throw
    }
  }

  /// For catch blocks that want the error on the local log too.
  static void report(Object error, [StackTrace? stack]) => _log('caught', error, stack);
}

class _FriendlyError extends StatelessWidget {
  const _FriendlyError();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: Color(0xFF9E9E9E)),
            SizedBox(height: 8),
            Text('تعذر عرض هذا الجزء', style: TextStyle(fontSize: 14, color: Color(0xFF424242), decoration: TextDecoration.none)),
            SizedBox(height: 4),
            Text('ارجع للخلف وحاول مرة أخرى', style: TextStyle(fontSize: 12, color: Color(0xFF757575), decoration: TextDecoration.none)),
          ],
        ),
      ),
    );
  }
}

/// Banner "no internet" on top of the whole app. When the connection comes back the banner shows "back online" for 2 seconds and
/// `AppConnectivity.restored` ticks, so a screen that failed because of the network can listen and reload by itself.
class AppConnectivity {
  static final ValueNotifier<int> restored = ValueNotifier<int>(0);
}

class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _offline = false;
  bool _justBack = false;

  @override
  void initState() {
    super.initState();
    try {
      Connectivity().checkConnectivity().then(_apply).catchError((_) {});
      _sub = Connectivity().onConnectivityChanged.listen(_apply, onError: (_) {});
    } catch (_) {
      // plugin missing (tests): no banner
    }
  }

  void _apply(List<ConnectivityResult> r) {
    final off = r.isEmpty || r.every((e) => e == ConnectivityResult.none);
    if (!mounted || off == _offline) return;
    setState(() {
      final wasOffline = _offline;
      _offline = off;
      _justBack = wasOffline && !off;
    });
    if (_justBack) {
      AppConnectivity.restored.value++;
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _justBack = false);
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final show = _offline || _justBack;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          widget.child,
          if (show)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: SafeArea(
                bottom: false,
                child: Material(
                  color: _offline ? const Color(0xFFB71C1C) : const Color(0xFF2E7D32),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: Text(
                      _offline ? 'لا يوجد اتصال بالإنترنت. سنعيد المحاولة تلقائياً عند عودة الاتصال' : 'عاد الاتصال بالإنترنت',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
