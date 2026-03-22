import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class PdfHelper {
  static Future<void> saveAndOpenPdf({
    required String kategori,
    required List<List<String>> tableData,
    required String total, // Tambahkan parameter total
  }) async {
    try {
      final pdf = pw.Document();

      // Load font dari assets agar mendukung Unicode/Karakter khusus
      final fontData = await rootBundle.load(
        "assets/fonts/Poppins-Regular.ttf",
      );
      final poppins = pw.Font.ttf(fontData);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          theme: pw.ThemeData.withFont(base: poppins),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header Laporan
                pw.Text(
                  "LAPORAN ${kategori.toUpperCase()}",
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text("K Gaming X Cafe - Laporan Operasional"),
                pw.Divider(thickness: 1, color: PdfColors.grey),
                pw.SizedBox(height: 20),

                // Tabel Data
                pw.TableHelper.fromTextArray(
                  headers: [
                    'NAMA',
                    'SHIFT',
                    'TANGGAL',
                    'DETAIL',
                    'JAM',
                    'HARGA',
                  ],
                  data: tableData,
                  headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                  headerDecoration: const pw.BoxDecoration(
                    color: PdfColors.blueGrey900,
                  ),
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  cellHeight: 25,
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3), // Nama
                    1: const pw.FlexColumnWidth(2), // Shift
                    2: const pw.FlexColumnWidth(2), // Tanggal
                    3: const pw.FlexColumnWidth(3), // Detail
                    4: const pw.FlexColumnWidth(1), // Jam
                    5: const pw.FlexColumnWidth(2), // Harga
                  },
                  cellAlignments: {
                    0: pw.Alignment.centerLeft,
                    1: pw.Alignment.centerLeft,
                    2: pw.Alignment.centerLeft,
                    3: pw.Alignment.centerLeft,
                    4: pw.Alignment.center,
                    5: pw.Alignment.centerRight,
                  },
                ),

                // Bagian Total Pendapatan
                pw.SizedBox(height: 15),
                pw.Container(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Divider(thickness: 1, color: PdfColors.black),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.end,
                        children: [
                          pw.Text(
                            "TOTAL PENDAPATAN:  ",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.Text(
                            "Rp $total",
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green900,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Proses Simpan File
      final output = await getApplicationDocumentsDirectory();
      final safeKategori = kategori.replaceAll(' ', '_');
      final file = File("${output.path}/Laporan_$safeKategori.pdf");
      await file.writeAsBytes(await pdf.save());

      // Mencoba membuka file secara otomatis
      final result = await OpenFilex.open(file.path);

      // Fallback: Jika tidak ada aplikasi pembuka PDF, tampilkan menu Share
      if (result.type == ResultType.noAppToOpen) {
        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Laporan $kategori Gaming X Cafe');
      }
    } catch (e) {
      print("Error PDF: $e");
    }
  }
}
