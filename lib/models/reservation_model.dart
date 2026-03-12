class ReservationModel {
  final int? id;
  final int unitId;
  final int shiftId;
  final String customerName;
  final String startTime;
  final int durationHours;
  final String endTime;
  final int totalPrice;
  final String status;

  ReservationModel({
    this.id,
    required this.unitId,
    required this.shiftId,
    required this.customerName,
    required this.startTime,
    required this.durationHours,
    required this.endTime,
    required this.totalPrice,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
    'unit_id': unitId,
    'shift_id': shiftId,
    'customer_name': customerName,
    'start_time': startTime,
    'duration_hours': durationHours,
    'end_time': endTime,
    'total_price': totalPrice,
    'status': status,
  };
}
