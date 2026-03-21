import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/jadwal_provider.dart';
import 'package:k_gamingxcafe/providers/shift_provider.dart';
import 'package:k_gamingxcafe/screens/login_screen.dart';
import 'package:k_gamingxcafe/screens/main_menu_screen.dart';
import 'package:k_gamingxcafe/screens/shift_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Provider
  final authProvider = AuthProvider();
  final shiftProvider = ShiftProvider();

  // 2. Muat data yang tersimpan di memori (Persistent Data)
  await authProvider.checkLoginStatus();
  await shiftProvider.loadActiveShift();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: shiftProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
        ChangeNotifierProvider(create: (_) => JadwalProvider()),
        // Tambahkan ShiftProvider jika sudah dibuat
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final shift = context.watch<ShiftProvider>();

    Widget homeWidget;

    if (auth.user == null) {
      // Jika belum login -> ke halaman Login
      homeWidget = const LoginScreen();
    } else if (shift.activeShift == null) {
      // Jika sudah login tapi belum pilih shift -> ke halaman Pilih Shift
      homeWidget = ShiftScreen(userId: auth.user!.id!);
    } else {
      // Jika sudah login dan sudah ada shift aktif -> langsung ke Dashboard
      homeWidget = MainMenuScreen(shiftName: shift.activeShiftName!);
    }

    return MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: "Poppins"),
      debugShowCheckedModeBanner: false,
      home: homeWidget,
    );
  }
}
