import 'dart:async';
import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class PendapatanProvider extends ChangeNotifier {
  int _totalGaming = 0;
  int _totalCafe = 0;
  int _totalGabungan = 0;

  int get totalGaming => _totalGaming;
  int get totalCafe => _totalCafe;
  int get totalGabungan => _totalGabungan;

  Timer? _timerRefresh;
  Timer? _timerReset;

  // Mulai fetch realtime saat provider dibuat
  void startRealtime() {
    // Fetch pertama kali langsung
    fetchSemua();

    // Refresh setiap 30 detik agar realtime
    _timerRefresh = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchSemua();
    });

    // Reset otomatis saat tengah malam (00:00)
    _jadwalResetTengahMalam();
  }

  Future<void> fetchSemua() async {
    _totalGaming = await DatabaseService.instance.getTotalGamingHariIni();
    _totalCafe = await DatabaseService.instance.getTotalCafeHariIni();
    _totalGabungan = await DatabaseService.instance.getTotalGabunganHariIni();
    notifyListeners();
  }

  void _jadwalResetTengahMalam() {
    final now = DateTime.now();
    // Hitung durasi sampai tengah malam berikutnya
    final tengahMalam = DateTime(now.year, now.month, now.day + 1);
    final durasiSampaiReset = tengahMalam.difference(now);

    _timerReset = Timer(durasiSampaiReset, () {
      // Reset nilai ke 0 (data DB sudah otomatis 0 karena filter DATE)
      fetchSemua();
      // Jadwal ulang untuk hari berikutnya
      _jadwalResetTengahMalam();
    });
  }

  @override
  void dispose() {
    _timerRefresh?.cancel();
    _timerReset?.cancel();
    super.dispose();
  }
}
