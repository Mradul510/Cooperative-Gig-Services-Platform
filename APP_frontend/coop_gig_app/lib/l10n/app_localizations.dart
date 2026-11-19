import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'CoopGig'**
  String get appTitle;

  /// Greeting on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome back,'**
  String get welcomeBack;

  /// Login button label
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button label
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Mobile field label
  ///
  /// In en, this message translates to:
  /// **'Mobile Number'**
  String get mobile;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get name;

  /// Role label
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// Customer role label
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// Worker role label
  ///
  /// In en, this message translates to:
  /// **'Cooperative Worker'**
  String get worker;

  /// Book now button
  ///
  /// In en, this message translates to:
  /// **'Book Now'**
  String get bookNow;

  /// Find worker button
  ///
  /// In en, this message translates to:
  /// **'Find a Worker'**
  String get findWorker;

  /// Section title for available workers
  ///
  /// In en, this message translates to:
  /// **'Available Workers'**
  String get availableWorkers;

  /// Distance label
  ///
  /// In en, this message translates to:
  /// **'within {km} km'**
  String withinKm(double km);

  /// Trust strip badge
  ///
  /// In en, this message translates to:
  /// **'100% Verified'**
  String get verifiedBadge;

  /// Trust strip badge
  ///
  /// In en, this message translates to:
  /// **'Fair Wage Split'**
  String get fairWageSplit;

  /// Trust strip badge
  ///
  /// In en, this message translates to:
  /// **'Welfare Backed'**
  String get welfareBacked;

  /// Service selection prompt
  ///
  /// In en, this message translates to:
  /// **'Select a Service'**
  String get selectService;

  /// Service chooser heading
  ///
  /// In en, this message translates to:
  /// **'Choose your service'**
  String get chooseService;

  /// Immediate slot label
  ///
  /// In en, this message translates to:
  /// **'Immediate'**
  String get slotImmediate;

  /// Scheduled slot label
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get slotScheduled;

  /// Confirm booking button
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// Worker payout label
  ///
  /// In en, this message translates to:
  /// **'Worker Wage (85%)'**
  String get workerPayout;

  /// Welfare payout label
  ///
  /// In en, this message translates to:
  /// **'Welfare Pool (10%)'**
  String get welfarePayout;

  /// Platform fee label
  ///
  /// In en, this message translates to:
  /// **'Platform Fee (5%)'**
  String get platformFee;

  /// Total amount label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalAmount;

  /// Accept job button for worker
  ///
  /// In en, this message translates to:
  /// **'Accept Job'**
  String get acceptJob;

  /// Decline job button for worker
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get declineJob;

  /// Booking pending status
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get bookingPending;

  /// Booking accepted status
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get bookingAccepted;

  /// Booking completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get bookingCompleted;

  /// Booking cancelled status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get bookingCancelled;

  /// Aadhaar upload button
  ///
  /// In en, this message translates to:
  /// **'Upload Aadhaar Card'**
  String get uploadAadhaar;

  /// Police verification upload button
  ///
  /// In en, this message translates to:
  /// **'Upload Police Verification'**
  String get uploadPolice;

  /// Certificate upload button
  ///
  /// In en, this message translates to:
  /// **'Upload Trade Certificate'**
  String get uploadCertificate;

  /// Document pending status
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get documentPending;

  /// Document approved status
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get documentApproved;

  /// Document rejected status
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get documentRejected;

  /// Earnings screen title
  ///
  /// In en, this message translates to:
  /// **'My Earnings'**
  String get earnings;

  /// Booking history menu item
  ///
  /// In en, this message translates to:
  /// **'Booking History'**
  String get bookingHistory;

  /// Profile screen title
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Grievance form button
  ///
  /// In en, this message translates to:
  /// **'File a Grievance'**
  String get fileGrievance;

  /// Grievance description hint
  ///
  /// In en, this message translates to:
  /// **'Describe your issue'**
  String get grievanceDesc;

  /// Submit grievance button
  ///
  /// In en, this message translates to:
  /// **'Submit Grievance'**
  String get submitGrievance;

  /// Online availability status
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get availabilityOnline;

  /// Offline availability status
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get availabilityOffline;

  /// Cleaning category
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get cleaning;

  /// Electrical category
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get electrical;

  /// Plumbing category
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get plumbing;

  /// Carpentry category
  ///
  /// In en, this message translates to:
  /// **'Carpentry'**
  String get carpentry;

  /// Language toggle label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageToggle;

  /// Light mode label
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// Dark mode label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Cooperative label
  ///
  /// In en, this message translates to:
  /// **'Cooperative'**
  String get cooperative;

  /// Society verification label
  ///
  /// In en, this message translates to:
  /// **'Society Verification'**
  String get societyVerification;

  /// Pending verification message
  ///
  /// In en, this message translates to:
  /// **'Pending society verification'**
  String get pendingVerification;

  /// Verified status
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verifiedStatus;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get errorNetwork;

  /// Unauthorized error message
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get errorUnauthorized;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingText;

  /// Empty workers state
  ///
  /// In en, this message translates to:
  /// **'No workers available nearby'**
  String get emptyWorkers;

  /// Empty bookings state
  ///
  /// In en, this message translates to:
  /// **'No bookings yet'**
  String get emptyBookings;

  /// See all button
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// Rating sheet title
  ///
  /// In en, this message translates to:
  /// **'Rate your experience'**
  String get rateWorker;

  /// Optional note hint
  ///
  /// In en, this message translates to:
  /// **'Add a note (optional)'**
  String get optionalNote;

  /// Worker payout hint on service tile
  ///
  /// In en, this message translates to:
  /// **'Worker gets'**
  String get workerGetsLabel;

  /// Jobs completed label
  ///
  /// In en, this message translates to:
  /// **'{count} jobs completed'**
  String jobsCompleted(int count);

  /// Footer label for category screen
  ///
  /// In en, this message translates to:
  /// **'{count} service selected · from {price}'**
  String serviceSelected(int count, String price);

  /// Grievance desk screen title
  ///
  /// In en, this message translates to:
  /// **'Grievance Desk'**
  String get grievanceDeskTitle;

  /// Empty grievances state
  ///
  /// In en, this message translates to:
  /// **'No grievances filed yet'**
  String get noGrievances;

  /// Pending documents label
  ///
  /// In en, this message translates to:
  /// **'Pending Documents'**
  String get pendingDocuments;

  /// Total earned label
  ///
  /// In en, this message translates to:
  /// **'Total Earned'**
  String get totalEarned;

  /// About menu item
  ///
  /// In en, this message translates to:
  /// **'About CoopGig'**
  String get about;

  /// Select booking for grievance dropdown
  ///
  /// In en, this message translates to:
  /// **'Select Booking'**
  String get selectBooking;

  /// Availability label
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// Document upload screen title
  ///
  /// In en, this message translates to:
  /// **'Document Upload'**
  String get documentUpload;

  /// Job requests screen title
  ///
  /// In en, this message translates to:
  /// **'Job Requests'**
  String get jobRequests;

  /// Empty job requests state
  ///
  /// In en, this message translates to:
  /// **'No new job requests'**
  String get noJobRequests;

  /// Visit fee label
  ///
  /// In en, this message translates to:
  /// **'from {price}'**
  String visitFeeFrom(String price);

  /// Cooperative pill label
  ///
  /// In en, this message translates to:
  /// **'Bhopal Central Co-op'**
  String get cooperativePill;

  /// Search field hint
  ///
  /// In en, this message translates to:
  /// **'Search services...'**
  String get searchHint;

  /// Apply filter button
  ///
  /// In en, this message translates to:
  /// **'Apply Filter'**
  String get applyFilter;

  /// Filter sheet title
  ///
  /// In en, this message translates to:
  /// **'Filter Workers'**
  String get filterTitle;

  /// Radius slider label
  ///
  /// In en, this message translates to:
  /// **'Search Radius'**
  String get radiusLabel;

  /// Availability filter toggle
  ///
  /// In en, this message translates to:
  /// **'Show available only'**
  String get showAvailableOnly;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
