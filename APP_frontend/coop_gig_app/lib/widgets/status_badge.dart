import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../config/localization.dart';

class StatusBadge extends StatelessWidget {
  final String status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String labelKey;

    switch (status.toLowerCase()) {
      case 'accepted':
        bg = AppColors.primaryLight.withValues(alpha: 0.12);
        fg = AppColors.primaryLight;
        labelKey = 'status_accepted';
        break;
      case 'completed':
      case 'approved':
      case 'resolved':
        bg = AppColors.verified.withValues(alpha: 0.12);
        fg = AppColors.verified;
        labelKey = status.toLowerCase() == 'completed'
            ? 'status_completed'
            : (status.toLowerCase() == 'approved' ? 'doc_approved' : 'status_resolved');
        break;
      case 'pending':
      case 'open':
        bg = AppColors.pending.withValues(alpha: 0.15);
        fg = AppColors.pending;
        labelKey = status.toLowerCase() == 'open' ? 'status_open' : 'status_pending';
        break;
      case 'cancelled':
      case 'rejected':
        bg = AppColors.error.withValues(alpha: 0.12);
        fg = AppColors.error;
        labelKey = status.toLowerCase() == 'cancelled' ? 'status_cancelled' : 'doc_rejected';
        break;
      default:
        bg = Colors.grey.withValues(alpha: 0.15);
        fg = Colors.grey.shade700;
        labelKey = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        AppStrings.get(context, labelKey),
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
