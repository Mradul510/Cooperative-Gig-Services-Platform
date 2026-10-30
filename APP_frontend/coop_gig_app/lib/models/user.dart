import 'worker.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String mobile;
  final String role; // 'customer', 'worker', 'cooperative_admin'
  final int? cooperativeId;
  final String? cooperativeName;
  final bool isVerified;
  final String? createdAt;
  final WorkerProfile? workerProfile;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.role,
    this.cooperativeId,
    this.cooperativeName,
    this.isVerified = false,
    this.createdAt,
    this.workerProfile,
  });

  bool get isCustomer => role == 'customer';
  bool get isWorker => role == 'worker';
  bool get isAdmin => role == 'cooperative_admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      mobile: json['mobile'] ?? '',
      role: json['role'] ?? 'customer',
      cooperativeId: json['cooperative_id'],
      cooperativeName: json['cooperative_name'],
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      createdAt: json['created_at'],
      workerProfile: json['worker_profile'] != null
          ? WorkerProfile.fromJson(json['worker_profile'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'mobile': mobile,
      'role': role,
      'cooperative_id': cooperativeId,
      'cooperative_name': cooperativeName,
      'is_verified': isVerified ? 1 : 0,
      'created_at': createdAt,
      'worker_profile': workerProfile?.toJson(),
    };
  }
}

