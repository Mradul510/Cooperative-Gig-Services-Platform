import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/worker.dart';
import '../../models/service.dart';
import '../../controllers/booking_controller.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../widgets/fee_breakdown_card.dart';
import '../../widgets/bottom_slide_route.dart';
import 'booking_detail_screen.dart';

class BookingSheet extends StatefulWidget {
  final WorkerFeedItem worker;
  final ServiceItem service;

  const BookingSheet({
    super.key,
    required this.worker,
    required this.service,
  });

  @override
  State<BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<BookingSheet> {
  String _slotType = 'immediate'; // 'immediate' or 'scheduled'
  DateTime _scheduledDate = DateTime.now().add(const Duration(hours: 2));
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 14, minute: 0);

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 14)),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );
    if (picked != null) {
      setState(() => _scheduledTime = picked);
    }
  }

  void _confirmBooking() async {
    final bookingCtrl = Provider.of<BookingController>(context, listen: false);

    String? bookingTimeIso;
    if (_slotType == 'scheduled') {
      final combined = DateTime(
        _scheduledDate.year,
        _scheduledDate.month,
        _scheduledDate.day,
        _scheduledTime.hour,
        _scheduledTime.minute,
      );
      bookingTimeIso = combined.toIso8601String();
    } else {
      bookingTimeIso = DateTime.now().toIso8601String();
    }

    final booking = await bookingCtrl.createBooking(
      workerId: widget.worker.userId,
      serviceId: widget.service.id,
      slotType: _slotType,
      bookingTime: bookingTimeIso,
    );

    if (!mounted) return;

    if (booking != null) {
      Navigator.pop(context); // close sheet
      Navigator.of(context).push(
        BottomSlideRoute(
          page: BookingDetailScreen(bookingId: booking.id, initialBooking: booking),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingCtrl.errorMessage ?? 'Failed to confirm booking'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingCtrl = Provider.of<BookingController>(context);

    final service = widget.service;
    final worker = widget.worker;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Worker Summary Card
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
                    child: Text(
                      worker.name.isNotEmpty ? worker.name[0].toUpperCase() : 'W',
                      style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          worker.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        Text(
                          '${service.title}  ·  ${worker.distanceKm.toStringAsFixed(1)} km away',
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
                ],
              ),
              const SizedBox(height: 16),

              // Slot Selector: Immediate vs Scheduled (B-2)
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppStrings.get(context, 'slot_immediate'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _slotType == 'immediate' ? AppColors.primaryLight : null,
                            ),
                          ),
                        ),
                      ),
                      selected: _slotType == 'immediate',
                      onSelected: (val) => setState(() => _slotType = 'immediate'),
                      selectedColor: AppColors.primaryLight.withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ChoiceChip(
                      label: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            AppStrings.get(context, 'slot_scheduled'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _slotType == 'scheduled' ? AppColors.primaryLight : null,
                            ),
                          ),
                        ),
                      ),
                      selected: _slotType == 'scheduled',
                      onSelected: (val) => setState(() => _slotType = 'scheduled'),
                      selectedColor: AppColors.primaryLight.withValues(alpha: 0.15),
                    ),
                  ),
                ],
              ),

            // If Scheduled, show date & time picker
            if (_slotType == 'scheduled') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 16, color: AppColors.primaryLight),
                            const SizedBox(width: 8),
                            Text(
                              DateFormat('EEE, dd MMM').format(_scheduledDate),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(height: 20, width: 1, color: Theme.of(context).dividerColor),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.access_time, size: 16, color: AppColors.primaryLight),
                            const SizedBox(width: 8),
                            Text(
                              _scheduledTime.format(context),
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // PRD B-1: Fee Breakdown Card (85% worker, 10% welfare, 5% platform)
            FeeBreakdownCard(
              totalAmount: service.basePrice,
              workerPayout: service.workerPayout,
              welfarePayout: service.welfarePayout,
              platformPayout: service.platformPayout,
            ),
            const SizedBox(height: 20),

            // Confirm Booking Button (B-3)
            ElevatedButton(
              onPressed: bookingCtrl.isLoading ? null : _confirmBooking,
              child: bookingCtrl.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(AppStrings.get(context, 'confirm_booking')),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    ),
  );
  }
}
