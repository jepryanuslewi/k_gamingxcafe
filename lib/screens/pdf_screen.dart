import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart'; // Tambahkan intl di pubspec.yaml jika belum ada
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

class PdfHelper {
  static Future<void> saveAndOpenPdf({
    required String kategori,
    required List<List<String>> tableData,
    required String total,
  }) async {
    try {
      final pdf = pw.Document();

      // Load font
      final fontData = await rootBundle.load(
        "assets/fonts/Poppins-Regular.ttf",
      );
      final poppins = pw.Font.ttf(fontData);

      // Ambil waktu saat ini untuk tanggal generate
      String tanggalCetak = DateFormat(
        'dd MMMM yyyy, HH:mm',
      ).format(DateTime.now());

      pdf.addPage(
        pw.MultiPage(
          // Menggunakan MultiPage agar jika data banyak otomatis pindah halaman
          pageFormat: PdfPageFormat.a4.copyWith(
            marginBottom: 1 * PdfPageFormat.cm,
            marginTop: 1 * PdfPageFormat.cm,
            marginLeft: 1 * PdfPageFormat.cm,
            marginRight: 1 * PdfPageFormat.cm,
          ),
          theme: pw.ThemeData.withFont(base: poppins),
          header: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          "LAPORAN ${kategori.toUpperCase()}",
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blueGrey900,
                          ),
                        ),
                        pw.Text(
                          "K Gaming X Cafe",
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          "Dicetak pada:",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                        pw.Text(
                          tanggalCetak,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: PdfColors.grey700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Divider(thickness: 1, color: PdfColors.grey300),
                pw.SizedBox(height: 10),
              ],
            );
          },
          build: (pw.Context context) {
            return [
              pw.TableHelper.fromTextArray(
                headers: [
                  'NAMA',
                  'SHIFT',
                  'TANGGAL',
                  'DETAIL',
                  'WAKTU', // Kolom 4
                  'DUR', // Kolom 5 (Durasi)
                  'HARGA', // Kolom 6
                ],
                // Kita ambil index 0,1,2,3,4,5,6 saja (Status index 7 diabaikan di PDF agar tidak terlalu sempit)
                data: tableData
                    .map(
                      (row) => [
                        row[0],
                        row[1],
                        row[2],
                        row[3].split(' | ')[0],
                        row[4],
                        row[5],
                        "Rp ${row[6]}",
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                  fontSize: 9,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blueGrey900,
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                cellHeight: 20,
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5), // Nama
                  1: const pw.FlexColumnWidth(1.5), // Shift
                  2: const pw.FlexColumnWidth(2), // Tanggal
                  3: const pw.FlexColumnWidth(3), // Detail
                  4: const pw.FlexColumnWidth(2.5), // Waktu (15:00 - 16:00)
                  5: const pw.FlexColumnWidth(1), // Durasi
                  6: const pw.FlexColumnWidth(2), // Harga
                },
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerLeft,
                  4: pw.Alignment.center,
                  5: pw.Alignment.center,
                  6: pw.Alignment.centerRight,
                },
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      "TOTAL PENDAPATAN:  ",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
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
              ),
            ];
          },
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
              ),
            );
          },
        ),
      );

      // Simpan File
      final output =
          await getExternalStorageDirectory(); // Lebih aman untuk Android agar gampang dicari
      final directory = output ?? await getApplicationDocumentsDirectory();
      final fileName =
          "Laporan_${kategori}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${directory.path}/$fileName");

      await file.writeAsBytes(await pdf.save());

      final result = await OpenFilex.open(file.path);

      if (result.type == ResultType.noAppToOpen) {
        await Share.shareXFiles([XFile(file.path)], text: 'Laporan $kategori');
      }
    } catch (e) {
      print("Error PDF: $e");
    }
  }
}
