import '../services/database_service.dart';

class ShiftRepository {
  final dbService = DatabaseService.instance;

  Future<int> startShift(int userId, String shiftName) async {
    final db = await dbService.database;

    final id = await db.insert('shifts', {
      'user_id': userId,
      'shift_name': shiftName,
      'start_time': DateTime.now().toIso8601String(),
    });

    return id;
  }

  Future<void> endShift(int shiftId) async {
    final db = await dbService.database;

    await db.update(
      'shifts',
      {'end_time': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [shiftId],
    );
  }

  Future<int> getShiftRentalTotal(int shiftId) async {
    final db = await DatabaseService.instance.database;

    final result = await db.rawQuery(
      '''
    SELECT SUM(total_price) as total
    FROM reservations
    WHERE shift_id = ?
    AND status = 'completed'
  ''',
      [shiftId],
    );

    return result.first['total'] == null ? 0 : result.first['total'] as int;
  }
}
