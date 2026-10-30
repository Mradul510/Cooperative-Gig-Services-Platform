import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/localization.dart';

class TrustStrip extends StatelessWidget {
  const TrustStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isDark ? AppColors.borderDark : const Color(0xFFE5EDE8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildItem(
              context,
              '🛡️',
              AppStrings.get(context, 'trust_verified'),
            ),
          ),
          Container(
            height: 16,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: isDark ? AppColors.borderDark : const Color(0xFFDCE6DF),
          ),
          Expanded(
            child: _buildItem(
              context,
              '⚖️',
              AppStrings.get(context, 'trust_fair_wage'),
            ),
          ),
          Container(
            height: 16,
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            color: isDark ? AppColors.borderDark : const Color(0xFFDCE6DF),
          ),
          Expanded(
            child: _buildItem(
              context,
              '🏥',
              AppStrings.get(context, 'trust_welfare'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    String emoji,
    String label,
  ) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 13)),
            const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
