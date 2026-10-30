import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
import '../worker/job_requests_screen.dart';
import '../worker/earnings_screen.dart';
import '../worker/document_upload_screen.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthController>(context);
    final categoryCtrl = Provider.of<CategoryController>(context);
    final workerCtrl = Provider.of<WorkerController>(context);
    final user = auth.currentUser;

    // Default trade icons & symbols as in Figma (Cleaning 🧹, Electrical ⚡, Plumbing 🔧, AC Service ❄️)
    final categoryIcons = {
      'Cleaning': '🧹',
      'Electrical': '⚡',
      'Plumbing': '🔧',
      'AC Service': '❄️',
      'Carpentry': '🪚',
    };

    return RefreshIndicator(
      onRefresh: () async {
        await categoryCtrl.fetchCategories();
        await workerCtrl.fetchWorkers();
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
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
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
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                // Circular White Bell Icon Button
                Container(
                  width: 44,
                  height: 44,
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications: No pending alerts')),
                      );
                    },
                    icon: const Text('🔔', style: TextStyle(fontSize: 18)),
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

            // BIG HERO HEADING (Figma exact: "Welcome Home , \nEnjoy Services")
            Text(
              'Welcome Home ,',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                letterSpacing: -0.6,
                height: 1.15,
              ),
            ),
            Text(
              'Enjoy Services',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                letterSpacing: -0.6,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 20),

            // LOCATION SEARCH PILL (Figma exact: 📍 Bhopal Central Co-op |)
            InkWell(
              onTap: () => _showSocietySwitcher(context),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
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
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),

            // CATEGORY TILES (Figma exact: 4 rounded square white tiles in a row with icons & labels)
            _buildFigmaCategoryRow(context, categoryCtrl, categoryIcons, isDark),
            const SizedBox(height: 24),

            // TRUST STRIP (Figma exact: 🛡️ 100% Verified | ⚖️ Fair Wage Split | 🏥 Welfare Backed)
            const TrustStrip(),
            const SizedBox(height: 28),

            // AVAILABLE WORKERS (5 KM) (Figma exact)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.get(context, 'available_workers_title'),
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
        ),
      ),
    );
  }

  Widget _buildFigmaCategoryRow(
    BuildContext context,
    CategoryController categoryCtrl,
    Map<String, String> categoryIcons,
    bool isDark,
  ) {
    // If categories loaded from API, use them; otherwise use standard Figma categories
    final categories = categoryCtrl.categories.isNotEmpty
        ? categoryCtrl.categories
        : [];

    final displayList = [
      {'name': 'Cleaning', 'emoji': '🧹'},
      {'name': 'Electrical', 'emoji': '⚡'},
      {'name': 'Plumbing', 'emoji': '🔧'},
      {'name': 'AC Service', 'emoji': '❄️'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(4, (index) {
        final fallback = displayList[index];
        final name = categories.length > index ? categories[index].name : fallback['name']!;
        final emoji = categories.length > index
            ? (categories[index].icon ?? categoryIcons[categories[index].name] ?? fallback['emoji']!)
            : fallback['emoji']!;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : 5,
              right: index == 3 ? 0 : 5,
            ),
            child: InkWell(
              onTap: () {
                if (categories.length > index) {
                  categoryCtrl.selectCategory(categories[index]);
                  Navigator.of(context).push(
                    BottomSlideRoute(page: CategoryScreen(category: categories[index])),
                  );
                } else if (categories.isNotEmpty) {
                  categoryCtrl.selectCategory(categories.first);
                  Navigator.of(context).push(
                    BottomSlideRoute(page: CategoryScreen(category: categories.first)),
                  );
                }
              },
              borderRadius: BorderRadius.circular(22),
              child: Column(
                children: [
                  // White rounded square tile
                  Container(
                    height: 72,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
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
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        gradient: isDark ? AppColors.darkSageGradient : AppColors.sageGradient,
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
            color: isDark ? AppColors.surfaceDark : Colors.white,
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
