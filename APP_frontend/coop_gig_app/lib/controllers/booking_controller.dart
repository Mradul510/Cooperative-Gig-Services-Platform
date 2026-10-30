import 'package:flutter/material.dart';
import '../models/booking.dart';
import '../models/grievance.dart';
import '../services/api_service.dart';

class BookingController with ChangeNotifier {
  List<Booking> _bookings = [];
  List<Grievance> _grievances = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get bookings => _bookings;
  List<Grievance> get grievances => _grievances;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Filtered lists for worker
  List<Booking> get pendingRequests =>
      _bookings.where((b) => b.status == 'pending').toList();

  List<Booking> get activeAcceptedJobs =>
      _bookings.where((b) => b.status == 'accepted').toList();

  List<Booking> get completedBookings =>
      _bookings.where((b) => b.status == 'completed').toList();

  double get totalWorkerEarnings =>
      completedBookings.fold(0.0, (sum, b) => sum + b.workerPayout);

  Future<void> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookings = await ApiService().getBookings();
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

