import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/pendapatan_provider.dart';
import 'package:k_gamingxcafe/providers/shift_provider.dart';
import 'package:k_gamingxcafe/screens/edit_profile_screen.dart';
import 'package:k_gamingxcafe/screens/jadwal_screen.dart';
import 'package:k_gamingxcafe/screens/laporan/laporan_pegawai_screen.dart';
import 'package:k_gamingxcafe/screens/login_screen.dart';
import 'package:k_gamingxcafe/screens/stock/stock_screen.dart';
import 'package:k_gamingxcafe/screens/transaksi/transaksi_screen.dart';
import 'package:k_gamingxcafe/widgets/card_button.dart';
import 'package:k_gamingxcafe/widgets/card_pendapatan.dart';
import 'package:k_gamingxcafe/widgets/dialog/dialog_singout.dart';
import 'package:intl/intl.dart';
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
    Future.microtask(() => context.read<PendapatanProvider>().fetchSemua());
  }

  @override
  Widget build(BuildContext context) {
    final tanggal = DateTime.now();
    final authprovider = context.watch<AuthProvider>();
    final String username = authprovider.user?.username ?? "";
    final pendapatanProv = context.watch<PendapatanProvider>();
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;

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
        backgroundColor: Color.fromARGB(100, 19, 15, 51),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
            child: Column(
              children: [
                // ── HEADER ─────────────────────────────────────
                SizedBox(
                  height: 80,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/images/bgLoginScreen.png",
                            height: 60,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "GAMING",
                                    style: TextStyle(
                                      color: const Color.fromRGBO(226, 19, 136, 100),
                                      fontSize: isTablet ? 28 : 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "X",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 28 : 22,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "CAFE",
                                    style: TextStyle(
                                      color: const Color.fromRGBO(0, 224, 198, 100),
                                      fontSize: isTablet ? 28 : 22,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "Booking & Transaction App",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isTablet ? 16 : 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Profile Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromRGBO(11, 18, 32, 100),
                          elevation: 0,
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
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: isTablet ? 18 : 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  widget.shiftName,
                                  style: TextStyle(
                                    color: const Color(0xFF00E0C6),
                                    fontSize: isTablet ? 13 : 11,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.person_pin,
                              size: isTablet ? 50 : 40,
                              color: const Color(0xFF00E0C6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // ── MAIN CARD ───────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(100, 20, 28, 47),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color.fromRGBO(0, 224, 198, 100),
                    ),
                  ),
                  padding: EdgeInsets.only(
                    left: isTablet ? 30 : 20,
                    right: isTablet ? 30 : 20,
                    top: isTablet ? 30 : 20,
                    bottom: isTablet ? 30 : 20,
                  ),
                  width: double.infinity,
                  child: Column(
                    children: [
                      // Tanggal & Sapaan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Semangat, $username',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 20 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 20 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Card Pendapatan ─────────────────────
                      isTablet
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: CardPendapatan(
                                    text: 'Gaming Hari Ini',
                                    total: pendapatanProv.totalGaming,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CardPendapatan(
                                    text: 'Cafe Hari Ini',
                                    total: pendapatanProv.totalCafe,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CardPendapatan(
                                    text: 'Gaming x Cafe',
                                    total: pendapatanProv.totalGabungan,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                CardPendapatan(
                                  text: 'Gaming Hari Ini',
                                  total: pendapatanProv.totalGaming,
                                ),
                                const SizedBox(height: 8),
                                CardPendapatan(
                                  text: 'Cafe Hari Ini',
                                  total: pendapatanProv.totalCafe,
                                ),
                                const SizedBox(height: 8),
                                CardPendapatan(
                                  text: 'Gaming x Cafe',
                                  total: pendapatanProv.totalGabungan,
                                ),
                              ],
                            ),

                      const SizedBox(height: 20),

                      // ── Menu Buttons ────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: CardButton(
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
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: CardButton(
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
                                if (context.mounted) {
                                  context
                                      .read<PendapatanProvider>()
                                      .fetchSemua();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: CardButton(
                              text: "STOCK",
                              icon: Icons.inventory_2_outlined,
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
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: CardButton(
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
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // ── SIGN OUT ────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.09,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor:
                                const Color.fromRGBO(226, 19, 136, 100),
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Gagal logout: $e")));
      }
    }
  }
}