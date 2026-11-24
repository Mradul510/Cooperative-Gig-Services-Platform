import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../models/worker.dart';
import '../../controllers/auth_controller.dart';
import '../../config/theme.dart';
import '../../config/config.dart';
import '../../services/api_service.dart';
import '../../widgets/verified_badge.dart';
import '../booking/booking_sheet.dart';
import '../home/home_screen.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryItem category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<WorkerFeedItem> _onlineWorkers = [];
  bool _isLoadingWorkers = true;

  List<ServiceItem> _services = [];
  ServiceItem? _selectedService;

  @override
  void initState() {
    super.initState();
    _loadCategoryData();
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('electr')) return Icons.bolt_rounded;
    if (name.contains('plumb')) return Icons.plumbing_rounded;
    if (name.contains('carpent')) return Icons.handyman_rounded;
    return Icons.cleaning_services_rounded;
  }

  Future<void> _loadCategoryData() async {
    setState(() {
      _isLoadingWorkers = true;
    });

    try {
      // 1. Fetch available services
      final services = await ApiService().getServices(categoryId: widget.category.id);
      if (services.isNotEmpty) {
        _services = services;
      } else {
        _services = _getFallbackServices(widget.category.name);
      }
      if (_services.isNotEmpty && _selectedService == null) {
        _selectedService = _services.first;
      }

      // 2. Fetch online workers for this category
      final workers = await ApiService().getWorkers(
        lat: 23.2599,
        lng: 77.4126,
        radius: 5.0,
        category: widget.category.name,
      );

      // Filter to only workers who are actively online
      _onlineWorkers = workers.where((w) => w.availability).toList();
    } catch (_) {
      // Fallback services if offline
      if (_services.isEmpty) {
        _services = _getFallbackServices(widget.category.name);
        _selectedService = _services.first;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWorkers = false;
        });
      }
    }
  }

  List<ServiceItem> _getFallbackServices(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('electr')) {
      return [
        ServiceItem(id: 4, categoryId: widget.category.id, title: 'Fan Installation & Repair', basePrice: 299, durationMins: 45),
        ServiceItem(id: 5, categoryId: widget.category.id, title: 'Switch / Socket Fitting', basePrice: 199, durationMins: 30),
        ServiceItem(id: 6, categoryId: widget.category.id, title: 'Full House Wiring Check', basePrice: 499, durationMins: 90),
      ];
    } else if (name.contains('plumb')) {
      return [
        ServiceItem(id: 7, categoryId: widget.category.id, title: 'Tap & Valve Repair', basePrice: 199, durationMins: 30),
        ServiceItem(id: 8, categoryId: widget.category.id, title: 'Pipe Leakage Fix', basePrice: 399, durationMins: 60),
        ServiceItem(id: 9, categoryId: widget.category.id, title: 'Drainage Blockage Clear', basePrice: 499, durationMins: 60),
      ];
    } else if (name.contains('carpent')) {
      return [
        ServiceItem(id: 10, categoryId: widget.category.id, title: 'Door Lock & Handle Fitting', basePrice: 249, durationMins: 45),
        ServiceItem(id: 11, categoryId: widget.category.id, title: 'Furniture Assembly & Repair', basePrice: 399, durationMins: 60),
        ServiceItem(id: 12, categoryId: widget.category.id, title: 'Custom Modular Fitting', basePrice: 599, durationMins: 90),
      ];
    } else {
      return [
        ServiceItem(id: 1, categoryId: widget.category.id, title: 'Regular Home Cleaning', basePrice: 399, durationMins: 60),
        ServiceItem(id: 2, categoryId: widget.category.id, title: 'Kitchen Deep Cleaning', basePrice: 699, durationMins: 90),
        ServiceItem(id: 3, categoryId: widget.category.id, title: 'Full House Deep Clean', basePrice: 1499, durationMins: 180),
      ];
    }
  }

  void _openBookingSheet(WorkerFeedItem worker) {
    final effectiveService = _selectedService ??
        (_services.isNotEmpty
            ? _services.first
            : ServiceItem(
                id: 1,
                categoryId: widget.category.id,
                title: '${widget.category.name} Visit',
                basePrice: worker.visitFee > 0 ? worker.visitFee : 399,
              ));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BookingSheet(
        worker: worker,
        service: effectiveService,
      ),
    );
  }

  void _navigateBack() {
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

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthController>(context);
    final user = auth.currentUser;
    final catIcon = _getCategoryIcon(widget.category.name);

    return Scaffold(
      backgroundColor: AppColors.bgCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimaryLight),
          onPressed: _navigateBack,
        ),
        title: Row(
          children: [
            Icon(catIcon, size: 20, color: AppColors.forestGreen),
            const SizedBox(width: 8),
            Text(
              '${widget.category.name} Services',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.forestGreen),
            tooltip: 'Refresh Online Workers',
            onPressed: _loadCategoryData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCategoryData,
        color: AppColors.forestGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CATEGORY HEADER HERO CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.forestGreenDark,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.circle, size: 8, color: Color(0xFF4ADE80)),
                              const SizedBox(width: 6),
                              Text(
                                '${_onlineWorkers.length} WORKERS ONLINE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          user?.cooperativeName ?? 'Bhopal Central Co-op',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Verified ${widget.category.name} Specialists',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Every booking provides an 85% living wage directly to the tradesperson with society-backed background verification.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildTrustBadge(Icons.verified_outlined, '100% Verified'),
                        _buildTrustBadge(Icons.handshake_outlined, '85% Fair Wage'),
                        _buildTrustBadge(Icons.health_and_safety_outlined, 'Welfare Backed'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. CHOOSE YOUR SERVICE SELECTOR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '1. Choose Service Needed',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    '${_services.length} options',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Service Cards Wrap / List
              Column(
                children: _services.map((service) {
                  final isSelected = _selectedService?.id == service.id;
                  final workerCut = (service.basePrice * 0.85).toStringAsFixed(0);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedService = service;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.forestGreenLight : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? AppColors.forestGreen : AppColors.borderLight,
                          width: isSelected ? 1.8 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                            color: isSelected ? AppColors.forestGreen : Colors.grey.shade400,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  service.title,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: AppColors.textPrimaryLight,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Duration: ${service.durationMins} mins · Worker gets ₹$workerCut',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            AppConfig.formatINR(service.basePrice),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.forestGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 22),

              // 3. AVAILABLE ONLINE WORKERS IN THIS CATEGORY
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        '2. Available Online Workers',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Text(
                          '${_onlineWorkers.length} Online',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (_isLoadingWorkers) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.forestGreen),
                        SizedBox(height: 12),
                        Text(
                          'Finding online verified workers nearby...',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (_onlineWorkers.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.person_off_outlined, size: 44, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'No workers currently online in ${widget.category.name}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Workers in this cooperative will appear here when their duty switch is turned Online.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.forestGreen,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        onPressed: _loadCategoryData,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh Status'),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _onlineWorkers.length,
                  itemBuilder: (context, index) {
                    final worker = _onlineWorkers[index];
                    return _buildOnlineWorkerCard(context, worker);
                  },
                ),
              ],
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineWorkerCard(BuildContext context, WorkerFeedItem worker) {
    final activeService = _selectedService ??
        (_services.isNotEmpty ? _services.first : ServiceItem(id: 1, categoryId: widget.category.id, title: 'Visit', basePrice: 399));

    final totalFee = activeService.basePrice;
    final workerFee = (totalFee * 0.85).toStringAsFixed(0);
    final welfareFee = (totalFee * 0.10).toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP ROW: Avatar + Name + Online badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
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
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        VerifiedBadge(isVerified: worker.isVerified),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${worker.tradeCategory ?? widget.category.name} Specialist · Co-op Member',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 10),

          // MIDDLE STATS ROW: Rating, Jobs, Distance, Online Status
          Row(
            children: [
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                  const SizedBox(width: 3),
                  Text(
                    worker.ratingAvg > 0 ? worker.ratingAvg.toStringAsFixed(1) : '4.8',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${worker.jobsCompleted > 0 ? worker.jobsCompleted : 40}+ jobs)',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: AppColors.coralPin),
                  const SizedBox(width: 2),
                  Text(
                    '${worker.distanceKm > 0 ? worker.distanceKm.toStringAsFixed(1) : "0.5"} km away',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bolt, size: 12, color: Color(0xFF16A34A)),
                    SizedBox(width: 2),
                    Text(
                      'Online Now',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // BOTTOM ROW: 85/10/5 breakdown + 1-Tap Book Button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            AppConfig.formatINR(totalFee),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.forestGreen,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'total price',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Worker: ₹$workerFee (85%) · Welfare: ₹$welfareFee',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                    elevation: 1,
                  ),
                  onPressed: () => _openBookingSheet(worker),
                  icon: const Icon(Icons.calendar_today_outlined, size: 15),
                  label: const Text(
                    'Book Now',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
