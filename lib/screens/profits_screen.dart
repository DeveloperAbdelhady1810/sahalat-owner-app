// ============================================================
// سهلات المالك – شاشة الأرباح (Flutter)
// Mirrors: ProfitsScreen.tsx
// ============================================================

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sahalat_owner/main.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../models/models.dart';
import '../services/mock_api_service.dart';
import '../widgets/common_widgets.dart';

class ProfitsScreen extends StatefulWidget {
  const ProfitsScreen({super.key});

  @override
  State<ProfitsScreen> createState() => _ProfitsScreenState();
}

class _ProfitsScreenState extends State<ProfitsScreen> {
  final _searchController = TextEditingController();
  List<OrderEntity> _orders = [];
  List<OrderEntity> _filtered = [];
  bool _loading = true;
  String _statusFilter = 'all';
  bool _showFilters = false;

  static const _baseLabels = {
    CommissionBase.orderTotal: 'إجمالي الطلب',
    CommissionBase.orderSubtotal: 'المجموع الفرعي',
    CommissionBase.deliveryFee: 'رسوم التوصيل',
    CommissionBase.serviceFee: 'رسوم الخدمة',
  };

  String _statusFilterLabel(String s) {
    switch (s) {
      case 'all': return ArStrings.all;
      case 'delivered': return ArStrings.statusDelivered;
      case 'cancelled': return ArStrings.statusCancelled;
      case 'refunded': return ArStrings.statusRefunded;
      default: return s;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _searchController.addListener(_filter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    // final orders = await MockApiService.instance.getOrders();
    final orders = prefs!.getString("orders") != null?
      json.decode(prefs!.getString('orders') ?? '[]')
      : [];
    List<OrderEntity> allOrders = [];
    for (Map order in orders) {
      // 


      // print(DateFormat('yyyy-MM-dd HH:mm:ss').parse(order['created_at'], true).toLocal());
      // Parse UTC timestamp and convert to local time
      final utcDateTime = DateTime.parse(order['created_at']);
      final localDateTime = utcDateTime.toLocal();
      final localDate = DateFormat('yyyy-MM-dd').format(localDateTime);
      final localTime = DateFormat('HH:mm:ss').format(localDateTime);
      
      allOrders.add(
        OrderEntity(
        id: "SAH-${order['id'].toString()}",
        date: localDate,
        time: localTime,
        store: order['seller']!=null?(id:order['seller']['id'].toString(),name:order['seller']['name']??''):(id: '', name: 'طلب نقل'),
        driver: (id:order['delivery']['id'].toString() ,name:order['delivery']['name']),
        user: (id:order['user']['id'].toString(),name:order['user']['name']),
        subtotal: (double.tryParse((order['total'].toString()).toString()) ?? 0.0),
        deliveryFee: (double.tryParse((order['deliveryTotal']??"0").toString()) ?? 0.0),
        serviceFee: (double.tryParse((order['total'].toString()).toString()) ?? 0.0)*0.05,
        discount: order['discount']??0,
        tax: (double.tryParse((order['total'].toString()).toString()) ?? 0.0)*0.14,
        total: (double.tryParse((order['total'].toString()).toString()) ?? 0.0),
        commissionBase: CommissionBase.orderTotal,
        commissionRule: 'fixed',
        commissionRate: 0.05,
        ownerProfit: (double.tryParse((order['total'].toString()).toString()) ?? 0.0)*0.05,
        status: OrderStatus.confirmed,
        paymentMethod: order['payment_method']??'Paymob',
        city: order['city']??''
      )
      );
    }
    // final List<OrderEntity> allOrders = orders.map((order){
    //   return OrderEntity(
    //     id: order['id'].toString(),
    //     date: order['created_at'],
    //     time: order['created_at'],
    //     store: order['seller']!=null?(id:order['seller']['id'].toString(),name:order['seller']['name']??''):(id: '', name: ''),
    //     driver: (id:order['delivery']['id'].toString() ,name:order['delivery']['name']),
    //     user: (id:order['user']['id'].toString(),name:order['user']['name']),
    //     subtotal: double.parse(order['total'].toString()),
    //     deliveryFee: double.parse(order['deliveryTotal']??"0"),
    //     serviceFee: double.parse(order['total'].toString())*0.05,
    //     discount: order['discount']??0,
    //     tax: double.parse(order['total'].toString())*0.14,
    //     total: double.parse(order['total'].toString()),
    //     commissionBase: CommissionBase.orderTotal,
    //     commissionRule: 'fixed',
    //     commissionRate: 0.05,
    //     ownerProfit: double.parse(order['total'].toString())*0.05,
    //     status: OrderStatus.confirmed,
    //     paymentMethod: order['payment_method']??'Paymob',
    //     city: order['city']??''
    //   );
    // }).toList();
    // print(allOrders);
    if (mounted) setState(() { _orders = allOrders; _filtered = allOrders; _loading = false; });
  }

  void _filter() {
    final q = _searchController.text.toLowerCase();
    setState(() {
      _filtered = _orders.where((o) {
        final matchSearch = q.isEmpty || o.id.toLowerCase().contains(q) || o.store.name.toLowerCase().contains(q) || o.driver.name.toLowerCase().contains(q);
        final matchStatus = _statusFilter == 'all' || o.status.name == _statusFilter;
        return matchSearch && matchStatus;
      }).toList();
    });
  }

  double get _totalProfit => _filtered.where((o) => o.status == OrderStatus.delivered).fold(0, (s, o) => s + o.ownerProfit);

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
                Row(
                  children: [
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(ArStrings.profits, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                        Text(ArStrings.ownerRevenueCenter, style: TextStyle(fontSize: 12, color: Colors.white60)),
                      ]),
                    ),
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: const Icon(Icons.download_outlined, color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Summary strip
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                _summaryChip(ArStrings.totalProfit, '${ArStrings.sar_symbol} ${_totalProfit.toStringAsFixed(2)}', AppColors.primary, AppColors.primaryLight),
                const SizedBox(width: 8),
                _summaryChip(ArStrings.delivered, '${_filtered.where((o) => o.status == OrderStatus.delivered).length}', AppColors.success, AppColors.successLight),
                const SizedBox(width: 8),
                _summaryChip(ArStrings.refunded, '${_filtered.where((o) => o.status == OrderStatus.refunded).length}', AppColors.danger, AppColors.dangerLight),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Expanded(child: AppSearchBar(controller: _searchController, placeholder: 'رقم الطلب، المتجر، السائق...', onChanged: (_) => _filter())),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => setState(() => _showFilters = !_showFilters),
                  child: Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _showFilters ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: _showFilters ? AppColors.primary : AppColors.border),
                    ),
                    child: Icon(Icons.filter_list, size: 16, color: _showFilters ? Colors.white : AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          if (_showFilters)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['all', 'delivered', 'cancelled', 'refunded'].map((s) =>
                    GestureDetector(
                      onTap: () { setState(() => _statusFilter = s); _filter(); },
                      child: Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _statusFilter == s ? AppColors.primary : AppColors.gray100,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(_statusFilterLabel(s),
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusFilter == s ? Colors.white : AppColors.textSecondary)),
                      ),
                    )
                  ).toList(),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // Orders list
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                ? const EmptyStateWidget(icon: Icons.trending_up, title: ArStrings.noTransactions, description: 'حاول تعديل الفلاتر')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final order = _filtered[i];
                      return GestureDetector(
                        onTap: () => context.go('/profits/${order.id}'),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadius.xl),
                            boxShadow: AppShadows.card,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Row(children: [
                                        Text(order.id, style: AppTypography.subheading.copyWith(fontSize: 13)),
                                        const SizedBox(width: 8),
                                        StatusBadgeWidget(status: order.status.name),
                                      ]),
                                      Text('${order.date} · ${order.time}', style: AppTypography.caption),
                                    ]),
                                  ),
                                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Text('+${ArStrings.sar_symbol} ${order.ownerProfit.toStringAsFixed(2)}',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                                    const Text(ArStrings.ownerProfitLabel, style: AppTypography.micro),
                                  ]),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Divider(color: AppColors.gray100, height: 1),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(child: _orderMeta(ArStrings.store, order.store.name)),
                                  Expanded(child: _orderMeta(ArStrings.driver, order.driver.name.split(' ').first)),
                                  Expanded(child: _orderMeta(ArStrings.base, _baseLabels[order.commissionBase] ?? '')),
                                  Expanded(child: _orderMeta(ArStrings.rate, '${order.commissionRate}%')),
                                ],
                              ),
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

  Widget _summaryChip(String label, String value, Color color, Color bg) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(AppRadius.xl)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        ]),
      ),
    );
  }

  Widget _orderMeta(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: AppTypography.micro),
      Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
    ],
  );
}
