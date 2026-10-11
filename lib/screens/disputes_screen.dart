// ============================================================
// سهلات المالك – شاشة النزاعات (Flutter)
// Mirrors: DisputesScreen.tsx
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../models/models.dart';
import '../services/mock_api_service.dart';
import '../widgets/common_widgets.dart';

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({super.key});
  @override
  State<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen> {
  List<Dispute> _disputes = [];
  bool _loading = true;
  DisputeStatus? _statusFilter; // null = all
  String? _expanded;
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final disputes = await MockApiService.instance.getDisputes();
    if (mounted) setState(() { _disputes = disputes; _loading = false; });
  }

  List<Dispute> get _filtered => _statusFilter == null
    ? _disputes
    : _disputes.where((d) => d.status == _statusFilter).toList();

  Color _severityColor(String s) => s == 'high' ? AppColors.danger : s == 'medium' ? AppColors.warning : AppColors.success;
  Color _severityBg(String s) => s == 'high' ? AppColors.dangerLight : s == 'medium' ? AppColors.warningLight : AppColors.successLight;
  Color _severityBorder(String s) => s == 'high' ? const Color(0xFFFECACA) : s == 'medium' ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0);

  String _severityLabel(String s) {
    switch (s) {
      case 'high': return 'عالي';
      case 'medium': return 'متوسط';
      default: return 'منخفض';
    }
  }

  @override
  Widget build(BuildContext context) {
    final openCount = _disputes.where((d) => d.status == DisputeStatus.open).length;
    final investigatingCount = _disputes.where((d) => d.status == DisputeStatus.investigating).length;
    final resolvedCount = _disputes.where((d) => d.status == DisputeStatus.resolved).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: ArStrings.financialIssues, subtitle: ArStrings.disputeInbox, showBack: true),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                _summaryCard(ArStrings.open, openCount, AppColors.danger, AppColors.dangerLight, DisputeStatus.open),
                const SizedBox(width: 8),
                _summaryCard(ArStrings.investigating, investigatingCount, AppColors.warning, AppColors.warningLight, DisputeStatus.investigating),
                const SizedBox(width: 8),
                _summaryCard(ArStrings.resolved, resolvedCount, AppColors.success, AppColors.successLight, DisputeStatus.resolved),
              ],
            ),
          ),

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _filterChip(ArStrings.all, null),
              const SizedBox(width: 8),
              _filterChip(ArStrings.open, DisputeStatus.open),
              const SizedBox(width: 8),
              _filterChip(ArStrings.investigating, DisputeStatus.investigating),
              const SizedBox(width: 8),
              _filterChip(ArStrings.resolved, DisputeStatus.resolved),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('${_filtered.length} ${ArStrings.issues}', style: AppTypography.label),
            ),
          ),

          // Disputes list
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.warning_amber_rounded,
                    title: ArStrings.noIssues,
                    description: 'لا توجد نزاعات تطابق هذا الفلتر.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => _buildDisputeCard(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(String label, int count, Color color, Color bg, DisputeStatus status) {
    final isActive = _statusFilter == status;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _statusFilter = isActive ? null : status),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: isActive ? color : Colors.transparent, width: 2),
          ),
          child: Column(children: [
            Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          ]),
        ),
      ),
    );
  }

  Widget _filterChip(String label, DisputeStatus? status) {
    final isActive = _statusFilter == status;
    return GestureDetector(
      onTap: () => setState(() => _statusFilter = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  Widget _buildDisputeCard(Dispute dispute) {
    final isExpanded = _expanded == dispute.id;
    final sevColor = _severityColor(dispute.severity);
    final sevBg = _severityBg(dispute.severity);
    final sevBorder = _severityBorder(dispute.severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: sevBorder),
        boxShadow: AppShadows.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Severity bar
          Container(height: 4, color: sevColor),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(dispute.type, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              StatusBadgeWidget(status: dispute.status.name, small: true),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(color: sevBg, borderRadius: BorderRadius.circular(AppRadius.full)),
                                child: Text(_severityLabel(dispute.severity), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: sevColor)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text('${dispute.id} · ${dispute.entityName} · ${dispute.date}', style: AppTypography.caption),
                        ],
                      ),
                    ),
                    if (dispute.amount != null) ...[
                      const SizedBox(width: 8),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Text('${ArStrings.sar_symbol} ${dispute.amount!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.danger)),
                        Text(ArStrings.amount, style: AppTypography.micro),
                      ]),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(dispute.description, style: AppTypography.bodyMd.copyWith(height: 1.55)),

                // Resolved info
                if (dispute.status == DisputeStatus.resolved && dispute.resolvedAt != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                        const SizedBox(width: 8),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${ArStrings.resolvedOn} ${dispute.resolvedAt}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                          if (dispute.notes != null) ...[
                            const SizedBox(height: 2),
                            Text(dispute.notes!, style: AppTypography.caption),
                          ],
                        ])),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // Expand toggle
                GestureDetector(
                  onTap: () => setState(() => _expanded = isExpanded ? null : dispute.id),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(isExpanded ? ArStrings.hideDetails : ArStrings.showDetails, style: AppTypography.bodyMd.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 16, color: AppColors.textSecondary),
                    ]),
                  ),
                ),
              ],
            ),
          ),

          // Expanded: comment + actions
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.gray100),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Navigate to entity
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/settlements/${dispute.entityType}s/${dispute.entityId}'),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                      ),
                      child: Text('عرض رصيد ${dispute.entityName} ←', style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Comment box
                  Text(ArStrings.addComment, style: AppTypography.label),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      hintText: 'ملاحظات التحقيق، النتائج، الإجراءات المتخذة...',
                      hintStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      _smallOutlineBtn(
                        icon: Icons.attach_file,
                        label: ArStrings.attach,
                        color: AppColors.textSecondary,
                        borderColor: AppColors.border,
                        onTap: () {},
                      ),
                      const SizedBox(width: 8),
                      _smallFilledBtn(
                        icon: Icons.chat_bubble_outline,
                        label: ArStrings.saveNote,
                        color: AppColors.primary,
                        onTap: () {},
                      ),
                      const Spacer(),
                      if (dispute.status != DisputeStatus.resolved)
                        _smallOutlineBtn(
                          icon: Icons.check_circle_outline,
                          label: ArStrings.markResolved,
                          color: AppColors.success,
                          borderColor: AppColors.success,
                          onTap: () => showConfirmSheet(
                            context,
                            title: ArStrings.resolveDispute,
                            message: 'هل تريد وضع علامة "محلول" على هذه المشكلة؟ تأكد من اتخاذ جميع الإجراءات التصحيحية. سيتم تسجيلها في سجل المراجعة.',
                            confirmLabel: ArStrings.resolveIssue,
                          ).then((v) { if (v == true && mounted) setState(() {}); }),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _smallOutlineBtn({required IconData icon, required String label, required Color color, required Color borderColor, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(border: Border.all(color: borderColor), borderRadius: BorderRadius.circular(AppRadius.sm)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    );
  }

  Widget _smallFilledBtn({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.sm)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
      ),
    );
  }
}
