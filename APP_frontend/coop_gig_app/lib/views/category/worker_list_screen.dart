import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../models/service.dart';
import '../../models/worker.dart';
import '../../controllers/worker_controller.dart';
import '../../controllers/category_controller.dart';
import '../../config/config.dart';
import '../../config/theme.dart';
import '../../config/trade_assets.dart';
import '../../config/localization.dart';
import '../../widgets/verified_badge.dart';
import '../booking/booking_sheet.dart';
import 'filter_sheet.dart';

class WorkerListScreen extends StatefulWidget {
  final String title;
  final String? categoryName;
  final ServiceItem? selectedService;
  final int? preselectedWorkerId;

  const WorkerListScreen({
    super.key,
    required this.title,
    this.categoryName,
    this.selectedService,
    this.preselectedWorkerId,
  });

  @override
  State<WorkerListScreen> createState() => _WorkerListScreenState();
}

class _WorkerListScreenState extends State<WorkerListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WorkerController>(context, listen: false)
          .fetchWorkers(category: widget.categoryName);
    });
  }

  void _openBookingSheet(WorkerFeedItem worker) {
    ServiceItem? service = widget.selectedService;
    if (service == null) {
      final categoryCtrl = Provider.of<CategoryController>(context, listen: false);
      if (categoryCtrl.services.isNotEmpty) {
        service = categoryCtrl.services.first;
      } else {
        service = ServiceItem(
          id: 1,
          categoryId: 1,
          title: '${worker.tradeCategory ?? "Home"} Service Visit',
          basePrice: worker.visitFee > 0 ? worker.visitFee : 399.0,
        );
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BookingSheet(
        worker: worker,
        service: service!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final workerCtrl = Provider.of<WorkerController>(context);

    return Container(
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkSageGradient : AppColors.sageGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => FilterSheet(category: widget.categoryName),
              );
            },
          ),
        ],
      ),
      body: workerCtrl.isLoading
          ? _buildLoadingShimmer()
          : workerCtrl.workers.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  itemCount: workerCtrl.workers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final worker = workerCtrl.workers[index];
                    return _buildWorkerCard(context, worker, isDark);
                  },
                ),
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, WorkerFeedItem worker, bool isDark) {
    final gradient = TradeAssets.getAvatarGradient(worker.userId);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openBookingSheet(worker),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Avatar with verified overlay, Name, Reg ID, Price
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: gradient,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: gradient.first.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            worker.name.isNotEmpty ? worker.name[0].toUpperCase() : 'W',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      if (worker.isVerified)
                        Positioned(
                          bottom: -3,
                          right: -3,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardTheme.color,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AppColors.verified,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                worker.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            VerifiedBadge(isVerified: worker.isVerified, showText: false),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${worker.tradeCategory ?? "Tradesperson"} · ${worker.cooperativeRegNo ?? "BCK-COOP"}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.pending),
                            const SizedBox(width: 3),
                            Text(
                              worker.ratingAvg > 0 ? worker.ratingAvg.toStringAsFixed(1) : '4.8',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${worker.jobsCompleted} ${AppStrings.get(context, 'jobs_done')}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppConfig.formatINRWhole(worker.visitFee),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.forestGreen,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                      Text(
                        'Visit fee',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 18),

              // Bottom Row: Distance pill + Welfare & Insurance pill
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.near_me_rounded, size: 12, color: AppColors.primaryLight),
                        const SizedBox(width: 4),
                        Text(
                          '${worker.distanceKm.toStringAsFixed(1)} km away',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.verified.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.shield_rounded, size: 12, color: AppColors.verified),
                        const SizedBox(width: 4),
                        Text(
                          worker.welfareActive
                              ? 'Insurance Active'
                              : 'Welfare Pending',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.verified,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, _) => Container(
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_search_rounded, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppStrings.get(context, 'no_workers_found'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try increasing the dispatch radius (up to 5 km) or check back shortly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
