import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/service.dart';
import '../../models/user.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/worker_controller.dart';
import '../../controllers/category_controller.dart';
import '../../controllers/booking_controller.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../widgets/bottom_slide_route.dart';
import '../../widgets/trust_strip.dart';
import '../../widgets/worker_micro_card.dart';
import '../category/category_screen.dart';
import '../category/worker_list_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/booking_history_screen.dart';
import '../profile/grievance_screen.dart';
import '../booking/booking_detail_screen.dart';
import '../worker/job_requests_screen.dart';
import '../worker/earnings_screen.dart';
import '../worker/document_upload_screen.dart';
import '../../models/booking.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
    Provider.of<CategoryController>(context, listen: false).fetchCategories();
    Provider.of<WorkerController>(context, listen: false).fetchWorkers();
    Provider.of<BookingController>(context, listen: false).fetchBookings();
  }

  Widget _buildHomeTab(BuildContext context) {
        final auth = Provider.of<AuthController>(context);
    final categoryCtrl = Provider.of<CategoryController>(context);
    final workerCtrl = Provider.of<WorkerController>(context);
    final bookingCtrl = Provider.of<BookingController>(context);
    final user = auth.currentUser;
    final isWorker = user?.isWorker ?? false;

    // Trade vector icons matching professional clean UI
    final categoryIcons = {
      'Cleaning': Icons.cleaning_services_rounded,
      'Electrical': Icons.bolt_rounded,
      'Plumbing': Icons.plumbing_rounded,
      'AC Service': Icons.ac_unit_rounded,
      'Carpentry': Icons.handyman_rounded,
    };

    return RefreshIndicator(
      onRefresh: () async {
        await categoryCtrl.fetchCategories();
        await workerCtrl.fetchWorkers();
        await bookingCtrl.fetchBookings();
        if (isWorker) {
          await auth.refreshProfile();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP BAR (Figma exact: RJ avatar + Welcome back Roshan Joshi + White circular Bell button)
            Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: AppColors.forestGreen,
                  child: Text(
                    user != null && user.name.isNotEmpty
                        ? (user.name.trim().split(' ').length > 1
                            ? '${user.name.trim().split(' ')[0][0]}${user.name.trim().split(' ')[1][0]}'.toUpperCase()
                            : user.name.substring(0, user.name.length >= 2 ? 2 : 1).toUpperCase())
                        : 'RJ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.get(context, 'welcome_back'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        user?.name.isNotEmpty == true ? user!.name : 'Roshan Joshi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // 1-Tap Mode Toggle: Worker Mode <-> Customer Mode
                InkWell(
                  onTap: () async {
                    if (isWorker) {
                      await auth.switchToCustomer();
                    } else {
                      await auth.switchToWorker();
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: isWorker ? AppColors.forestGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.forestGreen),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isWorker ? Icons.engineering : Icons.person_outline,
                          size: 15,
                          color: isWorker ? Colors.white : AppColors.forestGreen,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isWorker ? 'Worker' : 'Customer',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isWorker ? Colors.white : AppColors.forestGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Circular White Bell Icon Button
                Container(
                  width: 44,
                  height: 44,
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications: No pending alerts')),
                      );
                    },
                    icon: Icon(
                      Icons.notifications_none_rounded,
                      color: AppColors.forestGreen,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // PENDING VERIFICATION BANNER (FOR WORKERS)
            if (auth.isWorkerPendingVerification) ...[
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.pending.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.pending.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.pending, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pending Cooperative Verification',
                            style: TextStyle(
                              color: AppColors.pending,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            AppStrings.get(context, 'pending_verification_banner'),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.pending,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(
                                BottomSlideRoute(page: const DocumentUploadScreen()),
                              );
                            },
                            child: const Text(
                              'Upload verification documents now →',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.pending,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (isWorker) ...[
              _buildWorkerHubView(context, auth, user, categoryIcons),
            ] else ...[
              // BIG HERO HEADING (Figma exact: "Welcome Home , \nEnjoy Services")
              Text(
                'Welcome Home ,',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),
              Text(
                'Enjoy Services',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                  letterSpacing: -0.6,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 20),

              // LOCATION SEARCH PILL (Figma exact: Bhopal Central Co-op |)
              InkWell(
                onTap: () => _showSocietySwitcher(context),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
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
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppColors.coralPin, // Terracotta red pin
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user?.cooperativeName ?? 'Bhopal Central Co-op',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '|',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),

              // CATEGORY HEADER (Figma exact)
              Text(
                'Category',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 16),

              // CATEGORY TILES (Figma exact: 4 rounded square white tiles in a row with icons & labels)
              _buildFigmaCategoryRow(context, categoryCtrl, categoryIcons),
              const SizedBox(height: 24),

              // TRUST STRIP (Figma exact: 100% Verified | Fair Wage Split | Welfare Backed)
              const TrustStrip(),
              const SizedBox(height: 28),

              // AVAILABLE WORKERS (5 KM) - ONLY SHOWN FOR CUSTOMERS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.get(context, 'available_workers_title'),
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        BottomSlideRoute(
                          page: const WorkerListScreen(title: 'Available Workers (5 km)'),
                        ),
                      );
                    },
                    child: Text(
                      AppStrings.get(context, 'see_all'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Worker Feed (or Figma-style placeholder / cards)
              SizedBox(
                height: 215,
                child: _buildWorkerFeed(context, workerCtrl),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFigmaCategoryRow(
    BuildContext context,
    CategoryController categoryCtrl,
    Map<String, IconData> categoryIcons,
      ) {
    // If categories loaded from API, use them; otherwise use standard categories
    final categories = categoryCtrl.categories;

    final displayList = [
      {'name': 'Cleaning', 'icon': Icons.cleaning_services_rounded, 'id': 1},
      {'name': 'Electrical', 'icon': Icons.bolt_rounded, 'id': 2},
      {'name': 'Plumbing', 'icon': Icons.plumbing_rounded, 'id': 3},
      {'name': 'Carpentry', 'icon': Icons.handyman_rounded, 'id': 4},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        final fallback = displayList[index];
        final name = categories.length > index ? categories[index].name : fallback['name'] as String;
        final icon = categories.length > index
            ? (categoryIcons[categories[index].name] ?? fallback['icon'] as IconData)
            : fallback['icon'] as IconData;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 5,
              right: index == 3 ? 0 : 5,
            ),
            child: InkWell(
              onTap: () {
                final targetCategory = (categories.length > index)
                    ? categories[index]
                    : CategoryItem(
                        id: fallback['id'] as int,
                        name: fallback['name'] as String,
                      );
                categoryCtrl.selectCategory(targetCategory);
                Navigator.of(context).push(
                  BottomSlideRoute(
                    page: CategoryScreen(category: targetCategory),
                    settings: RouteSettings(name: '/category/${targetCategory.name}'),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(22),
              child: Column(
                children: [
                  // White rounded square tile
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          size: 26,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      name,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryLight,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildWorkerFeed(BuildContext context, WorkerController workerCtrl) {
    if (workerCtrl.isLoading && workerCtrl.workers.isEmpty) {
      // Figma loading placeholder bar
      return Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(24),
        ),
      );
    }

    if (workerCtrl.workers.isEmpty) {
      return Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search_rounded, size: 36, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No workers available in 5 km right now',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: workerCtrl.workers.length,
      separatorBuilder: (_, _) => const SizedBox(width: 12),
      itemBuilder: (context, index) {
        final worker = workerCtrl.workers[index];
        return WorkerMicroCard(
          worker: worker,
          onTap: () {
            Navigator.of(context).push(
              BottomSlideRoute(
                page: WorkerListScreen(
                  title: '${worker.name} (${worker.tradeCategory})',
                  preselectedWorkerId: worker.userId,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildWorkerHubView(
    BuildContext context,
    AuthController auth,
    User? user,
        Map<String, IconData> categoryIcons,
  ) {
    final workerProfile = user?.workerProfile;
    final isOnline = workerProfile?.availability ?? true;
    final trade = workerProfile?.tradeCategory ?? 'Cleaning';
    final bookingCtrl = Provider.of<BookingController>(context);
    final activeGigs = bookingCtrl.bookings
        .where((b) => b.status == 'pending' || b.status == 'accepted')
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HERO HEADING (Worker Partner Hub)
        Text(
          'Worker Partner Hub ,',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        Text(
          'Duty & Dispatch Desk',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimaryLight,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Bhopal Central Co-op · Hyper-local 5 km Matching',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 18),

        // 1. LIVE DUTY / ONLINE AVAILABILITY SWITCH CARD
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isOnline
                ? (const Color(0xFFF1F8F4))
                : (const Color(0xFFF9F9F9)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isOnline ? AppColors.forestGreen.withValues(alpha: 0.35) : Colors.grey.shade300,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isOnline
                    ? AppColors.forestGreen.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOnline ? AppColors.forestGreen : Colors.grey.shade400,
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: AppColors.forestGreen.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isOnline ? 'DUTY ONLINE' : 'DUTY OFFLINE',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: 0.5,
                            color: isOnline ? AppColors.forestGreen : Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: (isOnline ? AppColors.forestGreen : Colors.grey).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isOnline ? '5 km Active' : 'Paused',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isOnline ? AppColors.forestGreen : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isOnline
                          ? 'Visible to nearby customers in Bhopal Central Co-op'
                          : 'Turn on duty switch to receive nearby gig dispatches',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isOnline,
                activeThumbColor: AppColors.forestGreen,
                activeTrackColor: AppColors.forestGreen.withValues(alpha: 0.5),
                onChanged: (val) async {
                  await auth.toggleAvailability(val);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val
                              ? 'Duty Status: You are now ONLINE & receiving gigs!'
                              : 'Duty Status: You are now OFFLINE (Duty paused).',
                        ),
                        backgroundColor: val ? AppColors.forestGreen : Colors.grey.shade800,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 2. WORKER TRADE & CREDENTIALS CARD
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      categoryIcons[trade] ?? Icons.handyman_rounded,
                      color: AppColors.forestGreen,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$trade Specialist',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.verified_rounded, color: AppColors.forestGreen, size: 16),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.cooperativeName ?? 'Bhopal Central Co-op · Ward 14',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricPill(
                    icon: Icons.star_rounded,
                    iconColor: Colors.amber.shade700,
                    value: '${(workerProfile?.ratingAvg ?? 4.8).toStringAsFixed(1)} ★',
                    label: 'Co-op Rating',
                                      ),
                  _buildMetricPill(
                    icon: Icons.task_alt_rounded,
                    iconColor: AppColors.forestGreen,
                    value: '${workerProfile?.jobsCompleted ?? 0}',
                    label: 'Jobs Done',
                                      ),
                  _buildMetricPill(
                    icon: Icons.percent_rounded,
                    iconColor: AppColors.forestGreen,
                    value: '85%',
                    label: 'Take-Home',
                                      ),
                  _buildMetricPill(
                    icon: Icons.health_and_safety_rounded,
                    iconColor: AppColors.verified,
                    value: 'Active',
                    label: 'Welfare Fund',
                                      ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 3. COOPERATIVE FAIR WAGE BREAKDOWN STRIP
        const TrustStrip(),
        const SizedBox(height: 24),

        // 4. ACTION HUB (2x2 GRID)
        Text(
          'Quick Operations',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context: context,
                title: 'Job Requests',
                subtitle: 'Review & accept gigs',
                icon: Icons.assignment_turned_in_outlined,
                iconColor: AppColors.primaryLight,
                badgeText: bookingCtrl.pendingRequests.isNotEmpty
                    ? '${bookingCtrl.pendingRequests.length} New'
                    : null,
                                onTap: () {
                  Navigator.of(context).push(
                    BottomSlideRoute(page: const JobRequestsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context: context,
                title: 'My Earnings',
                subtitle: '85% wage payouts',
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.verified,
                badgeText: '₹${bookingCtrl.totalWorkerEarnings.toStringAsFixed(0)}',
                                onTap: () {
                  Navigator.of(context).push(
                    BottomSlideRoute(page: const EarningsScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context: context,
                title: 'KYC & Badges',
                subtitle: 'Aadhaar & clearance',
                icon: Icons.verified_user_outlined,
                iconColor: AppColors.forestGreen,
                badgeText: 'Verified',
                                onTap: () {
                  Navigator.of(context).push(
                    BottomSlideRoute(page: const DocumentUploadScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                context: context,
                title: 'Union Grievance',
                subtitle: 'Support & SOS desk',
                icon: Icons.support_agent_rounded,
                iconColor: AppColors.pending,
                                onTap: () {
                  Navigator.of(context).push(
                    BottomSlideRoute(page: const GrievanceScreen()),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),

        // 5. TODAY'S ACTIVE GIGS QUEUE
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Today's Gigs Queue",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
                color: AppColors.textPrimaryLight,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.forestGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${activeGigs.length} Active',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (activeGigs.isNotEmpty) ...[
          ...activeGigs.map((booking) => _buildActiveGigCard(context, booking)),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE2EBE5),
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.radar_rounded,
                    color: AppColors.forestGreen,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Waiting for nearby gig requests',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'You are Online in Bhopal Central Co-op. New $trade bookings within 5 km will show here automatically.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondaryLight,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMetricPill({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    String? badgeText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                if (badgeText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveGigCard(BuildContext context, Booking booking) {
    final isPending = booking.status == 'pending';
    final statusColor = isPending ? AppColors.pending : AppColors.forestGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2EBE5),
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
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPending ? Icons.pending_actions_rounded : Icons.handyman_rounded,
              color: statusColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking.serviceTitle ?? 'Home Service',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                    Text(
                      '₹${booking.workerPayout.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.forestGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${booking.customerName ?? 'Customer'} · ${booking.slotType.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      booking.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            color: Colors.grey.shade400,
            onPressed: () {
              Navigator.of(context).push(
                BottomSlideRoute(
                  page: BookingDetailScreen(
                    bookingId: booking.id,
                    initialBooking: booking,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showSocietySwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Cooperative Society',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Hyper-local 5 km matching applies from your society jurisdiction.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.forestGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_city, color: AppColors.forestGreen),
                ),
                title: const Text('Bhopal Central Co-op', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Bhopal Central & Old City Ward (Active 5 km)'),
                trailing: const Icon(Icons.check_circle_rounded, color: AppColors.forestGreen),
                onTap: () => Navigator.pop(ctx),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.location_city, color: Colors.grey),
                ),
                title: const Text('Indore South Labour Co-op', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Zone 3 · Expanding soon'),
                trailing: const Text('Coming Soon', style: TextStyle(fontSize: 11, color: Colors.grey)),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
        final auth = Provider.of<AuthController>(context);
    final isWorker = auth.currentUser?.isWorker ?? false;

    final List<Widget> tabs;
    final List<BottomNavigationBarItem> navItems;

    if (isWorker) {
      tabs = [
        _buildHomeTab(context),
        const JobRequestsScreen(),
        const EarningsScreen(),
        const ProfileScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Jobs'),
        BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_rounded), label: 'Earnings'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ];
    } else {
      tabs = [
        _buildHomeTab(context),
        const BookingHistoryScreen(),
        const ProfileScreen(),
      ];
      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today_rounded), label: 'Bookings'),
        BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profile'),
      ];
    }

    return Container(
      // THE SIGNATURE FIGMA SAGE/CREAM GRADIENT BACKGROUND
      decoration: BoxDecoration(
        gradient: AppColors.sageGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(
            index: _currentTabIndex.clamp(0, tabs.length - 1),
            children: tabs,
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentTabIndex.clamp(0, tabs.length - 1),
            onTap: (index) => setState(() => _currentTabIndex = index),
            selectedItemColor: AppColors.forestGreen,
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            items: navItems,
          ),
        ),
      ),
    );
  }
}
