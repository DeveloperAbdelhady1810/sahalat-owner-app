// ============================================================
// سهلات المالك – لوحة التحكم الرئيسية (Flutter)
// Mirrors: DashboardScreen.tsx
// ============================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sahalat_owner/models/models.dart';
import 'package:sahalat_owner/services/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_tokens.dart';
import '../widgets/common_widgets.dart';
import '../l10n/strings_ar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.prefs});
  final SharedPreferences prefs;
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _period = 'week';
  Map<String, dynamic>? _kpis;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
  late SharedPreferences prefs;
  String? _error;

  Future<void> _loadData() async {
    prefs = widget.prefs;
    if (mounted) setState(() { _error = null; });
    try {
      final kpis = await API().getDashboardKPIs();
      final orders = kpis['orders'] as List<dynamic>;
      final users = kpis['users'] as List<dynamic>;
      final deliveries = kpis['deliveries'] as List<dynamic>;
      final stores = kpis['sellers'] as List<dynamic>;
      final itAdmins = kpis['itAdmins'] as List<dynamic>;
      await prefs.setString('users', json.encode(users));
      await prefs.setString('deliveries', json.encode(deliveries));
      await prefs.setString('stores', json.encode(stores));
      await prefs.setString('itAdmins', json.encode(itAdmins));
      await prefs.setString('orders', json.encode(orders));
      if (mounted) setState(() { _kpis = kpis; _loading = false; });
    } catch (e) {
      if (identical(e, API.sessionExpired)) {
        await API().logout();
        if (mounted) context.go('/login');
        return;
      }
      if (mounted) setState(() { _loading = false; _error = 'تعذر تحميل البيانات، تحقق من الاتصال وحاول مرة أخرى'; });
    }
  }

  /// 12800 -> "12.8K", 950 -> "950"; null (not loaded) -> "—". Never invents a number.
  String _money(dynamic v) {
    final n = double.tryParse(v?.toString() ?? '');
    if (n == null) return '—';
    if (n.abs() >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toStringAsFixed(n == n.roundToDouble() ? 0 : 2);
  }

  String _count(dynamic v) => v == null ? '—' : v.toString();

  double get _profit {
    if (_kpis == null) return 0;
    if (_period == 'today') return (double.tryParse((_kpis!['profitToday'].toString()).toString()) ?? 0.0);
    if (_period == 'week') return (double.tryParse((_kpis!['profitWeek'].toString()).toString()) ?? 0.0);
    return (double.tryParse((_kpis!['profitMonth'].toString()).toString()) ?? 0.0);
  }

  String get _periodLabel {
    if (_period == 'today') return ArStrings.today;
    if (_period == 'week') return ArStrings.thisWeek;
    return ArStrings.thisMonth;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null && _kpis == null)
            ? _buildError()
            : RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            slivers: [
              // Gradient header
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(gradient: AppGradients.primary),
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(AppRadius.xl),
                                ),
                                child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                              ),
                              Positioned(
                                top: 9, left: 9,
                                child: Container(
                                  width: 8, height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.danger, shape: BoxShape.circle,
                                    border: Border.fromBorderSide(BorderSide(color: AppColors.primary, width: 1.5)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text(ArStrings.welcomeBack, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.65), fontFamily: 'Cairo')),
                            Text(prefs.getString("name")??"", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Cairo')),
                          ]),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Period toggle
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Row(
                          children: [
                            {'key': 'today', 'label': ArStrings.today},
                            {'key': 'week', 'label': ArStrings.thisWeek},
                            {'key': 'month', 'label': ArStrings.thisMonth},
                          ].map((p) {
                            final isActive = _period == p['key'];
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _period = p['key']!),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isActive ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppRadius.sm),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    p['label']!,
                                    style: TextStyle(
                                      fontSize: 12, fontWeight: FontWeight.w600,
                                      fontFamily: 'Cairo',
                                      color: isActive ? AppColors.primary : Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Profit
                      Text('${ArStrings.ownerProfit} — $_periodLabel',
                        style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.6), fontFamily: 'Cairo'),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        '${_profit.toStringAsFixed(2)} ${ArStrings.currency_symbol}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -1, fontFamily: 'Cairo'),
                      ),
                    ],
                  ),
                ),
              ),

              // KPI cards
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    // Give cards a bit more height so longer Arabic captions + trend row fit without overflow.
                    childAspectRatio: 1.15,
                  ),
                  delegate: SliverChildListDelegate([
                    KpiCard(label: ArStrings.pendingSettlements, value: '${_money(_kpis?['pendingSettlementsTotal'])} ${ArStrings.sar_symbol}', sub: ArStrings.acrossAllAccounts, icon: Icons.swap_horiz, color: AppColors.warning, bgColor: AppColors.warningLight),
                    KpiCard(label: ArStrings.ordersToday, value: _count(_kpis?['totalOrdersToday']), sub: '${_count(_kpis?['totalOrdersMonth'])} هذا الشهر', icon: Icons.flash_on_outlined, color: AppColors.success, bgColor: AppColors.successLight),
                    KpiCard(label: ArStrings.refunds, value: '${_money(_kpis?['refundsAmount'])} ${ArStrings.sar_symbol}', sub: '${_count(_kpis?['refundsCount'])} طلبات', icon: Icons.cancel_outlined, color: AppColors.danger, bgColor: AppColors.dangerLight),
                    KpiCard(label: ArStrings.completedSettlements, value: '${_money(_kpis?['completedSettlementsTotal'])} ${ArStrings.sar_symbol}', sub: ArStrings.total, icon: Icons.check_circle_outline, color: AppColors.info, bgColor: AppColors.infoLight),
                  ]),
                ),
              ),

              // Alerts
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    for (final alert in [
                      if (((_kpis?['pendingAccountsCount'] ?? 0) as num) > 0)
                        {'msg': '${_kpis?['pendingAccountsCount']} حسابات في انتظار الموافقة', 'type': 'warning', 'action': 'مراجعة', 'path': '/accounts'},
                    ]) _buildAlert(context, alert),
                  ]),
                ),
              ),

              // Quick actions
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(ArStrings.quickActions, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary, fontFamily: 'Cairo')),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _quickAction(context, Icons.check_circle_outline, ArStrings.approveAccounts, AppColors.warning, AppColors.warningLight, '/accounts'),
                          _quickAction(context, Icons.description_outlined, ArStrings.auditLogs, AppColors.info, AppColors.infoLight, '/settings/audit-logs'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.gray300),
            const SizedBox(height: 12),
            Text(_error ?? '', textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() { _loading = true; });
                _loadData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlert(BuildContext context, Map<String, dynamic> alert) {
    final isWarning = alert['type'] == 'warning';
    final isDanger = alert['type'] == 'danger';
    final bg = isDanger ? AppColors.dangerLight : isWarning ? AppColors.warningLight : AppColors.infoLight;
    final border = isDanger ? AppColors.danger.withOpacity(0.3) : isWarning ? AppColors.warning.withOpacity(0.3) : AppColors.info.withOpacity(0.3);
    final iconColor = isDanger ? AppColors.danger : isWarning ? AppColors.warning : AppColors.info;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.go(alert['path'] as String),
            child: Text('← ${alert['action']}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: iconColor, fontFamily: 'Cairo')),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(alert['msg'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary, fontFamily: 'Cairo'), textAlign: TextAlign.right)),
          Icon(Icons.warning_amber_rounded, size: 16, color: iconColor),
        ],
      ),
    );
  }

  Widget _quickAction(BuildContext context, IconData icon, String label, Color color, Color bg, String path) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(path),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.md)),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(height: 6),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Cairo')),
            ],
          ),
        ),
      ),
    );
  }
}
