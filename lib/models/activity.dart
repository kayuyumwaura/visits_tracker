class Activity {
  final int? id;
  final String? description;
  final DateTime? createdAt;

  Activity({this.id, this.description, this.createdAt});

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['id'] as int?,
      description: json['description'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }

  @override
  String toString() {
    return 'Activity(id: $id, description: $description)';
  }
}
