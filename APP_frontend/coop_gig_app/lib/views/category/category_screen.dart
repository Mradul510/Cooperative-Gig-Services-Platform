import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../models/worker.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/worker_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../config/config.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../widgets/bottom_slide_route.dart';
import '../../widgets/service_tile.dart';
import '../../widgets/trust_strip.dart';
import '../../widgets/verified_badge.dart';
import '../booking/booking_sheet.dart';
import '../home/home_screen.dart';
import 'filter_sheet.dart';
import 'worker_list_screen.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryItem category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = Provider.of<CategoryController>(context, listen: false);
      ctrl.fetchServices(categoryId: widget.category.id).then((_) {
        final effServices = _getEffectiveServices(ctrl.services);
        if (effServices.isNotEmpty && ctrl.selectedService == null) {
          ctrl.selectService(effServices.first);
        }
      });
      Provider.of<WorkerController>(context, listen: false)
          .fetchWorkers(category: widget.category.name);
    });
  }

  List<ServiceItem> _getEffectiveServices(List<ServiceItem> apiServices) {
    if (apiServices.isNotEmpty) return apiServices;
    final name = widget.category.name.toLowerCase();
    if (name.contains('clean')) {
      return [
        ServiceItem(id: 1, categoryId: widget.category.id, title: 'Regular home cleaning', basePrice: 399, durationMins: 60),
        ServiceItem(id: 2, categoryId: widget.category.id, title: 'Kitchen cleaning', basePrice: 699, durationMins: 90),
        ServiceItem(id: 3, categoryId: widget.category.id, title: 'Deep home cleaning', basePrice: 1499, durationMins: 180),
      ];
    } else if (name.contains('electr')) {
      return [
        ServiceItem(id: 4, categoryId: widget.category.id, title: 'Fan installation', basePrice: 299, durationMins: 45),
        ServiceItem(id: 5, categoryId: widget.category.id, title: 'Switch/socket repair', basePrice: 199, durationMins: 30),
        ServiceItem(id: 6, categoryId: widget.category.id, title: 'Wiring inspection', basePrice: 499, durationMins: 90),
      ];
    } else if (name.contains('plumb')) {
      return [
        ServiceItem(id: 7, categoryId: widget.category.id, title: 'Tap repair', basePrice: 199, durationMins: 30),
        ServiceItem(id: 8, categoryId: widget.category.id, title: 'Pipe leakage fix', basePrice: 399, durationMins: 60),
        ServiceItem(id: 9, categoryId: widget.category.id, title: 'Water heater installation', basePrice: 699, durationMins: 120),
      ];
    } else {
      return [
        ServiceItem(id: 10, categoryId: widget.category.id, title: 'Furniture repair', basePrice: 299, durationMins: 60),
        ServiceItem(id: 11, categoryId: widget.category.id, title: 'Door/window fix', basePrice: 399, durationMins: 60),
        ServiceItem(id: 12, categoryId: widget.category.id, title: 'Custom shelf fitting', basePrice: 599, durationMins: 90),
      ];
    }
  }

  void _openBookingSheet(BuildContext context, WorkerFeedItem worker, ServiceItem service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => BookingSheet(
        worker: worker,
        service: service,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
        final categoryCtrl = Provider.of<CategoryController>(context);
    final workerCtrl = Provider.of<WorkerController>(context);
    final auth = Provider.of<AuthController>(context);
    final user = auth.currentUser;

    final services = _getEffectiveServices(categoryCtrl.services);
    final selectedService = categoryCtrl.selectedService ?? (services.isNotEmpty ? services.first : null);
    final categoryWorkers = workerCtrl.workers;

    void navigateBack() {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            settings: const RouteSettings(name: '/home'),
            builder: (_) => const HomeScreen(),
          ),
        );
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        navigateBack();
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.sageGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 70,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    elevation: 2,
                    shadowColor: Colors.black12,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: navigateBack,
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_rounded,
                          size: 22,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              '${widget.category.name} Services',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryLight,
              ),
            ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.tune_rounded,
                    size: 20,
                    color: AppColors.forestGreen,
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => FilterSheet(category: widget.category.name),
                    );
                  },
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HERO BANNER
                    _buildFigmaHeroBanner(context),
                    const SizedBox(height: 18),

                    // SOCIETY & AVAILABILITY LINE
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: AppColors.coralPin,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${user?.cooperativeName ?? "Bhopal Central Co-op"} · ${AppStrings.get(context, 'available_today')}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // CHOOSE YOUR SERVICE HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.get(context, 'choose_service'),
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          '${services.length} services',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // SERVICE TILES LIST
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        final isSelected = selectedService?.id == service.id;
                        return ServiceTile(
                          service: service,
                          isSelected: isSelected,
                          onTap: () => categoryCtrl.selectService(service),
                        );
                      },
                    ),
                    const SizedBox(height: 22),

                    // WORKERS WHO PUT THEMSELVES IN THIS CATEGORY
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${widget.category.name} Workers Nearby',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          '${categoryWorkers.length} available',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (workerCtrl.isLoading) ...[
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ] else if (categoryWorkers.isEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE2EBE5),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.person_search_outlined, size: 38, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            Text(
                              'No registered workers in this category nearby',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Workers who select "${widget.category.name}" during signup or in Profile will appear here.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categoryWorkers.length,
                        itemBuilder: (context, index) {
                          final worker = categoryWorkers[index];
                          return _buildCategoryWorkerCard(context, worker, selectedService);
                        },
                      ),
                    ],
                    const SizedBox(height: 20),

                    // TRUST STRIP PILL
                    const TrustStrip(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // STICKY BOTTOM FOOTER
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            selectedService != null
                                ? '1 ${AppStrings.get(context, 'selected')}'
                                : 'Select a service',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                selectedService != null
                                    ? AppConfig.formatINRWhole(selectedService.basePrice)
                                    : '₹ --',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimaryLight,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppStrings.get(context, 'onwards'),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        backgroundColor: selectedService != null
                            ? AppColors.forestGreen
                            : Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: selectedService != null
                          ? () {
                              Navigator.of(context).push(
                                BottomSlideRoute(
                                  page: WorkerListScreen(
                                    title: '${widget.category.name} Workers',
                                    categoryName: widget.category.name,
                                    selectedService: selectedService,
                                  ),
                                  settings: RouteSettings(name: '/workers/${widget.category.name}'),
                                ),
                              );
                            }
                          : null,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.get(context, 'find_worker'),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCategoryWorkerCard(
    BuildContext context,
    WorkerFeedItem worker,
    ServiceItem? selectedService,
      ) {
    final effectiveService = selectedService ??
        ServiceItem(
          id: 1,
          categoryId: widget.category.id,
          title: '${widget.category.name} Visit',
          basePrice: worker.visitFee > 0 ? worker.visitFee : 399,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2EBE5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: AppColors.forestGreen,
            child: Text(
              worker.name.trim().isNotEmpty
                  ? (worker.name.trim().split(' ').length > 1
                      ? '${worker.name.trim().split(' ')[0][0]}${worker.name.trim().split(' ')[1][0]}'.toUpperCase()
                      : worker.name.substring(0, worker.name.length >= 2 ? 2 : 1).toUpperCase())
                  : 'W',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
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
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    VerifiedBadge(isVerified: worker.isVerified),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(
                      worker.ratingAvg > 0 ? worker.ratingAvg.toStringAsFixed(1) : '4.8',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${worker.jobsCompleted} jobs',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '· ${worker.distanceKm.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.forestGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              backgroundColor: AppColors.forestGreen,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              minimumSize: const Size(0, 36),
            ),
            onPressed: () => _openBookingSheet(context, worker, effectiveService),
            child: const Text('Book', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildFigmaHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.forestGreenDark,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: 170,
              child: Image.network(
                'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=500&q=80',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.forestGreenDark,
                    AppColors.forestGreenDark.withValues(alpha: 0.95),
                    AppColors.forestGreenDark.withValues(alpha: 0.65),
                    AppColors.forestGreenDark.withValues(alpha: 0.25),
                  ],
                  stops: const [0.0, 0.45, 0.7, 1.0],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.white, size: 12),
                            SizedBox(width: 4),
                            Text(
                              'HOME, REFRESHED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 13, color: Colors.amber),
                            SizedBox(width: 3),
                            Text(
                              '4.9 (120+)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'A little care .',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          height: 1.15,
                        ),
                      ),
                      Text(
                        'A cleaner home .',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                          height: 1.15,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Trusted help, right in your society.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
