// Mirrors: AccountsScreen.tsx (with IT Admins as 4th segment)
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../models/models.dart';
import '../widgets/common_widgets.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});
  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  String _segment = 'stores';
  List<Store> _stores = [];
  List<Driver> _drivers = [];
  List<AppUser> _users = [];
  List<ITAdmin> _itAdmins = [];
  bool _loading = true;
  final _searchController = TextEditingController();
  String _statusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    
    final SharedPreferences prefs = await SharedPreferences.getInstance();
      final s = (json.decode(prefs.getString('stores') ?? '[]') as List<dynamic>).map((e) {
      final utcDateTime = DateTime.parse(e['created_at']);
      final localDateTime = utcDateTime.toLocal();
      final localDate = DateFormat('yyyy-MM-dd').format(localDateTime);
      final localTime = DateFormat('HH:mm:ss').format(localDateTime);
      return Store(
        id: e['id'].toString(),
        name: e['name'],
        phone: e['phone'],
        city: e['city']??'غير محدد',
        ordersCount: e['orders'].length,
        email: e['email'],
        category: e['category'],
        commissionRate: 0.05,
        currentBalance: (double.tryParse((e['wallet']??"0").toString()) ?? 0.0),
        hasMismatch: false,
        joinedAt: localDate,
        netPayable: (double.tryParse((e['wallet']??"0").toString()) ?? 0.0) - ((double.tryParse((e['wallet']??"0").toString()) ?? 0.0) * 0.05),
        ownerRetained: ((double.tryParse((e['wallet']??"0").toString()) ?? 0.0) * 0.05).toDouble(),
        rating: e['rating'] != null ? (double.tryParse((e['rating'].toString()).toString()) ?? 0.0) : 0.0,
        totalCommission: (double.tryParse((e['wallet']??"0").toString()) ?? 0.0) * 0.05,
        totalPayouts: 0.0,
        totalRefunds: 0.0,
        totalSales: e['orders'].fold(0.0, (sum, o) => sum + (double.tryParse((o['total'].toString()).toString()) ?? 0.0)),

        status: e['account_status']=="active"?AccountStatus.activated:AccountStatus.values.firstWhere((s) => s.name == e['account_status'], orElse: () => AccountStatus.pending)
      );
    }).toList();
    final d = (json.decode(prefs.getString('deliveries') ?? '[]') as List<dynamic>).map((e) {
      final utcDateTime = DateTime.parse(e['created_at']);
      final localDateTime = utcDateTime.toLocal();
      final localDate = DateFormat('yyyy-MM-dd').format(localDateTime);
      final localTime = DateFormat('HH:mm:ss').format(localDateTime);
      return Driver(
        id: e['id'].toString(),
        name: e['name'],
        phone: e['phone'],
        city: e['city']??'غير محدد',
        ordersCount: e['orders'].length + e['transportorders'].length,
        email: e['email'],
        currentBalance: (double.tryParse((e['wallet']??"0").toString()) ?? 0.0),
        joinedAt: localDate,
        commissionRate: 0.05,
        // rating: e['rating'] != null ? double.parse(e['rating'].toString()) : 0.0,
        totalEarnings: (double.tryParse((e['wallet']??"0").toString()) ?? 0.0),
        totalPayouts: 0.0,
        // totalRefunds: 0.0,
        hasMismatch: false,
        netPayable: (double.tryParse((e['wallet']??"0").toString()) ?? 0.0) - ((double.tryParse((e['wallet']??"0").toString()) ?? 0.0) * 0.05),
        totalCommission: (double.tryParse((e['wallet']??"0").toString()) ?? 0.0) * 0.05,
        vehicle: e['car_type'],
        totalDeliveries: e['orders'].length + e['transportorders'].length,

        status: e['active'] == 'true' ? AccountStatus.activated : AccountStatus.deactivated
      );
    }).toList();
    final u = (json.decode(prefs.getString('users') ?? '[]') as List<dynamic>).map((e) {
      final utcDateTime = DateTime.parse(e['created_at']);
      final localDateTime = utcDateTime.toLocal();
      final localDate = DateFormat('yyyy-MM-dd').format(localDateTime);
      final localTime = DateFormat('HH:mm:ss').format(localDateTime);
      return AppUser(
        id: e['id'].toString(),
        name: e['name'],
        phone: e['phone'],
        city: e['city']??'غير محدد',
        ordersCount: e['orders'].length,
        email: e['email']??'غير محدد',
        joinedAt: localDate,
        hasMismatch: false,
        totalSpent: e['orders'].fold(0.0, (sum, o) => sum + (double.tryParse((o['total'].toString()).toString()) ?? 0.0)),
        commissionRate: 0.05,
        currentBalance: (double.tryParse((e['wallet']??"0").toString()) ?? 0.0),
        netPayable: (double.tryParse((e['wallet']??"0").toString()) ?? 0.0) - ((double.tryParse((e['wallet']??"0").toString()) ?? 0.0) * 0.05),
        totalCommission: (double.tryParse((e['wallet']??"0").toString()) ?? 0.0) * 0.05,
        totalPayouts: 0.0,
        totalRefunds: 0.0,
        status: e['status'] == 'true' ? AccountStatus.activated : AccountStatus.deactivated
      );
    }).toList();
    final a = (json.decode(prefs.getString('itAdmins') ?? '[]') as List<dynamic>).map((e) {
      final utcDateTime = DateTime.parse(e['created_at']);
      final localDateTime = utcDateTime.toLocal();
      final localDate = DateFormat('yyyy-MM-dd').format(localDateTime);
      final localTime = DateFormat('HH:mm:ss').format(localDateTime);
      return ITAdmin(
        id: e['id'].toString(),
        name: e['name'],
        phone: e['phone'],
        email: e['email'],
        joinedAt: localDate,
        lastLogin: e['last_login'] != null ? DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(e['last_login']).toLocal()) : 'N/A',
        deviceCount: e['devices'] != null ? (e['devices'] as List<dynamic>).length : 0,
        twoFactorEnabled: e['two_factor_enabled'] ?? false,
        // permissions: List<String>.from(e['permissions'] ?? []),
        permissions: e['permissions'].keys.map((k)=> e['permissions'][k] == true ? k : null).whereType<String>().toList(),
        status: e['status'] == 'Active' ? AccountStatus.activated : AccountStatus.deactivated
      );
    }).toList();
    if (mounted) setState(() { _stores = s; _drivers = d; _users = u; _itAdmins = a; _loading = false; });
  }

  List<dynamic> get _current {
    switch (_segment) {
      case 'stores': return _stores;
      case 'drivers': return _drivers;
      case 'it-admins': return _itAdmins;
      default: return _users;
    }
  }

  bool get _isITAdmin => _segment == 'it-admins';

  String _statusLabel(String s) {
    switch (s) {
      case 'all': return ArStrings.all;
      case 'activated': return ArStrings.statusActivated;
      case 'pending': return ArStrings.statusPending;
      case 'created': return ArStrings.statusCreated;
      case 'deactivated': return ArStrings.statusDeactivated;
      default: return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient header with segmented control
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.primary),
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ArStrings.accounts, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(ArStrings.manageStoresDrivers, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _segTab(ArStrings.stores, 'stores', _stores.length),
                      const SizedBox(width: 6),
                      _segTab(ArStrings.drivers, 'drivers', _drivers.length),
                      const SizedBox(width: 6),
                      _segTab(ArStrings.users, 'users', _users.length),
                      const SizedBox(width: 6),
                      _segTab(ArStrings.itAdmins, 'it-admins', _itAdmins.length),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // IT Admin info banner
          if (_isITAdmin)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3FF),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: const Color(0xFFDDD6FE)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('حسابات مشرفي تقنية المعلومات', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
                        SizedBox(height: 2),
                        Text('مشرفو المنصة بصلاحيات محدودة. لا يمكنهم تعديل قواعد العمولة أو إجراء التحويلات.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF8B5CF6))),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: ['all', 'activated', 'pending', 'created', 'deactivated'].map((s) =>
                GestureDetector(
                  onTap: () => setState(() => _statusFilter = s),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _statusFilter == s ? AppColors.primary : AppColors.gray100,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(_statusLabel(s),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: _statusFilter == s ? Colors.white : AppColors.textSecondary)),
                  ),
                )
              ).toList(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: AppSearchBar(
              controller: _searchController,
              placeholder: '${ArStrings.search} ${_isITAdmin ? ArStrings.itAdmins : _segment == 'stores' ? ArStrings.stores : _segment == 'drivers' ? ArStrings.drivers : ArStrings.users}...',
            ),
          ),

          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _current.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: ArStrings.noAccountsFound,
                    description: 'جرّب بحثاً أو فلتراً مختلفاً',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _current.length,
                    itemBuilder: (ctx, i) {
                      final e = _current[i];
                      return GestureDetector(
                        onTap: () => context.go('/accounts/$_segment/${e.id}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            boxShadow: AppShadows.card,
                          ),
                          child: Row(
                            children: [
                              // Avatar with shield badge for IT Admins
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 44, height: 44,
                                    decoration: BoxDecoration(
                                      color: _isITAdmin
                                        ? const Color(0xFFF5F3FF)
                                        : HSLColor.fromAHSL(1, (e.id as String).codeUnitAt(0) * 7 % 360, 0.6, 0.9).toColor(),
                                      borderRadius: BorderRadius.circular(AppRadius.xl),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text((e.name as String)[0],
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800,
                                        color: _isITAdmin
                                          ? const Color(0xFF7C3AED)
                                          : HSLColor.fromAHSL(1, (e.id as String).codeUnitAt(0) * 7 % 360, 0.6, 0.35).toColor())),
                                  ),
                                  if (_isITAdmin)
                                    Positioned(
                                      right: -2, bottom: -2,
                                      child: Container(
                                        width: 16, height: 16,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF7C3AED),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        child: const Icon(Icons.shield, size: 9, color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(children: [
                                    Expanded(child: Text(e.name as String,
                                      style: AppTypography.subheading.copyWith(fontSize: 14),
                                      overflow: TextOverflow.ellipsis)),
                                    StatusBadgeWidget(status: (e.status as AccountStatus).name, small: true),
                                  ]),
                                  Text('${e.id} · ${e.phone}', style: AppTypography.caption),
                                  if (_isITAdmin) ...[
                                    Text('${ArStrings.lastLogin}: ${(e as ITAdmin).lastLogin} · ${e.deviceCount} ${ArStrings.devices}',
                                      style: AppTypography.caption),
                                    const SizedBox(height: 4),
                                    Row(children: [
                                      if ((e as ITAdmin).twoFactorEnabled) ...[
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(AppRadius.full)),
                                          child: Text(ArStrings.twoFAEnabled, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.success)),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(AppRadius.full)),
                                        child: Text('${(e as ITAdmin).permissions.length} ${ArStrings.permissions}',
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFF7C3AED))),
                                      ),
                                    ]),
                                  ] else
                                    Text('${(e as dynamic).city ?? ''} · ${e.ordersCount} ${ArStrings.orders}', style: AppTypography.caption),
                                ]),
                              ),
                              const Icon(Icons.chevron_left, color: AppColors.gray300, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _segTab(String label, String value, int count) {
    final isActive = _segment == value;
    return GestureDetector(
      onTap: () => setState(() { _segment = value; _statusFilter = 'all'; }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: isActive ? AppColors.primary : Colors.white70)),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primaryLight : Colors.white24,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text('$count', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? AppColors.primary : Colors.white70)),
          ),
        ]),
      ),
    );
  }
}
