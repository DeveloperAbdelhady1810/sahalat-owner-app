// Mirrors: CommissionRulesScreen.tsx
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../models/models.dart';
import '../services/mock_api_service.dart';
import '../widgets/common_widgets.dart';

class CommissionRulesScreen extends StatefulWidget {
  const CommissionRulesScreen({super.key});
  @override
  State<CommissionRulesScreen> createState() => _CommissionRulesScreenState();
}

class _CommissionRulesScreenState extends State<CommissionRulesScreen> {
  List<CommissionRule> _rules = [];
  bool _loading = true;
  String? _expanded;

  static const _scopeLabels = {
    RuleScope.global: 'عام',
    RuleScope.typeStores: 'كل المتاجر',
    RuleScope.typeDrivers: 'كل السائقين',
    RuleScope.typeUsers: 'كل المستخدمين',
    RuleScope.accountSpecific: 'خاص بالحساب',
  };
  static const _baseLabels = {
    CommissionBase.orderTotal: 'إجمالي الطلب',
    CommissionBase.orderSubtotal: 'المجموع الفرعي',
    CommissionBase.deliveryFee: 'رسوم التوصيل',
    CommissionBase.serviceFee: 'رسوم الخدمة',
  };

  @override
  void initState() {
    super.initState();
    MockApiService.instance.getCommissionRules().then((r) { if (mounted) setState(() { _rules = r; _loading = false; }); });
  }

  void _openSimulator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommissionSimulatorSheet(rules: _rules.where((r) => r.enabled).toList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: ArStrings.commissionRules,
        subtitle: ArStrings.priorityBasedEngine,
        showBack: true,
        rightElement: Row(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(
            onTap: _openSimulator,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.calculate_outlined, size: 14, color: Color(0xFF7C3AED)),
                const SizedBox(width: 4),
                Text(ArStrings.simulate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => context.go('/settings/commission-rules/create'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(AppRadius.md)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.add, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(ArStrings.newRule, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
              ]),
            ),
          ),
        ]),
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Priority explanation
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(AppRadius.xl), border: Border.all(color: const Color(0xFFC7D2FE))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(ArStrings.priorityOrder, style: AppTypography.label.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 6),
                  Row(children: [
                    _priorityTag(ArStrings.accountSpecific),
                    const Text(' ← ', style: TextStyle(color: AppColors.textMuted)),
                    _priorityTag(ArStrings.typeRule),
                    const Text(' ← ', style: TextStyle(color: AppColors.textMuted)),
                    _priorityTag(ArStrings.global),
                  ]),
                ]),
              ),
              const SizedBox(height: AppSpacing.md),

              for (final rule in _rules) ...[
                _buildRuleCard(rule),
                const SizedBox(height: 10),
              ],
            ],
          ),
    );
  }

  Widget _priorityTag(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.sm)),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
  );

  Widget _buildRuleCard(CommissionRule rule) {
    final isExpanded = _expanded == rule.id;
    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.card),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = isExpanded ? null : rule.id),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(rule.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(width: 8),
                        StatusBadgeWidget(status: rule.enabled ? 'enabled' : 'disabled', small: true),
                      ]),
                      const SizedBox(height: 4),
                      Wrap(spacing: 6, children: [
                        _chip(_scopeLabels[rule.scope] ?? '', AppColors.primaryLight, AppColors.primary),
                        _chip('أول. ${rule.priority}', AppColors.gray100, AppColors.textSecondary),
                      ]),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('${rule.commissionRate}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1)),
                    Text(_baseLabels[rule.commissionBase] ?? '', style: AppTypography.micro),
                  ]),
                ]),
                const SizedBox(height: 8),
                Text('نافذ: ${rule.effectiveDate} · بواسطة: ${rule.createdBy}', style: AppTypography.caption),
              ]),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.gray100),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (rule.note.isNotEmpty) ...[
                    Text(rule.note, style: AppTypography.bodyMd.copyWith(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 12),
                  ],
                  // Example calc
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مثال (طلب بقيمة ١٠٠ ر.س)', style: AppTypography.label),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('أساس العمولة', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Text('${ArStrings.sar_symbol} ${rule.commissionBase == CommissionBase.deliveryFee ? 15 : rule.commissionBase == CommissionBase.serviceFee ? 5 : rule.commissionBase == CommissionBase.orderSubtotal ? 80 : 100}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ]),
                        const Divider(),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('ربح المالك', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.success)),
                          Text('${ArStrings.sar_symbol} ${((rule.commissionBase == CommissionBase.deliveryFee ? 15.0 : rule.commissionBase == CommissionBase.serviceFee ? 5.0 : rule.commissionBase == CommissionBase.orderSubtotal ? 80.0 : 100.0) * rule.commissionRate / 100).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.success)),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))), child: Text(ArStrings.editRule, style: const TextStyle(color: AppColors.primary, fontSize: 12)))),
                    const SizedBox(width: 8),
                    Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: BorderSide(color: rule.enabled ? AppColors.warning : AppColors.success), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))), child: Text(rule.enabled ? ArStrings.disable : ArStrings.enable, style: TextStyle(color: rule.enabled ? AppColors.warning : AppColors.success, fontSize: 12)))),
                  ]),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, Color bg, Color text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.full)),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text)),
  );
}

