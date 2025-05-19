class Customer {
  final int? id;
  final String? name;
  final DateTime? createdAt;

  Customer({this.id, this.name, this.createdAt});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int?,
      name: json['name'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }

  @override
  String toString() {
    return 'Customer(id: $id, name: $name)';
  }
}
