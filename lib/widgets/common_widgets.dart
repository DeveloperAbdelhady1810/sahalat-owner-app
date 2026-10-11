// ============================================================
// سهلات المالك – Common Reusable Widgets (Flutter)
// Mirrors: /src/app/components/shared/
// ============================================================

import 'package:flutter/material.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';

// ─── KPI Card ──────────────────────────────────────────────
// Mirrors: KPICard.tsx
class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final IconData? icon;
  final Color color;
  final Color bgColor;
  final Map<String, dynamic>? trend;

  const KpiCard({
    super.key, required this.label, required this.value,
    this.sub, this.icon, this.color = AppColors.primary,
    this.bgColor = AppColors.primaryLight, this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null)
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppRadius.md)),
                  child: Icon(icon, size: 18, color: color),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w600, fontFamily: 'Cairo'), textAlign: TextAlign.right),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.displayMd.copyWith(fontSize: 22, fontFamily: 'Cairo'), textAlign: TextAlign.right),
          if (sub != null) ...[
            const SizedBox(height: 2),
            Text(sub!, style: AppTypography.micro.copyWith(fontFamily: 'Cairo'), textAlign: TextAlign.right),
          ],
          if (trend != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('مقارنة بالأسبوع الماضي', style: AppTypography.micro.copyWith(fontFamily: 'Cairo')),
                const SizedBox(width: 4),
                Text(
                  '${trend!['positive'] ? '↑' : '↓'} ${trend!['value']}',
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: trend!['positive'] ? AppColors.success : AppColors.danger,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Status Badge ──────────────────────────────────────────
// Mirrors: StatusBadge.tsx
class StatusBadgeWidget extends StatelessWidget {
  final String status;
  final bool small;

  const StatusBadgeWidget({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.statusColor(status);
    final label = ArStrings.statusLabel(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: small ? 10 : 11,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
              fontFamily: 'Cairo',
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: small ? 5 : 6, height: small ? 5 : 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ────────────────────────────────────────────
// Mirrors: SearchBar.tsx
class AppSearchBar extends StatelessWidget {
  final String placeholder;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const AppSearchBar({
    super.key,
    this.placeholder = 'بحث...',
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () { controller.clear(); onChanged?.call(''); },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Icon(Icons.close, size: 14, color: AppColors.textMuted),
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted, fontFamily: 'Cairo'),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
                filled: false,
              ),
              style: AppTypography.body.copyWith(fontFamily: 'Cairo'),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.search, size: 16, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.md),
        ],
      ),
    );
  }
}

// ─── Segmented Control ─────────────────────────────────────
// Mirrors: SegmentedControl.tsx
class SegmentedControlWidget extends StatelessWidget {
  final List<({String label, String value, int? count})> options;
  final String value;
  final ValueChanged<String> onChanged;

  const SegmentedControlWidget({
    super.key, required this.options, required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: options.map((opt) {
          final isActive = opt.value == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(opt.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  boxShadow: isActive ? AppShadows.sm : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      opt.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? AppColors.primary : AppColors.textSecondary,
                      ),
                    ),
                    if (opt.count != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primaryLight : AppColors.gray300,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          '${opt.count}',
                          style: TextStyle(
                            fontSize: 10, fontWeight: FontWeight.w700,
                            color: isActive ? AppColors.primary : AppColors.gray600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────
// Mirrors: EmptyState.tsx
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final ({String label, VoidCallback onTap})? action;

  const EmptyStateWidget({
    super.key, required this.icon, required this.title,
    this.description, this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(color: AppColors.gray100, borderRadius: BorderRadius.circular(24)),
            child: Icon(icon, size: 32, color: AppColors.gray300),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: AppTypography.subheading.copyWith(color: AppColors.gray700)),
          if (description != null) ...[
            const SizedBox(height: 6),
            Text(description!, textAlign: TextAlign.center, style: AppTypography.bodyMd.copyWith(color: AppColors.textMuted)),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: action!.onTap,
              child: Text(action!.label),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── App Header ────────────────────────────────────────────
// Mirrors: Header.tsx
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final bool showBack;
  final Widget? rightElement;
  final bool gradient;

  const AppHeader({
    super.key, required this.title, this.subtitle,
    this.showBack = false, this.rightElement, this.gradient = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final decoration = gradient
      ? const BoxDecoration(gradient: AppGradients.primary)
      : const BoxDecoration(color: AppColors.surface, border: Border(bottom: BorderSide(color: AppColors.border)));

    return Container(
      decoration: decoration,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                if (showBack)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36, height: 36,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: gradient ? Colors.white.withOpacity(0.15) : AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Icon(Icons.chevron_left, color: gradient ? Colors.white : AppColors.textPrimary, size: 20),
                    ),
                  ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w700,
                          color: gradient ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: gradient ? Colors.white.withOpacity(0.7) : AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (rightElement != null) rightElement!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Confirm Bottom Sheet ──────────────────────────────────
// Mirrors: ConfirmModal.tsx
Future<bool?> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'تأكيد',
  bool danger = false,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
    ),
    builder: (ctx) => Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: danger ? AppColors.dangerLight : AppColors.warningLight,
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Icon(Icons.warning_amber_rounded, color: danger ? AppColors.danger : AppColors.warning, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: AppTypography.subheading)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(message, style: AppTypography.bodyMd),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.gray100,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(ArStrings.cancel, style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: danger ? AppColors.danger : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(confirmLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ─── Loading Skeleton ──────────────────────────────────────
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonBox({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppRadius.md,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => Container(
        width: widget.width, height: widget.height,
        decoration: BoxDecoration(
          color: AppColors.gray200.withOpacity(_animation.value),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}