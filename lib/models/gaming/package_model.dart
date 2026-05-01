class PackageModel {
  final int? id;
  final String name;
  final int price;
  final int durationHours; // Tambahkan ini sesuai kolom DB
  final String category;

  PackageModel({
    this.id,
    required this.name,
    required this.price,
    required this.durationHours, // Tambahkan ini
    required this.category,
  });

  factory PackageModel.fromMap(Map<String, dynamic> map) => PackageModel(
    id: map['id'],
    name: map['name'],
    price: map['price'],
    durationHours: map['duration_hours'] ?? 1, 
    category: map['category'] ?? 'Event',
  );
}
