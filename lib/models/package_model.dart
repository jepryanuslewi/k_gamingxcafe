class PackageModel {
  final int? id;
  final String name;
  final int price;
  final String category; // Tambahkan ini: 'Event', 'Reguler', dll.

  PackageModel({
    this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  factory PackageModel.fromMap(Map<String, dynamic> map) => PackageModel(
    id: map['id'],
    name: map['name'],
    price: map['price'],
    category: map['category'] ?? 'Event',
  );
}
