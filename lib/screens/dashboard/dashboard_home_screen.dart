import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k_gamingxcafe/providers/pendapatan_provider.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import 'package:provider/provider.dart';

class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({super.key});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  // ── Data minggu & bulan ini ──────────────────
  int _totalHariIni = 0;
  int _transaksiHariIni = 0;
  int _totalMingguIni = 0;
  int _transaksiMingguIni = 0;
  int _totalBulanIni = 0;
  int _transaksiBulanIni = 0;

  // ── Data per kategori ────────────────────────
  int _totalWalkIn = 0;
  int _transaksiWalkIn = 0;
  int _totalBooking = 0;
  int _transaksiBooking = 0;
  int _totalShiftPagi = 0;
  int _transaksiShiftPagi = 0;
  int _totalShiftMalam = 0;
  int _transaksiShiftMalam = 0;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Fetch provider data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PendapatanProvider>().fetchSemua();
      _fetchExtraData();
    });
  }

  Future<void> _fetchExtraData() async {
    setState(() => _isLoading = true);

    final db = await DatabaseService.instance.database;
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');

    // ── Minggu ini ───────────────────────────────
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final weekStart = fmt.format(startOfWeek);
    final today = fmt.format(now);

    // ── Bulan ini ────────────────────────────────
    final monthStart = fmt.format(DateTime(now.year, now.month, 1));

    // ─────────────────────────────────────────────
    // HARI INI (cafe_transactions only)
    // ─────────────────────────────────────────────
    final hariIniCafe = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total_harga), 0) AS total, COUNT(*) AS jumlah
      FROM cafe_transactions
      WHERE DATE(created_at) = ?
        AND status = 'active'
    ''',
      [today],
    );

    _totalHariIni = (hariIniCafe.first['total'] as num?)?.toInt() ?? 0;
    _transaksiHariIni = (hariIniCafe.first['jumlah'] as int?) ?? 0;

    // ─────────────────────────────────────────────
    // MINGGU INI (cafe_transactions only)
    // ─────────────────────────────────────────────
    final mingguCafe = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total_harga), 0) AS total, COUNT(*) AS jumlah
      FROM cafe_transactions
      WHERE DATE(created_at) BETWEEN ? AND ?
        AND status = 'active'
    ''',
      [weekStart, today],
    );

    _totalMingguIni = (mingguCafe.first['total'] as num?)?.toInt() ?? 0;
    _transaksiMingguIni = (mingguCafe.first['jumlah'] as int?) ?? 0;

    // ─────────────────────────────────────────────
    // BULAN INI (cafe_transactions only)
    // ─────────────────────────────────────────────
    final bulanCafe = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total_harga), 0) AS total, COUNT(*) AS jumlah
      FROM cafe_transactions
      WHERE DATE(created_at) BETWEEN ? AND ?
        AND status = 'active'
    ''',
      [monthStart, today],
    );

    _totalBulanIni = (bulanCafe.first['total'] as num?)?.toInt() ?? 0;
    _transaksiBulanIni = (bulanCafe.first['jumlah'] as int?) ?? 0;

    // ─────────────────────────────────────────────
    // WALK-IN bulan ini
    // ─────────────────────────────────────────────
    final walkIn = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total_price), 0) AS total, COUNT(*) AS jumlah
      FROM jadwal
      WHERE DATE(created_at) BETWEEN ? AND ?
        AND status = 'walkin'
        AND status_completed = 'done'
    ''',
      [monthStart, today],
    );

    _totalWalkIn = (walkIn.first['total'] as num?)?.toInt() ?? 0;
    _transaksiWalkIn = (walkIn.first['jumlah'] as int?) ?? 0;

    // ─────────────────────────────────────────────
    // BOOKING bulan ini
    // ─────────────────────────────────────────────
    final booking = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total_price), 0) AS total, COUNT(*) AS jumlah
      FROM jadwal
      WHERE DATE(created_at) BETWEEN ? AND ?
        AND status = 'booking'
        AND status_completed = 'done'
    ''',
      [monthStart, today],
    );

    _totalBooking = (booking.first['total'] as num?)?.toInt() ?? 0;
    _transaksiBooking = (booking.first['jumlah'] as int?) ?? 0;

    // ─────────────────────────────────────────────
    // SHIFT PAGI & MALAM bulan ini
    // Asumsi: shift_name berisi kata "Pagi" atau "Malam"
    // ─────────────────────────────────────────────
    final shiftPagi = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(j.total_price), 0) AS total, COUNT(*) AS jumlah
      FROM jadwal j
      INNER JOIN shifts s ON j.shift_id = s.id
      WHERE DATE(j.created_at) BETWEEN ? AND ?
        AND j.status_completed = 'done'
        AND LOWER(s.shift_name) LIKE '%pagi%'
    ''',
      [monthStart, today],
    );

    _totalShiftPagi = (shiftPagi.first['total'] as num?)?.toInt() ?? 0;
    _transaksiShiftPagi = (shiftPagi.first['jumlah'] as int?) ?? 0;

    final shiftMalam = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(j.total_price), 0) AS total, COUNT(*) AS jumlah
      FROM jadwal j
      INNER JOIN shifts s ON j.shift_id = s.id
      WHERE DATE(j.created_at) BETWEEN ? AND ?
        AND j.status_completed = 'done'
        AND LOWER(s.shift_name) LIKE '%malam%'
    ''',
      [monthStart, today],
    );

    _totalShiftMalam = (shiftMalam.first['total'] as num?)?.toInt() ?? 0;
    _transaksiShiftMalam = (shiftMalam.first['jumlah'] as int?) ?? 0;

    if (mounted) setState(() => _isLoading = false);
  }

  String _formatRp(int value) =>
      'Rp ${NumberFormat('#,###', 'id_ID').format(value)}';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final pendapatan = context.watch<PendapatanProvider>();

    // Hitung total transaksi hari ini dari provider
    // (tidak disimpan terpisah di provider, kita tampilkan gabungan)
    final totalHariIni = pendapatan.totalGabungan;

    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await context.read<PendapatanProvider>().fetchSemua();
            await _fetchExtraData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(now),
                const SizedBox(height: 20),

                // ── TOP STATS ──────────────────────────────
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: CircularProgressIndicator(
                        color: Color(0xFF00E0C6),
                      ),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: DashboardCard(
                          title: "Penjualan Hari Ini",
                          value: _formatRp(_totalHariIni),
                          subtitle: "Total Transaksi: $_transaksiHariIni",
                          accentColor: const Color(0xFF00E0C6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          title: "Penjualan Minggu Ini",
                          value: _formatRp(_totalMingguIni),
                          subtitle: "Total Transaksi: $_transaksiMingguIni",
                          accentColor: const Color(0xFF00E0C6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardCard(
                          title: "Penjualan Bulan Ini",
                          value: _formatRp(_totalBulanIni),
                          subtitle: "Total Transaksi: $_transaksiBulanIni",
                          accentColor: const Color(0xFF00E0C6),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ── CONTAINER BREAKDOWN ────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xff1c273d),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Column(
                      children: [
                        // BARIS 1 — Walk-in & Booking
                        Row(
                          children: [
                            Expanded(
                              child: DashboardCard(
                                title: "Transaksi PS Walk-In",
                                value: _formatRp(_totalWalkIn),
                                subtitle:
                                    "Total Transaksi Bulan Ini: $_transaksiWalkIn",
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: DashboardCard(
                                title: "Transaksi PS Booking",
                                value: _formatRp(_totalBooking),
                                subtitle:
                                    "Total Transaksi Bulan Ini: $_transaksiBooking",
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // BARIS 2 — Shift Pagi & Malam
                        Row(
                          children: [
                            Expanded(
                              child: DashboardCard(
                                title: "Shift Pagi Gaming",
                                value: _formatRp(_totalShiftPagi),
                                subtitle:
                                    "Total Transaksi Bulan Ini: $_transaksiShiftPagi",
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: DashboardCard(
                                title: "Shift Malam Gaming",
                                value: _formatRp(_totalShiftMalam),
                                subtitle:
                                    "Total Transaksi Bulan Ini: $_transaksiShiftMalam",
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ── HINT SWIPE TO REFRESH ──────────────────
                const Center(
                  child: Text(
                    "Tarik ke bawah untuk refresh data",
                    style: TextStyle(color: Colors.white24, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(DateTime now) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Text(
              "DASHBOARD",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10),
            Text(
              "GAMING",
              style: TextStyle(
                color: Color.fromRGBO(226, 19, 136, 100),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(width: 5),
            Text(
              "X",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.normal,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(width: 5),
            Text(
              "CAFE",
              style: TextStyle(
                color: Color.fromRGBO(0, 224, 198, 100),
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: "Poppins",
              ),
            ),
          ],
        ),
        Text(
          DateFormat('dd/MM/yyyy').format(now),
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  DASHBOARD CARD WIDGET
// ─────────────────────────────────────────────
class DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color accentColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    this.accentColor = const Color(0xFF00E0C6),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff1c273d),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(subtitle, style: TextStyle(color: accentColor, fontSize: 13)),
        ],
      ),
    );
  }
}
