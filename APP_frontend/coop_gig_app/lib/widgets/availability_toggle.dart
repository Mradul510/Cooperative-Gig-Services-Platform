import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/localization.dart';

class AvailabilityToggle extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onChanged;

  const AvailabilityToggle({
    super.key,
    required this.isOnline,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isOnline
            ? AppColors.verified.withValues(alpha: 0.12)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isOnline
              ? AppColors.verified
              : (Theme.of(context).brightness == Brightness.dark
                  ? AppColors.borderDark
                  : AppColors.borderLight),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.verified : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOnline
                ? AppStrings.get(context, 'online')
                : AppStrings.get(context, 'offline'),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isOnline ? AppColors.verified : Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Switch.adaptive(
            value: isOnline,
            onChanged: onChanged,
            activeThumbColor: AppColors.verified,
          ),
        ],
      ),
    );
  }
}
