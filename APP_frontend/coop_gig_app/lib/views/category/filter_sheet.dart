import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/worker_controller.dart';
import '../../config/theme.dart';

class FilterSheet extends StatefulWidget {
  final String? category;
  const FilterSheet({super.key, this.category});

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late double _radius;
  late bool _onlyAvailable;

  @override
  void initState() {
    super.initState();
    final workerCtrl = Provider.of<WorkerController>(context, listen: false);
    _radius = workerCtrl.radiusKm;
    _onlyAvailable = workerCtrl.availabilityFilter;
  }

  @override
  Widget build(BuildContext context) {
    final workerCtrl = Provider.of<WorkerController>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Text(
                'Dispatch Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Maximum Radius Slider (1 km to 5 km)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Search Radius', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '${_radius.toStringAsFixed(1)} km (Max 5 km)',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                  ),
                ],
              ),
              Slider(
                value: _radius,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                activeColor: AppColors.primaryLight,
                onChanged: (val) => setState(() => _radius = val),
              ),
              const SizedBox(height: 12),

              // Availability toggle
              SwitchListTile(
                title: const Text('Show available workers only', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Workers currently online and ready to accept jobs'),
                value: _onlyAvailable,
                activeThumbColor: AppColors.verified,
                contentPadding: EdgeInsets.zero,
                onChanged: (val) => setState(() => _onlyAvailable = val),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: () {
                  workerCtrl.setRadius(_radius);
                  workerCtrl.setAvailabilityFilter(_onlyAvailable);
                  workerCtrl.fetchWorkers(category: widget.category);
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
