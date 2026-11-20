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
    // Icon helper according to service title
    Widget getServiceIcon() {
      final title = service.title.toLowerCase();
      IconData iconData = Icons.cleaning_services_rounded;
      if (title.contains('kitchen')) {
        iconData = Icons.countertops_rounded;
      } else if (title.contains('deep')) {
        iconData = Icons.sanitizer_rounded;
      } else if (title.contains('fan') || title.contains('switch') || title.contains('wiring') || title.contains('electric')) {
        iconData = Icons.bolt_rounded;
      } else if (title.contains('tap') || title.contains('pipe') || title.contains('plumb') || title.contains('leak')) {
        iconData = Icons.plumbing_rounded;
      } else if (title.contains('carpenter') || title.contains('door') || title.contains('furnitur') || title.contains('shelf')) {
        iconData = Icons.handyman_rounded;
      }
      return Icon(
        iconData,
        size: 24,
        color: isSelected ? AppColors.forestGreen : const Color(0xFF2C6B56),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? AppColors.forestGreenLight
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected
              ? AppColors.forestGreen
              : const Color(0xFFE2EBE5),
          width: isSelected ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
                      : const Color(0xFFEFF5F0),
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (service.description != null && service.description!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        service.description!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          AppConfig.formatINRWhole(service.basePrice),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            '· ${service.durationMins ~/ 60 > 0 ? "${service.durationMins ~/ 60}-${(service.durationMins ~/ 60) + 1} hours" : "${service.durationMins} mins"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondaryLight,
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
                        : Colors.grey.shade400,
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
