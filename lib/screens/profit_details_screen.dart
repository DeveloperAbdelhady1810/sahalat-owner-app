// Mirrors: ProfitDetailsScreen.tsx
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../models/models.dart';
import '../services/mock_api_service.dart';
import '../widgets/common_widgets.dart';

class ProfitDetailsScreen extends StatefulWidget {
  final String orderId;
  const ProfitDetailsScreen({super.key, required this.orderId});

  @override
  State<ProfitDetailsScreen> createState() => _ProfitDetailsScreenState();
}

class _ProfitDetailsScreenState extends State<ProfitDetailsScreen> {
  OrderEntity? _order;

  @override
  void initState() {
    super.initState();
    // MockApiService.instance.getOrder(widget.orderId).then((o) { if (mounted) setState(() => _order = o); });
    loadOrder();
  }

  Future<void> loadOrder() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final orders = prefs!.getString("orders") != null?
      json.decode(prefs!.getString('orders')!)
      : [];
    for (Map order in orders) {
      if (order['id'].toString() == widget.orderId.split('-')[1]) {
        final utcDateTime = DateTime.parse(order['created_at']);
        final localDateTime = utcDateTime.toLocal();
        final localDate = DateFormat('yyyy-MM-dd').format(localDateTime);
        final localTime = DateFormat('HH:mm:ss').format(localDateTime);
        
        setState(() {
          _order = OrderEntity(
            id: widget.orderId,
            date: localDate,
            time: localTime,
            store: order['seller']!=null?(id:order['seller']['id'].toString(),name:order['seller']['name']??''):(id: '', name: 'طلب نقل'),
            driver: (id:order['delivery']['id'].toString() ,name:order['delivery']['name']),
            user: (id:order['user']['id'].toString(),name:order['user']['name']),
            subtotal: double.parse(order['total'].toString()),
            deliveryFee: double.parse(order['deliveryTotal']??"0"),
            serviceFee: double.parse(order['total'].toString())*0.05,
            discount: order['discount']??0,
            tax: double.parse(order['total'].toString())*0.14,
            total: double.parse(order['total'].toString()),
            commissionBase: CommissionBase.orderTotal,
            commissionRule: 'fixed',
            commissionRate: 0.05,
            ownerProfit: double.parse(order['total'].toString())*0.05,
            status: OrderStatus.confirmed,
            paymentMethod: order['payment_method']??'Paymob',
            city: order['city']??''
          );
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: widget.orderId,
        subtitle: _order != null ? '${_order!.date} · ${_order!.time}' : '',
        showBack: true,
      ),
      body: _order == null
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // Status card
              _card(child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('طريقة الدفع', style: AppTypography.label),
                  Text(_order!.paymentMethod, style: AppTypography.subheading),
                ])),
                StatusBadgeWidget(status: _order!.status.name),
              ])),
              const SizedBox(height: AppSpacing.md),

              // Financial breakdown
              _card(
                title: ArStrings.profitBreakdown,
                child: Column(children: [
                  _row('المجموع الفرعي', '${ArStrings.sar_symbol} ${_order!.subtotal.toStringAsFixed(2)}'),
                  _row('رسوم التوصيل', '${ArStrings.sar_symbol} ${_order!.deliveryFee.toStringAsFixed(2)}'),
                  _row('رسوم الخدمة', '${ArStrings.sar_symbol} ${_order!.serviceFee.toStringAsFixed(2)}'),
                  if (_order!.discount > 0) _row('الخصم', '-${ArStrings.sar_symbol} ${_order!.discount.toStringAsFixed(2)}', color: AppColors.danger),
                  if (_order!.tax > 0) _row('الضريبة', '${ArStrings.sar_symbol} ${_order!.tax.toStringAsFixed(2)}'),
                  const Divider(height: 24),
                  _row('إجمالي الطلب', '${ArStrings.sar_symbol} ${_order!.total.toStringAsFixed(2)}', bold: true),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(AppRadius.md)),
                    child: Row(children: [
                      Expanded(child: Text(ArStrings.ownerProfitLabel, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.success))),
                      Text('${ArStrings.sar_symbol} ${_order!.ownerProfit.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.success)),
                    ]),
                  ),
                ]),
              ),
              const SizedBox(height: AppSpacing.md),

              // Commission rule
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('قاعدة العمولة المطبّقة', style: AppTypography.label.copyWith(color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text(_order!.commissionRule, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
                  Text('${ArStrings.rate}: ${_order!.commissionRate}%', style: TextStyle(fontSize: 12, color: AppColors.secondary)),
                ]),
              ),
            ],
          ),
    );
  }

  Widget _card({String? title, required Widget child}) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.xl), boxShadow: AppShadows.card),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[Text(title, style: AppTypography.label), const SizedBox(height: 12)],
        child,
      ],
    ),
  );

  Widget _row(String label, String value, {bool bold = false, Color? color}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Expanded(child: Text(label, style: TextStyle(fontSize: 13, fontWeight: bold ? FontWeight.w700 : FontWeight.w400, color: AppColors.textSecondary))),
      Text(value, style: TextStyle(fontSize: bold ? 14 : 13, fontWeight: bold ? FontWeight.w800 : FontWeight.w500, color: color ?? AppColors.textPrimary)),
    ]),
  );
}
