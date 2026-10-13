// سجل التدقيق - بيانات حقيقية من /owner/audit-logs (للقراءة فقط)
import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../services/api.dart';
import '../widgets/common_widgets.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});
  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  // (label, action filter sent to the server; "x.*" = every action that starts with "x.")
  static const _groups = <(String, String?)>[
    ('الكل', null),
    ('تسجيل الدخول', 'login.*'),
    ('الموافقات والإيقاف', 'seller.*'),
    ('السائقون', 'delivery.*'),
    ('الإعدادات', 'settings.*'),
    ('المستندات', 'document.*'),
  ];

  final List<Map<String, dynamic>> _rows = [];
  final _search = TextEditingController();
  String? _action;
  int _page = 1;
  int _lastPage = 1;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({bool reset = false}) async {
    if (reset) {
      setState(() {
        _loading = true;
        _error = null;
        _page = 1;
        _rows.clear();
      });
    } else {
      setState(() => _loadingMore = true);
    }
    try {
      final res = await API().getAuditLogs(action: _action, page: _page);
      final data = (res['data'] as List? ?? []).cast<Map<String, dynamic>>();
      final meta = (res['meta'] as Map?) ?? {};
      if (!mounted) return;
      setState(() {
        _rows.addAll(data);
        _lastPage = (meta['last_page'] as num?)?.toInt() ?? 1;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e == API.sessionExpired ? 'انتهت الجلسة، سجّل الدخول من جديد' : 'تعذر تحميل السجل. تحقق من الاتصال وحاول مرة أخرى';
        _loading = false;
        _loadingMore = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _search.text.trim().toLowerCase();
    if (q.isEmpty) return _rows;
    return _rows.where((r) => '${r['action']} ${r['actor_name']} ${r['actor_type']} ${r['target_type']} ${r['target_id']}'.toLowerCase().contains(q)).toList();
  }

  String _label(String action) {
    const m = {
      'login.success': 'تسجيل دخول ناجح',
      'login.failed': 'محاولة دخول فاشلة',
      'login.blocked': 'دخول مرفوض (حساب غير مفعّل)',
      'seller.approve': 'قبول متجر',
      'seller.reject': 'رفض متجر',
      'seller.suspend': 'إيقاف متجر',
      'seller.delete': 'حذف متجر',
      'delivery.approve': 'قبول سائق',
      'delivery.reject': 'رفض سائق',
      'delivery.block': 'حظر سائق',
      'settings.update': 'تعديل الإعدادات',
      'document.view': 'عرض مستند',
      'document.download': 'تنزيل مستند',
      'account.delete': 'حذف حساب',
      'it_admin.create': 'إنشاء حساب إدارة',
      'it_admin.update': 'تعديل حساب إدارة',
      'it_admin.delete': 'حذف حساب إدارة',
    };
    return m[action] ?? action;
  }

  (IconData, Color, Color) _style(String action) {
    if (action == 'login.failed' || action.endsWith('.delete') || action.endsWith('.block') || action.endsWith('.suspend') || action == 'login.blocked') {
      return (Icons.warning_amber_rounded, AppColors.danger, AppColors.dangerLight);
    }
    if (action.startsWith('document.') || action.startsWith('settings.') || action.endsWith('.reject')) {
      return (Icons.visibility_outlined, AppColors.warning, AppColors.warningLight);
    }
    return (Icons.check_circle_outline, AppColors.info, AppColors.infoLight);
  }

  String _who(Map<String, dynamic> r) {
    const types = {'it_admin': 'الإدارة', 'owner': 'المالك', 'seller': 'متجر', 'staff': 'موظف متجر', 'delivery': 'سائق', 'user': 'عميل', 'system': 'النظام'};
    final t = types[r['actor_type']] ?? (r['actor_type'] ?? 'غير معروف').toString();
    final n = (r['actor_name'] ?? '').toString();
    return n.isEmpty ? t : '$t - $n';
  }

  String _when(dynamic v) {
    final s = (v ?? '').toString();
    return s.length >= 16 ? s.substring(0, 16).replaceFirst('T', ' ') : s;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _filtered;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(title: ArStrings.auditLogs, subtitle: ArStrings.allSystemActions, showBack: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: AppSearchBar(controller: _search, placeholder: 'بحث في الإجراءات والمنفذين...', onChanged: (_) => setState(() {})),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _groups.map((g) {
                final on = _action == g.$2;
                return GestureDetector(
                  onTap: () {
                    _action = g.$2;
                    _load(reset: true);
                  },
                  child: Container(
                    margin: const EdgeInsetsDirectional.only(end: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: on ? AppColors.primary : AppColors.gray100, borderRadius: BorderRadius.circular(AppRadius.full)),
                    child: Text(g.$1, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: on ? Colors.white : AppColors.textSecondary)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Text(_error!, textAlign: TextAlign.center),
                            const SizedBox(height: 12),
                            ElevatedButton(onPressed: () => _load(reset: true), child: const Text('إعادة المحاولة')),
                          ]),
                        ),
                      )
                    : rows.isEmpty
                        ? EmptyStateWidget(icon: Icons.description_outlined, title: ArStrings.noAuditLogs, description: 'لا توجد أحداث تطابق الفلاتر')
                        : RefreshIndicator(
                            onRefresh: () => _load(reset: true),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: rows.length + 1,
                              itemBuilder: (ctx, i) {
                                if (i == rows.length) {
                                  if (_page >= _lastPage) return const SizedBox(height: 24);
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Center(
                                      child: _loadingMore
                                          ? const CircularProgressIndicator()
                                          : TextButton(
                                              onPressed: () {
                                                _page += 1;
                                                _load();
                                              },
                                              child: const Text('عرض المزيد')),
                                    ),
                                  );
                                }
                                final r = rows[i];
                                final st = _style((r['action'] ?? '').toString());
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppRadius.md), border: Border.all(color: AppColors.border)),
                                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Container(width: 34, height: 34, decoration: BoxDecoration(color: st.$3, shape: BoxShape.circle), child: Icon(st.$1, size: 17, color: st.$2)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                        Text(_label((r['action'] ?? '').toString()), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                        const SizedBox(height: 2),
                                        Text(_who(r), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                        if (r['target_type'] != null)
                                          Text('${r['target_type']}${r['target_id'] != null ? ' #${r['target_id']}' : ''}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                        const SizedBox(height: 2),
                                        Text('${_when(r['created_at'])}${r['ip'] != null ? '  ·  ${r['ip']}' : ''}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                      ]),
                                    ),
                                  ]),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
