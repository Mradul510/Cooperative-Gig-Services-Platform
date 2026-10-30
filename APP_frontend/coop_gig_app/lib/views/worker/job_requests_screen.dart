import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/worker_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/booking.dart';
import '../../config/config.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../widgets/availability_toggle.dart';
import '../../widgets/bottom_slide_route.dart';
import '../booking/booking_detail_screen.dart';

class JobRequestsScreen extends StatefulWidget {
  const JobRequestsScreen({super.key});

  @override
  State<JobRequestsScreen> createState() => _JobRequestsScreenState();
}

class _JobRequestsScreenState extends State<JobRequestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingController>(context, listen: false).fetchBookings();
    });
  }

  void _respondToRequest(int bookingId, String status) async {
    final bookingCtrl = Provider.of<BookingController>(context, listen: false);
    final success = await bookingCtrl.updateStatus(bookingId, status);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'accepted' ? 'Job accepted!' : 'Job declined'),
          backgroundColor: status == 'accepted' ? AppColors.verified : AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingCtrl = Provider.of<BookingController>(context);
    final workerCtrl = Provider.of<WorkerController>(context);
    final auth = Provider.of<AuthController>(context);
    final workerProfile = auth.currentUser?.workerProfile;

    final pendingRequests = bookingCtrl.pendingRequests;
    final activeJobs = bookingCtrl.activeAcceptedJobs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooperative Job Dispatch'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: AvailabilityToggle(
                isOnline: workerProfile?.availability ?? true,
                onChanged: (val) async {
                  await workerCtrl.toggleAvailability(val);
                  await auth.refreshProfile();
                },
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => bookingCtrl.fetchBookings(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Requests Section
              Row(
                children: [
                  const Text(
                    'Incoming Job Requests',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: pendingRequests.isNotEmpty ? AppColors.pending : Colors.grey,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${pendingRequests.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (pendingRequests.isEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.inbox_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No new incoming requests at the moment.',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pendingRequests.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final req = pendingRequests[index];
                    return _buildRequestCard(context, req, isDark);
                  },
                ),
              ],
              const SizedBox(height: 24),

              // Active Accepted Jobs Section
              if (activeJobs.isNotEmpty) ...[
                const Text(
                  'Active Jobs in Progress',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeJobs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final job = activeJobs[index];
                    return _buildActiveJobCard(context, job, isDark);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, Booking req, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.pending.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  req.serviceTitle ?? 'Service Visit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Earn ${AppConfig.formatINR(req.workerPayout)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.verified,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Household: ${req.customerName ?? "Customer"}  ·  ${req.slotType == "immediate" ? "Immediate Dispatch" : "Scheduled Slot"}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.verified),
                  onPressed: () => _respondToRequest(req.id, 'accepted'),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(AppStrings.get(context, 'accept_job')),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () => _respondToRequest(req.id, 'cancelled'),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(AppStrings.get(context, 'decline_job')),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveJobCard(BuildContext context, Booking job, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  job.serviceTitle ?? 'Service Visit',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppConfig.formatINR(job.workerPayout),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.verified,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Customer: ${job.customerName ?? "Customer"} (${job.customerMobile ?? ""})',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      BottomSlideRoute(
                        page: BookingDetailScreen(bookingId: job.id, initialBooking: job),
                      ),
                    );
                  },
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('View Details'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.verified),
                  onPressed: () => _respondToRequest(job.id, 'completed'),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Mark Complete ✓'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
