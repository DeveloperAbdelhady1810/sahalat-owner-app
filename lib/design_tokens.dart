// ============================================================
// Sahalat Owner – Design Tokens (Flutter)
// Mirrors: /src/app/designTokens.ts (React)
// ============================================================

import 'package:flutter/material.dart';

// ─── Colors ────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color primaryGradStart = Color(0xFF4F46E5);
  static const Color primaryGradEnd = Color(0xFF7C3AED);

  static const Color secondary = Color(0xFF8B5CF6);
  static const Color secondaryLight = Color(0xFFF5F3FF);

  static const Color success = Color(0xFF10B981);
  static const Color successDark = Color(0xFF059669);
  static const Color successLight = Color(0xFFECFDF5);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningDark = Color(0xFFD97706);
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color danger = Color(0xFFEF4444);
  static const Color dangerDark = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFFEF2F2);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoDark = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFFEFF6FF);

  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFFF7ED);

  static const Color background = Color(0xFFF1F5F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);
  static const Color overlay = Color(0x990F172A);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Gray scale
  static const Color gray50 = Color(0xFFF8FAFC);
  static const Color gray100 = Color(0xFFF1F5F9);
  static const Color gray200 = Color(0xFFE2E8F0);
  static const Color gray300 = Color(0xFFCBD5E1);
  static const Color gray400 = Color(0xFF94A3B8);
  static const Color gray500 = Color(0xFF64748B);
  static const Color gray600 = Color(0xFF475569);
  static const Color gray700 = Color(0xFF334155);
  static const Color gray800 = Color(0xFF1E293B);
  static const Color gray900 = Color(0xFF0F172A);

  // Status color map
  static Map<String, Color> statusColors = {
    'activated': success,
    'active': success,
    'pending': warning,
    'deactivated': gray400,
    'deleted': danger,
    'created': info,
    'settled': success,
    'partially_settled': warning,
    'failed': danger,
    'delivered': success,
    'cancelled': danger,
    'refunded': orange,
    'in-progress': info,
    'confirmed': primary,
    'open': danger,
    'investigating': warning,
    'resolved': success,
    'enabled': success,
    'disabled': gray400,
  };

  static Color statusColor(String status) =>
      statusColors[status.toLowerCase()] ?? gray400;
}

// ─── Gradients ─────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );

  static const LinearGradient dark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF312E81)],
  );
}

// ─── Spacing (8pt grid) ────────────────────────────────────
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// ─── Border Radius ─────────────────────────────────────────
class AppRadius {
  AppRadius._();

  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 9999.0;
}

// ─── Shadows ───────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x14000000), blurRadius: 4, offset: Offset(0, 1)),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x0F000000), blurRadius: 8, offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0A000000), blurRadius: 1),
  ];

  static const List<BoxShadow> primary = [
    BoxShadow(color: Color(0x4D4F46E5), blurRadius: 14, offset: Offset(0, 4)),
  ];
}

// ─── Typography ────────────────────────────────────────────
class AppTypography {
  AppTypography._();

  static const TextStyle displayLg = TextStyle(
    fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -1,
  );
  static const TextStyle displayMd = TextStyle(
    fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.5,
  );
  static const TextStyle heading = TextStyle(
    fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle subheading = TextStyle(
    fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary,
  );
  static const TextStyle bodyMd = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted,
  );
  static const TextStyle label = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.05,
  );
  static const TextStyle micro = TextStyle(
    fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted,
  );
}
