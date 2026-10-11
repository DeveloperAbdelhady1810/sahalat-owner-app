// ============================================================
// سهلات المالك – خدمة API وهمية (Flutter)
// يعكس: /src/app/mockData.ts
// استبدل باستدعاءات API حقيقية في الإنتاج.
// ============================================================

import 'dart:async';
import '../models/models.dart';

class MockApiService {
  MockApiService._();
  static final MockApiService instance = MockApiService._();

  // ─── تأخير الشبكة المحاكَى ─────────────────────────────
  Future<T> _delay<T>(T data, {int ms = 400}) async {
    await Future.delayed(Duration(milliseconds: ms));
    return data;
  }

  // ─── المصادقة ──────────────────────────────────────────
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 900));
    return {
      'success': true,
      'user': {
        'name': 'عبدالله الراشد',
        'email': email,
        'role': 'owner',
      },
    };
  }

  // ─── مؤشرات لوحة التحكم ────────────────────────────────
  Future<Map<String, dynamic>> getDashboardKPIs() => _delay({
    'profitToday': 156.30,
    'profitWeek': 2244.55,
    'profitMonth': 8975.20,
    'pendingSettlementsTotal': 12800.25,
    'completedSettlementsTotal': 47350.00,
    'totalOrdersToday': 31,
    'totalOrdersMonth': 1240,
    'refundsCount': 12,
    'refundsAmount': 345.80,
    'pendingAccountsCount': 4,
    'settlementIssues': 2,
    'negativeBalances': 1,
  });

  // ─── اتجاه الأرباح ─────────────────────────────────────
  Future<List<Map<String, dynamic>>> getProfitTrend() => _delay([
    {'day': 'الإثنين', 'profit': 245.50, 'orders': 48},
    {'day': 'الثلاثاء', 'profit': 312.75, 'orders': 62},
    {'day': 'الأربعاء', 'profit': 198.20, 'orders': 39},
    {'day': 'الخميس', 'profit': 425.80, 'orders': 85},
    {'day': 'الجمعة', 'profit': 518.40, 'orders': 103},
    {'day': 'السبت', 'profit': 387.60, 'orders': 77},
    {'day': 'الأحد', 'profit': 156.30, 'orders': 31},
  ]);

  // ─── المتاجر ────────────────────────────────────────────
  Future<List<Store>> getStores({String? search, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var stores = _mockStores;
    if (search != null && search.isNotEmpty) {
      stores = stores.where((s) =>
        s.name.toLowerCase().contains(search.toLowerCase()) ||
        s.id.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    if (status != null && status != 'all') {
      stores = stores.where((s) => s.status.name == status).toList();
    }
    return stores;
  }

  Future<Store?> getStore(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockStores.firstWhere((s) => s.id == id);
  }

  // ─── السائقون ───────────────────────────────────────────
  Future<List<Driver>> getDrivers({String? search, String? status}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var drivers = _mockDrivers;
    if (search != null && search.isNotEmpty) {
      drivers = drivers.where((d) =>
        d.name.toLowerCase().contains(search.toLowerCase()) ||
        d.id.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    return drivers;
  }

  // ─── المستخدمون ─────────────────────────────────────────
  Future<List<AppUser>> getUsers({String? search}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var users = _mockUsers;
    if (search != null && search.isNotEmpty) {
      users = users.where((u) =>
        u.name.toLowerCase().contains(search.toLowerCase()) ||
        u.id.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    return users;
  }

  // ─── الطلبات / الأرباح ─────────────────────────────────
  Future<List<OrderEntity>> getOrders({String? search, String? status, String? paymentMethod}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockOrders;
  }

  Future<OrderEntity?> getOrder(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockOrders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }

  // ─── قواعد العمولة ─────────────────────────────────────
  Future<List<CommissionRule>> getCommissionRules() => _delay(_mockRules);

  Future<bool> createCommissionRule(CommissionRule rule) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return true;
  }

  Future<bool> updateCommissionRule(CommissionRule rule) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  // ─── التسويات ───────────────────────────────────────────
  Future<List<Settlement>> getSettlements({String? entityId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (entityId != null) {
      return _mockSettlements.where((s) => s.entityId == entityId).toList();
    }
    return _mockSettlements;
  }

  Future<bool> initiateTransfer({
    required String entityId,
    required double amount,
    required String method,
    required String referenceId,
    required String notes,
    required bool closeAndReset,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }

  // ─── سجلات المراجعة ────────────────────────────────────
  Future<List<AuditLog>> getAuditLogs({String? search, String? severity}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockAuditLogs;
  }

  // ─── النزاعات ───────────────────────────────────────────
  Future<List<Dispute>> getDisputes({DisputeStatus? status}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (status != null) {
      return _mockDisputes.where((d) => d.status == status).toList();
    }
    return _mockDisputes;
  }

  Future<bool> resolveDispute(String disputeId, String notes) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // ─── مشرفو IT ──────────────────────────────────────────
  Future<List<ITAdmin>> getITAdmins({String? search}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var admins = _mockITAdmins;
    if (search != null && search.isNotEmpty) {
      admins = admins.where((a) =>
        a.name.toLowerCase().contains(search.toLowerCase()) ||
        a.id.toLowerCase().contains(search.toLowerCase())
      ).toList();
    }
    return admins;
  }

  Future<ITAdmin?> getITAdmin(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockITAdmins.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<bool> updateAccountStatus(String accountId, String accountType, AccountStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }

  // ─── البيانات الوهمية ───────────────────────────────────
  static final List<Store> _mockStores = [
    Store(id: 'ST001', name: 'مطعم البيك', phone: '+966501234567', email: 'albaik@example.sa', city: 'الرياض', status: AccountStatus.activated, joinedAt: '2023-06-15', ordersCount: 1240, totalSales: 62000, totalCommission: 3100, totalRefunds: 450, totalPayouts: 2200, currentBalance: 2847.50, ownerRetained: 3100, netPayable: 2847.50, hasMismatch: false, rating: 4.8, category: 'وجبات سريعة', commissionRate: 5),
    Store(id: 'ST002', name: 'حلويات الرياض', phone: '+966502345678', email: 'rsweets@example.sa', city: 'الرياض', status: AccountStatus.activated, joinedAt: '2023-08-20', ordersCount: 876, totalSales: 43800, totalCommission: 2190, totalRefunds: 200, totalPayouts: 1500, currentBalance: 1235.00, ownerRetained: 2190, netPayable: 1235.00, hasMismatch: false, rating: 4.6, category: 'حلويات', commissionRate: 5),
    Store(id: 'ST003', name: 'بيت المشويات جدة', phone: '+966503456789', email: 'jgrill@example.sa', city: 'جدة', status: AccountStatus.activated, joinedAt: '2023-07-10', ordersCount: 654, totalSales: 32700, totalCommission: 1635, totalRefunds: 120, totalPayouts: 900, currentBalance: 980.75, ownerRetained: 1635, netPayable: 980.75, hasMismatch: true, rating: 4.3, category: 'مشويات', commissionRate: 5),
    Store(id: 'ST004', name: 'مطبخ التوابل الدمام', phone: '+966504567890', email: 'dspice@example.sa', city: 'الدمام', status: AccountStatus.pending, joinedAt: '2024-01-05', ordersCount: 0, totalSales: 0, totalCommission: 0, totalRefunds: 0, totalPayouts: 0, currentBalance: 0, ownerRetained: 0, netPayable: 0, hasMismatch: false, rating: 0, category: 'هندي', commissionRate: 5),
    Store(id: 'ST008', name: 'مأكولات بحرية الخبر', phone: '+966508901234', email: 'kseafood@example.sa', city: 'الخبر', status: AccountStatus.activated, joinedAt: '2024-01-20', ordersCount: 95, totalSales: 14250, totalCommission: 712.50, totalRefunds: 100, totalPayouts: 400, currentBalance: 420.00, ownerRetained: 712.50, netPayable: 420.00, hasMismatch: true, rating: 4.4, category: 'مأكولات بحرية', commissionRate: 6),
  ];

  static final List<Driver> _mockDrivers = [
    Driver(id: 'DR001', name: 'أحمد الراشدي', phone: '+966511234567', email: 'ahmed.r@example.sa', city: 'الرياض', status: AccountStatus.activated, joinedAt: '2023-07-01', ordersCount: 892, totalDeliveries: 892, totalEarnings: 13380, totalCommission: 669, totalPayouts: 500, currentBalance: 856.75, netPayable: 856.75, hasMismatch: false, vehicle: 'دراجة نارية', commissionRate: 5),
    Driver(id: 'DR002', name: 'خالد العتيبي', phone: '+966512345678', email: 'khalid.o@example.sa', city: 'الرياض', status: AccountStatus.activated, joinedAt: '2023-08-15', ordersCount: 654, totalDeliveries: 654, totalEarnings: 9810, totalCommission: 490.50, totalPayouts: 350, currentBalance: 612.50, netPayable: 612.50, hasMismatch: false, vehicle: 'سيارة', commissionRate: 5),
    Driver(id: 'DR003', name: 'عمر الزهراني', phone: '+966513456789', email: 'omar.z@example.sa', city: 'جدة', status: AccountStatus.activated, joinedAt: '2023-09-20', ordersCount: 421, totalDeliveries: 421, totalEarnings: 6315, totalCommission: 315.75, totalPayouts: 200, currentBalance: 398.25, netPayable: 398.25, hasMismatch: true, vehicle: 'دراجة نارية', commissionRate: 5),
    Driver(id: 'DR004', name: 'فيصل الغامدي', phone: '+966514567890', email: 'faisal.g@example.sa', city: 'الدمام', status: AccountStatus.pending, joinedAt: '2024-01-15', ordersCount: 0, totalDeliveries: 0, totalEarnings: 0, totalCommission: 0, totalPayouts: 0, currentBalance: 0, netPayable: 0, hasMismatch: false, vehicle: 'سيارة', commissionRate: 5),
  ];

  static final List<AppUser> _mockUsers = [
    AppUser(id: 'US001', name: 'محمد الفيصل', phone: '+966521234567', email: 'mfaisal@example.sa', city: 'الرياض', status: AccountStatus.activated, joinedAt: '2023-05-10', ordersCount: 87, totalSpent: 4350, totalCommission: 217.50, totalRefunds: 50, totalPayouts: 0, currentBalance: 217.50, netPayable: 217.50, hasMismatch: false, commissionRate: 5),
    AppUser(id: 'US002', name: 'سارة المطيري', phone: '+966522345678', email: 'sara.m@example.sa', city: 'جدة', status: AccountStatus.activated, joinedAt: '2023-07-22', ordersCount: 65, totalSpent: 3250, totalCommission: 162.50, totalRefunds: 30, totalPayouts: 0, currentBalance: 162.50, netPayable: 162.50, hasMismatch: false, commissionRate: 5),
    AppUser(id: 'US003', name: 'عبدالله القحطاني', phone: '+966523456789', email: 'aqa@example.sa', city: 'الرياض', status: AccountStatus.activated, joinedAt: '2023-08-30', ordersCount: 43, totalSpent: 2150, totalCommission: 107.50, totalRefunds: 0, totalPayouts: 0, currentBalance: 107.50, netPayable: 107.50, hasMismatch: false, commissionRate: 5),
  ];

  static final List<OrderEntity> _mockOrders = [
    OrderEntity(id: 'ORD-2024-001', date: '2024-02-23', time: '09:15', store: (id: 'ST001', name: 'مطعم البيك'), driver: (id: 'DR001', name: 'أحمد الراشدي'), user: (id: 'US001', name: 'محمد الفيصل'), subtotal: 85, deliveryFee: 15, serviceFee: 5, discount: 0, tax: 4.25, total: 109.25, commissionBase: CommissionBase.orderTotal, commissionRule: 'القاعدة العامة', commissionRate: 5, ownerProfit: 5.46, status: OrderStatus.delivered, paymentMethod: 'Card', city: 'الرياض'),
    OrderEntity(id: 'ORD-2024-002', date: '2024-02-23', time: '10:30', store: (id: 'ST002', name: 'حلويات الرياض'), driver: (id: 'DR002', name: 'خالد العتيبي'), user: (id: 'US002', name: 'سارة المطيري'), subtotal: 120, deliveryFee: 15, serviceFee: 5, discount: 10, tax: 0, total: 130, commissionBase: CommissionBase.orderSubtotal, commissionRule: 'القاعدة العامة', commissionRate: 5, ownerProfit: 6.0, status: OrderStatus.delivered, paymentMethod: 'Cash', city: 'الرياض'),
    OrderEntity(id: 'ORD-2024-007', date: '2024-02-21', time: '13:10', store: (id: 'ST002', name: 'حلويات الرياض'), driver: (id: 'DR001', name: 'أحمد الراشدي'), user: (id: 'US003', name: 'عبدالله القحطاني'), subtotal: 75, deliveryFee: 15, serviceFee: 5, discount: 0, tax: 3.75, total: 98.75, commissionBase: CommissionBase.orderTotal, commissionRule: 'القاعدة العامة', commissionRate: 5, ownerProfit: 4.94, status: OrderStatus.refunded, paymentMethod: 'Card', city: 'الرياض'),
  ];

  static final List<CommissionRule> _mockRules = [
    CommissionRule(id: 'CR001', name: 'القاعدة العامة', scope: RuleScope.global, appliesTo: 'جميع الحسابات', commissionRate: 5, commissionBase: CommissionBase.orderTotal, effectiveDate: '2023-01-01', enabled: true, priority: 1, createdAt: '2023-01-01', createdBy: 'المالك', note: 'عمولة عامة افتراضية على جميع الطلبات', history: [RuleHistoryEntry(date: '2023-06-01', actor: 'المالك', oldRate: 4, newRate: 5, reason: 'تعديل سنوي للمعدل')]),
    CommissionRule(id: 'CR002', name: 'قاعدة نوع المتاجر', scope: RuleScope.typeStores, appliesTo: 'جميع المتاجر', commissionRate: 5, commissionBase: CommissionBase.orderTotal, effectiveDate: '2023-03-01', enabled: true, priority: 2, createdAt: '2023-03-01', createdBy: 'المالك', note: 'المعدل القياسي لجميع المتاجر', history: []),
    CommissionRule(id: 'CR004', name: 'قاعدة المتجر ST008', scope: RuleScope.accountSpecific, appliesTo: 'مأكولات بحرية الخبر (ST008)', commissionRate: 6, commissionBase: CommissionBase.orderTotal, effectiveDate: '2024-01-20', enabled: true, priority: 3, createdAt: '2024-01-20', createdBy: 'المالك', note: 'مطعم بحري مميز – هامش أعلى', history: [RuleHistoryEntry(date: '2024-01-20', actor: 'المالك', oldRate: 5, newRate: 6, reason: 'معدل مميز تم التفاوض عليه')]),
  ];

  static final List<Settlement> _mockSettlements = [
    Settlement(id: 'SET001', date: '2024-02-15', entityType: 'store', entityId: 'ST001', entityName: 'مطعم البيك', amount: 2000, method: 'تحويل بنكي', referenceId: 'TXN-BNK-001', notes: 'تسوية شهرية فبراير – الأسبوع الأول', status: 'completed', period: 'فبراير 1–15، 2024'),
    Settlement(id: 'SET002', date: '2024-02-10', entityType: 'driver', entityId: 'DR001', entityName: 'أحمد الراشدي', amount: 500, method: 'محفظة إلكترونية', referenceId: 'TXN-WLT-001', notes: 'مدفوعات السائق الأسبوعية', status: 'completed', period: 'فبراير 4–10، 2024'),
    Settlement(id: 'SET005', date: '2024-01-31', entityType: 'store', entityId: 'ST003', entityName: 'بيت المشويات جدة', amount: 900, method: 'تحويل بنكي', referenceId: 'TXN-BNK-003', notes: 'تسوية يناير 2024', status: 'failed', period: 'يناير 2024'),
  ];

  static final List<AuditLog> _mockAuditLogs = [
    AuditLog(id: 'AL001', date: '2024-02-23', time: '09:42', actor: 'المالك', actorRole: 'المالك', action: 'تحديث قاعدة عمولة', target: 'القاعدة العامة', targetType: 'commission_rule', before: '4%', after: '5%', notes: 'زيادة سنوية في المعدل', severity: 'warning'),
    AuditLog(id: 'AL002', date: '2024-02-23', time: '09:15', actor: 'المالك', actorRole: 'المالك', action: 'بدء تسوية', target: 'مطعم البيك (ST001)', targetType: 'settlement', before: 'معلق', after: 'مسوّى بـ 2,000 ريال', notes: 'مدفوعات فبراير الأسبوع الأول', severity: 'info'),
    AuditLog(id: 'AL007', date: '2024-02-20', time: '18:45', actor: 'المالك', actorRole: 'المالك', action: 'فشل التسوية', target: 'بيت المشويات جدة (ST003)', targetType: 'settlement', before: 'تم البدء', after: 'فاشل – خطأ بنكي', severity: 'critical'),
    AuditLog(id: 'AL008', date: '2024-02-20', time: '09:00', actor: 'المالك', actorRole: 'المالك', action: 'حذف حساب', target: 'حساب تجريبي (US099)', targetType: 'account', before: 'معطّل', after: 'محذوف (ناعم)', notes: 'تنظيف الحسابات التجريبية', severity: 'critical'),
  ];

  static final List<Dispute> _mockDisputes = [
    Dispute(id: 'DSP001', date: '2024-02-23', entityType: 'store', entityId: 'ST003', entityName: 'بيت المشويات جدة', type: 'عدم تطابق في التسوية', description: 'يُفيد المتجر بأن إجمالي المبلغ المستحق لا يتطابق مع حساب النظام. تم اكتشاف فارق بمقدار 127.50 ريال.', status: DisputeStatus.open, severity: 'high', amount: 127.50),
    Dispute(id: 'DSP002', date: '2024-02-22', entityType: 'driver', entityId: 'DR003', entityName: 'عمر الزهراني', type: 'تناقض في الرصيد', description: 'يُظهر رصيد السائق قيمة سالبة بعد عكس الطلب الملغى. يحتاج إلى إعادة الحساب.', status: DisputeStatus.investigating, severity: 'medium', amount: 45.25),
    Dispute(id: 'DSP004', date: '2024-02-18', entityType: 'store', entityId: 'ST001', entityName: 'مطعم البيك', type: 'طلبات مفقودة', description: '3 طلبات من 14 فبراير لم تنعكس في حساب التسوية. احتمال وجود مشكلة في المزامنة.', status: DisputeStatus.resolved, severity: 'medium', amount: 32.50, resolvedAt: '2024-02-20', notes: 'تم العثور على الطلبات وإعادة مزامنتها. تمت إعادة حساب التسوية بشكل صحيح.'),
  ];

  static final List<ITAdmin> _mockITAdmins = [
    ITAdmin(id: 'IT001', name: 'بلال الخوري', phone: '+966531234567', email: 'bilal@sahalat.sa', status: AccountStatus.activated, joinedAt: '2023-01-10', lastLogin: '2024-02-23', permissions: ['manage_accounts', 'view_profits', 'export_reports', 'view_audit_logs'], deviceCount: 2, twoFactorEnabled: true),
    ITAdmin(id: 'IT002', name: 'رانيا المنصوري', phone: '+966532345678', email: 'rania@sahalat.sa', status: AccountStatus.activated, joinedAt: '2023-03-15', lastLogin: '2024-02-22', permissions: ['manage_accounts', 'view_profits', 'export_reports'], deviceCount: 1, twoFactorEnabled: true),
    ITAdmin(id: 'IT003', name: 'ياسر الحربي', phone: '+966533456789', email: 'yasser@sahalat.sa', status: AccountStatus.deactivated, joinedAt: '2022-11-20', lastLogin: '2024-01-15', permissions: ['manage_accounts', 'view_profits'], deviceCount: 0, twoFactorEnabled: false),
    ITAdmin(id: 'IT004', name: 'حصة المطيري', phone: '+966534567890', email: 'hessa@sahalat.sa', status: AccountStatus.pending, joinedAt: '2024-02-20', lastLogin: 'لم يسجل دخولاً بعد', permissions: [], deviceCount: 0, twoFactorEnabled: false),
  ];
}
