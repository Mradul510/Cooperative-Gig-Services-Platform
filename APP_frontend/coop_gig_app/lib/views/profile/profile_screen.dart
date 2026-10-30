import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../providers/settings_provider.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../widgets/verified_badge.dart';
import '../../widgets/bottom_slide_route.dart';
import '../auth/splash_screen.dart';
import '../worker/document_upload_screen.dart';
import '../worker/earnings_screen.dart';
import 'booking_history_screen.dart';
import 'grievance_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthController>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final user = auth.currentUser;

    final isWorker = user?.isWorker ?? false;
    final workerProfile = user?.workerProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get(context, 'profile')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // USER INFO CARD (P-2)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: AppColors.primaryLight,
                    child: Text(
                      user != null && user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Member',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user?.email ?? ""}  ·  ${user?.mobile ?? ""}',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      VerifiedBadge(isVerified: user?.isVerified ?? false),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          user?.cooperativeName ?? 'Bhopal Central Co-op',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isWorker && workerProfile?.cooperativeRegNo != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Co-op Reg ID: ${workerProfile!.cooperativeRegNo!}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // WORKER DOCUMENT STATUS / UPLOADER (P-2)
            if (isWorker) ...[
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: ListTile(
                  leading: const Icon(Icons.file_copy_outlined, color: AppColors.primaryLight),
                  title: const Text('Cooperative Documents & Verification', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    user?.isVerified == true ? 'All 3 documents approved' : 'Review pending or incomplete',
                    style: TextStyle(
                      fontSize: 12,
                      color: user?.isVerified == true ? AppColors.verified : AppColors.pending,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.of(context).push(
                      BottomSlideRoute(page: const DocumentUploadScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: ListTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.verified),
                  title: Text(AppStrings.get(context, 'earnings'), style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('85% worker living wage receipts', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    Navigator.of(context).push(
                      BottomSlideRoute(page: const EarningsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // BOOKINGS & GRIEVANCE SHORTCUTS (P-3 & P-4)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primaryLight),
                    title: Text(AppStrings.get(context, 'booking_history'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).push(
                        BottomSlideRoute(page: const BookingHistoryScreen()),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.support_agent_outlined, color: AppColors.primaryLight),
                    title: Text(AppStrings.get(context, 'grievance_desk'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Resolution guaranteed within 72 hours', style: TextStyle(fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                    onTap: () {
                      Navigator.of(context).push(
                        BottomSlideRoute(page: const GrievanceScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // PREFERENCES (P-1 & P-5)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                children: [
                  // P-1: Dark Mode Toggle
                  SwitchListTile.adaptive(
                    secondary: const Icon(Icons.dark_mode_outlined, color: AppColors.primaryLight),
                    title: Text(AppStrings.get(context, 'dark_mode'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    value: settings.isDarkMode,
                    activeThumbColor: AppColors.primaryLight,
                    onChanged: (val) => settings.toggleTheme(val),
                  ),
                  const Divider(),
                  // P-5: Language Switch
                  ListTile(
                    leading: const Icon(Icons.language_outlined, color: AppColors.primaryLight),
                    title: Text(AppStrings.get(context, 'language'), style: const TextStyle(fontWeight: FontWeight.w600)),
                    trailing: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'en', label: Text('EN')),
                        ButtonSegment(value: 'hi', label: Text('हिं')),
                      ],
                      selected: {settings.locale.languageCode},
                      onSelectionChanged: (set) {
                        settings.setLocale(set.first);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // LOGOUT BUTTON
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
              ),
              onPressed: () async {
                await auth.logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  BottomSlideRoute(page: const SplashScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, size: 18),
              label: Text(AppStrings.get(context, 'logout')),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

