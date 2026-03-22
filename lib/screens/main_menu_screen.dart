import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/shift_provider.dart';
import 'package:k_gamingxcafe/screens/jadwal_screen.dart';
import 'package:k_gamingxcafe/screens/laporan/laporan_screen.dart';
import 'package:k_gamingxcafe/screens/login_screen.dart';
import 'package:k_gamingxcafe/screens/stock/stock_screen.dart';
import 'package:k_gamingxcafe/screens/transaksi_screen.dart';
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
  Widget build(BuildContext context) {
    final tanggal = DateTime.now();
    final authprovider = context.watch<AuthProvider>();
    final String username = authprovider.user?.username ?? "";
    return PopScope(
      canPop: false, // Menghalangi tombol back
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Opsional: Tampilkan SnackBar jika perlu
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(
              child: Text("Gunakan tombol SIGN OUT untuk keluar"),
            ),
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Color.fromRGBO(11, 18, 32, 100),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
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
                                    children: [
                                      const Text(
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
                                      const SizedBox(width: 16),
                                      const Text(
                                        "X",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 35,
                                          fontWeight: FontWeight.normal,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      const Text(
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
                                  Text(
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
                          // Profile===========================================================
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                            ),
                            onPressed: () {},
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      username,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(widget.shiftName),
                                  ],
                                ),
                                Icon(
                                  Icons.person_2_outlined,
                                  size: 70,
                                  color: Color.fromRGBO(0, 224, 198, 100),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),

                    // menu===================================================
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(20, 28, 47, 100),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Color.fromRGBO(0, 224, 198, 100),
                        ),
                      ),
                      padding: EdgeInsets.only(left: 50, right: 50, top: 20),
                      height: 420,
                      width: double.infinity,
                      child: Column(
                        children: [
                          // 1
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              // username
                              Text(
                                'Semangat, $username',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              // tanggal
                              Text(
                                '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          // 2
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              CardPendapatan(
                                text: 'Gaming Hari Ini',
                                total: 1000000,
                              ),
                              CardPendapatan(
                                text: 'Cafe Hari Ini',
                                total: 1000000,
                              ),
                              CardPendapatan(
                                text: 'Gaming x Cafe Hari Ini',
                                total: 1000000,
                              ),
                            ],
                          ),
                          // 3
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 1
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,

                                children: [
                                  // 1
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
                                  // 2
                                  CardButton(
                                    text: "TRANSAKSI",
                                    icon: Icons.payment,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TransaksiScreen(
                                            shiftName: widget.shiftName,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),

                              // 2
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // 1
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
                                  // 2
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
                          SizedBox(height: 10),
                          // 4
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Color.fromRGBO(
                                  226,
                                  19,
                                  136,
                                  100,
                                ),
                              ),
                              onPressed: () {
                                DialogSingout.showLogoutDialog(
                                  context,
                                  onConfirm: () => _processLogout(
                                    context,
                                  ), // Panggil fungsi logout yang sudah Anda buat
                                );
                              },
                              child: Text(
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
    // 1. Ambil instance provider tanpa mendengarkan perubahan (listen: false)
    final shiftProvider = Provider.of<ShiftProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 2. Jalankan fungsi stopShift untuk mengisi end_time di Database
      await shiftProvider.stopShift();

      // 3. Hapus data user dari AuthProvider
      authProvider.logout();

      // 4. Arahkan kembali ke Login dan hapus semua tumpukan halaman (history)
      // Ini penting agar pegawai tidak bisa klik 'Back' setelah logout
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Penanganan error jika database gagal update
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal logout: $e")));
      }
    }
  }
}
