import 'package:flutter/material.dart';
import '../models/worker.dart';
import '../services/api_service.dart';

class WorkerController with ChangeNotifier {
  List<WorkerFeedItem> _workers = [];
  Map<String, dynamic>? _selectedWorkerDetail;
  bool _isLoading = false;
  String? _errorMessage;

  // Filters
  double _radiusKm = 5.0;
  String? _filterCategory;
  bool _availabilityFilter = true;

  List<WorkerFeedItem> get workers => _workers;
  Map<String, dynamic>? get selectedWorkerDetail => _selectedWorkerDetail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get radiusKm => _radiusKm;
  String? get filterCategory => _filterCategory;
  bool get availabilityFilter => _availabilityFilter;

  void setRadius(double radius) {
    _radiusKm = radius.clamp(1.0, 5.0);
    notifyListeners();
  }

  void setAvailabilityFilter(bool val) {
    _availabilityFilter = val;
    notifyListeners();
  }

  Future<void> fetchWorkers({
    double lat = 23.2599,
    double lng = 77.4126,
    String? category,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _filterCategory = category;
    notifyListeners();

    try {
      final list = await ApiService().getWorkers(
        lat: lat,
        lng: lng,
        radius: _radiusKm,
        category: category,
      );

      if (_availabilityFilter) {
        _workers = list.where((w) => w.availability).toList();
      } else {
        _workers = list;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWorkerDetail(int workerId) async {
    _isLoading = true;
    _selectedWorkerDetail = null;
    notifyListeners();

    try {
      _selectedWorkerDetail = await ApiService().getWorkerProfile(workerId);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleAvailability(bool newStatus) async {
    try {
      await ApiService().updateAvailability(newStatus);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadDocument(String docType, String filePath) async {
    _isLoading = true;
    notifyListeners();
    try {
      await ApiService().uploadDocument(docType: docType, filePath: filePath);
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
}
