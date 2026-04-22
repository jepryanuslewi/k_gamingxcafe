import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelHelper {
  // ─────────────────────────────────────────────────────────────
  // ENTRY POINT — dipanggil dari TabelLaporanWidget
  // ─────────────────────────────────────────────────────────────

  static Future<void> saveAndShareExcel({
    required String kategori,
    required List<List<String>> tableData,
    required String total,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
  }) async {
    try {
      final excel = Excel.createExcel();

      // Hapus sheet default yang kosong
      excel.delete('Sheet1');

      // Buat sheet sesuai kategori
      final sheetName = 'Laporan ${_capitalize(kategori)}';
      final Sheet sheet = excel[sheetName];

      // Tulis isi sheet sesuai kategori
      switch (kategori) {
        case 'Jadwal':
          _writeSheet(
            sheet: sheet,
            kategori: kategori,
            headers: [
              'NAMA',
              'SHIFT',
              'TANGGAL',
              'DETAIL',
              'JAM',
              'DURASI',
              'HARGA',
              'STATUS',
            ],
            tableData: tableData,
            totalLabel: 'TOTAL PENDAPATAN',
            totalValue: total,
            tanggalAwal: tanggalAwal,
            tanggalAkhir: tanggalAkhir,
          );
          break;
        case 'Transaksi':
          _writeSheet(
            sheet: sheet,
            kategori: kategori,
            headers: [
              'OPERATOR',
              'SHIFT',
              'TANGGAL',
              'PRODUK',
              'KATEGORI',
              'QTY',
              'HARGA SATUAN',
              'TOTAL',
            ],
            tableData: tableData,
            totalLabel: 'TOTAL PENJUALAN',
            totalValue: total,
            tanggalAwal: tanggalAwal,
            tanggalAkhir: tanggalAkhir,
          );
          break;
        case 'Stock':
          _writeSheet(
            sheet: sheet,
            kategori: kategori,
            headers: [
              'NAMA',
              'SHIFT',
              'TANGGAL',
              'BAHAN',
              'KATEGORI',
              'JUMLAH',
              'TIPE',
              'KETERANGAN',
            ],
            tableData: tableData,
            totalLabel: 'MASUK / KELUAR',
            totalValue: total,
            tanggalAwal: tanggalAwal,
            tanggalAkhir: tanggalAkhir,
          );
          break;
      }

      // Simpan file ke direktori sementara
      final dir = await getTemporaryDirectory();
      final tanggalStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final filePath = '${dir.path}/Laporan_${kategori}_$tanggalStr.xlsx';

      final fileBytes = excel.save();
      if (fileBytes == null) throw Exception('Gagal generate Excel');

      final file = File(filePath);
      await file.writeAsBytes(fileBytes, flush: true);

      // Share file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Laporan $kategori - Gaming X Cafe',
        text:
            'Laporan $kategori periode ${_formatPeriode(tanggalAwal, tanggalAkhir)}',
      );
    } catch (e) {
      debugPrint('ExcelHelper Error: $e');
      rethrow; // Biar bisa ditangkap di UI untuk snackbar
    }
  }

  // ─────────────────────────────────────────────────────────────
  // TULIS ISI SHEET
  // ─────────────────────────────────────────────────────────────

  static void _writeSheet({
    required Sheet sheet,
    required String kategori,
    required List<String> headers,
    required List<List<String>> tableData,
    required String totalLabel,
    required String totalValue,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
  }) {
    // ── Baris 1: Judul ──────────────────────────
    final titleCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    );
    titleCell.value = TextCellValue(
      'GAMING X CAFE — LAPORAN ${kategori.toUpperCase()}',
    );
    titleCell.cellStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.fromHexString('#00E0C6'),
    );

    // ── Baris 2: Periode ─────────────────────────
    final periodeCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
    );
    periodeCell.value = TextCellValue(
      'Periode: ${_formatPeriode(tanggalAwal, tanggalAkhir)}',
    );
    periodeCell.cellStyle = CellStyle(
      italic: true,
      fontColorHex: ExcelColor.fromHexString('#888888'),
    );

    // ── Baris 3: Tanggal cetak ────────────────────
    final cetakCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2),
    );
    cetakCell.value = TextCellValue(
      'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
    );
    cetakCell.cellStyle = CellStyle(
      italic: true,
      fontColorHex: ExcelColor.fromHexString('#888888'),
    );

    // ── Baris 5 (index 4): Header kolom ──────────
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#0B1220'),
        fontColorHex: ExcelColor.fromHexString('#00E0C6'),
        horizontalAlign: HorizontalAlign.Center,
        textWrapping: TextWrapping.WrapText,
      );
    }

    // ── Baris data (mulai index 5) ────────────────
    for (int rowIdx = 0; rowIdx < tableData.length; rowIdx++) {
      final row = tableData[rowIdx];
      final isGanjil = rowIdx % 2 == 0;

      for (int colIdx = 0; colIdx < row.length; colIdx++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: rowIdx + 5),
        );
        cell.value = TextCellValue(row[colIdx]);
        cell.cellStyle = CellStyle(
          backgroundColorHex: isGanjil
              ? ExcelColor.fromHexString('#141C2F')
              : ExcelColor.fromHexString('#0F1626'),
          fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
        );
      }
    }

    // ── Baris total (setelah data + 1 baris kosong) ──
    final totalRowIdx = tableData.length + 6;

    final labelCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: headers.length - 2,
        rowIndex: totalRowIdx,
      ),
    );
    labelCell.value = TextCellValue(totalLabel);
    labelCell.cellStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      backgroundColorHex: ExcelColor.fromHexString('#141C2F'),
    );

    final valueCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: headers.length - 1,
        rowIndex: totalRowIdx,
      ),
    );
    valueCell.value = TextCellValue(totalValue);
    valueCell.cellStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.fromHexString('#00FF7F'), // greenAccent
      backgroundColorHex: ExcelColor.fromHexString('#141C2F'),
    );

    // ── Atur lebar kolom ──────────────────────────
    final colWidths = {
      0: 18.0, // Nama/Operator
      1: 18.0, // Shift
      2: 14.0, // Tanggal
      3: 24.0, // Detail/Produk/Bahan
      4: 14.0, // Kategori/Jam
      5: 10.0, // Durasi/Qty/Jumlah
      6: 16.0, // Harga/Harga Satuan/Tipe
      7: 20.0, // Status/Total/Keterangan
    };

    colWidths.forEach((col, width) {
      sheet.setColumnWidth(col, width);
    });
  }

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  static String _formatPeriode(DateTime? awal, DateTime? akhir) {
    if (awal == null || akhir == null) return '-';
    final fmt = DateFormat('dd/MM/yyyy');
    return '${fmt.format(awal)} s/d ${fmt.format(akhir)}';
  }
}
