import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/localization.dart';

class VerifiedBadge extends StatelessWidget {
  final bool isVerified;
  final bool showText;

  const VerifiedBadge({
    super.key,
    required this.isVerified,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.verified.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.verified.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, size: 13, color: AppColors.verified),
            if (showText) ...[
              const SizedBox(width: 4),
              Text(
                AppStrings.get(context, 'trust_verified'),
                style: const TextStyle(
                  color: AppColors.verified,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.pending.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.pending.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_empty, size: 12, color: AppColors.pending),
            if (showText) ...[
              const SizedBox(width: 4),
              Text(
                '${AppStrings.get(context, 'pending_verification_banner').substring(0, 15)}...',
                style: const TextStyle(
                  color: AppColors.pending,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ]
          ],
        ),
      );
    }
  }
}
