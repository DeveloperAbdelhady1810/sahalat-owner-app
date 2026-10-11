// Mirrors: ReportsScreen.tsx
import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../widgets/common_widgets.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _activeReport = 'profit';
  String _period = 'أسبوعي';
  bool _exporting = false;

  final _reportTypes = [
    (id: 'profit', label: 'تقرير الأرباح', icon: Icons.trending_up, color: AppColors.primary, bg: AppColors.primaryLight, desc: 'ربح المالك يومياً / أسبوعياً / شهرياً'),
    (id: 'settlement', label: 'تقرير التسويات', icon: Icons.swap_horiz, color: AppColors.success, bg: AppColors.successLight, desc: 'المدفوعات حسب نوع الحساب والفترة'),
    (id: 'refund', label: 'تأثير الاسترداد', icon: Icons.cancel_outlined, color: AppColors.danger, bg: AppColors.dangerLight, desc: 'تأثير المبالغ المستردة على العمولات'),
  ];

  Future<void> _export(String fmt) async {
    setState(() => _exporting = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _exporting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: ArStrings.reportsCenter, subtitle: ArStrings.exportAnalyze, showBack: true),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final rt in _reportTypes) ...[
                GestureDetector(
                  onTap: () => setState(() => _activeReport = rt.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: _activeReport == rt.id ? rt.bg : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      border: Border.all(color: _activeReport == rt.id ? rt.color : AppColors.border, width: _activeReport == rt.id ? 2 : 1),
                      boxShadow: AppShadows.card,
                    ),
                    child: Row(children: [
                      Container(width: 42, height: 42,
                        decoration: BoxDecoration(color: _activeReport == rt.id ? rt.color : AppColors.gray100, borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: Icon(rt.icon, size: 18, color: _activeReport == rt.id ? Colors.white : AppColors.textMuted)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(rt.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _activeReport == rt.id ? rt.color : AppColors.textPrimary)),
                        Text(rt.desc, style: AppTypography.caption),
                      ])),
                      if (_activeReport == rt.id) Container(width: 8, height: 8, decoration: BoxDecoration(color: rt.color, shape: BoxShape.circle)),
                    ]),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.md),

              // Period selector
              Row(children: [ArStrings.daily, ArStrings.weekly, ArStrings.monthly].map((p) =>
                GestureDetector(
                  onTap: () => setState(() => _period = p),
                  child: Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: _period == p ? AppColors.primary : AppColors.gray100,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(p, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _period == p ? Colors.white : AppColors.textSecondary)),
                  ),
                )
              ).toList()),

              const SizedBox(height: AppSpacing.md),

              // Summary cards
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.card),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ArStrings.reportSummary, style: AppTypography.label),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2,
                      children: _summaryData.map((s) => Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(AppRadius.md)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(s.$1, style: AppTypography.micro),
                          Text(s.$2, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        ]),
                      )).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Export buttons
              Row(children: [
                Expanded(child: ElevatedButton.icon(
                  onPressed: () => _export('PDF'),
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                  label: Text(ArStrings.exportPDF),
                  style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl))),
                )),
                const SizedBox(width: 12),
                Expanded(child: OutlinedButton.icon(
                  onPressed: () => _export('CSV'),
                  icon: const Icon(Icons.table_chart_outlined, size: 16, color: AppColors.primary),
                  label: Text(ArStrings.exportCSV, style: const TextStyle(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52), side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.xl))),
                )),
              ]),
            ],
          ),
          if (_exporting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(ArStrings.exporting, style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
              )),
            ),
        ],
      ),
    );
  }

  List<(String, String)> get _summaryData {
    if (_activeReport == 'profit') return [
      ('إجمالي الأرباح (شهر)', '${ArStrings.sar_symbol} ٨٬٩٧٥'),
      ('هذا الأسبوع', '${ArStrings.sar_symbol} ٢٬٢٤٤'),
      ('اليوم', '${ArStrings.sar_symbol} ١٥٦'),
      ('متوسط لكل طلب', '${ArStrings.sar_symbol} ٧٫٢٣'),
    ];
    if (_activeReport == 'settlement') return [
      ('إجمالي التسويات', '${ArStrings.sar_symbol} ٤٧٬٣٥٠'),
      ('معلق', '${ArStrings.sar_symbol} ١٢٬٨٠٠'),
      ('المتاجر', '${ArStrings.sar_symbol} ٨٬٥٠٠'),
      ('السائقون', '${ArStrings.sar_symbol} ٣٬٢٠٠'),
    ];
    return [
      ('إجمالي الاسترداد', '${ArStrings.sar_symbol} ٣٤٥٫٨٠'),
      ('عدد الاسترداد', '١٢ طلب'),
      ('عمولة مستردة', '${ArStrings.sar_symbol} ٢٨٫٤٠'),
      ('التأثير', '٣٫٩٪ من الربح'),
    ];
  }
}
