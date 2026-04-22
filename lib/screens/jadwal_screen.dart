import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/gaming/ps_unit_model.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/shift_provider.dart';
import 'package:provider/provider.dart';
import 'package:k_gamingxcafe/providers/gaming/jadwal_provider.dart';
import 'package:k_gamingxcafe/models/gaming/jadwal_model.dart';
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
                child: Consumer<JadwalProvider>(
                  builder: (context, provider, child) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(20, 28, 47, 1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'JADWAL $currentView', // ✅ ikut rebuild
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
                                      provider.loadJadwalByView("WALK IN");
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  ButtonWidget(
                                    text: "BOOKING",
                                    onPressed: () {
                                      setState(() => currentView = "BOOKING");
                                      provider.loadJadwalByView("BOOKING");
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  ButtonWidget(
                                    text: "Kembali",
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  SizedBox(width: 10),
                                  ButtonWidget(
                                    text: "Pesan",
                                    onPressed: () => _showAddDialog(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(child: _buildJadwalList(provider)),
                        ],
                      ),
                    );
                  },
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
                await context.read<JadwalProvider>().deleteJadwal(
                  item.id!,
                  item.unitId,
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  context.read<JadwalProvider>().loadJadwalByView(currentView);
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

  void _showConfirmSelesai(BuildContext context, JadwalModel item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF141C2F),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF00E0C6), width: 1),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Color(0xFF00E0C6)),
              SizedBox(width: 10),
              Text(
                "SELESAIKAN JADWAL?",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            "Apakah jadwal untuk ${item.customerName ?? 'Guest'} sudah selesai?\n\nStatus unit PS akan dikembalikan menjadi IDLE.",
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
                backgroundColor: const Color(0xFF00E0C6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final provider = context.read<JadwalProvider>();
                await provider.completeJadwal(
                  item.id!,
                  item.unitId,
                ); // ✅ bukan deleteJadwal
                if (context.mounted) {
                  Navigator.pop(context);
                  provider.loadJadwalByView(currentView);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Jadwal berhasil diselesaikan"),
                    ),
                  );
                }
              },
              child: const Text(
                "SELESAI",
                style: TextStyle(
                  color: Color(0xFF0B1220),
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
    await Future.wait([provider.loadAllUnits(), provider.loadAllPackages()]);

    if (!mounted) return;

    final result = await showDialog(
      context: context,
      builder: (context) => AddScheduleDialog(
        allUnits: provider.allUnits,
        availablePackages: provider.allPackages,
      ),
    );

    if (result != null) {
      final newJadwal = JadwalModel(
        unitId: result['unit_id'],
        shiftId: shiftId,
        customerName: result['customer_name'],
        customerPhone: result['customer_phone'],
        category: result['category'],
        packageName: result['package_name'],
        createdAt: result['created_at'],
        startTime: result['start_time'],
        durationHours: result['duration'],
        endTime: DateTime.parse(
          result['start_time'],
        ).add(Duration(hours: result['duration'])).toIso8601String(),
        totalPrice: result['total_price'],
        status:
            result['status'], // ✅ pakai dari pilihan user ('walkin'/'booking')
      );

      await provider.addJadwal(newJadwal);

      // ✅ Pindah tab sesuai status yang dipilih user
      setState(
        () =>
            currentView = result['status'] == 'walkin' ? "WALK IN" : "BOOKING",
      );
      provider.loadJadwalByView(currentView);
    }
  }

  Widget _buildJadwalList(JadwalProvider provider) {
    final data = provider.filteredJadwal;

    if (data.isEmpty) {
      return const Center(
        child: Text(
          "Tidak ada jadwal",
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    String formatDate(String isoString) {
      if (isoString.contains('T') || isoString.contains('-')) {
        DateTime dt = DateTime.parse(isoString);
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
      return "-";
    }

    String formatTime(String isoString) {
      if (isoString.contains('T') || isoString.contains('-')) {
        DateTime dt = DateTime.parse(isoString);
        return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
      }
      return isoString;
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
            pricePerHour: 0,
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
                  } else if (value == 'done') {
                    // ✅ tambah ini
                    _showConfirmSelesai(context, item);
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

              // INFORMASI DATA
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
                        const SizedBox(width: 8),

                        // ✅ Badge WALK IN / BOOKING
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.status == 'booking'
                                ? Colors.orange.withOpacity(0.2)
                                : const Color(0xFF00E0C6).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: item.status == 'booking'
                                  ? Colors.orange
                                  : const Color(0xFF00E0C6),
                              width: 0.5,
                            ),
                          ),
                          child: Text(
                            item.status == 'booking' ? 'BOOKING' : 'WALK IN',
                            style: TextStyle(
                              color: item.status == 'booking'
                                  ? Colors.orange
                                  : const Color(0xFF00E0C6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // ✅ Badge nomor telepon (jika ada)
                        if (item.customerPhone != null &&
                            item.customerPhone!.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.customerPhone!,
                              style: const TextStyle(
                                color: Colors.white54,
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
              // WAKTU
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
                    item.packageName ?? 'Unit: ${unit.name}',
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
  }

  Widget _buildHeader(BuildContext context) {
    final String username =
        context.read<AuthProvider>().user?.username ?? "Pegawai";
    return // ── HEADER ────────────────────────────────────────────
    Container(
      color: Colors.transparent,
      width: double.infinity,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset("assets/images/bgLoginScreen.png"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: const [
                      Text(
                        "GAMING",
                        style: TextStyle(
                          color: Color.fromRGBO(226, 19, 136, 100),
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "X",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.normal,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "CAFE",
                        style: TextStyle(
                          color: Color.fromRGBO(0, 224, 198, 100),
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    "Booking & Transaction App",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromRGBO(11, 18, 32, 100),
            ),
            onPressed: () {},
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.shiftName,
                      style: const TextStyle(color: Color(0xFF00E0C6)),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.person_pin,
                  size: 50,
                  color: Color(0xFF00E0C6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