// ─── Commission Simulator Bottom Sheet ────────────────────────────────────────
class _CommissionSimulatorSheet extends StatefulWidget {
  final List<CommissionRule> rules;
  const _CommissionSimulatorSheet({required this.rules});
  @override
  State<_CommissionSimulatorSheet> createState() => _CommissionSimulatorSheetState();
}

class _CommissionSimulatorSheetState extends State<_CommissionSimulatorSheet> {
  final _subtotalCtrl = TextEditingController(text: '100');
  final _deliveryCtrl = TextEditingController(text: '15');
  final _serviceCtrl = TextEditingController(text: '5');
  final _discountCtrl = TextEditingController(text: '0');
  late String _selectedRuleId;

  static const _baseLabels = {
    CommissionBase.orderTotal: 'إجمالي الطلب',
    CommissionBase.orderSubtotal: 'المجموع الفرعي',
    CommissionBase.deliveryFee: 'رسوم التوصيل',
    CommissionBase.serviceFee: 'رسوم الخدمة',
  };

  @override
  void initState() {
    super.initState();
    _selectedRuleId = widget.rules.isNotEmpty ? widget.rules.first.id : '';
  }

  @override
  void dispose() {
    _subtotalCtrl.dispose(); _deliveryCtrl.dispose(); _serviceCtrl.dispose(); _discountCtrl.dispose();
    super.dispose();
  }

  Map<String, double>? _calculate() {
    final rule = widget.rules.firstWhere((r) => r.id == _selectedRuleId, orElse: () => widget.rules.first);
    final sub = double.tryParse(_subtotalCtrl.text) ?? 0;
    final del = double.tryParse(_deliveryCtrl.text) ?? 0;
    final svc = double.tryParse(_serviceCtrl.text) ?? 0;
    final disc = double.tryParse(_discountCtrl.text) ?? 0;
    final total = sub + del + svc - disc;
    final base = rule.commissionBase == CommissionBase.orderTotal ? total
        : rule.commissionBase == CommissionBase.orderSubtotal ? sub
        : rule.commissionBase == CommissionBase.deliveryFee ? del : svc;
    final profit = base * rule.commissionRate / 100;
    final margin = total > 0 ? (profit / total) * 100 : 0.0;
    return {'sub': sub, 'del': del, 'svc': svc, 'disc': disc, 'total': total, 'base': base, 'profit': profit, 'margin': margin};
  }

