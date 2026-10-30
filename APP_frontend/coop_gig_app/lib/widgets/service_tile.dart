import 'package:flutter/material.dart';
import '../models/service.dart';
import '../config/config.dart';
import '../config/theme.dart';

class ServiceTile extends StatelessWidget {
  final ServiceItem service;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceTile({
    super.key,
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Icon helper according to service title
    Widget getServiceIcon() {
      if (service.title.toLowerCase().contains('kitchen')) {
        return const Text('🧽', style: TextStyle(fontSize: 22));
      } else if (service.title.toLowerCase().contains('deep')) {
        return const Text('🫧', style: TextStyle(fontSize: 22));
      } else if (service.title.toLowerCase().contains('fan') || service.title.toLowerCase().contains('switch')) {
        return const Text('⚡', style: TextStyle(fontSize: 22));
      } else if (service.title.toLowerCase().contains('tap') || service.title.toLowerCase().contains('pipe')) {
        return const Text('🔧', style: TextStyle(fontSize: 22));
      }
      return const Text('🧹', style: TextStyle(fontSize: 22));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppColors.forestGreenDark : AppColors.forestGreenLight)
            : (isDark ? AppColors.surfaceDark : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.forestGreen
              : (isDark ? AppColors.borderDark : const Color(0xFFE2EBE5)),
          width: isSelected ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // Left icon square container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.8)
                      : (isDark ? AppColors.bgDarkTop : const Color(0xFFEFF5F0)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: getServiceIcon()),
              ),
              const SizedBox(width: 14),

              // Title, Subtitle, Price & Duration
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (service.description != null && service.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        service.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          AppConfig.formatINRWhole(service.basePrice),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '· ${service.durationMins ~/ 60 > 0 ? "${service.durationMins ~/ 60}-${(service.durationMins ~/ 60) + 1} hours" : "${service.durationMins} mins"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right Circular Check / Radio Indicator (Figma exact)
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.forestGreen : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.forestGreen
                        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
