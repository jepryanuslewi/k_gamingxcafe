import 'dart:async';
import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/gaming/jadwal_model.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class _NotifRecord {
  bool expiredSent;
  _NotifRecord({this.expiredSent = false});
}

class NontifikasiService {
  static final NontifikasiService _instance = NontifikasiService._internal();
  factory NontifikasiService() => _instance;
  NontifikasiService._internal();

  Timer? _timer;
  final Map<int, _NotifRecord> _notifTracker = {};

  void Function(NotifPayload)? onNotification;

  void startWatcher() {
    _timer?.cancel();
    _notifTracker.clear();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkAllJadwal();
    });
    Future.delayed(const Duration(milliseconds: 500), _checkAllJadwal);
  }

  void stopWatcher() {
    _timer?.cancel();
    _timer = null;
  }

  void resetTracker(int jadwalId) {
    _notifTracker.remove(jadwalId);
  }

  void resetAll() {
    _notifTracker.clear();
  }

  void scheduleRenotif(int jadwalId) {
    Future.delayed(const Duration(seconds: 5), () {
      _notifTracker[jadwalId]?.expiredSent = false;

      _checkAllJadwal();
    });
  }

  Future<void> _checkAllJadwal() async {
    try {
      final db = DatabaseService.instance;
      final List<JadwalModel> aktifList = await db.getActiveJadwal();
      final now = DateTime.now();

      for (final jadwal in aktifList) {
        if (jadwal.id == null) continue;

        final endTime = DateTime.tryParse(jadwal.endTime);
        if (endTime == null) continue;

        final sisaDurasi = endTime.difference(now);
        final record = _notifTracker[jadwal.id!] ?? _NotifRecord();
        _notifTracker[jadwal.id!] = record;

        // Ambil nama unit dari database
        String unitLabel;
        if (jadwal.packageName != null && jadwal.packageName!.isNotEmpty) {
          unitLabel = jadwal.packageName!;
        } else if (jadwal.unitId != null) {
          final unitName = await db.getUnitNameById(jadwal.unitId!);
          unitLabel = unitName ?? 'Unit ${jadwal.unitId}';
        } else {
          unitLabel = 'Unit tidak diketahui';
        }

        if ((sisaDurasi.isNegative || sisaDurasi.inSeconds == 0) &&
            !record.expiredSent) {
          record.expiredSent = true;
          onNotification?.call(
            NotifPayload(
              jadwalId: jadwal.id!,
              unitId: jadwal.unitId,
              customerName: jadwal.customerName ?? 'Guest',
              packageOrUnit: unitLabel,
              category: jadwal.category ?? '-',
              endTime: endTime,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[NontifikasiService] Error saat cek jadwal: $e');
    }
  }
}

class NotifPayload {
  final int jadwalId;
  final int? unitId;
  final String customerName;
  final String packageOrUnit;
  final String category;
  final DateTime endTime;

  const NotifPayload({
    required this.jadwalId,
    required this.unitId,
    required this.customerName,
    required this.packageOrUnit,
    required this.category,
    required this.endTime,
  });
}
