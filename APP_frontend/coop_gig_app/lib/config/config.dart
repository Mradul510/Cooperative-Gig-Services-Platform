import 'package:intl/intl.dart';

class AppConfig {
  // Using localhost or 10.0.2.2 for Android emulator
  static String apiBaseUrl = 'http://localhost:3000/api';
  
  static const int connectionTimeoutSeconds = 15;
  static const double maxDispatchRadiusKm = 5.0;

  // PRD fee split standards (85/10/5)
  static const double defaultWorkerCut = 85.0;
  static const double defaultWelfareCut = 10.0;
  static const double defaultPlatformCut = 5.0;

  // Currency Formatter for Indian Rupee (INR)
  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inrWholeFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String formatINR(num amount) {
    return _inrFormat.format(amount);
  }

  static String formatINRWhole(num amount) {
    return _inrWholeFormat.format(amount);
  }
}

