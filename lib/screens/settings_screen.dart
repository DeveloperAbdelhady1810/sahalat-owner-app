// Mirrors: SettingsScreen.tsx
import 'package:flutter/material.dart';
import 'package:sahalat_owner/services/api.dart';
import 'package:go_router/go_router.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../widgets/common_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final Map<String, bool> _toggles = {
    'tax': true, 'refundReverse': true,
    'settlementPush': true, 'largePayout': true,
    'pendingApproval': true, 'mismatch': true,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: ArStrings.settings, subtitle: ArStrings.systemConfig),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(gradient: AppGradients.primary, borderRadius: BorderRadius.circular(AppRadius.xxl)),
            child: Row(children: [
              Container(width: 52, height: 52,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadius.xl)),
                alignment: Alignment.center,
                child: const Text('ع', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white))),
              const SizedBox(width: 12),
              const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('عبدالله الراشد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('owner@sahalat.sa', style: TextStyle(fontSize: 12, color: Colors.white60)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(AppRadius.full)),
                child: Text(ArStrings.owner, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
            ]),
          ),
          const SizedBox(height: AppSpacing.lg),

          _section(ArStrings.financeCommission, [
            _navItem(context, Icons.percent_outlined, ArStrings.commissionRules, '٦ قواعد نشطة', AppColors.primaryLight, AppColors.primary, '/settings/commission-rules', badge: '٦'),
            _toggleItem(ArStrings.taxHandling, 'تضمين الضريبة في أساس العمولة', Icons.attach_money_outlined, AppColors.successLight, AppColors.success, 'tax'),
            _toggleItem(ArStrings.refundReverseCommission, 'عكس تلقائي عند إلغاء الطلبات', Icons.refresh_outlined, AppColors.orangeLight, AppColors.orange, 'refundReverse'),
          ]),
          const SizedBox(height: AppSpacing.md),

          _section(ArStrings.reportsAudit, [
            _navItem(context, Icons.description_outlined, ArStrings.auditLogs, 'جميع إجراءات النظام', AppColors.infoLight, AppColors.info, '/settings/audit-logs', badge: 'جديد'),
            _navItem(context, Icons.bar_chart_outlined, ArStrings.reportsCenter, 'تصدير تقارير الأرباح والتسويات', AppColors.successLight, AppColors.success, '/settings/reports'),
            _navItem(context, Icons.warning_amber_rounded, ArStrings.financialIssues, '٣ نزاعات مفتوحة', AppColors.dangerLight, AppColors.danger, '/settings/disputes', badge: '٣', badgeColor: AppColors.danger),
          ]),
          const SizedBox(height: AppSpacing.md),

          _section(ArStrings.notifications, [
            _toggleItem('اكتمال التسوية', 'إشعار عند نجاح الدفع', Icons.notifications_outlined, AppColors.successLight, AppColors.success, 'settlementPush'),
            _toggleItem('طلب دفعة كبيرة', 'تنبيه للدفعات > ٥٠٠٠ ر.س', Icons.notifications_outlined, AppColors.warningLight, AppColors.warning, 'largePayout'),
            _toggleItem('حساب ينتظر الموافقة', 'عند تسجيل متاجر/سائقين جدد', Icons.notifications_outlined, AppColors.primaryLight, AppColors.primary, 'pendingApproval'),
            _toggleItem('عدم تطابق الحساب', 'اكتشاف تناقض في الأرصدة', Icons.notifications_outlined, AppColors.dangerLight, AppColors.danger, 'mismatch'),
          ]),
          const SizedBox(height: AppSpacing.md),

          // Permissions matrix
          _section(ArStrings.permissionsMatrix, [
            _permHeader(),
            for (final perm in [
              ('عرض الأرباح', true, true),
              ('تعديل قواعد العمولة', true, false),
              ('تسوية الحسابات', true, false),
              ('إدارة الحسابات', true, true),
              ('تصدير التقارير', true, true),
              ('تحويل الأموال', true, false),
            ])
              _permRow(perm.$1, perm.$2, perm.$3),
          ]),
          const SizedBox(height: AppSpacing.md),

          // Sign out
          _section('الحساب', [
            ListTile(
              leading: Container(width: 38, height: 38,
                decoration: BoxDecoration(color: AppColors.dangerLight, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: const Icon(Icons.logout, size: 17, color: AppColors.danger)),
              title: Text(ArStrings.signOut, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.danger)),
              subtitle: Text('إنهاء الجلسة الحالية', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              trailing: null,
              onTap: () => showConfirmSheet(context, title: ArStrings.signOut, message: ArStrings.signOutConfirm, confirmLabel: ArStrings.signOut, danger: true)
                .then((v) async { if (v == true) { await API().logout(); if (context.mounted) context.go('/login'); } }),
            ),
          ]),

          const SizedBox(height: AppSpacing.lg),
          Center(child: Text('سهلات المالك v2.4.1 · إصدار 2024.02.23', style: const TextStyle(fontSize: 11, color: AppColors.gray300))),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(title.toUpperCase(), style: AppTypography.label),
      ),
      Container(
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.card),
        child: Column(children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
            items[i],
          ],
        ]),
      ),
    ],
  );

  Widget _navItem(BuildContext context, IconData icon, String title, String sub, Color bg, Color color, String path, {String? badge, Color? badgeColor}) => ListTile(
    leading: Container(width: 38, height: 38,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Icon(icon, size: 17, color: color)),
    title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    subtitle: Text(sub, style: AppTypography.caption),
    trailing: badge != null
      ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: (badgeColor ?? color).withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadius.full)),
          child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: badgeColor ?? color)))
      : const Icon(Icons.chevron_left, color: AppColors.gray300, size: 18),
    onTap: () => context.go(path),
  );

  Widget _toggleItem(String title, String sub, IconData icon, Color bg, Color color, String key) => ListTile(
    leading: Container(width: 38, height: 38,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Icon(icon, size: 17, color: color)),
    title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
    subtitle: Text(sub, style: AppTypography.caption),
    trailing: Switch(value: _toggles[key] ?? true, onChanged: (v) => setState(() => _toggles[key] = v), activeColor: AppColors.primary),
    onTap: () => setState(() => _toggles[key] = !(_toggles[key] ?? true)),
  );

  Widget _permHeader() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(children: [
      const Expanded(child: SizedBox()),
      Text(ArStrings.owner, style: AppTypography.label),
      const SizedBox(width: 12),
      Text(ArStrings.itAdmin, style: AppTypography.label),
    ]),
  );

  Widget _permRow(String label, bool owner, bool admin) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    child: Row(children: [
      Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
      _permIcon(owner), const SizedBox(width: 24), _permIcon(admin),
    ]),
  );

  Widget _permIcon(bool allowed) => Container(
    width: 22, height: 22,
    decoration: BoxDecoration(
      color: allowed ? AppColors.successLight : AppColors.dangerLight,
      shape: BoxShape.circle,
    ),
    alignment: Alignment.center,
    child: Text(allowed ? '✓' : '✕', style: TextStyle(fontSize: 12, color: allowed ? AppColors.success : AppColors.danger)),
  );
}
