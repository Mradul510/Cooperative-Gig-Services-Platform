// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CoopGig';

  @override
  String get welcomeBack => 'Welcome back,';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get mobile => 'Mobile Number';

  @override
  String get password => 'Password';

  @override
  String get name => 'Full Name';

  @override
  String get role => 'Role';

  @override
  String get customer => 'Customer';

  @override
  String get worker => 'Cooperative Worker';

  @override
  String get bookNow => 'Book Now';

  @override
  String get findWorker => 'Find a Worker';

  @override
  String get availableWorkers => 'Available Workers';

  @override
  String withinKm(double km) {
    return 'within $km km';
  }

  @override
  String get verifiedBadge => '100% Verified';

  @override
  String get fairWageSplit => 'Fair Wage Split';

  @override
  String get welfareBacked => 'Welfare Backed';

  @override
  String get selectService => 'Select a Service';

  @override
  String get chooseService => 'Choose your service';

  @override
  String get slotImmediate => 'Immediate';

  @override
  String get slotScheduled => 'Scheduled';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get workerPayout => 'Worker Wage (85%)';

  @override
  String get welfarePayout => 'Welfare Pool (10%)';

  @override
  String get platformFee => 'Platform Fee (5%)';

  @override
  String get totalAmount => 'Total';

  @override
  String get acceptJob => 'Accept Job';

  @override
  String get declineJob => 'Decline';

  @override
  String get bookingPending => 'Pending';

  @override
  String get bookingAccepted => 'Accepted';

  @override
  String get bookingCompleted => 'Completed';

  @override
  String get bookingCancelled => 'Cancelled';

  @override
  String get uploadAadhaar => 'Upload Aadhaar Card';

  @override
  String get uploadPolice => 'Upload Police Verification';

  @override
  String get uploadCertificate => 'Upload Trade Certificate';

  @override
  String get documentPending => 'Pending Review';

  @override
  String get documentApproved => 'Approved';

  @override
  String get documentRejected => 'Rejected';

  @override
  String get earnings => 'My Earnings';

  @override
  String get bookingHistory => 'Booking History';

  @override
  String get myProfile => 'My Profile';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get fileGrievance => 'File a Grievance';

  @override
  String get grievanceDesc => 'Describe your issue';

  @override
  String get submitGrievance => 'Submit Grievance';

  @override
  String get availabilityOnline => 'Online';

  @override
  String get availabilityOffline => 'Offline';

  @override
  String get cleaning => 'Cleaning';

  @override
  String get electrical => 'Electrical';

  @override
  String get plumbing => 'Plumbing';

  @override
  String get carpentry => 'Carpentry';

  @override
  String get languageToggle => 'Language';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get cooperative => 'Cooperative';

  @override
  String get societyVerification => 'Society Verification';

  @override
  String get pendingVerification => 'Pending society verification';

  @override
  String get verifiedStatus => 'Verified';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get errorNetwork => 'Network error. Please check your connection.';

  @override
  String get errorUnauthorized => 'Session expired. Please login again.';

  @override
  String get loadingText => 'Loading...';

  @override
  String get emptyWorkers => 'No workers available nearby';

  @override
  String get emptyBookings => 'No bookings yet';

  @override
  String get seeAll => 'See All';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get submit => 'Submit';

  @override
  String get rateWorker => 'Rate your experience';

  @override
  String get optionalNote => 'Add a note (optional)';

  @override
  String get workerGetsLabel => 'Worker gets';

  @override
  String jobsCompleted(int count) {
    return '$count jobs completed';
  }

  @override
  String serviceSelected(int count, String price) {
    return '$count service selected · from $price';
  }

  @override
  String get grievanceDeskTitle => 'Grievance Desk';

  @override
  String get noGrievances => 'No grievances filed yet';

  @override
  String get pendingDocuments => 'Pending Documents';

  @override
  String get totalEarned => 'Total Earned';

  @override
  String get about => 'About CoopGig';

  @override
  String get selectBooking => 'Select Booking';

  @override
  String get availability => 'Availability';

  @override
  String get documentUpload => 'Document Upload';

  @override
  String get jobRequests => 'Job Requests';

  @override
  String get noJobRequests => 'No new job requests';

  @override
  String visitFeeFrom(String price) {
    return 'from $price';
  }

  @override
  String get cooperativePill => 'Bhopal Central Co-op';

  @override
  String get searchHint => 'Search services...';

  @override
  String get applyFilter => 'Apply Filter';

  @override
  String get filterTitle => 'Filter Workers';

  @override
  String get radiusLabel => 'Search Radius';

  @override
  String get showAvailableOnly => 'Show available only';
}