  @override
  Widget build(BuildContext context) {
    final calc = widget.rules.isEmpty ? null : _calculate();
    final selectedRule = widget.rules.isEmpty ? null : widget.rules.firstWhere((r) => r.id == _selectedRuleId, orElse: () => widget.rules.first);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.gray200, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.calculate_outlined, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('محاكي العمولة', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                Text('معاينة الربح قبل التطبيق', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              ])),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.close, size: 16, color: AppColors.textSecondary),
                ),
              ),
            ]),
          ),
          const Divider(height: 1, color: AppColors.gray100),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Rule selector
                if (widget.rules.isNotEmpty) ...[
                  Text('قاعدة العمولة', style: AppTypography.label),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedRuleId,
                        isExpanded: true,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        items: widget.rules.map((r) => DropdownMenuItem(
                          value: r.id,
                          child: Text('${r.name} — ${r.commissionRate}% على ${_baseLabels[r.commissionBase] ?? ''}'),
                        )).toList(),
                        onChanged: (v) { if (v != null) setState(() => _selectedRuleId = v); },
                      ),
                    ),
                  ),
                  if (selectedRule != null) ...[
                    const SizedBox(height: 4),
                    Text('النطاق: ${selectedRule.appliesTo} · الأولوية ${selectedRule.priority}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF6366F1))),
                  ],
                  const SizedBox(height: 16),
                ],

                // Input grid
                Text('تفاصيل الطلب', style: AppTypography.label),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.8,
                  children: [
                    _inputField('المجموع الفرعي', _subtotalCtrl),
                    _inputField('رسوم التوصيل', _deliveryCtrl),
                    _inputField('رسوم الخدمة', _serviceCtrl),
                    _inputField('الخصم', _discountCtrl),
                  ],
                ),
                const SizedBox(height: 16),

                // Result
                if (calc != null) ...[
                  // Breakdown
                  Container(
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: Column(children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                        child: Column(children: [
                          Text('تفصيل الحساب', style: AppTypography.label),
                          const SizedBox(height: 10),
                          ...[
                            ('المجموع الفرعي للطلب', calc['sub']!, false),
                            ('رسوم التوصيل', calc['del']!, false),
                            ('رسوم الخدمة', calc['svc']!, false),
                            ('الخصم', calc['disc']!, true),
                          ].map((r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(r.$1, style: AppTypography.bodyMd),
                              Text('${r.$3 ? '-' : ''}${ArStrings.sar_symbol} ${r.$2.toStringAsFixed(2)}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: r.$3 ? AppColors.danger : AppColors.textPrimary)),
                            ]),
                          )),
                          const Divider(),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('إجمالي الطلب', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            Text('${ArStrings.sar_symbol} ${calc['total']!.toStringAsFixed(2)}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          ]),
                        ]),
                      ),
                      // Base highlight
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryLight,
                          border: Border(top: BorderSide(color: Color(0xFFC7D2FE))),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('أساس العمولة (${selectedRule != null ? _baseLabels[selectedRule.commissionBase] ?? '' : ''})',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6366F1))),
                            Text('المعدل: ${selectedRule?.commissionRate ?? 0}%',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF818CF8))),
                          ]),
                          Text('${ArStrings.sar_symbol} ${calc['base']!.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                        ]),
                      ),
                      // Profit result
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.trending_up, size: 24, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Text('ربح المالك', style: TextStyle(fontSize: 12, color: Colors.white70)),
                            Text('${ArStrings.sar_symbol} ${calc['profit']!.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.5)),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            const Text('الهامش', style: TextStyle(fontSize: 11, color: Colors.white70)),
                            Text('${calc['margin']!.toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                          ]),
                        ]),
                      ),
                    ]),
                  ),

                  const SizedBox(height: 16),
                  // Quick compare
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.gray50, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('مقارنة سريعة — كل القواعد النشطة', style: AppTypography.label),
                      const SizedBox(height: 10),
                      for (final rule in widget.rules) ...[
                        GestureDetector(
                          onTap: () => setState(() => _selectedRuleId = rule.id),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: rule.id == _selectedRuleId ? AppColors.primaryLight : AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: rule.id == _selectedRuleId ? AppColors.primary : AppColors.border, width: 1.5),
                            ),
                            child: Row(children: [
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(rule.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                Text('${rule.commissionRate}% على ${_baseLabels[rule.commissionBase] ?? ''}', style: AppTypography.micro),
                              ])),
                              Builder(builder: (ctx) {
                                final b = rule.commissionBase == CommissionBase.orderTotal ? calc!['total']!
                                    : rule.commissionBase == CommissionBase.orderSubtotal ? calc!['sub']!
                                    : rule.commissionBase == CommissionBase.deliveryFee ? calc!['del']! : calc!['svc']!;
                                final p = b * rule.commissionRate / 100;
                                return Text('${ArStrings.sar_symbol} ${p.toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800,
                                    color: rule.id == _selectedRuleId ? AppColors.primary : AppColors.success));
                              }),
                            ]),
                          ),
                        ),
                      ],
                    ]),
                  ),
                  const SizedBox(height: 12),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController ctrl) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$label (${ArStrings.sar_symbol})', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.04)),
      const SizedBox(height: 4),
      Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.border)),
        child: Row(children: [
          Text('${ArStrings.sar_symbol} ', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ]),
      ),
    ]);
  }
}
