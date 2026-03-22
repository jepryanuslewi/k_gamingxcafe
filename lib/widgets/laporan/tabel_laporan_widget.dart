import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
// import 'package:k_gamingxcafe/screens/pdf_screen.dart'; // Sesuaikan jika ada helper PDF

class TabelLaporanWidget extends StatefulWidget {
  final String kategori; // Jadwal / Stock / Transaksi
  final String? subKategori; // Booking / Walk-In / Semua
  final DateTime? tanggalAwal;
  final DateTime? tanggalAkhir;
  final String? karyawan;

  const TabelLaporanWidget({
    super.key,
    required this.kategori,
    this.subKategori,
    this.tanggalAwal,
    this.tanggalAkhir,
    this.karyawan,
  });

  @override
  State<TabelLaporanWidget> createState() => _TabelLaporanWidgetState();
}

class _TabelLaporanWidgetState extends State<TabelLaporanWidget> {
  List<List<String>> _dataJadwal = [];
  String _totalPendapatan = "0";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDataFromDatabase();
  }

  @override
  void didUpdateWidget(covariant TabelLaporanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Refresh jika ada parameter filter yang berubah
    if (oldWidget.subKategori != widget.subKategori ||
        oldWidget.tanggalAwal != widget.tanggalAwal ||
        oldWidget.tanggalAkhir != widget.tanggalAkhir ||
        oldWidget.karyawan != widget.karyawan) {
      _loadDataFromDatabase();
    }
  }

  Future<void> _loadDataFromDatabase() async {
    try {
      if (!mounted) return;
      setState(() => _isLoading = true);

      final rawData = await DatabaseService.instance.getJadwalLaporan(
        tglAwal: widget.tanggalAwal,
        tglAkhir: widget.tanggalAkhir,
        subKategori:
            widget.subKategori, // Ini akan memfilter kolom 'status' di DB
        namaKaryawan: widget.karyawan,
      );

      int total = 0;
      List<List<String>> formattedData = rawData.map((row) {
        int harga = row['total_price'] is int
            ? row['total_price']
            : int.tryParse(row['total_price'].toString()) ?? 0;
        total += harga;

        return [
          row['customer_name']?.toString() ?? "-",
          row['operator']?.toString() ?? "N/A",
          row['created_at']?.toString().split(RegExp(r'[ T]'))[0] ?? "-",
          row['status']?.toString() ?? "-", // Index 3: Status (Booking/Walk-In)
          row['category']?.toString() ?? "-", // Index 4: Unit (PS4/PS5)
          row['package_name']?.toString() ?? "-",
          "${row['duration_hours']} Jam",
          _formatRibuan(harga),
        ];
      }).toList();

      if (mounted) {
        setState(() {
          _dataJadwal = formattedData;
          _totalPendapatan = _formatRibuan(total);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error UI Laporan: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatRibuan(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E0C6)),
        ),
      );
    }

    if (_dataJadwal.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 50),
        child: Center(
          child: Text(
            "Data tidak ditemukan.",
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(20, 28, 47, 1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(0, 224, 198, 0.3)),
      ),
      child: Column(
        children: [
          _buildHeaderSection(),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                Colors.white.withOpacity(0.05),
              ),
              columns: const [
                DataColumn(
                  label: Text(
                    'PELANGGAN',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                DataColumn(
                  label: Text('STAFF', style: TextStyle(color: Colors.white70)),
                ),
                DataColumn(
                  label: Text(
                    'TANGGAL',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'STATUS',
                    style: TextStyle(color: Colors.white70),
                  ),
                ), // Kolom Status
                DataColumn(
                  label: Text('UNIT', style: TextStyle(color: Colors.white70)),
                ), // Kolom Unit (PS4/PS5)
                DataColumn(
                  label: Text('PAKET', style: TextStyle(color: Colors.white70)),
                ),
                DataColumn(
                  label: Text('JAM', style: TextStyle(color: Colors.white70)),
                ),
                DataColumn(
                  label: Text('TOTAL', style: TextStyle(color: Colors.white70)),
                ),
              ],
              rows: _dataJadwal
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            item[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            item[1],
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        DataCell(
                          Text(
                            item[2],
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                        // Label Status: Booking (Orange) / Walk-In (Blue)
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: item[3].toLowerCase() == "booking"
                                  ? Colors.orange.withOpacity(0.2)
                                  : Colors.blue.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item[3].toUpperCase(),
                              style: TextStyle(
                                color: item[3].toLowerCase() == "booking"
                                    ? Colors.orange
                                    : Colors.blue,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            item[4],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        DataCell(
                          Text(
                            item[5],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        DataCell(
                          Text(
                            item[6],
                            style: const TextStyle(color: Color(0xFF00E0C6)),
                          ),
                        ),
                        DataCell(
                          Text(
                            "Rp ${item[7]}",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          _buildFooterSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    String kategoriTitle = widget.subKategori == "Semua"
        ? "BOOKING & WALK-IN"
        : widget.subKategori?.toUpperCase() ?? "LAPORAN";

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "LAPORAN ${widget.kategori.toUpperCase()}",
                style: const TextStyle(
                  color: Color(0xFF00E0C6),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                kategoriTitle,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () {}, // Panggil PdfHelper
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E0C6),
              foregroundColor: Colors.black,
            ),
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text("PDF"),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "TOTAL PENDAPATAN",
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "Rp $_totalPendapatan",
            style: const TextStyle(
              color: Colors.greenAccent,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
