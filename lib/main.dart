// ============================================================
// سهلات المالك – Flutter Entry Point
// Mirrors: React App.tsx + routes.ts
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'design_tokens.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/profits_screen.dart';
import 'screens/profit_details_screen.dart';
import 'screens/accounts_screen.dart';
import 'screens/account_details_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/audit_logs_screen.dart';
import 'screens/reports_screen.dart';
import 'widgets/main_shell.dart';
import 'package:sahalat_owner/services/secure_token_store.dart';
import 'package:sahalat_owner/services/app_update_guard.dart';
import 'package:sahalat_owner/services/app_guard.dart';

SharedPreferences? prefs;
void main() => AppGuard.run(_main);

Future<void> _main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  // login token: secure storage; an older plain SharedPreferences copy is moved once, then wiped
  await SecureTokenStore.init(
    legacyRead: () async => prefs!.getString('token'),
    legacyWipe: () async => prefs!.remove('token'),
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  runApp(const SahalatOwnerApp());
}
// ─── Router ────────────────────────────────────────────────
final _router = GoRouter(
  initialLocation: prefs!.get('email') != null ? '/dashboard' : '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => DashboardScreen(prefs: prefs!,),
        ),
        GoRoute(
          path: '/profits',
          builder: (context, state) => const ProfitsScreen(),
          routes: [
            GoRoute(
              path: ':orderId',
              builder: (context, state) =>
                  ProfitDetailsScreen(orderId: state.pathParameters['orderId']!),
            ),
          ],
        ),
        GoRoute(
          path: '/accounts',
          builder: (context, state) => const AccountsScreen(),
          routes: [
            GoRoute(
              path: ':accountType/:accountId',
              builder: (context, state) => AccountDetailsScreen(
                accountType: state.pathParameters['accountType']!,
                accountId: state.pathParameters['accountId']!,
              ),
            ),
          ],
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
          routes: [
            GoRoute(
              path: 'audit-logs',
              builder: (context, state) => const AuditLogsScreen(),
            ),
            GoRoute(
              path: 'reports',
              builder: (context, state) => const ReportsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

// ─── App ───────────────────────────────────────────────────
class SahalatOwnerApp extends StatelessWidget {
  const SahalatOwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MaterialApp.router(
        title: 'سهلات المالك',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        // blocks the app with an update screen when the server says this version is below the minimum (set in IT settings)
        builder: (context, child) => AppUpdateGuard(app: 'owner', baseApiUrl: const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.sahalat.sa.com/api'), child: OfflineBanner(child: child ?? const SizedBox.shrink())),
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [Locale('ar', 'SA')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.light,
          ),
          fontFamily: 'Cairo',
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
          ),
          cardTheme: CardThemeData(
            color: AppColors.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.xl),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textInverse,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              minimumSize: const Size.fromHeight(52),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.gray50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}
