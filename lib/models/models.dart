// ============================================================
// Sahalat Owner – Data Models (Flutter/Dart)
// Mirrors: /src/app/mockData.ts types
// ============================================================

// ─── Enums ─────────────────────────────────────────────────
enum AccountStatus { created, pending, activated, deactivated, deleted }

enum OrderStatus { pending, confirmed, inProgress, delivered, cancelled, refunded }

enum SettlementStatus { pending, partiallySettled, settled, failed }

enum DisputeStatus { open, investigating, resolved }

enum CommissionBase { orderTotal, orderSubtotal, deliveryFee, serviceFee }

enum RuleScope { global, typeStores, typeDrivers, typeUsers, accountSpecific }

// ─── Models ────────────────────────────────────────────────
class Store {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String city;
  final AccountStatus status;
  final String joinedAt;
  final int ordersCount;
  final double totalSales;
  final double totalCommission;
  final double totalRefunds;
  final double totalPayouts;
  final double currentBalance;
  final double ownerRetained;
  final double netPayable;
  final bool hasMismatch;
  final double rating;
  final String category;
  final double commissionRate;

  const Store({
    required this.id, required this.name, required this.phone,
    required this.email, required this.city, required this.status,
    required this.joinedAt, required this.ordersCount, required this.totalSales,
    required this.totalCommission, required this.totalRefunds, required this.totalPayouts,
    required this.currentBalance, required this.ownerRetained, required this.netPayable,
    required this.hasMismatch, required this.rating, required this.category,
    required this.commissionRate,
  });
}

class Driver {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String city;
  final AccountStatus status;
  final String joinedAt;
  final int ordersCount;
  final int totalDeliveries;
  final double totalEarnings;
  final double totalCommission;
  final double totalPayouts;
  final double currentBalance;
  final double netPayable;
  final bool hasMismatch;
  final String vehicle;
  final double commissionRate;

  const Driver({
    required this.id, required this.name, required this.phone,
    required this.email, required this.city, required this.status,
    required this.joinedAt, required this.ordersCount, required this.totalDeliveries,
    required this.totalEarnings, required this.totalCommission, required this.totalPayouts,
    required this.currentBalance, required this.netPayable, required this.hasMismatch,
    required this.vehicle, required this.commissionRate,
  });
}

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String city;
  final AccountStatus status;
  final String joinedAt;
  final int ordersCount;
  final double totalSpent;
  final double totalCommission;
  final double totalRefunds;
  final double totalPayouts;
  final double currentBalance;
  final double netPayable;
  final bool hasMismatch;
  final double commissionRate;

  const AppUser({
    required this.id, required this.name, required this.phone,
    required this.email, required this.city, required this.status,
    required this.joinedAt, required this.ordersCount, required this.totalSpent,
    required this.totalCommission, required this.totalRefunds, required this.totalPayouts,
    required this.currentBalance, required this.netPayable, required this.hasMismatch,
    required this.commissionRate,
  });
}

class OrderEntity {
  final String id;
  final String date;
  final String time;
  final ({String id, String name}) store;
  final ({String id, String name}) driver;
  final ({String id, String name}) user;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double discount;
  final double tax;
  final double total;
  final CommissionBase commissionBase;
  final String commissionRule;
  final double commissionRate;
  final double ownerProfit;
  final OrderStatus status;
  final String paymentMethod;
  final String city;

  const OrderEntity({
    required this.id, required this.date, required this.time,
    required this.store, required this.driver, required this.user,
    required this.subtotal, required this.deliveryFee, required this.serviceFee,
    required this.discount, required this.tax, required this.total,
    required this.commissionBase, required this.commissionRule,
    required this.commissionRate, required this.ownerProfit,
    required this.status, required this.paymentMethod, required this.city,
  });
}

class CommissionRule {
  final String id;
  final String name;
  final RuleScope scope;
  final String appliesTo;
  final double commissionRate;
  final CommissionBase commissionBase;
  final String effectiveDate;
  final bool enabled;
  final int priority;
  final String createdAt;
  final String createdBy;
  final String note;
  final List<RuleHistoryEntry> history;

  const CommissionRule({
    required this.id, required this.name, required this.scope,
    required this.appliesTo, required this.commissionRate,
    required this.commissionBase, required this.effectiveDate,
    required this.enabled, required this.priority, required this.createdAt,
    required this.createdBy, required this.note, required this.history,
  });
}

class RuleHistoryEntry {
  final String date;
  final String actor;
  final double oldRate;
  final double newRate;
  final String reason;

  const RuleHistoryEntry({
    required this.date, required this.actor,
    required this.oldRate, required this.newRate, required this.reason,
  });
}

class Settlement {
  final String id;
  final String date;
  final String entityType;
  final String entityId;
  final String entityName;
  final double amount;
  final String method;
  final String referenceId;
  final String notes;
  final String status;
  final String period;

  const Settlement({
    required this.id, required this.date, required this.entityType,
    required this.entityId, required this.entityName, required this.amount,
    required this.method, required this.referenceId, required this.notes,
    required this.status, required this.period,
  });
}

class AuditLog {
  final String id;
  final String date;
  final String time;
  final String actor;
  final String actorRole;
  final String action;
  final String target;
  final String targetType;
  final String? before;
  final String? after;
  final String? notes;
  final String severity; // 'info' | 'warning' | 'critical'

  const AuditLog({
    required this.id, required this.date, required this.time,
    required this.actor, required this.actorRole, required this.action,
    required this.target, required this.targetType,
    this.before, this.after, this.notes, required this.severity,
  });
}

class Dispute {
  final String id;
  final String date;
  final String entityType;
  final String entityId;
  final String entityName;
  final String type;
  final String description;
  final DisputeStatus status;
  final String severity; // 'low' | 'medium' | 'high'
  final double? amount;
  final String? resolvedAt;
  final String? notes;

  const Dispute({
    required this.id, required this.date, required this.entityType,
    required this.entityId, required this.entityName, required this.type,
    required this.description, required this.status, required this.severity,
    this.amount, this.resolvedAt, this.notes,
  });
}

class ITAdmin {
  final String id;
  final String name;
  final String phone;
  final String email;
  final AccountStatus status;
  final String joinedAt;
  final String lastLogin;
  final List<String> permissions;
  final int deviceCount;
  final bool twoFactorEnabled;

  const ITAdmin({
    required this.id, required this.name, required this.phone,
    required this.email, required this.status, required this.joinedAt,
    required this.lastLogin, required this.permissions,
    required this.deviceCount, required this.twoFactorEnabled,
  });
}