// Mirrors: SettlementDetailsScreen.tsx
import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../widgets/common_widgets.dart';

class SettlementDetailsScreen extends StatelessWidget {
  final String entityType;
  final String entityId;
  const SettlementDetailsScreen({super.key, required this.entityType, required this.entityId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: entityId,
        subtitle: entityType,
        showBack: true,
        rightElement: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: const Icon(Icons.download_outlined, size: 16, color: AppColors.textSecondary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Balance summary
          Container(
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.card),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text('ملخص الرصيد', style: AppTypography.label),
                ),
                const Divider(height: 1, color: AppColors.gray100),
                for (final row in [
                  ('إجمالي المبيعات', '${ArStrings.sar_symbol} ٣٢٬٧٠٠', false, AppColors.textPrimary),
                  ('عمولة المالك المحتجزة', '-${ArStrings.sar_symbol} ١٬٦٣٥', false, AppColors.danger),
                  ('إجمالي المبالغ المستردة', '-${ArStrings.sar_symbol} ١٢٠', false, AppColors.orange),
                  ('إجمالي المدفوعات المنجزة', '-${ArStrings.sar_symbol} ٩٠٠', false, AppColors.textSecondary),
                  ('الرصيد الصافي الحالي', '${ArStrings.sar_symbol} ٩٨٠٫٧٥', true, AppColors.success),
                ])
                  Container(
                    color: row.$3 ? AppColors.successLight : null,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(children: [
                      Expanded(child: Text(row.$1, style: TextStyle(fontSize: 13, fontWeight: row.$3 ? FontWeight.w700 : FontWeight.w400, color: AppColors.textSecondary))),
                      Text(row.$2, style: TextStyle(fontSize: row.$3 ? 18 : 13, fontWeight: row.$3 ? FontWeight.w800 : FontWeight.w500, color: row.$4)),
                    ]),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Transfer button
          ElevatedButton.icon(
            onPressed: () => showConfirmSheet(
              context,
              title: 'تحويل وتسوية',
              message: 'تحويل المبلغ الصافي المستحق إلى $entityId؟',
              confirmLabel: ArStrings.transfer,
              danger: false,
            ),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('تحويل وتسوية — ر.س ٩٨٠٫٧٥'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl)),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))),
                child: const Text('تأشير كمُسوَّى يدوياً', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh, size: 14, color: AppColors.warning),
                label: const Text('إعادة الحساب', style: TextStyle(fontSize: 12, color: AppColors.warning)),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.warning), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
