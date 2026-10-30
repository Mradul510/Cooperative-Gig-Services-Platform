import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../providers/settings_provider.dart';
import '../../config/theme.dart';
import '../../config/localization.dart';
import '../../widgets/bottom_slide_route.dart';
import '../home/home_screen.dart';

class AuthSheet extends StatefulWidget {
  const AuthSheet({super.key});

  @override
  State<AuthSheet> createState() => _AuthSheetState();
}

class _AuthSheetState extends State<AuthSheet> {
  bool _isLogin = true;

  // Login form controllers
  final _loginIdentifierController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register form controllers
  final _regNameController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regMobileController = TextEditingController();
  final _regPasswordController = TextEditingController();
  String _selectedRole = 'customer'; // 'customer' or 'worker'

  bool _obscurePassword = true;

  @override
  void dispose() {
    _loginIdentifierController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regEmailController.dispose();
    _regMobileController.dispose();
    _regPasswordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    final identifier = _loginIdentifierController.text.trim();
    final password = _loginPasswordController.text.trim();

    if (identifier.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both identifier and password')),
      );
      return;
    }

    final auth = Provider.of<AuthController>(context, listen: false);
    final success = await auth.login(identifier, password);
    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        BottomSlideRoute(page: const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _submitRegister() async {
    final name = _regNameController.text.trim();
    final email = _regEmailController.text.trim();
    final mobile = _regMobileController.text.trim();
    final password = _regPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || mobile.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all registration fields')),
      );
      return;
    }

    final auth = Provider.of<AuthController>(context, listen: false);
    final success = await auth.register(
      name: name,
      email: email,
      mobile: mobile,
      password: password,
      role: _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacement(
        BottomSlideRoute(page: const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settings = Provider.of<SettingsProvider>(context);
    final auth = Provider.of<AuthController>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              // Top drag indicator
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

              // Language toggle + header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isLogin
                        ? AppStrings.get(context, 'login')
                        : AppStrings.get(context, 'register'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      final newLang = settings.locale.languageCode == 'en' ? 'hi' : 'en';
                      settings.setLocale(newLang);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.language, size: 14, color: AppColors.primaryLight),
                          const SizedBox(width: 4),
                          Text(
                            settings.locale.languageCode == 'en' ? 'हिन्दी' : 'English',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tab Toggle: Login vs Register
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isLogin ? AppColors.primaryLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            AppStrings.get(context, 'login'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _isLogin ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isLogin = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isLogin ? AppColors.primaryLight : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            AppStrings.get(context, 'register'),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: !_isLogin ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_isLogin) ...[
                // LOGIN FORM
                TextField(
                  controller: _loginIdentifierController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get(context, 'email_or_mobile'),
                    prefixIcon: const Icon(Icons.person_outline, size: 20),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _loginPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.get(context, 'password'),
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submitLogin,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(AppStrings.get(context, 'sign_in')),
                ),
              ] else ...[
                // REGISTER FORM
                TextField(
                  controller: _regNameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get(context, 'full_name'),
                    prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: AppStrings.get(context, 'email'),
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regMobileController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: AppStrings.get(context, 'mobile'),
                    prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _regPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: AppStrings.get(context, 'password'),
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ROLE SELECTOR
                Text(
                  AppStrings.get(context, 'select_role'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: Text(AppStrings.get(context, 'customer')),
                        selected: _selectedRole == 'customer',
                        onSelected: (val) => setState(() => _selectedRole = 'customer'),
                        selectedColor: AppColors.primaryLight.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: _selectedRole == 'customer' ? AppColors.primaryLight : null,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: Text(AppStrings.get(context, 'worker')),
                        selected: _selectedRole == 'worker',
                        onSelected: (val) => setState(() => _selectedRole = 'worker'),
                        selectedColor: AppColors.verified.withValues(alpha: 0.15),
                        labelStyle: TextStyle(
                          color: _selectedRole == 'worker' ? AppColors.verified : null,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedRole == 'worker') ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.pending.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.pending.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 16, color: AppColors.pending),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            AppStrings.get(context, 'pending_verification_banner'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.pending,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submitRegister,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(AppStrings.get(context, 'sign_up')),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
  );
  }
}
