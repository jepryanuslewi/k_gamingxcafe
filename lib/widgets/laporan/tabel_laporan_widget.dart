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
    if (oldWidget.karyawan != widget.karyawan ||
        oldWidget.tanggalAwal != widget.tanggalAwal ||
        oldWidget.tanggalAkhir != widget.tanggalAkhir ||
        oldWidget.subKategori != widget.subKategori ||
        oldWidget.kategori != widget.kategori) {
      _loadDataFromDatabase();
    }
  }

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

  String _formatStatus(String? status) {
    switch (status) {
      case 'booking':
        return 'BOOKING';
      case 'walkin':
        return 'WALK IN';
      default:
        return '-';
    }
  }

  String _formatStatusCompleted(String? status) {
    switch (status) {
      case 'active':
        return 'AKTIF';
      case 'done':
        return 'SELESAI';
      case 'deleted':
        return 'DIHAPUS';
      default:
        return '-';
    }
  }

  Future<void> _loadDataFromDatabase() async {
    // Fungsi bantu untuk memformat jam
    String ambilJam(String? raw) {
      if (raw == null || raw.isEmpty || raw == "null") return "--:--";
      try {
        final DateTime dateTime = DateTime.parse(raw);
        return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
      } catch (e) {
        return "--:--";
      }
    }

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

        // Gabungkan Jam Mulai - Jam Selesai
        String rentangWaktu =
            "${ambilJam(row['start_time']?.toString())} - ${ambilJam(row['end_time']?.toString())}";

        return [
          row['operator']?.toString() ?? "-", // [0]
          row['shift_name']?.toString() ?? "-", // [1]
          _formatTanggal(row['created_at']?.toString()), // [2]
          "${row['unit_name'] ?? row['package_name'] ?? '-'} | ${_formatStatus(row['status']?.toString())}", // [3]
          rentangWaktu, // [4]
          row['duration_hours']?.toString() ?? "0", // [5]
          _formatRibuan(harga), // [6]
          _formatStatusCompleted(row['status_completed']?.toString()), // [7]
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Color _badgeColor(String detail) {
    if (detail.contains('BOOKING')) return Colors.orange;
    if (detail.contains('WALK IN')) return const Color(0xFF00E0C6);
    if (detail.contains('SELESAI')) return Colors.greenAccent;
    if (detail.contains('DIHAPUS')) return Colors.redAccent;
    return Colors.white54;
  }

  Color _statusCompletedColor(String status) {
    switch (status) {
      case 'AKTIF':
        return const Color(0xFF00E0C6);
      case 'SELESAI':
        return Colors.greenAccent;
      case 'DIHAPUS':
        return Colors.redAccent;
      default:
        return Colors.white54;
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
                  label: Text(
                    'DURASI',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                DataColumn(
                  label: Text('HARGA', style: TextStyle(color: Colors.white70)),
                ),
                DataColumn(
                  label: Text(
                    'STATUS',
                    style: TextStyle(color: Colors.white70),
                  ),
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
                                  color: _badgeColor(item[3]).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _badgeColor(item[3]),
                                    width: 0.5,
                                  ),
                                ),
                                child: Text(
                                  item[3].contains(' | ')
                                      ? item[3].split(' | ')[1]
                                      : '-',
                                  style: TextStyle(
                                    color: _badgeColor(item[3]),
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
                            item[4],
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            "${item[5]} Jam",
                            style: const TextStyle(color: Color(0xFF00E0C6)),
                          ),
                        ),
                        DataCell(
                          Text(
                            "Rp ${item[6]}",
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                        ),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusCompletedColor(
                                item[7],
                              ).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _statusCompletedColor(item[7]),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              item[7],
                              style: TextStyle(
                                color: _statusCompletedColor(item[7]),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            ),
          ),
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
