import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/reservation_provider.dart';
import 'package:k_gamingxcafe/providers/shift_provider.dart';
import 'package:k_gamingxcafe/views/login_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ShiftProvider()),
        ChangeNotifierProvider(create: (_) => ReservationProvider()),
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
    return MaterialApp(
      theme: ThemeData(useMaterial3: true, fontFamily: "Poppins"),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
