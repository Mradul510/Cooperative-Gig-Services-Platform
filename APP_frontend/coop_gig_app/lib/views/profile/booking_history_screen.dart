import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/booking.dart';
import '../../config/config.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/bottom_slide_route.dart';
import '../booking/booking_detail_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingController>(context, listen: false).fetchBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingCtrl = Provider.of<BookingController>(context);
    final auth = Provider.of<AuthController>(context);
    final isWorker = auth.currentUser?.isWorker ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(context, 'booking_history')),
      ),
      body: RefreshIndicator(
        onRefresh: () => bookingCtrl.fetchBookings(),
        child: bookingCtrl.isLoading && bookingCtrl.bookings.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : bookingCtrl.bookings.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.history, size: 54, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text(
                            'No bookings recorded yet.',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Confirmed bookings and their fee splits will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: bookingCtrl.bookings.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final booking = bookingCtrl.bookings[index];
                      return _buildBookingItem(context, booking, isWorker, isDark);
                    },
                  ),
      ),
    );
  }

  Widget _buildBookingItem(BuildContext context, Booking booking, bool isWorker, bool isDark) {
    final otherParty = isWorker
        ? (booking.customerName ?? 'Customer')
        : (booking.workerName ?? 'Worker');

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            BottomSlideRoute(
              page: BookingDetailScreen(bookingId: booking.id, initialBooking: booking),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      booking.serviceTitle ?? 'Service Visit',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                  StatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    isWorker ? Icons.person_outline : Icons.engineering_outlined,
                    size: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      otherParty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppConfig.formatINR(booking.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      booking.createdAt.isNotEmpty
                          ? DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.tryParse(booking.createdAt) ?? DateTime.now())
                          : '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Worker 85% (${AppConfig.formatINR(booking.workerPayout)})',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.verified,
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
}

