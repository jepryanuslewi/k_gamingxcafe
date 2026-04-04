class PsUnitModel {
  final int? id;
  final String name;
  final String type;
  final int pricePerHour;
  final String status;

  PsUnitModel({
    this.id,
    required this.name,
    required this.type,
    required this.pricePerHour,
    required this.status,
  });

  factory PsUnitModel.fromMap(Map<String, dynamic> map) => PsUnitModel(
    id: map['id'],
    name: map['name'],
    type: map['type'],
    pricePerHour: map['price_per_hour'],
    status: map['status'],
  );
}
