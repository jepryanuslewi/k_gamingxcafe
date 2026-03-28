import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/screens/pdf_screen.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class TabelLaporanWidget extends StatefulWidget {
  final String kategori;
  final String? subKategori;
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
    // Cek apakah ada parameter yang berubah
    if (oldWidget.karyawan != widget.karyawan ||
        oldWidget.tanggalAwal != widget.tanggalAwal ||
        oldWidget.tanggalAkhir != widget.tanggalAkhir ||
        oldWidget.subKategori != widget.subKategori ||
        oldWidget.kategori != widget.kategori) {
      // Jika berubah, panggil ulang data dari database
      _loadDataFromDatabase();
    }
  }

  // ✅ Tambah fungsi ini
  String _formatTanggal(String? raw) {
    if (raw == null || raw.isEmpty) return "-";
    try {
      final datePart = raw.split(RegExp(r'[ T]'))[0];
      final parts = datePart.split('-');
      if (parts.length != 3) return raw;
      return "${parts[2]}/${parts[1]}/${parts[0]}";
    } catch (e) {
      return raw;
    }
  }

  String _formatRibuan(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  Future<void> _loadDataFromDatabase() async {
    try {
      setState(() => _isLoading = true);

      final rawData = await DatabaseService.instance.getJadwalLaporan(
        tglAwal: widget.tanggalAwal,
        tglAkhir: widget.tanggalAkhir,
        subKategori: widget.subKategori,
        namaKaryawan: widget.karyawan,
      );

      int total = 0;
      List<List<String>> formattedData = rawData.map((row) {
        int harga = row['total_price'] is int
            ? row['total_price']
            : int.tryParse(row['total_price'].toString()) ?? 0;

        total += harga;

        return [
          row['operator']?.toString() ?? "-",
          row['shift_name']?.toString() ?? "-",
          _formatTanggal(row['created_at']?.toString()), // ✅ format dd/MM/yy
          "${row['unit_name'] ?? row['package_name'] ?? '-'} | ${row['status'] == 'booking' ? 'BOOKING' : 'WALK IN'}",
          row['duration_hours']?.toString() ?? "0",
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
      print("UI Load Error: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(20, 28, 47, 1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(0, 224, 198, 0.3)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "LAPORAN ${widget.kategori.toUpperCase()}",
                  style: const TextStyle(
                    color: Color(0xFF00E0C6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => PdfHelper.saveAndOpenPdf(
                    kategori: widget.kategori,
                    tableData: _dataJadwal,
                    total: _totalPendapatan,
                  ),
                  icon: const Icon(Icons.picture_as_pdf, size: 18),
                  label: const Text("EXPORT PDF"),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(
                  label: Text('NAMA', style: TextStyle(color: Colors.white70)),
                ),
                DataColumn(
                  label: Text('SHIFT', style: TextStyle(color: Colors.white70)),
                ),
                DataColumn(
                  label: Text(
                    'TANGGAL',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'DETAIL',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                DataColumn(
                  label: Text('JAM', style: TextStyle(color: Colors.white70)),
                ),
                DataColumn(
                  label: Text('HARGA', style: TextStyle(color: Colors.white70)),
                ),
              ],
              rows: _dataJadwal
                  .map(
                    (item) => DataRow(
                      cells: [
                        DataCell(
                          Text(
                            item[0],
                            style: const TextStyle(color: Colors.white),
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
                        DataCell(
                          Row(
                            children: [
                              Text(
                                // Ambil nama unit/paket
                                item[3].split(' | ')[0],
                                style: const TextStyle(color: Colors.white),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: item[3].contains('BOOKING')
                                      ? Colors.orange.withOpacity(0.2)
                                      : const Color(
                                          0xFF00E0C6,
                                        ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: item[3].contains('BOOKING')
                                        ? Colors.orange
                                        : const Color(0xFF00E0C6),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  item[3].contains('BOOKING')
                                      ? 'BOOKING'
                                      : 'WALK IN',
                                  style: TextStyle(
                                    color: item[3].contains('BOOKING')
                                        ? Colors.orange
                                        : const Color(0xFF00E0C6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text(
                            "${item[4]} Jam",
                            style: const TextStyle(color: Color(0xFF00E0C6)),
                          ),
                        ),
                        DataCell(
                          Text(
                            "Rp ${item[5]}",
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
          // Footer Total
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "TOTAL PENDAPATAN",
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  "Rp $_totalPendapatan",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
