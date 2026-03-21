import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/ps_unit_model.dart';
import 'package:k_gamingxcafe/providers/shift_provider.dart';
import 'package:provider/provider.dart';
import 'package:k_gamingxcafe/providers/jadwal_provider.dart';
import 'package:k_gamingxcafe/models/jadwal_model.dart';
import 'package:k_gamingxcafe/widgets/gaming/add_schedule_dialog.dart';
import 'package:k_gamingxcafe/widgets/gaming/button_widget.dart';

class JadwalScreen extends StatefulWidget {
  final String shiftName;
  const JadwalScreen({super.key, required this.shiftName});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  String currentView = "WALK IN";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JadwalProvider>().loadJadwalByView(currentView);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tanggal = DateTime.now();

    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 18, 32, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(20, 28, 47, 1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color.fromRGBO(0, 224, 198, 1),
                    ),
                  ),
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'JADWAL $currentView',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.white24, height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ButtonWidget(
                                text: "WALK IN",
                                onPressed: () {
                                  setState(() => currentView = "WALK IN");
                                  context
                                      .read<JadwalProvider>()
                                      .loadJadwalByView("WALK IN");
                                },
                              ),
                              const SizedBox(width: 10),
                              ButtonWidget(
                                text: "BOOKING",
                                onPressed: () {
                                  setState(() => currentView = "BOOKING");
                                  context
                                      .read<JadwalProvider>()
                                      .loadJadwalByView("BOOKING");
                                },
                              ),
                            ],
                          ),
                          ButtonWidget(
                            text: "ADD",
                            onPressed: () => _showAddDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(child: _buildJadwalList()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showConfirmDelete(BuildContext context, JadwalModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141C2F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
              SizedBox(width: 10),
              Text(
                "HAPUS JADWAL?",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            "Apakah Anda yakin ingin menghapus jadwal untuk ${item.customerName ?? 'Guest'}?\n\nStatus unit PS akan dikembalikan menjadi IDLE.",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "BATAL",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                // 1. Panggil fungsi hapus di Provider
                // Pastikan di JadwalProvider Anda sudah ada fungsi deleteJadwal
                await context.read<JadwalProvider>().deleteJadwal(
                  item.id!,
                  item.unitId,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  // 2. Refresh list setelah hapus
                  context.read<JadwalProvider>().loadJadwalByView(currentView);

                  // 3. Beri notifikasi singkat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Jadwal berhasil dihapus")),
                  );
                }
              },
              child: const Text(
                "HAPUS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) async {
    final shiftId = context.read<ShiftProvider>().activeShift?['id'];
    // SAFETY CHECK: Jika shiftId null, hentikan proses
    if (shiftId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Error: Sesi Shift tidak ditemukan. Silahkan login ulang.",
          ),
        ),
      );
      return;
    }

    final provider = context.read<JadwalProvider>();

    // 1. Ambil data Unit DAN Paket dari Database agar data tidak kosong ([])
    await Future.wait([
      provider.loadAllUnits(),
      provider
          .loadAllPackages(), // Pastikan fungsi ini sudah ada di JadwalProvider
    ]);

    if (!mounted) return;

    // 2. Munculkan Dialog dengan mengirimkan data asli dari Provider
    final result = await showDialog(
      context: context,
      builder: (context) => AddScheduleDialog(
        allUnits: provider.allUnits,
        availablePackages:
            provider.allPackages, // PERBAIKAN: Jangan kirim [] lagi
      ),
    );

    // 3. Proses hasil inputan dari Dialog
    if (result != null) {
      final newJadwal = JadwalModel(
        unitId: result['unit_id'],
        shiftId:
            shiftId, // Anda bisa sesuaikan dengan ID shift yang sedang aktif
        customerName: result['customer_name'],
        customerPhone: result['customer_phone'],
        category: result['category'],
        packageName: result['package_name'],
        startTime: result['start_time'],
        durationHours: result['duration'],
        endTime: DateTime.parse(
          result['start_time'],
        ).add(Duration(hours: result['duration'])).toIso8601String(),
        totalPrice: result['total_price'],
        status: 'active',
      );

      // 4. Simpan ke Database melalui Provider
      await provider.addJadwal(newJadwal);

      // 5. Refresh tampilan list jadwal (Walk-In atau Booking)
      provider.loadJadwalByView(currentView);
    }
  }

  Widget _buildJadwalList() {
    return Consumer<JadwalProvider>(
      builder: (context, provider, child) {
        final data = provider.filteredJadwal;
        if (data.isEmpty)
          return const Center(
            child: Text(
              "Tidak ada jadwal",
              style: TextStyle(color: Colors.white54),
            ),
          );

        String formatDate(String isoString) {
          DateTime dt = DateTime.parse(isoString);
          // Daftar bulan singkat
          List<String> months = [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "Mei",
            "Jun",
            "Jul",
            "Agu",
            "Sep",
            "Okt",
            "Nov",
            "Des",
          ];
          return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
        }

        String formatTime(String isoString) {
          DateTime dt = DateTime.parse(isoString);
          return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
        }

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final item = data[index];
            final unit = provider.allUnits.firstWhere(
              (u) => u.id == item.unitId,
              orElse: () => PsUnitModel(
                id: 0,
                name: "Unknown",
                type: "Regular",
                status: "Available",
                pricePerHour:
                    0, // Pastikan di PsUnitModel field-nya bernama pricePerHour
              ),
            );

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  // 1. TOMBOL TITIK TIGA (Popup Menu)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white54),
                    color: const Color(0xFF141C2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white10),
                    ),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showConfirmDelete(context, item);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Hapus Jadwal",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'done',
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF00E0C6),
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Text(
                              "Selesaikan",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 2. INFORMASI DATA
                  // ... di dalam itemBuilder ListView ...
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              item.customerName ?? "Guest",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            // Ganti blok pengecekan kategori dengan ini:
                            if (item.customerPhone != null &&
                                item.customerPhone!.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00E0C6,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  item.customerPhone!,
                                  style: const TextStyle(
                                    color: Color(0xFF00E0C6),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${formatDate(item.startTime)} | ${item.category}",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 3. WAKTU (Sisi Kanan)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "${formatTime(item.startTime)} - ${formatTime(item.endTime)}",
                        style: const TextStyle(
                          color: Color(0xFF00E0C6),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        item.packageName ??
                            'Unit: ${unit.name}', // Menampilkan "PS5 01" bukan "1"
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 80,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset("assets/images/bgLoginScreen.png", height: 50),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "GAMING X CAFE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.shiftName,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
