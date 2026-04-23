import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/pendapatan_provider.dart';
import 'package:k_gamingxcafe/providers/shift_provider.dart';
import 'package:k_gamingxcafe/screens/edit_profile_screen.dart';
import 'package:k_gamingxcafe/screens/jadwal_screen.dart';
import 'package:k_gamingxcafe/screens/laporan/laporan_screen.dart';
import 'package:k_gamingxcafe/screens/login_screen.dart';
import 'package:k_gamingxcafe/screens/stock/stock_screen.dart';
import 'package:k_gamingxcafe/screens/transaksi/transaksi_screen.dart';
import 'package:k_gamingxcafe/widgets/card_button.dart';
import 'package:k_gamingxcafe/widgets/card_pendapatan.dart';
import 'package:k_gamingxcafe/widgets/dialog/dialog_singout.dart';
import 'package:provider/provider.dart';

class MainMenuScreen extends StatefulWidget {
  final String shiftName;
  const MainMenuScreen({super.key, required this.shiftName});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data saat layar pertama kali dibuka
    Future.microtask(() => context.read<PendapatanProvider>().fetchSemua());
  }

  @override
  Widget build(BuildContext context) {
    final tanggal = DateTime.now();
    final authprovider = context.watch<AuthProvider>();
    final String username = authprovider.user?.username ?? "";

    // Watch PendapatanProvider agar otomatis rebuild saat data berubah
    final pendapatanProv = context.watch<PendapatanProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text("Gunakan tombol SIGN OUT untuk keluar"),
            ),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(11, 18, 32, 100),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    // ── HEADER ────────────────────────────────────────────
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
                                          color: Color.fromRGBO(
                                            226,
                                            19,
                                            136,
                                            100,
                                          ),
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
                                          color: Color.fromRGBO(
                                            0,
                                            224,
                                            198,
                                            100,
                                          ),
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
                              backgroundColor: const Color.fromRGBO(
                                11,
                                18,
                                32,
                                100,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfileScreen(),
                                ),
                              );
                            },
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
                                      style: const TextStyle(
                                        color: Color(0xFF00E0C6),
                                      ),
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
                    ),

                    const SizedBox(height: 40),

                    // ── MENU CONTAINER ────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(20, 28, 47, 100),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color.fromRGBO(0, 224, 198, 100),
                        ),
                      ),
                      padding: const EdgeInsets.only(
                        left: 50,
                        right: 50,
                        top: 20,
                      ),
                      height: 420,
                      width: double.infinity,
                      child: Column(
                        children: [
                          // Salam & tanggal
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Semangat, $username',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
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
                          const SizedBox(height: 20),

                          // ── CARD PENDAPATAN REALTIME ───────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CardPendapatan(
                                text: 'Gaming Hari Ini',
                                total: pendapatanProv.totalGaming,
                              ),
                              CardPendapatan(
                                text: 'Cafe Hari Ini',
                                total: pendapatanProv.totalCafe,
                              ),
                              CardPendapatan(
                                text: 'Gaming x Cafe Hari Ini',
                                total: pendapatanProv.totalGabungan,
                              ),
                            ],
                          ),

                          // ── TOMBOL MENU ───────────────────────────────
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CardButton(
                                    text: "JADWAL",
                                    icon: Icons.calendar_month,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => JadwalScreen(
                                            shiftName: widget.shiftName,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  CardButton(
                                    text: "TRANSAKSI",
                                    icon: Icons.payment,
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TransaksiScreen(
                                            shiftName: widget.shiftName,
                                          ),
                                        ),
                                      );
                                      // Refresh pendapatan setelah kembali dari transaksi
                                      if (context.mounted) {
                                        context
                                            .read<PendapatanProvider>()
                                            .fetchSemua();
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  CardButton(
                                    text: "STOCK",
                                    icon: Icons.calendar_month,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => StockScreen(
                                            shiftName: widget.shiftName,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  CardButton(
                                    text: "LAPORAN",
                                    icon: Icons.bar_chart_sharp,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LaporanScreen(
                                            shiftName: widget.shiftName,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // ── TOMBOL SIGN OUT ───────────────────────────
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: const Color.fromRGBO(
                                  226,
                                  19,
                                  136,
                                  100,
                                ),
                              ),
                              onPressed: () {
                                DialogSingout.showLogoutDialog(
                                  context,
                                  onConfirm: () => _processLogout(context),
                                );
                              },
                              child: const Text(
                                "SIGN OUT",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _processLogout(BuildContext context) async {
    final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await shiftProvider.stopShift();
      authProvider.logout();

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal logout: $e")));
      }
    }
  }
}
