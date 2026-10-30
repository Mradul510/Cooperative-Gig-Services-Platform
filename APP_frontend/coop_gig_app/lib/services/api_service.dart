import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/config.dart';
import '../models/user.dart';
import '../models/worker.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../models/grievance.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;

  void setToken(String? token) {
    _authToken = token;
  }

  Map<String, String> _headers({bool isMultipart = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (!isMultipart) {
      headers['Content-Type'] = 'application/json';
    }
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // --- AUTH ---
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/register');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'mobile': mobile,
        'password': password,
        'role': role,
      }),
    ).timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['error'] ?? 'Registration failed');
    }
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/login');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'identifier': identifier,
        'password': password,
      }),
    ).timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['error'] ?? 'Login failed');
    }
  }

  Future<User> getMe() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/auth/me');
    final response = await http.get(url, headers: _headers())
        .timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      return User.fromJson(data['data']);
    } else {
      throw Exception(data['error'] ?? 'Failed to load user profile');
    }
  }

  // --- CATALOGUE ---
  Future<List<CategoryItem>> getCategories() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/categories');
    final response = await http.get(url, headers: _headers())
        .timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      final list = data['data'] as List;
      return list.map((item) => CategoryItem.fromJson(item)).toList();
    } else {
      throw Exception(data['error'] ?? 'Failed to load categories');
    }
  }

  Future<List<ServiceItem>> getServices({int? categoryId}) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}/services').replace(
      queryParameters: categoryId != null ? {'category_id': categoryId.toString()} : null,
    );
    final response = await http.get(uri, headers: _headers())
        .timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      final list = data['data'] as List;
      return list.map((item) => ServiceItem.fromJson(item)).toList();
    } else {
      throw Exception(data['error'] ?? 'Failed to load services');
    }
  }

  // --- WORKERS ---
  Future<List<WorkerFeedItem>> getWorkers({
    double lat = 23.2599,
    double lng = 77.4126,
    double radius = 5.0,
    String? category,
  }) async {
    final queryParams = {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'radius': radius.toString(),
    };
    if (category != null && category.isNotEmpty) {
      queryParams['category'] = category;
    }

    final uri = Uri.parse('${AppConfig.apiBaseUrl}/workers').replace(
      queryParameters: queryParams,
    );
    final response = await http.get(uri, headers: _headers())
        .timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      final list = data['data'] as List;
      return list.map((item) => WorkerFeedItem.fromJson(item)).toList();
    } else {
      throw Exception(data['error'] ?? 'Failed to fetch nearby workers');
    }
  }

  Future<Map<String, dynamic>> getWorkerProfile(int workerId) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/workers/$workerId');
    final response = await http.get(url, headers: _headers())
        .timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['error'] ?? 'Failed to get worker profile');
    }
  }

  Future<void> updateAvailability(bool availability) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/workers/availability');
    final response = await http.patch(
      url,
      headers: _headers(),
      body: jsonEncode({'availability': availability ? 1 : 0}),
    ).timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      return;
    } else {
      throw Exception(data['error'] ?? 'Failed to update availability');
    }
  }

  Future<void> uploadDocument({
    required String docType, // 'aadhaar_doc', 'police_doc', 'certificate_doc'
    required String filePath,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/workers/documents');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(_headers(isMultipart: true));
    request.files.add(await http.MultipartFile.fromPath(docType, filePath));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      return;
    } else {
      throw Exception(data['error'] ?? 'Failed to upload document');
    }
  }

  // --- BOOKINGS ---
  Future<Booking> createBooking({
    required int workerId,
    required int serviceId,
    required String slotType,
    String? bookingTime,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/bookings');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'worker_id': workerId,
        'service_id': serviceId,
        'slot_type': slotType,
        'booking_time': ?bookingTime,
      }),
    ).timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      return Booking.fromJson(data['data']);
    } else {
      throw Exception(data['error'] ?? 'Failed to create booking');
    }
  }

  Future<List<Booking>> getBookings() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/bookings');
    final response = await http.get(url, headers: _headers())
        .timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      final list = data['data'] as List;
      return list.map((item) => Booking.fromJson(item)).toList();
    } else {
      throw Exception(data['error'] ?? 'Failed to fetch bookings');
    }
  }

  Future<Booking> updateBookingStatus(int bookingId, String status) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/bookings/$bookingId/status');
    final response = await http.patch(
      url,
      headers: _headers(),
      body: jsonEncode({'status': status}),
    ).timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      return Booking.fromJson(data['data']);
    } else {
      throw Exception(data['error'] ?? 'Failed to update booking status');
    }
  }

  Future<void> rateBooking(int bookingId, int rating, String? note) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/bookings/$bookingId/rate');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'rating': rating,
        if (note != null && note.isNotEmpty) 'rating_note': note,
      }),
    ).timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      return;
    } else {
      throw Exception(data['error'] ?? 'Failed to submit rating');
    }
  }

  // --- GRIEVANCES ---
  Future<void> fileGrievance({
    required int bookingId,
    required String description,
  }) async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/grievances');
    final response = await http.post(
      url,
      headers: _headers(),
      body: jsonEncode({
        'booking_id': bookingId,
        'description': description,
      }),
    ).timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      return;
    } else {
      throw Exception(data['error'] ?? 'Failed to file grievance');
    }
  }

  Future<List<Grievance>> getGrievances() async {
    final url = Uri.parse('${AppConfig.apiBaseUrl}/grievances');
    final response = await http.get(url, headers: _headers())
        .timeout(const Duration(seconds: AppConfig.connectionTimeoutSeconds));

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300 && data['success'] == true) {
      final list = data['data'] as List;
      return list.map((item) => Grievance.fromJson(item)).toList();
    } else {
      throw Exception(data['error'] ?? 'Failed to fetch grievances');
    }
  }
}
