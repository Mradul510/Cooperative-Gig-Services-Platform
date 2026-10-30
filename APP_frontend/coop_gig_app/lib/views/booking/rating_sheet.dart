import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/booking_controller.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';

class RatingSheet extends StatefulWidget {
  final int bookingId;
  final String workerName;

  const RatingSheet({
    super.key,
    required this.bookingId,
    required this.workerName,
  });

  @override
  State<RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<RatingSheet> {
  int _rating = 5;
  final TextEditingController _noteController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _submitRating() async {
    setState(() => _isSubmitting = true);
    final bookingCtrl = Provider.of<BookingController>(context, listen: false);
    final success = await bookingCtrl.rateBooking(
      widget.bookingId,
      _rating,
      _noteController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thank you! Your rating has been recorded.'),
          backgroundColor: AppColors.verified,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bookingCtrl.errorMessage ?? 'Failed to submit rating'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                Text(
                  '${AppStrings.get(context, 'rate_worker')}: ${widget.workerName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.get(context, 'rate_experience'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 18),

                // Star Rating Row
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return IconButton(
                        icon: Icon(
                          starIndex <= _rating ? Icons.star : Icons.star_border,
                          size: 34,
                          color: AppColors.pending,
                        ),
                        onPressed: () => setState(() => _rating = starIndex),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 14),

                // Optional Note TextField
                TextField(
                  controller: _noteController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Share a brief review (optional)...',
                  ),
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRating,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(AppStrings.get(context, 'submit_rating')),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

