class JadwalModel {
  final int? id;
  final int? unitId;
  final int shiftId;
  final String? customerName;
  final String? customerPhone;
  final String category;
  final String? packageName;
  final String startTime;
  final int durationHours;
  final String endTime;
  final int totalPrice;
  final String status;

  JadwalModel({
    this.id,
    this.unitId,
    required this.shiftId, // Pastikan ini 'shiftId'
    this.customerName,
    this.customerPhone,
    required this.category,
    this.packageName,
    required this.startTime,
    required this.durationHours,
    required this.endTime,
    required this.totalPrice,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() => {
    'unit_id': unitId,
    'shift_id': shiftId,
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'category': category,
    'package_name': packageName,
    'start_time': startTime,
    'duration_hours': durationHours,
    'end_time': endTime,
    'total_price': totalPrice,
    'status': status,
  };

  factory JadwalModel.fromMap(Map<String, dynamic> map) => JadwalModel(
    id: map['id'],
    unitId: map['unit_id'],
    shiftId: map['shift_id'], // PERBAIKAN: Gunakan shiftId, bukan shift_id
    customerName: map['customer_name'],
    customerPhone: map['customer_phone'],
    category: map['category'] ?? 'Reguler', // Beri default jika null
    packageName: map['package_name'],
    startTime: map['start_time'] ?? '',
    durationHours: map['duration_hours'] ?? 0,
    endTime: map['end_time'] ?? '',
    totalPrice: map['total_price'] ?? 0,
    status: map['status'] ?? 'active',
  );
}
