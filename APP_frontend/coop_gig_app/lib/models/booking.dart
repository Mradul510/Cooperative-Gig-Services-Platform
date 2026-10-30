class Booking {
  final int id;
  final int customerId;
  final int workerId;
  final int serviceId;
  final String status; // 'pending', 'accepted', 'completed', 'cancelled'
  final String slotType; // 'immediate', 'scheduled'
  final String? bookingTime;
  final double totalAmount;
  final double workerPayout;
  final double welfarePayout;
  final double platformPayout;
  final int? rating;
  final String? ratingNote;
  final String createdAt;

  // Joined display fields
  final String? customerName;
  final String? customerMobile;
  final String? workerName;
  final String? workerMobile;
  final String? serviceTitle;
  final String? serviceCategory;

  Booking({
    required this.id,
    required this.customerId,
    required this.workerId,
    required this.serviceId,
    required this.status,
    required this.slotType,
    this.bookingTime,
    required this.totalAmount,
    required this.workerPayout,
    required this.welfarePayout,
    required this.platformPayout,
    this.rating,
    this.ratingNote,
    required this.createdAt,
    this.customerName,
    this.customerMobile,
    this.workerName,
    this.workerMobile,
    this.serviceTitle,
    this.serviceCategory,
  });

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      customerId: json['customer_id'] is int ? json['customer_id'] : int.parse(json['customer_id'].toString()),
      workerId: json['worker_id'] is int ? json['worker_id'] : int.parse(json['worker_id'].toString()),
      serviceId: json['service_id'] is int ? json['service_id'] : int.parse(json['service_id'].toString()),
      status: json['status'] ?? 'pending',
      slotType: json['slot_type'] ?? 'immediate',
      bookingTime: json['booking_time'],
      totalAmount: (json['total_amount'] != null) ? double.parse(json['total_amount'].toString()) : 0.0,
      workerPayout: (json['worker_payout'] != null) ? double.parse(json['worker_payout'].toString()) : 0.0,
      welfarePayout: (json['welfare_payout'] != null) ? double.parse(json['welfare_payout'].toString()) : 0.0,
      platformPayout: (json['platform_payout'] != null) ? double.parse(json['platform_payout'].toString()) : 0.0,
      rating: json['rating'],
      ratingNote: json['rating_note'],
      createdAt: json['created_at'] ?? '',
      customerName: json['customer_name'],
      customerMobile: json['customer_mobile'],
      workerName: json['worker_name'],
      workerMobile: json['worker_mobile'],
      serviceTitle: json['service_title'],
      serviceCategory: json['category_name'],
    );
  }
}

