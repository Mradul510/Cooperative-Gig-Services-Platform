class WorkerProfile {
  final int id;
  final int userId;
  final String? tradeCategory;
  final int experienceYears;
  final String? aadhaarDoc;
  final String aadhaarStatus; // 'pending', 'approved', 'rejected'
  final String? aadhaarRejectionReason;
  final String? policeDoc;
  final String policeStatus;
  final String? policeRejectionReason;
  final String? certificateDoc;
  final String certificateStatus;
  final String? certificateRejectionReason;
  final bool welfareActive;
  final double ratingAvg;
  final int jobsCompleted;
  final double? latitude;
  final double? longitude;
  final bool availability;
  final String? cooperativeRegNo;

  WorkerProfile({
    required this.id,
    required this.userId,
    this.tradeCategory,
    this.experienceYears = 0,
    this.aadhaarDoc,
    this.aadhaarStatus = 'pending',
    this.aadhaarRejectionReason,
    this.policeDoc,
    this.policeStatus = 'pending',
    this.policeRejectionReason,
    this.certificateDoc,
    this.certificateStatus = 'pending',
    this.certificateRejectionReason,
    this.welfareActive = false,
    this.ratingAvg = 0.0,
    this.jobsCompleted = 0,
    this.latitude,
    this.longitude,
    this.availability = false,
    this.cooperativeRegNo,
  });

  factory WorkerProfile.fromJson(Map<String, dynamic> json) {
    return WorkerProfile(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      tradeCategory: json['trade_category'],
      experienceYears: json['experience_years'] ?? 0,
      aadhaarDoc: json['aadhaar_doc'],
      aadhaarStatus: json['aadhaar_status'] ?? 'pending',
      aadhaarRejectionReason: json['aadhaar_rejection_reason'],
      policeDoc: json['police_doc'],
      policeStatus: json['police_status'] ?? 'pending',
      policeRejectionReason: json['police_rejection_reason'],
      certificateDoc: json['certificate_doc'],
      certificateStatus: json['certificate_status'] ?? 'pending',
      certificateRejectionReason: json['certificate_rejection_reason'],
      welfareActive: json['welfare_active'] == 1 || json['welfare_active'] == true,
      ratingAvg: (json['rating_avg'] != null) ? double.parse(json['rating_avg'].toString()) : 0.0,
      jobsCompleted: json['jobs_completed'] ?? 0,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      availability: json['availability'] == 1 || json['availability'] == true,
      cooperativeRegNo: json['cooperative_reg_no'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trade_category': tradeCategory,
      'experience_years': experienceYears,
      'aadhaar_doc': aadhaarDoc,
      'aadhaar_status': aadhaarStatus,
      'aadhaar_rejection_reason': aadhaarRejectionReason,
      'police_doc': policeDoc,
      'police_status': policeStatus,
      'police_rejection_reason': policeRejectionReason,
      'certificate_doc': certificateDoc,
      'certificate_status': certificateStatus,
      'certificate_rejection_reason': certificateRejectionReason,
      'welfare_active': welfareActive ? 1 : 0,
      'rating_avg': ratingAvg,
      'jobs_completed': jobsCompleted,
      'latitude': latitude,
      'longitude': longitude,
      'availability': availability ? 1 : 0,
      'cooperative_reg_no': cooperativeRegNo,
    };
  }
}

class WorkerFeedItem {
  final int userId;
  final String name;
  final String? tradeCategory;
  final double ratingAvg;
  final int jobsCompleted;
  final bool isVerified;
  final bool welfareActive;
  final double visitFee;
  final double distanceKm;
  final String? cooperativeRegNo;
  final bool availability;

  WorkerFeedItem({
    required this.userId,
    required this.name,
    this.tradeCategory,
    this.ratingAvg = 0.0,
    this.jobsCompleted = 0,
    this.isVerified = false,
    this.welfareActive = false,
    this.visitFee = 0.0,
    this.distanceKm = 0.0,
    this.cooperativeRegNo,
    this.availability = true,
  });

  factory WorkerFeedItem.fromJson(Map<String, dynamic> json) {
    return WorkerFeedItem(
      userId: json['user_id'] is int ? json['user_id'] : int.parse(json['user_id'].toString()),
      name: json['name'] ?? '',
      tradeCategory: json['trade_category'],
      ratingAvg: (json['rating_avg'] != null) ? double.parse(json['rating_avg'].toString()) : 0.0,
      jobsCompleted: json['jobs_completed'] ?? 0,
      isVerified: json['is_verified'] == 1 || json['is_verified'] == true,
      welfareActive: json['welfare_active'] == 1 || json['welfare_active'] == true,
      visitFee: (json['visit_fee'] != null) ? double.parse(json['visit_fee'].toString()) : 399.0,
      distanceKm: (json['distance_km'] != null) ? double.parse(json['distance_km'].toString()) : 1.2,
      cooperativeRegNo: json['cooperative_reg_no'],
      availability: json['availability'] == 1 || json['availability'] == true,
    );
  }
}

