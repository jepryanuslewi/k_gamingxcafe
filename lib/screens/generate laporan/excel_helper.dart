import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelHelper {
  static Future<void> saveAndShareExcel({
    required String kategori,
    required List<List<String>> tableData,
    required String total,
    DateTime? tanggalAwal,
    DateTime? tanggalAkhir,
  }) async {
    try {
      final excel = Excel.createExcel();
      excel.delete('Sheet1');

      final Sheet sheet = excel['Laporan $kategori'];

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

      final dir = await getTemporaryDirectory();
      final tanggalStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final filePath = '${dir.path}/Laporan_${kategori}_$tanggalStr.xlsx';

      final fileBytes = excel.save();
      if (fileBytes == null) throw Exception('Gagal generate Excel');

      await File(filePath).writeAsBytes(fileBytes, flush: true);

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'Laporan $kategori - Gaming X Cafe',
        text:
            'Laporan $kategori periode ${_formatPeriode(tanggalAwal, tanggalAkhir)}',
      );
    } catch (e) {
      debugPrint('ExcelHelper Error: $e');
      rethrow;
    }
  }

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
    // ── Baris 1: Judul ──────────────────────────
    final titleCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
    );
    titleCell.value = TextCellValue(
      'GAMING X CAFE - LAPORAN ${kategori.toUpperCase()}',
    );
    titleCell.cellStyle = CellStyle(bold: true, fontSize: 13);
    // ── Baris 2: Periode ────────────────────────
    final periodeCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1),
    );
    periodeCell.value = TextCellValue(
      'Periode: ${_formatPeriode(tanggalAwal, tanggalAkhir)}',
    );

    // ── Baris 3: Tanggal cetak ──────────────────
    final cetakCell = sheet.cell(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 2),
    );
    cetakCell.value = TextCellValue(
      'Dicetak: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
    );

    // ── Baris 5 (index 4): Header kolom ─────────
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 4),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = CellStyle(
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );
    }

    // ── Baris data (mulai index 5) ───────────────
    for (int rowIdx = 0; rowIdx < tableData.length; rowIdx++) {
      final row = tableData[rowIdx];
      for (int colIdx = 0; colIdx < row.length; colIdx++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: colIdx, rowIndex: rowIdx + 5),
        );
        cell.value = TextCellValue(row[colIdx]);
      }
    }

    // ── Baris total ──────────────────────────────
    final totalRowIdx = tableData.length + 6;

    final labelCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: headers.length - 2,
        rowIndex: totalRowIdx,
      ),
    );
    labelCell.value = TextCellValue(totalLabel);
    labelCell.cellStyle = CellStyle(bold: true);

    final valueCell = sheet.cell(
      CellIndex.indexByColumnRow(
        columnIndex: headers.length - 1,
        rowIndex: totalRowIdx,
      ),
    );
    valueCell.value = TextCellValue(totalValue);
    valueCell.cellStyle = CellStyle(bold: true);

    // ── Lebar kolom ──────────────────────────────
    sheet.setColumnWidth(0, 18.0);
    sheet.setColumnWidth(1, 18.0);
    sheet.setColumnWidth(2, 14.0);
    sheet.setColumnWidth(3, 24.0);
    sheet.setColumnWidth(4, 14.0);
    sheet.setColumnWidth(5, 10.0);
    sheet.setColumnWidth(6, 16.0);
    sheet.setColumnWidth(7, 20.0);
  }

  static String _formatPeriode(DateTime? awal, DateTime? akhir) {
    if (awal == null || akhir == null) return '-';
    final fmt = DateFormat('dd/MM/yyyy');
    return '${fmt.format(awal)} s/d ${fmt.format(akhir)}';
  }
}
