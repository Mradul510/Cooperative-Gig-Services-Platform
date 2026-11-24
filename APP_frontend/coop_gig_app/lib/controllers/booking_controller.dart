import 'dart:async';
import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/grievance.dart';
import '../services/api_service.dart';

class BookingController with ChangeNotifier {
  List<Booking> _bookings = [];
  List<Grievance> _grievances = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Real-time dispatch polling
  Timer? _pollTimer;
  final Set<int> _knownPendingIds = {};
  final ValueNotifier<Booking?> onNewJobReceived = ValueNotifier<Booking?>(null);

  List<Booking> get bookings => _bookings;
  List<Grievance> get grievances => _grievances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPolling => _pollTimer != null && _pollTimer!.isActive;

  // Filtered lists for worker
  List<Booking> get pendingRequests =>
      _bookings.where((b) => b.status == 'pending').toList();

  List<Booking> get activeAcceptedJobs =>
      _bookings.where((b) => b.status == 'accepted').toList();

  List<Booking> get completedBookings =>
      _bookings.where((b) => b.status == 'completed').toList();

  double get totalWorkerEarnings =>
      completedBookings.fold(0.0, (sum, b) => sum + b.workerPayout);

  /// Starts periodic background polling (default 3 seconds) for live dispatch requests
  void startLiveDispatchPolling({int intervalSeconds = 3}) {
    if (_pollTimer != null && _pollTimer!.isActive) return;

    // Silent poll immediately
    _silentPollBookings();

    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) {
      _silentPollBookings();
    });
  }

  /// Stops background polling
  void stopLiveDispatchPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Silent fetch for background polling without triggering full-screen loading spinners
  Future<void> _silentPollBookings() async {
    try {
      final fresh = await ApiService().getBookings();

      // Check for any newly arrived pending bookings
      for (final b in fresh) {
        if (b.status == 'pending' && !_knownPendingIds.contains(b.id)) {
          _knownPendingIds.add(b.id);
          // Pop new job alert
          onNewJobReceived.value = b;
        }
      }

      // Sync known set with current pending
      final currentPendingIds = fresh
          .where((b) => b.status == 'pending')
          .map((b) => b.id)
          .toSet();
      _knownPendingIds.removeWhere((id) => !currentPendingIds.contains(id));

      _bookings = fresh;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await ApiService().getBookings();
      // Record initial pending bookings to avoid false alert on initial load
      for (final b in _bookings) {
        if (b.status == 'pending') {
          _knownPendingIds.add(b.id);
        }
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Booking?> createBooking({
    required int workerId,
    required int serviceId,
    required String slotType,
    String? bookingTime,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final booking = await ApiService().createBooking(
        workerId: workerId,
        serviceId: serviceId,
        slotType: slotType,
        bookingTime: bookingTime,
      );
      _bookings.insert(0, booking);
      _isLoading = false;
      notifyListeners();
      return booking;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateStatus(int bookingId, String newStatus) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await ApiService().updateBookingStatus(bookingId, newStatus);
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> rateBooking(int bookingId, int rating, String? note) async {
    try {
      await ApiService().rateBooking(bookingId, rating, note);
      await fetchBookings();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> fileGrievance(int bookingId, String description) async {
    try {
      await ApiService().fileGrievance(bookingId: bookingId, description: description);
      await fetchGrievances();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchGrievances() async {
    try {
      _grievances = await ApiService().getGrievances();
      notifyListeners();
    } catch (_) {}
  }
}

