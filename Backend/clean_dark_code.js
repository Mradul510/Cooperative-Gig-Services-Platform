const fs = require('fs');
const path = require('path');

function cleanFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');

  // Specific replacements
  content = content.replace(/isDark \? AppColors\.darkSageGradient : AppColors\.sageGradient/g, 'AppColors.sageGradient');
  content = content.replace(/isDark \? AppColors\.surfaceDark : Colors\.white/g, 'Colors.white');
  content = content.replace(/isDark \? AppColors\.surfaceDark : const Color\(0xFFF1F8F4\)/g, 'const Color(0xFFF1F8F4)');
  content = content.replace(/isDark \? AppColors\.surfaceDark : const Color\(0xFFF9F9F9\)/g, 'const Color(0xFFF9F9F9)');
  content = content.replace(/isDark \? AppColors\.borderDark : const Color\(0xFFE2EBE5\)/g, 'const Color(0xFFE2EBE5)');
  content = content.replace(/isDark \? AppColors\.borderDark : AppColors\.borderLight/g, 'AppColors.borderLight');
  content = content.replace(/isDark \? AppColors\.textPrimaryDark : AppColors\.textPrimaryLight/g, 'AppColors.textPrimaryLight');
  content = content.replace(/isDark \? AppColors\.textPrimaryDark : AppColors\.forestGreen/g, 'AppColors.forestGreen');
  content = content.replace(/isDark \? AppColors\.textSecondaryDark : AppColors\.textSecondaryLight/g, 'AppColors.textSecondaryLight');
  content = content.replace(/Colors\.black\.withValues\(alpha: isDark \? 0\.2 : 0\.04\)/g, 'Colors.black.withValues(alpha: 0.04)');
  content = content.replace(/Colors\.black\.withValues\(alpha: isDark \? 0\.2 : 0\.03\)/g, 'Colors.black.withValues(alpha: 0.03)');
  content = content.replace(/Colors\.black\.withValues\(alpha: isDark \? 0\.25 : 0\.04\)/g, 'Colors.black.withValues(alpha: 0.04)');

  // Remove unused isDark declarations
  content = content.replace(/const isDark = false;\r?\n/g, '');
  content = content.replace(/, bool isDark\)/g, ')');
  content = content.replace(/bool isDark,\r?\n/g, '');
  content = content.replace(/required bool isDark,\r?\n/g, '');
  content = content.replace(/isDark: isDark,\r?\n/g, '');
  content = content.replace(/, isDark\)/g, ')');

  fs.writeFileSync(filePath, content, 'utf8');
  console.log('Cleaned:', filePath);
}

const baseDir = path.join(__dirname, '..', 'APP_frontend', 'coop_gig_app', 'lib');
cleanFile(path.join(baseDir, 'views', 'category', 'category_screen.dart'));
cleanFile(path.join(baseDir, 'views', 'home', 'home_screen.dart'));
