// Mirrors: CreateRuleScreen.tsx
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class CreateRuleScreen extends StatefulWidget {
  const CreateRuleScreen({super.key});
  @override
  State<CreateRuleScreen> createState() => _CreateRuleScreenState();
}

class _CreateRuleScreenState extends State<CreateRuleScreen> {
  int _step = 1;
  final _nameController = TextEditingController();
  RuleScope _scope = RuleScope.global;
  CommissionBase _base = CommissionBase.orderTotal;
  double _rate = 5.0;
  bool _enabled = true;
  bool _saved = false;

  static const _scopeOpts = [
    (RuleScope.global, 'عام', 'ينطبق على جميع الحسابات'),
    (RuleScope.typeStores, 'كل المتاجر', 'جميع حسابات المتاجر'),
    (RuleScope.typeDrivers, 'كل السائقين', 'جميع حسابات السائقين'),
    (RuleScope.typeUsers, 'كل المستخدمين', 'جميع حسابات المستخدمين'),
    (RuleScope.accountSpecific, 'حسابات محددة', 'اختر حسابات فردية'),
  ];

  static const _baseOpts = [
    (CommissionBase.orderTotal, 'إجمالي الطلب', 'يشمل رسوم التوصيل'),
    (CommissionBase.orderSubtotal, 'المجموع الفرعي', 'قبل رسوم التوصيل'),
    (CommissionBase.deliveryFee, 'رسوم التوصيل فقط', 'عمولة على التوصيل'),
    (CommissionBase.serviceFee, 'رسوم الخدمة فقط', 'رسوم خدمة المنصة'),
  ];

  double get _baseAmount => _base == CommissionBase.deliveryFee ? 15 : _base == CommissionBase.serviceFee ? 5 : _base == CommissionBase.orderSubtotal ? 80 : 100;
  double get _exampleProfit => _baseAmount * _rate / 100;

  @override
  Widget build(BuildContext context) {
    if (_saved) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 80, height: 80, decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle), child: const Icon(Icons.check_circle_outline, size: 40, color: AppColors.success)),
          const SizedBox(height: 16),
          const Text('تم إنشاء القاعدة!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          Text(_nameController.text.isNotEmpty ? _nameController.text : 'قاعدة عمولة جديدة', textAlign: TextAlign.center, style: AppTypography.bodyMd),
        ])),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: 'إنشاء قاعدة عمولة', showBack: true),
      body: Column(
        children: [
          // Progress
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: List.generate(3, (i) => Expanded(child: Container(
              height: 6, margin: EdgeInsets.only(left: i < 2 ? 6 : 0),
              decoration: BoxDecoration(color: i < _step ? AppColors.primary : AppColors.gray200, borderRadius: BorderRadius.circular(AppRadius.full)),
            )))),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 4),
            child: Align(alignment: Alignment.centerRight, child: Text('الخطوة $_step من ٣', style: AppTypography.caption)),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  if (_step == 1) ...[
                    _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('اسم القاعدة *', style: AppTypography.label),
                      const SizedBox(height: 6),
                      TextField(controller: _nameController, textDirection: TextDirection.rtl, decoration: const InputDecoration(hintText: 'مثال: متاجر مميزة – جدة')),
                      const SizedBox(height: 16),
                      Text('تنطبق على *', style: AppTypography.label),
                      const SizedBox(height: 8),
                      for (final opt in _scopeOpts)
                        GestureDetector(
                          onTap: () => setState(() => _scope = opt.$1),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _scope == opt.$1 ? AppColors.primaryLight : AppColors.gray50,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: _scope == opt.$1 ? AppColors.primary : AppColors.border, width: _scope == opt.$1 ? 1.5 : 1),
                            ),
                            child: Row(children: [
                              Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _scope == opt.$1 ? AppColors.primary : AppColors.border, width: 2), color: _scope == opt.$1 ? AppColors.primary : Colors.transparent),
                                alignment: Alignment.center, child: _scope == opt.$1 ? Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)) : null),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(opt.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                Text(opt.$3, style: AppTypography.caption),
                              ])),
                            ]),
                          ),
                        ),
                    ])),
                  ],

                  if (_step == 2) ...[
                    _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('معدل العمولة (%)', style: AppTypography.label),
                      const SizedBox(height: 12),
                      Row(children: [
                        for (final v in [1.0, 3.0, 5.0, 7.0, 10.0])
                          GestureDetector(
                            onTap: () => setState(() => _rate = v),
                            child: Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _rate == v ? AppColors.primaryLight : AppColors.gray100,
                                borderRadius: BorderRadius.circular(AppRadius.full),
                                border: Border.all(color: _rate == v ? AppColors.primary : AppColors.border),
                              ),
                              child: Text('${v.toInt()}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _rate == v ? AppColors.primary : AppColors.textSecondary)),
                            ),
                          ),
                      ]),
                      const SizedBox(height: 16),
                      Text('أساس العمولة', style: AppTypography.label),
                      const SizedBox(height: 8),
                      for (final opt in _baseOpts)
                        GestureDetector(
                          onTap: () => setState(() => _base = opt.$1),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _base == opt.$1 ? AppColors.primaryLight : AppColors.gray50,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: _base == opt.$1 ? AppColors.primary : AppColors.border, width: _base == opt.$1 ? 1.5 : 1),
                            ),
                            child: Row(children: [
                              Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _base == opt.$1 ? AppColors.primary : AppColors.border, width: 2), color: _base == opt.$1 ? AppColors.primary : Colors.transparent),
                                alignment: Alignment.center, child: _base == opt.$1 ? Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)) : null),
                              const SizedBox(width: 12),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(opt.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                Text(opt.$3, style: AppTypography.caption),
                              ])),
                            ]),
                          ),
                        ),
                    ])),
                  ],

                  if (_step == 3) ...[
                    _card(child: Column(children: [
                      for (final row in [
                        ('اسم القاعدة', _nameController.text.isEmpty ? '—' : _nameController.text),
                        ('تنطبق على', _scopeOpts.firstWhere((o) => o.$1 == _scope).$2),
                        ('المعدل', '$_rate%'),
                        ('الأساس', _baseOpts.firstWhere((o) => o.$1 == _base).$2),
                        ('الحالة', _enabled ? ArStrings.statusEnabled : ArStrings.statusDisabled),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(children: [
                            Expanded(child: Text(row.$1, style: AppTypography.bodyMd.copyWith(color: AppColors.secondary))),
                            Text(row.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                          ]),
                        ),
                    ])),
                    const SizedBox(height: AppSpacing.md),
                    _card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('مثال على الحساب', style: AppTypography.label),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المبلغ الأساسي'), Text('${ArStrings.sar_symbol} ${_baseAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w600))]),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('المعدل'), Text('$_rate%', style: const TextStyle(fontWeight: FontWeight.w600))]),
                      const Divider(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('ربح المالك', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.success)),
                        Text('${ArStrings.sar_symbol} ${_exampleProfit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.success)),
                      ]),
                    ])),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                  Row(children: [
                    if (_step > 1) ...[
                      Expanded(child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.border), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md))),
                        child: const Text('→ رجوع', style: TextStyle(color: AppColors.textSecondary)),
                      )),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_step < 3) setState(() => _step++);
                          else {
                            setState(() => _saved = true);
                            Future.delayed(const Duration(seconds: 2), () { if (context.mounted) context.go('/settings/commission-rules'); });
                          }
                        },
                        child: Text(_step < 3 ? 'متابعة ←' : '✓ إنشاء القاعدة'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.card),
    child: child,
  );
}
