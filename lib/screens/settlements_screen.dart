// Mirrors: SettlementsScreen.tsx
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../models/models.dart';
import '../services/mock_api_service.dart';
import '../widgets/common_widgets.dart';

class SettlementsScreen extends StatefulWidget {
  const SettlementsScreen({super.key});
  @override
  State<SettlementsScreen> createState() => _SettlementsScreenState();
}

class _SettlementsScreenState extends State<SettlementsScreen> {
  String _segment = 'stores';
  List<Store> _stores = [];
  List<Driver> _drivers = [];
  List<AppUser> _users = [];
  bool _loading = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final s = await MockApiService.instance.getStores();
    final d = await MockApiService.instance.getDrivers();
    final u = await MockApiService.instance.getUsers();
    if (mounted) setState(() { _stores = s; _drivers = d; _users = u; _loading = false; });
  }

  List<dynamic> get _current => _segment == 'stores' ? _stores : _segment == 'drivers' ? _drivers : _users;

  String _segLabel(String s) {
    switch (s) {
      case 'stores': return ArStrings.stores;
      case 'drivers': return ArStrings.drivers;
      default: return ArStrings.users;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(gradient: AppGradients.primary),
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ArStrings.settlements, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                Text(ArStrings.balanceManagement, style: const TextStyle(fontSize: 12, color: Colors.white60)),
                const SizedBox(height: 12),
                // Segmented
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: Row(
                    children: ['stores', 'drivers', 'users'].map((s) {
                      final active = _segment == s;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _segment = s),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            alignment: Alignment.center,
                            child: Text(_segLabel(s),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? AppColors.primary : Colors.white.withOpacity(0.7))),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Summary
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _chip(ArStrings.totalPayable, '${ArStrings.sar_symbol} ${_current.fold(0.0, (s, e) => s + (e.netPayable as double)).toStringAsFixed(0)}K', AppColors.danger, AppColors.dangerLight),
                const SizedBox(width: 8),
                _chip(ArStrings.pending, '${_current.where((e) => (e.netPayable as double) > 0).length}', AppColors.warning, AppColors.warningLight),
                const SizedBox(width: 8),
                _chip(ArStrings.issues, '${_current.where((e) => e.hasMismatch as bool).length}', AppColors.info, AppColors.infoLight),
              ],
            ),
          ),

          // List
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _current.length,
                  itemBuilder: (ctx, i) {
                    final e = _current[i];
                    final hasMismatch = e.hasMismatch as bool;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.xl),
                        boxShadow: AppShadows.card,
                      ),
                      child: Column(
                        children: [
                          if (hasMismatch)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: const BoxDecoration(
                                color: AppColors.dangerLight,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
                              ),
                              child: Row(children: [
                                const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.danger),
                                const SizedBox(width: 6),
                                Text(ArStrings.balanceMismatch, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.danger)),
                              ]),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(e.name as String, style: AppTypography.subheading),
                                      Text('${e.id} · ${e.city}', style: AppTypography.caption),
                                    ]),
                                  ),
                                  StatusBadgeWidget(status: (e.status as AccountStatus).name),
                                ]),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _balanceChip(ArStrings.netPayable, '${ArStrings.sar_symbol} ${(e.netPayable as double).toStringAsFixed(2)}', AppColors.success, AppColors.successLight),
                                    const SizedBox(width: 8),
                                    _balanceChip(ArStrings.commission, '${ArStrings.sar_symbol} ${(e.totalCommission as double).toStringAsFixed(0)}', AppColors.danger, AppColors.dangerLight),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => context.go('/settlements/$_segment/${e.id}'),
                                        style: OutlinedButton.styleFrom(
                                          side: const BorderSide(color: AppColors.border),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                                        ),
                                        child: Text(ArStrings.viewDetails, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: (e.netPayable as double) > 0 ? () {} : null,
                                        icon: const Icon(Icons.swap_horiz, size: 14),
                                        label: Text(ArStrings.transfer, style: const TextStyle(fontSize: 12)),
                                        style: ElevatedButton.styleFrom(
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value, Color color, Color bg) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.xl)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ]),
    ),
  );

  Widget _balanceChip(String label, String value, Color color, Color bg) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
      ]),
    ),
  );
}
