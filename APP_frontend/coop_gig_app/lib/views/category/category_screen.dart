import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../config/config.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../widgets/bottom_slide_route.dart';
import '../../widgets/service_tile.dart';
import '../../widgets/trust_strip.dart';
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
        // Auto-select first service if none selected (as shown in Figma Screen 2)
        if (ctrl.services.isNotEmpty && ctrl.selectedService == null) {
          ctrl.selectService(ctrl.services.first);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoryCtrl = Provider.of<CategoryController>(context);
    final auth = Provider.of<AuthController>(context);
    final user = auth.currentUser;

    final services = categoryCtrl.services;
    final selectedService = categoryCtrl.selectedService;

    return Container(
      // THE SIGNATURE FIGMA SAGE/CREAM GRADIENT BACKGROUND
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.darkSageGradient : AppColors.sageGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Center(
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 24,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          title: Text(
            '${widget.category.name} Services',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Text('🛍️', style: TextStyle(fontSize: 18)),
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
        body: categoryCtrl.isLoading && services.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // HERO BANNER (Figma exact: Dark Forest Green Card with Living Room photo backdrop)
                          _buildFigmaHeroBanner(context),
                          const SizedBox(height: 18),

                          // SOCIETY & AVAILABILITY LINE (Figma exact: 📍 Bhopal Central Co-op · Available today)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: AppColors.coralPin, // Terracotta red pin
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
                                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // CHOOSE YOUR SERVICE HEADER (Figma exact: Choose your service ... 3 services)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                AppStrings.get(context, 'choose_service'),
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                              Text(
                                '${services.length} services',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // SERVICE TILES LIST (Figma exact)
                          if (services.isEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32),
                              child: Center(child: Text('No services listed in this category yet')),
                            ),
                          ] else ...[
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
                          ],
                          const SizedBox(height: 14),

                          // TRUST STRIP PILL (Figma exact at bottom of content)
                          const TrustStrip(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  // STICKY BOTTOM FOOTER (Figma exact: ₹399 onwards ... Find a worker →)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
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
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppStrings.get(context, 'onwards'),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
    );
  }

  Widget _buildFigmaHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.forestGreenDark, // #17332B deep forest green
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
            // Right-side living room photo
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
            // Gradient blend over image from left to right
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
            // Banner content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Pills: ✨ HOME, REFRESHED  and  ★ 4.9 (120+)
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
                            Text('✨', style: TextStyle(fontSize: 10)),
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

                  // Middle & Bottom text: "A little care .\nA cleaner home ."
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
