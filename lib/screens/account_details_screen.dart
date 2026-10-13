// Mirrors: AccountDetailsScreen.tsx
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sahalat_owner/main.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../models/models.dart';
import '../services/mock_api_service.dart';
import '../widgets/common_widgets.dart';

class AccountDetailsScreen extends StatefulWidget {
  final String accountType;
  final String accountId;
  const AccountDetailsScreen({super.key, required this.accountType, required this.accountId});

  @override
  State<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends State<AccountDetailsScreen> {
  dynamic _entity;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    dynamic e;
      // await MockApiService.instance.getStores()).firstWhere((s) => s.id == widget.accountId, orElse: () => throw Exception()
      // = (await MockApiService.instance.getUsers()).firstWhere((u) => u.id == widget.accountId, orElse: () => throw Exception());
    if (widget.accountType == 'stores'){
      final s = prefs!.getString("stores") != null?
        json.decode(prefs!.getString('stores') ?? '[]')
        : [];
      Map store = (s as List).firstWhere((s) => s['id'].toString() == widget.accountId, orElse: () => throw Exception());
      final utcDateTime = DateTime.parse(store['created_at']);
      final localDateTime = utcDateTime.toLocal();
      final localDate = DateFormat('yyyy-MM-dd').format(localDateTime);
      final localTime = DateFormat('HH:mm:ss').format(localDateTime);
      e = Store(
        id: store['id'].toString(),
        name: store['name'],
        phone: store['phone'],
        city: store['city']??'غير محدد',
        ordersCount: store['orders'].length,
        email: store['email'],
        category: store['category'],
        commissionRate: 0.05,
        currentBalance: (double.tryParse((store['wallet']??"0").toString()) ?? 0.0),
        hasMismatch: false,
        joinedAt: localDate,
        netPayable: (double.tryParse((store['wallet']??"0").toString()) ?? 0.0) - ((double.tryParse((store['wallet']??"0").toString()) ?? 0.0) * 0.05),
        ownerRetained: ((double.tryParse((store['wallet']??"0").toString()) ?? 0.0) * 0.05).toDouble(),
        rating: store['rating'] != null ? (double.tryParse((store['rating'].toString()).toString()) ?? 0.0) : 0.0,
        totalCommission: (double.tryParse((store['wallet']??"0").toString()) ?? 0.0) * 0.05,
        totalPayouts: 0.0,
        totalRefunds: 0.0,
        totalSales: store['orders'].fold(0.0, (sum, o) => sum + (double.tryParse((o['total'].toString()).toString()) ?? 0.0)),
        status: store['account_status']=="active"?AccountStatus.activated:AccountStatus.values.firstWhere((s) => s.name == store['account_status'], orElse: () => AccountStatus.pending)
      );
    }else if (widget.accountType == 'drivers') {
      final d = prefs!.getString("deliveries") != null?
        json.decode(prefs!.getString('deliveries') ?? '[]')
        : [];
      Map delivery = (d as List).firstWhere((d) => d['id'].toString() == widget.accountId, orElse: () => throw Exception());
      final utcDateTime = DateTime.parse(delivery['created_at']);
      final localDateTime = utcDateTime.toLocal();
      final localDate = DateFormat('yyyy-MM-dd').format(localDateTime);
      final localTime = DateFormat('HH:mm:ss').format(localDateTime);
      e = Driver(
        id: delivery['id'].toString(),
        name: delivery['name'],
        phone: delivery['phone'],
        city: delivery['city']??'غير محدد',
        ordersCount: delivery['orders'].length + delivery['transportorders'].length,
        email: delivery['email'],
        currentBalance: (double.tryParse((delivery['wallet']??"0").toString()) ?? 0.0),
        joinedAt: localDate,
        commissionRate: 0.05,
        // rating: delivery['rating'] != null ? double.parse(delivery['rating'].toString()) : 0.0,
        totalEarnings: (double.tryParse((delivery['wallet']??"0").toString()) ?? 0.0),
        totalPayouts: 0.0,
        // totalRefunds: 0.0,
        hasMismatch: false,
        netPayable: (double.tryParse((delivery['wallet']??"0").toString()) ?? 0.0) - ((double.tryParse((delivery['wallet']??"0").toString()) ?? 0.0) * 0.05),
        totalCommission: (double.tryParse((delivery['wallet']??"0").toString()) ?? 0.0) * 0.05,
        vehicle: delivery['car_type'],
        totalDeliveries: delivery['orders'].length + delivery['transportorders'].length,
        status: delivery['active'] == 'true' ? AccountStatus.activated : AccountStatus.deactivated
      );
    }else if (widget.accountType == 'it-admins') {
      final a = prefs!.getString("itAdmins") != null?
        json.decode(prefs!.getString('itAdmins') ?? '[]')
        : [];
      Map itadmin = (a as List).firstWhere((a) => a['id'].toString() == widget.accountId, orElse: () => throw Exception());
      final utcDateTime = DateTime.parse(itadmin['created_at']);
      final localDateTime = utcDateTime.toLocal();
      final localDate = DateFormat('yyyy-MM-dd').format(localDateTime);
      final localTime = DateFormat('HH:mm:ss').format(localDateTime);
      e = ITAdmin(
        id: itadmin['id'].toString(),
        name: itadmin['name'],
        phone: itadmin['phone'],
        email: itadmin['email'],
        joinedAt: localDate,
        lastLogin: itadmin['last_login'] != null ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(itadmin['last_login']).toLocal()) : 'N/A',
        deviceCount: itadmin['devices'] != null ? (itadmin['devices'] as List<dynamic>).length : 0,
        twoFactorEnabled: itadmin['two_factor_enabled'] ?? false,
        permissions: itadmin['permissions'].keys.map((k)=> itadmin['permissions'][k] == true ? k : null).whereType<String>().toList(),
        status: itadmin['status'] == 'Active' ? AccountStatus.activated : AccountStatus.deactivated
      );
    }else {
      final u = prefs!.getString("users") != null?
        json.decode(prefs!.getString('users') ?? '[]')
        : [];
      Map user = (u as List).firstWhere((u) => u['id'].toString() == widget.accountId, orElse: () => throw Exception());
      final utcDateTime = DateTime.parse(user['created_at']);
      final localDateTime = utcDateTime.toLocal();
      final localDate = DateFormat('yyyy-MM-dd').format(localDateTime);
      final localTime = DateFormat('HH:mm:ss').format(localDateTime);
      e = AppUser(
        id: user['id'].toString(),
        name: user['name'],
        phone: user['phone'],
        city: user['city']??'غير محدد',
        ordersCount: user['orders'].length,
        email: user['email']??'غير محدد',
        joinedAt: localDate,
        hasMismatch: false,
        totalSpent: user['orders'].fold(0.0, (sum, o) => sum + (double.tryParse((o['total'].toString()).toString()) ?? 0.0)),
        commissionRate: 0.05,
        currentBalance: (double.tryParse((user['wallet']??"0").toString()) ?? 0.0),
        netPayable: (double.tryParse((user['wallet']??"0").toString()) ?? 0.0) - ((double.tryParse((user['wallet']??"0").toString()) ?? 0.0) * 0.05),
        totalCommission: (double.tryParse((user['wallet']??"0").toString()) ?? 0.0) * 0.05,
        totalPayouts: 0.0,
        totalRefunds: 0.0,
        status: user['status'] == 'true' ? AccountStatus.activated : AccountStatus.deactivated
      );
    }
    if (mounted) setState(() { _entity = e; _loading = false; });
  }

  String _accountTypeLabel() {
    switch (widget.accountType) {
      case 'stores': return ArStrings.stores;
      case 'drivers': return ArStrings.drivers;
      default: return ArStrings.users;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppHeader(title: widget.accountId, showBack: true), body: const Center(child: CircularProgressIndicator()));
    if (_entity == null) return const Scaffold(appBar: AppHeader(title: 'غير موجود', showBack: true), body: Center(child: Text('الحساب غير موجود')));

    final name = _entity.name as String;
    final status = (_entity.status as AccountStatus).name;
    double netPayable = 0.0;
    try {
      netPayable = _entity.netPayable as double;
    } catch (e) {
      netPayable = 0.0;
    }
    double totalCommission = 0.0;
    try {
      totalCommission = _entity.totalCommission as double;
    } catch (e) {
      totalCommission = 0.0;
    }
    double ordersCount = 0.0;
    try {
      ordersCount = _entity.ordersCount as double;
    } catch (e) {
      ordersCount = 0.0;
    }
    double commissionRate = 0.0;
    try {
      commissionRate = _entity.commissionRate as double;
    } catch (e) {
      commissionRate = 0.0;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: name,
        subtitle: '${widget.accountId} · ${_accountTypeLabel()}',
        showBack: true,
        // rightElement: Container(
        //   width: 36, height: 36,
        //   decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(AppRadius.md)),
        //   child: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
        // ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // Profile card
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.card),
            child: Column(
              children: [
                Row(children: [
                  Container(
                    width: 64, height: 64,
                    decoration: BoxDecoration(
                      color: HSLColor.fromAHSL(1, widget.accountId.codeUnitAt(0) * 7 % 360, 0.6, 0.9).toColor(),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                    ),
                    alignment: Alignment.center,
                    child: Text(name[0], style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800,
                      color: HSLColor.fromAHSL(1, widget.accountId.codeUnitAt(0) * 7 % 360, 0.6, 0.35).toColor())),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    StatusBadgeWidget(status: status),
                    
                    if (widget.accountType !="it-admins" && _entity.hasMismatch as bool) ...[
                      const SizedBox(height: 4),
                      const Row(children: [
                        Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.danger),
                        SizedBox(width: 4),
                        Text('عدم تطابق الرصيد', style: TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w600)),
                      ]),
                    ],
                  ])),
                ]),
                const SizedBox(height: 16),
                for (final row in [
                  (Icons.phone_outlined, 'الهاتف', _entity.phone as String),
                  (Icons.email_outlined, 'البريد الإلكتروني', _entity.email as String),
                  if (widget.accountType != 'it-admins')
                  (Icons.location_on_outlined, 'المدينة', _entity.city as String),
                  (Icons.calendar_today_outlined, ArStrings.joinedAt, _entity.joinedAt as String),
                ])
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Icon(row.$1, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      SizedBox(width: 80, child: Text(row.$2, style: AppTypography.caption)),
                      Expanded(child: Text(row.$3, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary))),
                    ]),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Stats
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 2.2,
            children: [
              _statCard(ArStrings.orders, '$ordersCount', AppColors.primary, AppColors.primaryLight),
              _statCard(ArStrings.commission, '${ArStrings.sar_symbol} ${totalCommission.toStringAsFixed(0)}', AppColors.danger, AppColors.dangerLight),
              _statCard(ArStrings.netPayable, '${ArStrings.sar_symbol} ${netPayable.toStringAsFixed(0)}', AppColors.success, AppColors.successLight),
              _statCard(ArStrings.rate, '$commissionRate%', AppColors.warning, AppColors.warningLight),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Quick actions
          Row(children: [
            _actionBtn(context, Icons.swap_horiz, ArStrings.settlements, AppColors.primary, () {}),
            const SizedBox(width: 8),
            _actionBtn(context, Icons.cancel_outlined, ArStrings.deactivate, AppColors.warning, () => showConfirmSheet(context, title: 'تعطيل الحساب', message: 'تعطيل $name؟', confirmLabel: ArStrings.deactivate)),
            const SizedBox(width: 8),
            _actionBtn(context, Icons.delete_outline, ArStrings.delete, AppColors.danger, () => showConfirmSheet(context, title: 'حذف الحساب', message: 'حذف $name؟', confirmLabel: ArStrings.delete, danger: true)),
          ]),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, Color bg) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.xl)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
    ]),
  );

  Widget _actionBtn(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Column(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ]),
      ),
    ),
  );
}
