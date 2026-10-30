class Grievance {
  final int id;
  final int bookingId;
  final int filedById;
  final String description;
  final String status; // 'open', 'resolved'
  final String? resolutionNote;
  final String? resolvedAt;
  final String createdAt;
  final String? filedByName;
  final String? serviceTitle;

  Grievance({
    required this.id,
    required this.bookingId,
    required this.filedById,
    required this.description,
    required this.status,
    this.resolutionNote,
    this.resolvedAt,
    required this.createdAt,
    this.filedByName,
    this.serviceTitle,
  });

  bool get isOpen => status == 'open';
  bool get isResolved => status == 'resolved';

  factory Grievance.fromJson(Map<String, dynamic> json) {
    return Grievance(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      bookingId: json['booking_id'] is int ? json['booking_id'] : int.parse(json['booking_id'].toString()),
      filedById: json['filed_by_id'] is int ? json['filed_by_id'] : int.parse(json['filed_by_id'].toString()),
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      resolutionNote: json['resolution_note'],
      resolvedAt: json['resolved_at'],
      createdAt: json['created_at'] ?? '',
      filedByName: json['filed_by_name'],
      serviceTitle: json['service_title'],
    );
  }
}

