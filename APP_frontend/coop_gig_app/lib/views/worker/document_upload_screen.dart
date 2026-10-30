import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/worker_controller.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../widgets/status_badge.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadDoc(String docType) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (!mounted) return;
    final workerCtrl = Provider.of<WorkerController>(context, listen: false);
    final auth = Provider.of<AuthController>(context, listen: false);

    final success = await workerCtrl.uploadDocument(docType, image.path);
    if (!mounted) return;

    if (success) {
      await auth.refreshProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document uploaded successfully for review!'),
          backgroundColor: AppColors.verified,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(workerCtrl.errorMessage ?? 'Upload failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = Provider.of<AuthController>(context);
    final profile = auth.currentUser?.workerProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cooperative Verification Docs'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: AppColors.primaryLight, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All cooperative tradespeople are 100% verified for identity, police clearance, and trade skills before dispatch.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 1. Aadhaar Identity Document
            _buildDocCard(
              context,
              title: AppStrings.get(context, 'doc_aadhaar'),
              subtitle: 'Government issued identity card (PDF/JPEG)',
              icon: Icons.badge_outlined,
              status: profile?.aadhaarStatus ?? 'pending',
              rejectionReason: profile?.aadhaarRejectionReason,
              docField: 'aadhaar_doc',
              isDark: isDark,
            ),
            const SizedBox(height: 14),

            // 2. Police Verification Certificate
            _buildDocCard(
              context,
              title: AppStrings.get(context, 'doc_police'),
              subtitle: 'Character certificate from local police station',
              icon: Icons.local_police_outlined,
              status: profile?.policeStatus ?? 'pending',
              rejectionReason: profile?.policeRejectionReason,
              docField: 'police_doc',
              isDark: isDark,
            ),
            const SizedBox(height: 14),

            // 3. Trade Certificate
            _buildDocCard(
              context,
              title: AppStrings.get(context, 'doc_trade'),
              subtitle: 'ITI certificate, skill diploma or cooperative reference',
              icon: Icons.workspace_premium_outlined,
              status: profile?.certificateStatus ?? 'pending',
              rejectionReason: profile?.certificateRejectionReason,
              docField: 'certificate_doc',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String status,
    required String? rejectionReason,
    required String docField,
    required bool isDark,
  }) {
    return Container(
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
              Icon(icon, color: AppColors.primaryLight, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
              StatusBadge(status: status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          if (rejectionReason != null && rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Rejection Reason: $rejectionReason',
                style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _uploadDoc(docField),
            icon: const Icon(Icons.file_upload_outlined, size: 16),
            label: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(AppStrings.get(context, 'upload_doc')),
            ),
          ),
        ],
      ),
    );
  }
}
