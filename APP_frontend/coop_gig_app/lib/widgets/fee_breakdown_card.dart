import 'package:flutter/material.dart';
import '../config/config.dart';
import '../config/theme.dart';
import '../config/localization.dart';

class FeeBreakdownCard extends StatelessWidget {
  final double totalAmount;
  final double workerPayout;
  final double welfarePayout;
  final double platformPayout;

  const FeeBreakdownCard({
    super.key,
    required this.totalAmount,
    required this.workerPayout,
    required this.welfarePayout,
    required this.platformPayout,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, size: 18, color: AppColors.verified),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  AppStrings.get(context, 'booking_breakdown_title'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildRow(
            context,
            label: '${AppStrings.get(context, 'worker_wage')} (85%)',
            subLabel: 'Direct living wage to worker',
            amount: workerPayout,
            color: AppColors.verified,
          ),
          const SizedBox(height: 10),
          _buildRow(
            context,
            label: '${AppStrings.get(context, 'welfare_pool')} (10%)',
            subLabel: 'Insurance, health & social security pool',
            amount: welfarePayout,
            color: AppColors.pending,
          ),
          const SizedBox(height: 10),
          _buildRow(
            context,
            label: '${AppStrings.get(context, 'platform_fee')} (5%)',
            subLabel: 'Server hosting & dispatch maintenance',
            amount: platformPayout,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppStrings.get(context, 'total_amount'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppConfig.formatINR(totalAmount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String subLabel,
    required double amount,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subLabel,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        Text(
          AppConfig.formatINR(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

