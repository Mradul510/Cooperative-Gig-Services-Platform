import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/booking.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/fee_breakdown_card.dart';
import '../../widgets/bottom_slide_route.dart';
import '../profile/grievance_screen.dart';
import 'rating_sheet.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;
  final Booking? initialBooking;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
    this.initialBooking,
  });

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingController>(context, listen: false).fetchBookings();
    });
  }

  void _handleStatusChange(String newStatus) async {
    final bookingCtrl = Provider.of<BookingController>(context, listen: false);
    final success = await bookingCtrl.updateStatus(widget.bookingId, newStatus);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking status updated to $newStatus'),
          backgroundColor: AppColors.verified,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingCtrl.errorMessage ?? 'Failed to update status'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _openRatingSheet(Booking booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => RatingSheet(
        bookingId: booking.id,
        workerName: booking.workerName ?? 'Worker',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingCtrl = Provider.of<BookingController>(context);
    final auth = Provider.of<AuthController>(context);
    final currentUser = auth.currentUser;

    Booking? booking;
    try {
      booking = bookingCtrl.bookings.firstWhere((b) => b.id == widget.bookingId);
    } catch (_) {
      booking = widget.initialBooking;
    }

    if (booking == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Booking Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final isWorker = currentUser?.isWorker ?? false;
    final otherPartyName = isWorker
        ? (booking.customerName ?? 'Customer')
        : (booking.workerName ?? 'Worker');
    final otherPartyMobile = isWorker ? booking.customerMobile : booking.workerMobile;

    return Scaffold(
      appBar: AppBar(
        title: Text('Booking #${booking.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem_outlined),
            tooltip: AppStrings.get(context, 'file_grievance'),
            onPressed: () {
              Navigator.of(context).push(
                BottomSlideRoute(
                  page: GrievanceScreen(preselectedBookingId: booking?.id),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.serviceTitle ?? 'Service Visit',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          booking.bookingTime != null
                              ? DateFormat('EEE, dd MMM yyyy · hh:mm a').format(
                                  DateTime.tryParse(booking.bookingTime!) ?? DateTime.now())
                              : 'Immediate Slot',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(status: booking.status),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Contact Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                    child: Text(
                      otherPartyName.isNotEmpty ? otherPartyName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherPartyName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                        if (otherPartyMobile != null && otherPartyMobile.isNotEmpty)
                          Text(
                            otherPartyMobile,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.verified.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.phone, size: 20, color: AppColors.verified),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling $otherPartyName at $otherPartyMobile')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Fee Breakdown Card (PRD B-1)
            FeeBreakdownCard(
              totalAmount: booking.totalAmount,
              workerPayout: booking.workerPayout,
              welfarePayout: booking.welfarePayout,
              platformPayout: booking.platformPayout,
            ),
            const SizedBox(height: 16),

            // Rating display if completed & rated
            if (booking.isCompleted && booking.rating != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.pending, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Rated ${booking.rating} / 5 Stars',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    if (booking.ratingNote != null && booking.ratingNote!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '"${booking.ratingNote}"',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Action Buttons based on Role & State
            if (isWorker) ...[
              if (booking.isPending) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.verified),
                        onPressed: () => _handleStatusChange('accepted'),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(AppStrings.get(context, 'accept_job')),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                        onPressed: () => _handleStatusChange('cancelled'),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(AppStrings.get(context, 'decline_job')),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (booking.isAccepted) ...[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.verified),
                  onPressed: () => _handleStatusChange('completed'),
                  child: const FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text('Mark Job Completed ✓'),
                  ),
                ),
              ],
            ] else ...[
              // Customer Controls
              if (booking.isPending) ...[
                OutlinedButton(
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () => _handleStatusChange('cancelled'),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(AppStrings.get(context, 'cancel_booking')),
                  ),
                ),
              ] else if (booking.isCompleted && booking.rating == null) ...[
                ElevatedButton(
                  onPressed: () => _openRatingSheet(booking!),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(AppStrings.get(context, 'rate_worker')),
                  ),
                ),
              ],
            ],
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
