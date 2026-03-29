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
  final String status; // 'walkin' / 'booking'
  final String statusCompleted; // ✅ 'active' / 'done' / 'deleted'
  final String? createdAt;

  JadwalModel({
    this.id,
    this.unitId,
    required this.shiftId,
    this.customerName,
    this.customerPhone,
    required this.category,
    this.packageName,
    required this.startTime,
    required this.durationHours,
    required this.endTime,
    required this.totalPrice,
    required this.status,
    this.statusCompleted = 'active', // ✅ default active
    this.createdAt,
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
    'status_completed': statusCompleted, // ✅
    'created_at': createdAt,
  };

  factory JadwalModel.fromMap(Map<String, dynamic> map) => JadwalModel(
    id: map['id'],
    unitId: map['unit_id'],
    shiftId: map['shift_id'],
    customerName: map['customer_name'],
    customerPhone: map['customer_phone'],
    category: map['category'] ?? 'Reguler',
    packageName: map['package_name'],
    startTime: map['start_time'] ?? '',
    durationHours: map['duration_hours'] ?? 0,
    endTime: map['end_time'] ?? '',
    totalPrice: map['total_price'] ?? 0,
    status: map['status'] ?? 'walkin',
    statusCompleted: map['status_completed'] ?? 'active', // ✅
    createdAt: map['created_at'],
  );
}
