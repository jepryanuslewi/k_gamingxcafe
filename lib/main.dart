import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/cafe/bahan_provider.dart';
import 'package:k_gamingxcafe/providers/cafe/menu_provider.dart';
import 'package:k_gamingxcafe/providers/gaming/jadwal_provider.dart';
import 'package:k_gamingxcafe/providers/pendapatan_provider.dart';
import 'package:k_gamingxcafe/providers/shift_provider.dart';
import 'package:k_gamingxcafe/screens/dashboard/dashboard_screen.dart';
import 'package:k_gamingxcafe/screens/login_screen.dart';
import 'package:k_gamingxcafe/screens/main_menu_screen.dart';
import 'package:k_gamingxcafe/screens/shift_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Instance Tunggal
  final authProvider = AuthProvider();
  final shiftProvider = ShiftProvider();

  // 2. Muat data dari SharedPreferences
  await authProvider.checkLoginStatus();
  await shiftProvider.loadActiveShift();

  runApp(
    MultiProvider(
      providers: [
        // Gunakan .value untuk provider yang sudah di-load datanya di atas
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: shiftProvider),

        // Untuk provider lainnya, tetap gunakan create biasa
        ChangeNotifierProvider(create: (_) => JadwalProvider()),
        ChangeNotifierProvider(create: (_) => BahanProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),

        // pendapatan
        // Tambahkan PendapatanProvider di MultiProvider
        ChangeNotifierProvider(
          create: (_) => PendapatanProvider()..startRealtime(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Gunakan watch agar widget rebuild saat status login/shift berubah
    final auth = context.watch<AuthProvider>();
    final shift = context.watch<ShiftProvider>();

    if (auth.user == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),
      );
    }

    // Periksa apakah admin (Admin biasanya tidak butuh pilih shift)
    if (auth.user?.role == 'admin') {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: DashboardScreen(), // Pastikan sudah diimport
      );
    }

    // Alur untuk Pegawai
    if (shift.activeShift == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ShiftScreen(
          userId: auth.user!.id!,
          username: auth.user!.username,
        ),
      );
    }

    return MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: "Poppins"),
      debugShowCheckedModeBanner: false,
      home: MainMenuScreen(shiftName: shift.activeShiftName!),
    );
  }
}
