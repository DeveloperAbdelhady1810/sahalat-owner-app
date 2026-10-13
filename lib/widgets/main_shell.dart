// ============================================================
// سهلات المالك – Main Shell with Bottom Navigation (Flutter)
// Mirrors: MobileLayout.tsx + BottomNav.tsx
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design_tokens.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/profits')) return 1;
    if (location.startsWith('/accounts')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: child,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
            boxShadow: AppShadows.md,
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'الرئيسية', isActive: index == 0, onTap: () => context.go('/dashboard')),
                  _NavItem(icon: Icons.trending_up_outlined, activeIcon: Icons.trending_up, label: 'الأرباح', isActive: index == 1, onTap: () => context.go('/profits')),
                  // التسويات: مخفية حتى تتوفر بيانات حقيقية من الخادم (كانت بيانات تجريبية)
                  _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'الحسابات', isActive: index == 2, onTap: () => context.go('/accounts')),
                  _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'الإعدادات', isActive: index == 3, onTap: () => context.go('/settings')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.activeIcon, required this.label,
    required this.isActive, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              Container(
                width: 32, height: 3,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(2)),
                ),
                margin: const EdgeInsets.only(bottom: 6),
              )
            else
              const SizedBox(height: 9),
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.textMuted,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
