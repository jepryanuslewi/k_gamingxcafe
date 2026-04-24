import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/screens/generate%20laporan/excel_helper.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import 'package:k_gamingxcafe/widgets/laporan/tabel_laporan_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DashboardLaporanScreen extends StatefulWidget {
  final String shiftName;
  const DashboardLaporanScreen({super.key, required this.shiftName});

  @override
  State<DashboardLaporanScreen> createState() => _DashboardLaporanScreenState();
}

class _DashboardLaporanScreenState extends State<DashboardLaporanScreen> {
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;

  String? selectedKategori;
  String? selectedSubKategori;
  String? selectedKaryawan = "Semua";

  bool isTableVisible = false;
  bool isExporting = false; // ← loading state saat export

  List<String> listKaryawan = ["Semua"];

  Future<void> _loadKaryawan() async {
    final names = await DatabaseService.instance.getAllStaffNames();
    setState(() {
      listKaryawan = names;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadKaryawan();
  }

  final List<String> listKategori = ["Jadwal", "Stock", "Transaksi"];

  List<String> getSubKategori() {
    if (selectedKategori == "Jadwal") return ["Walk-In", "Booking", "Semua"];
    if (selectedKategori == "Stock") return ["Masuk", "Keluar", "Semua"];
    if (selectedKategori == "Transaksi") return ["Makanan", "Minuman", "Semua"];
    return [];
  }

  Future<void> _selectDate(BuildContext context, bool isAwal) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E0C6),
              onPrimary: Color(0xFF0B1220),
              surface: Color(0xFF141C2F),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isAwal)
          tanggalAwal = picked;
        else
          tanggalAkhir = picked;
        isTableVisible = false;
      });
    }
  }

  // ─────────────────────────────────────────────
  //  AMBIL DATA DARI DATABASE
  // ─────────────────────────────────────────────
  Future<Map<String, dynamic>> _fetchAllExportData() async {
    final db = await DatabaseService.instance.database;
    final fmt = DateFormat('yyyy-MM-dd');
    final awal = fmt.format(tanggalAwal!);
    final akhir = fmt.format(tanggalAkhir!);

    // ── Jadwal (tabel: jadwal, shifts, users, ps_units) ──────────
    final jadwalRaw = await db.rawQuery(
      '''
      SELECT
        j.customer_name,
        s.shift_name,
        u.username        AS operator,
        j.created_at,
        j.category,
        -- Detail: paket event jika ada, fallback ke nama unit PS
        CASE
          WHEN j.package_name IS NOT NULL AND j.package_name != ''
            THEN j.package_name
          WHEN p.name IS NOT NULL
            THEN p.name
          ELSE '-'
        END AS detail,
        j.start_time,
        j.duration_hours,
        j.total_price,
        j.status
      FROM jadwal j
      INNER JOIN shifts s   ON j.shift_id = s.id
      INNER JOIN users  u   ON s.user_id  = u.id
      LEFT  JOIN ps_units p ON j.unit_id  = p.id
      WHERE DATE(j.created_at) BETWEEN ? AND ?
      ORDER BY j.created_at ASC
    ''',
      [awal, akhir],
    );

    final jadwalRows = jadwalRaw
        .map(
          (r) => [
            r['customer_name']?.toString() ?? '-', // NAMA
            r['shift_name']?.toString() ?? '-', // SHIFT
            (r['created_at']?.toString() ?? '-').substring(0, 10), // TANGGAL
            r['detail']?.toString() ?? '-', // DETAIL (paket / unit PS)
            r['start_time']?.toString() ?? '-', // JAM
            '${r['duration_hours'] ?? 0} Jam', // DURASI
            'Rp ${r['total_price'] ?? 0}', // HARGA
            r['status']?.toString() ?? '-', // STATUS
          ],
        )
        .toList();

    final jadwalTotal = jadwalRaw.fold<int>(
      0,
      (sum, r) => sum + ((r['total_price'] as int?) ?? 0),
    );

    // ── Transaksi (tabel: cafe_transactions, shifts, users, menu) ─
    final transaksiRaw = await db.rawQuery(
      '''
      SELECT
        u.username              AS operator,
        s.shift_name,
        ct.created_at,
        ct.nama_produk,
        COALESCE(m.kategori, '-') AS kategori,
        ct.jumlah,
        ct.harga_satuan,
        ct.total_harga
      FROM cafe_transactions ct
      INNER JOIN shifts s ON ct.shift_id   = s.id
      INNER JOIN users  u ON s.user_id     = u.id
      LEFT  JOIN menu   m ON ct.product_id = m.id
      WHERE DATE(ct.created_at) BETWEEN ? AND ?
        AND ct.status = 'active'
      ORDER BY ct.created_at ASC
    ''',
      [awal, akhir],
    );

    final transaksiRows = transaksiRaw
        .map(
          (r) => [
            r['operator']?.toString() ?? '-',
            r['shift_name']?.toString() ?? '-',
            (r['created_at']?.toString() ?? '-').substring(0, 10),
            r['nama_produk']?.toString() ?? '-',
            r['kategori']?.toString() ?? '-',
            r['jumlah']?.toString() ?? '0',
            'Rp ${r['harga_satuan'] ?? 0}',
            'Rp ${r['total_harga'] ?? 0}',
          ],
        )
        .toList();

    final transaksiTotal = transaksiRaw.fold<int>(
      0,
      (sum, r) => sum + ((r['total_harga'] as int?) ?? 0),
    );

    // ── Stock (tabel: riwayat_bahan, bahan) ──────────────────────
    final stockRaw = await db.rawQuery(
      '''
      SELECT
        rb.username,
        rb.nama_shift,
        rb.waktu,
        b.nama              AS nama_bahan,
        b.kategori,
        rb.jumlah,
        rb.tipe,
        COALESCE(rb.keterangan, '-') AS keterangan
      FROM riwayat_bahan rb
      JOIN bahan b ON rb.bahan_id = b.id
      WHERE DATE(rb.waktu) BETWEEN ? AND ?
      ORDER BY rb.waktu ASC
    ''',
      [awal, akhir],
    );

    final stockRows = stockRaw
        .map(
          (r) => [
            r['username']?.toString() ?? '-',
            r['nama_shift']?.toString() ?? '-',
            (r['waktu']?.toString() ?? '-').substring(0, 10),
            r['nama_bahan']?.toString() ?? '-',
            r['kategori']?.toString() ?? '-',
            r['jumlah']?.toString() ?? '0',
            r['tipe']?.toString() ?? '-',
            r['keterangan']?.toString() ?? '-',
          ],
        )
        .toList();

    final stockMasuk = stockRaw.where((r) => r['tipe'] == 'masuk').length;
    final stockKeluar = stockRaw.where((r) => r['tipe'] == 'keluar').length;

    return {
      'jadwalRows': jadwalRows,
      'jadwalTotal': 'Rp $jadwalTotal',
      'transaksiRows': transaksiRows,
      'transaksiTotal': 'Rp $transaksiTotal',
      'stockRows': stockRows,
      'stockTotal': '$stockMasuk Masuk / $stockKeluar Keluar',
    };
  }

  // ─────────────────────────────────────────────
  //  EXPORT ALL
  // ─────────────────────────────────────────────
  Future<void> _handleExportAll() async {
    if (tanggalAwal == null || tanggalAkhir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pilih tanggal awal dan akhir dulu")),
      );
      return;
    }

    setState(() => isExporting = true);

    try {
      final data = await _fetchAllExportData();

      await ExcelHelper.saveAndShareAllSheets(
        jadwalData: data['jadwalRows'] as List<List<String>>,
        jadwalTotal: data['jadwalTotal'] as String,
        transaksiData: data['transaksiRows'] as List<List<String>>,
        transaksiTotal: data['transaksiTotal'] as String,
        stockData: data['stockRows'] as List<List<String>>,
        stockTotal: data['stockTotal'] as String,
        tanggalAwal: tanggalAwal,
        tanggalAkhir: tanggalAkhir,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal export: $e")));
      }
    } finally {
      if (mounted) setState(() => isExporting = false);
    }
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final tanggal = DateTime.now();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 18, 32, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildMainForm(tanggal),
              if (isTableVisible && selectedKategori != null)
                TabelLaporanWidget(
                  kategori: selectedKategori!,
                  subKategori: selectedSubKategori,
                  tanggalAwal: tanggalAwal,
                  tanggalAkhir: tanggalAkhir,
                  karyawan: selectedKaryawan,
                ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 90,
      child: Row(
        children: [
          Image.asset("assets/images/bgLoginScreen.png", height: 60),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    fontFamily: "Poppins",
                  ),
                  children: [
                    TextSpan(
                      text: "GAMING ",
                      style: TextStyle(color: Color.fromRGBO(226, 19, 136, 1)),
                    ),
                    TextSpan(
                      text: "X ",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    TextSpan(
                      text: "CAFE",
                      style: TextStyle(color: Color.fromRGBO(0, 224, 198, 1)),
                    ),
                  ],
                ),
              ),
              const Text(
                "Kelola Laporan Lengkap",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainForm(DateTime tanggal) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(20, 28, 47, 1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LAPORAN LENGKAP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 40),

          // ── Filter ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    _buildDateTile(
                      "Tanggal Awal",
                      tanggalAwal,
                      () => _selectDate(context, true),
                    ),
                    const SizedBox(width: 20),
                    _buildDateTile(
                      "Tanggal Akhir",
                      tanggalAkhir,
                      () => _selectDate(context, false),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildDropdown(
                      "Pilih Kategori",
                      selectedKategori,
                      listKategori,
                      (val) => setState(() {
                        selectedKategori = val;
                        selectedSubKategori = null;
                        isTableVisible = false;
                      }),
                    ),
                    const SizedBox(width: 10),
                    _buildDropdown(
                      "Sub Kategori",
                      selectedSubKategori,
                      getSubKategori(),
                      (val) => setState(() {
                        selectedSubKategori = val;
                        isTableVisible = false;
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // ── Tombol ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tampilkan Laporan
              SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 20, 149, 134),
                    side: const BorderSide(
                      color: Color.fromARGB(255, 142, 142, 142),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (tanggalAwal == null ||
                        tanggalAkhir == null ||
                        selectedKategori == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Lengkapi semua filter terlebih dahulu",
                          ),
                        ),
                      );
                      return;
                    }
                    setState(() => isTableVisible = true);
                  },
                  child: const Text(
                    "TAMPILKAN LAPORAN",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 20),

              // Export All
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black26,
                    side: const BorderSide(color: Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: isExporting ? null : _handleExportAll,
                  child: isExporting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "EXPORT ALL",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            width: 150,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date == null
                      ? "Pilih Tanggal"
                      : DateFormat('dd/MM/yyyy').format(date),
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF00E0C6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          width: 150,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF141C2F),
              hint: const Text(
                "Pilih",
                style: TextStyle(color: Colors.white38),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E0C6)),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
