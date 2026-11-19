// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'CoopGig';

  @override
  String get welcomeBack => 'वापस स्वागत है,';

  @override
  String get login => 'लॉगिन करें';

  @override
  String get register => 'पंजीकरण करें';

  @override
  String get email => 'ईमेल';

  @override
  String get mobile => 'मोबाइल नंबर';

  @override
  String get password => 'पासवर्ड';

  @override
  String get name => 'पूरा नाम';

  @override
  String get role => 'भूमिका';

  @override
  String get customer => 'ग्राहक';

  @override
  String get worker => 'सहकारी कर्मी';

  @override
  String get bookNow => 'अभी बुक करें';

  @override
  String get findWorker => 'कर्मी खोजें';

  @override
  String get availableWorkers => 'उपलब्ध कर्मी';

  @override
  String withinKm(double km) {
    return '$km किमी के भीतर';
  }

  @override
  String get verifiedBadge => '100% सत्यापित';

  @override
  String get fairWageSplit => 'उचित वेतन विभाजन';

  @override
  String get welfareBacked => 'कल्याण समर्थित';

  @override
  String get selectService => 'सेवा चुनें';

  @override
  String get chooseService => 'अपनी सेवा चुनें';

  @override
  String get slotImmediate => 'तत्काल';

  @override
  String get slotScheduled => 'निर्धारित';

  @override
  String get confirmBooking => 'बुकिंग की पुष्टि करें';

  @override
  String get workerPayout => 'कर्मी वेतन (85%)';

  @override
  String get welfarePayout => 'कल्याण कोष (10%)';

  @override
  String get platformFee => 'प्लेटफ़ॉर्म शुल्क (5%)';

  @override
  String get totalAmount => 'कुल';

  @override
  String get acceptJob => 'काम स्वीकार करें';

  @override
  String get declineJob => 'अस्वीकार करें';

  @override
  String get bookingPending => 'प्रतीक्षित';

  @override
  String get bookingAccepted => 'स्वीकृत';

  @override
  String get bookingCompleted => 'पूर्ण';

  @override
  String get bookingCancelled => 'रद्द';

  @override
  String get uploadAadhaar => 'आधार कार्ड अपलोड करें';

  @override
  String get uploadPolice => 'पुलिस सत्यापन अपलोड करें';

  @override
  String get uploadCertificate => 'व्यापार प्रमाणपत्र अपलोड करें';

  @override
  String get documentPending => 'समीक्षा में';

  @override
  String get documentApproved => 'स्वीकृत';

  @override
  String get documentRejected => 'अस्वीकृत';

  @override
  String get earnings => 'मेरी कमाई';

  @override
  String get bookingHistory => 'बुकिंग इतिहास';

  @override
  String get myProfile => 'मेरी प्रोफ़ाइल';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get fileGrievance => 'शिकायत दर्ज करें';

  @override
  String get grievanceDesc => 'अपनी समस्या बताएं';

  @override
  String get submitGrievance => 'शिकायत जमा करें';

  @override
  String get availabilityOnline => 'ऑनलाइन';

  @override
  String get availabilityOffline => 'ऑफलाइन';

  @override
  String get cleaning => 'सफ़ाई';

  @override
  String get electrical => 'बिजली';

  @override
  String get plumbing => 'पाइपलाइन';

  @override
  String get carpentry => 'बढ़ईगीरी';

  @override
  String get languageToggle => 'भाषा';

  @override
  String get lightMode => 'लाइट मोड';

  @override
  String get darkMode => 'डार्क मोड';

  @override
  String get cooperative => 'सहकारी';

  @override
  String get societyVerification => 'सोसायटी सत्यापन';

  @override
  String get pendingVerification => 'सोसायटी सत्यापन प्रतीक्षित';

  @override
  String get verifiedStatus => 'सत्यापित';

  @override
  String get errorGeneric => 'कुछ गलत हो गया। कृपया पुनः प्रयास करें।';

  @override
  String get errorNetwork => 'नेटवर्क त्रुटि। कृपया अपना कनेक्शन जांचें।';

  @override
  String get errorUnauthorized => 'सत्र समाप्त हो गया। कृपया पुनः लॉगिन करें।';

  @override
  String get loadingText => 'लोड हो रहा है...';

  @override
  String get emptyWorkers => 'आस-पास कोई कर्मी उपलब्ध नहीं';

  @override
  String get emptyBookings => 'अभी तक कोई बुकिंग नहीं';

  @override
  String get seeAll => 'सभी देखें';

  @override
  String get retry => 'पुनः प्रयास करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get submit => 'जमा करें';

  @override
  String get rateWorker => 'अपना अनुभव रेट करें';

  @override
  String get optionalNote => 'नोट जोड़ें (वैकल्पिक)';

  @override
  String get workerGetsLabel => 'कर्मी को मिलता है';

  @override
  String jobsCompleted(int count) {
    return '$count काम पूरे';
  }

  @override
  String serviceSelected(int count, String price) {
    return '$count सेवा चुनी · $price से';
  }

  @override
  String get grievanceDeskTitle => 'शिकायत केंद्र';

  @override
  String get noGrievances => 'अभी तक कोई शिकायत नहीं';

  @override
  String get pendingDocuments => 'लंबित दस्तावेज़';

  @override
  String get totalEarned => 'कुल कमाई';

  @override
  String get about => 'CoopGig के बारे में';

  @override
  String get selectBooking => 'बुकिंग चुनें';

  @override
  String get availability => 'उपलब्धता';

  @override
  String get documentUpload => 'दस्तावेज़ अपलोड';

  @override
  String get jobRequests => 'काम के अनुरोध';

  @override
  String get noJobRequests => 'कोई नया काम नहीं';

  @override
  String visitFeeFrom(String price) {
    return '$price से';
  }

  @override
  String get cooperativePill => 'भोपाल सेंट्रल को-ऑप';

  @override
  String get searchHint => 'सेवाएं खोजें...';

  @override
  String get applyFilter => 'फ़िल्टर लगाएं';

  @override
  String get filterTitle => 'कर्मी फ़िल्टर';

  @override
  String get radiusLabel => 'खोज दायरा';

  @override
  String get showAvailableOnly => 'केवल उपलब्ध दिखाएं';
}
