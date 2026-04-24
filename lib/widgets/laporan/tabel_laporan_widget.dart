import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/screens/generate%20laporan/excel_helper.dart';
import 'package:k_gamingxcafe/screens/generate%20laporan/pdf_screen.dart';
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
  List<List<String>> _tableData = [];
  String _totalLabel = "TOTAL";
  String _totalValue = "0";
  bool _isLoading = true;

  // ─────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant TabelLaporanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final berubah =
        oldWidget.karyawan != widget.karyawan ||
        oldWidget.tanggalAwal != widget.tanggalAwal ||
        oldWidget.tanggalAkhir != widget.tanggalAkhir ||
        oldWidget.subKategori != widget.subKategori ||
        oldWidget.kategori != widget.kategori;
    if (berubah) _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) setState(() => _isLoading = true);

    try {
      switch (widget.kategori) {
        case "Jadwal":
          await _loadJadwal();
          break;
        case "Transaksi":
          await _loadTransaksi();
          break;
        case "Stock":
          await _loadStock();
          break;
      }
    } catch (e) {
      debugPrint("TabelLaporan Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── JADWAL ──────────────────────────────────

  Future<void> _loadJadwal() async {
    final rawData = await DatabaseService.instance.getJadwalLaporan(
      tglAwal: widget.tanggalAwal,
      tglAkhir: widget.tanggalAkhir,
      subKategori: widget.subKategori,
      namaKaryawan: widget.karyawan,
    );

    int total = 0;
    final formatted = rawData.map((row) {
      final harga = _toInt(row['total_price']);
      total += harga;
      return [
        row['operator']?.toString() ?? "-", // [0] Nama
        row['shift_name']?.toString() ?? "-", // [1] Shift
        _formatTanggal(row['created_at']?.toString()), // [2] Tanggal
        "${row['unit_name'] ?? row['package_name'] ?? '-'} | ${_formatStatus(row['status']?.toString())}", // [3] Detail
        "${_ambilJam(row['start_time']?.toString())} - ${_ambilJam(row['end_time']?.toString())}", // [4] Jam
        "${row['duration_hours']?.toString() ?? '0'} Jam", // [5] Durasi
        "Rp ${_formatRibuan(harga)}", // [6] Harga
        _formatStatusCompleted(
          row['status_completed']?.toString(),
        ), // [7] Status
      ];
    }).toList();

    if (mounted) {
      setState(() {
        _tableData = formatted;
        _totalLabel = "TOTAL PENDAPATAN";
        _totalValue = "Rp ${_formatRibuan(total)}";
      });
    }
  }

  // ── TRANSAKSI ───────────────────────────────

  Future<void> _loadTransaksi() async {
    final rawData = await DatabaseService.instance.getTransaksiLaporan(
      tglAwal: widget.tanggalAwal,
      tglAkhir: widget.tanggalAkhir,
      subKategori: widget.subKategori,
      namaKaryawan: widget.karyawan,
    );

    int total = 0;
    final formatted = rawData.map((row) {
      final harga = _toInt(row['total_harga']);
      total += harga;
      return [
        row['operator']?.toString() ?? "-", // [0] Operator
        row['shift_name']?.toString() ?? "-", // [1] Shift
        _formatTanggal(row['created_at']?.toString()), // [2] Tanggal
        row['nama_produk']?.toString() ?? "-", // [3] Produk
        row['kategori']?.toString() ?? "-", // [4] Kategori
        row['jumlah']?.toString() ?? "0", // [5] Qty
        "Rp ${_formatRibuan(_toInt(row['harga_satuan']))}", // [6] Harga Satuan
        "Rp ${_formatRibuan(harga)}", // [7] Total Harga
      ];
    }).toList();

    if (mounted) {
      setState(() {
        _tableData = formatted;
        _totalLabel = "TOTAL PENJUALAN";
        _totalValue = "Rp ${_formatRibuan(total)}";
      });
    }
  }

  // ── STOCK ────────────────────────────────────

  Future<void> _loadStock() async {
    final rawData = await DatabaseService.instance.getStockLaporan(
      tglAwal: widget.tanggalAwal,
      tglAkhir: widget.tanggalAkhir,
      subKategori: widget.subKategori,
      namaKaryawan: widget.karyawan,
    );

    int totalMasuk = 0;
    int totalKeluar = 0;

    final formatted = rawData.map((row) {
      final jumlah = (row['jumlah'] as num?)?.toInt() ?? 0;
      final tipe = row['tipe']?.toString() ?? "-";
      final hasil = (jumlah / jumlah).toInt();
      if (tipe == 'masuk') totalMasuk += hasil;
      if (tipe == 'keluar') totalKeluar += hasil;

      return [
        row['username']?.toString() ?? "-", // [0] Nama
        row['nama_shift']?.toString() ?? "-", // [1] Shift
        _formatTanggal(row['waktu']?.toString()), // [2] Tanggal
        row['nama_bahan']?.toString() ?? "-", // [3] Bahan
        row['kategori']?.toString() ?? "-", // [4] Kategori Bahan
        "$jumlah ${row['satuan']?.toString() ?? ''}", // [5] Jumlah + Satuan
        tipe.toUpperCase(), // [6] Tipe
        row['keterangan']?.toString() ?? "-", // [7] Keterangan
      ];
    }).toList();

    if (mounted) {
      setState(() {
        _tableData = formatted;
        _totalLabel = "MASUK / KELUAR";
        _totalValue = "+$totalMasuk / -$totalKeluar";
      });
    }
  }

  // ─────────────────────────────────────────────
  // HELPERS FORMAT
  // ─────────────────────────────────────────────

  int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    return int.tryParse(val.toString()) ?? 0;
  }

  String _formatTanggal(String? raw) {
    if (raw == null || raw.isEmpty) return "-";
    try {
      final datePart = raw.split(RegExp(r'[ T]'))[0];
      final parts = datePart.split('-');
      if (parts.length != 3) return raw;
      return "${parts[2]}/${parts[1]}/${parts[0]}";
    } catch (_) {
      return raw;
    }
  }

  String _formatRibuan(int angka) {
    return angka.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
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

  String _ambilJam(String? raw) {
    if (raw == null || raw.isEmpty || raw == "null") return "--:--";
    try {
      final dt = DateTime.parse(raw);
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (_) {
      return "--:--";
    }
  }

  // ─────────────────────────────────────────────
  // WARNA BADGE
  // ─────────────────────────────────────────────

  Color _badgeColorJadwal(String teks) {
    if (teks.contains('BOOKING')) return Colors.orange;
    if (teks.contains('WALK IN')) return const Color(0xFF00E0C6);
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

  Color _tipeStockColor(String tipe) {
    if (tipe == 'MASUK') return Colors.greenAccent;
    if (tipe == 'KELUAR') return Colors.redAccent;
    return Colors.white54;
  }

  Color _kategoriTransaksiColor(String kategori) {
    if (kategori == 'Makanan') return Colors.orangeAccent;
    if (kategori == 'Minuman') return const Color(0xFF00E0C6);
    return Colors.white54;
  }

  // ─────────────────────────────────────────────
  // KOLOM HEADER — berbeda tiap kategori
  // ─────────────────────────────────────────────

  List<DataColumn> _buildColumns() {
    const style = TextStyle(color: Colors.white70, fontWeight: FontWeight.bold);
    switch (widget.kategori) {
      case "Jadwal":
        return const [
          DataColumn(label: Text('NAMA', style: style)),
          DataColumn(label: Text('SHIFT', style: style)),
          DataColumn(label: Text('TANGGAL', style: style)),
          DataColumn(label: Text('DETAIL', style: style)),
          DataColumn(label: Text('JAM', style: style)),
          DataColumn(label: Text('DURASI', style: style)),
          DataColumn(label: Text('HARGA', style: style)),
          DataColumn(label: Text('STATUS', style: style)),
        ];
      case "Transaksi":
        return const [
          DataColumn(label: Text('OPERATOR', style: style)),
          DataColumn(label: Text('SHIFT', style: style)),
          DataColumn(label: Text('TANGGAL', style: style)),
          DataColumn(label: Text('PRODUK', style: style)),
          DataColumn(label: Text('KATEGORI', style: style)),
          DataColumn(label: Text('QTY', style: style)),
          DataColumn(label: Text('HARGA SATUAN', style: style)),
          DataColumn(label: Text('TOTAL', style: style)),
        ];
      case "Stock":
        return const [
          DataColumn(label: Text('NAMA', style: style)),
          DataColumn(label: Text('SHIFT', style: style)),
          DataColumn(label: Text('TANGGAL', style: style)),
          DataColumn(label: Text('BAHAN', style: style)),
          DataColumn(label: Text('KATEGORI', style: style)),
          DataColumn(label: Text('JUMLAH', style: style)),
          DataColumn(label: Text('TIPE', style: style)),
          DataColumn(label: Text('KETERANGAN', style: style)),
        ];
      default:
        return [];
    }
  }

  // ─────────────────────────────────────────────
  // BARIS DATA — render berbeda tiap kategori
  // ─────────────────────────────────────────────

  List<DataRow> _buildRows() {
    switch (widget.kategori) {
      case "Jadwal":
        return _rowsJadwal();
      case "Transaksi":
        return _rowsTransaksi();
      case "Stock":
        return _rowsStock();
      default:
        return [];
    }
  }

  List<DataRow> _rowsJadwal() {
    return _tableData.map((item) {
      final detailParts = item[3].split(' | ');
      final namaUnit = detailParts[0];
      final statusJadwal = detailParts.length > 1 ? detailParts[1] : '-';

      return DataRow(
        cells: [
          DataCell(Text(item[0], style: const TextStyle(color: Colors.white))),
          DataCell(
            Text(item[1], style: const TextStyle(color: Colors.white70)),
          ),
          DataCell(
            Text(item[2], style: const TextStyle(color: Colors.white70)),
          ),
          DataCell(
            Row(
              children: [
                Text(namaUnit, style: const TextStyle(color: Colors.white)),
                const SizedBox(width: 6),
                _buildBadge(statusJadwal, _badgeColorJadwal(statusJadwal)),
              ],
            ),
          ),
          DataCell(
            Text(
              item[4],
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
            ),
          ),
          DataCell(
            Text(item[5], style: const TextStyle(color: Color(0xFF00E0C6))),
          ),
          DataCell(
            Text(item[6], style: const TextStyle(color: Colors.greenAccent)),
          ),
          DataCell(_buildBadge(item[7], _statusCompletedColor(item[7]))),
        ],
      );
    }).toList();
  }

  List<DataRow> _rowsTransaksi() {
    return _tableData.map((item) {
      return DataRow(
        cells: [
          DataCell(Text(item[0], style: const TextStyle(color: Colors.white))),
          DataCell(
            Text(item[1], style: const TextStyle(color: Colors.white70)),
          ),
          DataCell(
            Text(item[2], style: const TextStyle(color: Colors.white70)),
          ),
          DataCell(Text(item[3], style: const TextStyle(color: Colors.white))),
          DataCell(_buildBadge(item[4], _kategoriTransaksiColor(item[4]))),
          DataCell(
            Text(
              item[5],
              style: const TextStyle(
                color: Color(0xFF00E0C6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataCell(
            Text(item[6], style: const TextStyle(color: Colors.white70)),
          ),
          DataCell(
            Text(item[7], style: const TextStyle(color: Colors.greenAccent)),
          ),
        ],
      );
    }).toList();
  }

  List<DataRow> _rowsStock() {
    return _tableData.map((item) {
      return DataRow(
        cells: [
          DataCell(Text(item[0], style: const TextStyle(color: Colors.white))),
          DataCell(
            Text(item[1], style: const TextStyle(color: Colors.white70)),
          ),
          DataCell(
            Text(item[2], style: const TextStyle(color: Colors.white70)),
          ),
          DataCell(Text(item[3], style: const TextStyle(color: Colors.white))),
          DataCell(
            Text(item[4], style: const TextStyle(color: Colors.white54)),
          ),
          DataCell(
            Text(
              item[5],
              style: const TextStyle(
                color: Color(0xFF00E0C6),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DataCell(_buildBadge(item[6], _tipeStockColor(item[6]))),
          DataCell(
            Text(
              item[7],
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
        ],
      );
    }).toList();
  }

  // ─────────────────────────────────────────────
  // WIDGET PEMBANTU
  // ─────────────────────────────────────────────

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.inbox_outlined, color: Colors.white24, size: 48),
            const SizedBox(height: 12),
            const Text(
              "Tidak ada data untuk filter ini",
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFF00E0C6)),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(20, 28, 47, 1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(0, 224, 198, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "LAPORAN ${widget.kategori.toUpperCase()}",
                  style: const TextStyle(
                    color: Color(0xFF00E0C6),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    // Tombol Export Excel
                    OutlinedButton.icon(
                      onPressed: _tableData.isEmpty
                          ? null
                          : () async {
                              try {
                                await ExcelHelper.saveAndShareExcel(
                                  kategori: widget.kategori,
                                  tableData: _tableData,
                                  total: _totalValue,
                                  tanggalAwal: widget.tanggalAwal,
                                  tanggalAkhir: widget.tanggalAkhir,
                                );
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal export Excel: $e'),
                                    ),
                                  );
                                }
                              }
                            },
                      icon: const Icon(Icons.table_chart_outlined, size: 16),
                      label: const Text("EXCEL"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.greenAccent,
                        side: const BorderSide(
                          color: Colors.greenAccent,
                          width: 0.8,
                        ),
                        disabledForegroundColor: Colors.white24,
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Tombol Export PDF (existing)
                    OutlinedButton.icon(
                      onPressed: _tableData.isEmpty
                          ? null
                          : () => PdfHelper.saveAndOpenPdf(
                              kategori: widget.kategori,
                              tableData: _tableData,
                              total: _totalValue,
                            ),
                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                      label: const Text("PDF"),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: const BorderSide(
                          color: Colors.redAccent,
                          width: 0.8,
                        ),
                        disabledForegroundColor: Colors.white24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Divider(color: Colors.white10, height: 30),
          ),

          // ── Tabel atau Empty State ───────────
          if (_tableData.isEmpty)
            _buildEmptyState()
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(
                  Colors.white.withOpacity(0.04),
                ),
                dataRowColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.white.withOpacity(0.08);
                  }
                  return Colors.transparent;
                }),
                dividerThickness: 0.3,
                columns: _buildColumns(),
                rows: _buildRows(),
              ),
            ),

          // ── Footer Total ─────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(24, 8, 24, 20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _totalLabel,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _totalValue,
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
