class Visit {
  final int? id;
  final int? customerId;
  final DateTime? visitDate;
  final String? status;
  final String? location;
  final String? notes;
  final List<int>? activitiesDone;
  final DateTime? createdAt;

  Visit({
    this.id,
    this.customerId,
    this.visitDate,
    this.status,
    this.location,
    this.notes,
    this.activitiesDone,
    this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'] as int?,
      customerId: json['customer_id'] as int?,
      visitDate: DateTime.tryParse(json['visit_date'] ?? ''),
      status: json['status'] as String?,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      activitiesDone: (json['activities_done'] as List<dynamic>?)
          ?.map((e) => int.tryParse(e.toString()) ?? -1)
          .where((e) => e != -1)
          .toList(),
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }

  @override
  String toString() {
    return 'Visit(id: $id, customerId: $customerId, date: $visitDate, status: $status, location: $location)';
  }
}
