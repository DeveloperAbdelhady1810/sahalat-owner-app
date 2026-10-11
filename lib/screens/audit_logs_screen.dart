// Mirrors: AuditLogsScreen.tsx
import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import '../models/models.dart';
import '../services/mock_api_service.dart';
import '../widgets/common_widgets.dart';

class AuditLogsScreen extends StatefulWidget {
  const AuditLogsScreen({super.key});
  @override
  State<AuditLogsScreen> createState() => _AuditLogsScreenState();
}

class _AuditLogsScreenState extends State<AuditLogsScreen> {
  List<AuditLog> _logs = [];
  bool _loading = true;
  String _severity = 'all';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    MockApiService.instance.getAuditLogs().then((l) { if (mounted) setState(() { _logs = l; _loading = false; }); });
  }

  List<AuditLog> get _filtered => _logs.where((l) {
    final q = _searchController.text.toLowerCase();
    final matchSearch = q.isEmpty || l.action.toLowerCase().contains(q) || l.target.toLowerCase().contains(q) || l.actor.toLowerCase().contains(q);
    final matchSeverity = _severity == 'all' || l.severity == _severity;
    return matchSearch && matchSeverity;
  }).toList();

  Color _severityColor(String s) => s == 'critical' ? AppColors.danger : s == 'warning' ? AppColors.warning : AppColors.info;
  Color _severityBg(String s) => s == 'critical' ? AppColors.dangerLight : s == 'warning' ? AppColors.warningLight : AppColors.infoLight;

  String _severityLabel(String s) {
    switch (s) {
      case 'all': return ArStrings.all;
      case 'critical': return ArStrings.critical;
      case 'warning': return ArStrings.warning;
      case 'info': return ArStrings.info;
      default: return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title: ArStrings.auditLogs,
        subtitle: ArStrings.allSystemActions,
        showBack: true,
        rightElement: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(AppRadius.md)),
          child: const Icon(Icons.download_outlined, size: 16, color: AppColors.textSecondary),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(children: [
              for (final s in [
                ('critical', AppColors.danger, AppColors.dangerLight),
                ('warning', AppColors.warning, AppColors.warningLight),
                ('info', AppColors.info, AppColors.infoLight),
              ])
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: s.$3, borderRadius: BorderRadius.circular(AppRadius.xl)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: s.$2, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('${_logs.where((l) => l.severity == s.$1).length} ${_severityLabel(s.$1)}',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: s.$2)),
                  ]),
                ),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppSearchBar(
              controller: _searchController,
              placeholder: 'بحث في الإجراءات والمنفذين...',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: ['all', 'info', 'warning', 'critical'].map((s) =>
              GestureDetector(
                onTap: () => setState(() => _severity = s),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _severity == s ? AppColors.danger : AppColors.gray100,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(_severityLabel(s),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _severity == s ? Colors.white : AppColors.textSecondary)),
                ),
              )
            ).toList()),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _filtered.isEmpty
                ? EmptyStateWidget(icon: Icons.description_outlined, title: ArStrings.noAuditLogs, description: 'لا توجد أحداث تطابق الفلاتر')
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) {
                      final log = _filtered[i];
                      final isLast = i == _filtered.length - 1;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(children: [
                            Container(width: 32, height: 32,
                              decoration: BoxDecoration(color: _severityBg(log.severity), shape: BoxShape.circle),
                              child: Icon(_severityIcon(log.severity), size: 15, color: _severityColor(log.severity))),
                            if (!isLast) Container(width: 2, height: 32, color: AppColors.gray200),
                          ]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Row(children: [
                                  Expanded(child: Text(log.action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                                  Text('${log.date} ${log.time}', style: AppTypography.micro),
                                ]),
                                Text(log.target, style: AppTypography.caption),
                                const SizedBox(height: 4),
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(AppRadius.full)),
                                    child: Text('${log.actor} · ${log.actorRole}', style: AppTypography.micro),
                                  ),
                                  if (log.before != null && log.after != null) ...[
                                    const SizedBox(width: 8),
                                    Text('${log.before} ← ${log.after}', style: AppTypography.micro),
                                  ],
                                ]),
                                if (log.notes != null) Text(log.notes!, style: AppTypography.caption.copyWith(fontStyle: FontStyle.italic)),
                              ]),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _severityIcon(String s) => s == 'critical' ? Icons.error_outline : s == 'warning' ? Icons.warning_amber_outlined : Icons.info_outline;
}
