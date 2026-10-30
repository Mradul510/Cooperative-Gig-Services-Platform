import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/booking_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../widgets/status_badge.dart';

class GrievanceScreen extends StatefulWidget {
  final int? preselectedBookingId;

  const GrievanceScreen({super.key, this.preselectedBookingId});

  @override
  State<GrievanceScreen> createState() => _GrievanceScreenState();
}

class _GrievanceScreenState extends State<GrievanceScreen> {
  int? _selectedBookingId;
  final TextEditingController _descController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedBookingId = widget.preselectedBookingId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingCtrl = Provider.of<BookingController>(context, listen: false);
      bookingCtrl.fetchBookings();
      bookingCtrl.fetchGrievances();
    });
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  void _submitGrievance() async {
    final desc = _descController.text.trim();
    if (_selectedBookingId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a booking to file grievance against')),
      );
      return;
    }
    if (desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description of the issue')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final bookingCtrl = Provider.of<BookingController>(context, listen: false);
    final success = await bookingCtrl.fileGrievance(_selectedBookingId!, desc);
    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      _descController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Grievance filed successfully. Cooperative desk will resolve within 72 hrs.'),
          backgroundColor: AppColors.verified,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingCtrl.errorMessage ?? 'Failed to file grievance'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bookingCtrl = Provider.of<BookingController>(context);
    final auth = Provider.of<AuthController>(context);
    final user = auth.currentUser;

    final bookings = bookingCtrl.bookings;
    final grievances = bookingCtrl.grievances;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(context, 'grievance_desk')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Society Contact Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.support_agent, color: AppColors.primaryLight, size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          user?.cooperativeName ?? 'Bhopal Central Labour Cooperative',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Helpline: +91 755 2400100  ·  Email: desk@coopbhopal.in\nResolution guarantee: Under 72 hours under Cooperative By-laws.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Grievance Filing Form
            Text(
              AppStrings.get(context, 'file_grievance'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),

            // Booking Dropdown
            DropdownButtonFormField<int>(
              initialValue: _selectedBookingId,
              isExpanded: true,
              hint: const Text('Select related booking'),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              items: bookings.map((b) {
                return DropdownMenuItem<int>(
                  value: b.id,
                  child: Text(
                    'Booking #${b.id} - ${b.serviceTitle ?? "Service"} (${b.status})',
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedBookingId = val),
            ),
            const SizedBox(height: 12),

            // Description TextField
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: AppStrings.get(context, 'grievance_desc'),
              ),
            ),
            const SizedBox(height: 14),

            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitGrievance,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(AppStrings.get(context, 'submit')),
            ),
            const SizedBox(height: 24),

            // Previously Filed Grievances
            const Text(
              'Your Grievance Records',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),

            if (grievances.isEmpty) ...[
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
                    Icon(Icons.check_circle_outline, color: AppColors.verified, size: 36),
                    SizedBox(height: 8),
                    Text(
                      'No grievances on record. Excellent service record!',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ] else ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: grievances.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final g = grievances[index];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Grievance #${g.id} (Booking #${g.bookingId})',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            StatusBadge(status: g.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          g.description,
                          style: const TextStyle(fontSize: 13),
                        ),
                        if (g.isResolved && g.resolutionNote != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.verified.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check, size: 14, color: AppColors.verified),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Resolution: ${g.resolutionNote}',
                                    style: const TextStyle(
                                      color: AppColors.verified,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
