import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/screens/dashboard/dashboard_screen.dart';
import 'package:k_gamingxcafe/screens/shift_screen.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      bool success = await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );

      setState(() => _isLoading = false);

      if (success) {
        final user = authProvider.user;
        if (mounted && user != null) {
          Widget destination;
          if (user.role == 'admin') {
            destination = const DashboardScreen();
          } else {
            destination = ShiftScreen(
              userId: user.id!,
              username: user.username,
            );
          }

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => destination),
            (route) => false,
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color.fromRGBO(226, 19, 136, 100),
              content: Center(
                child: Text(
                  'Username atau Password salah!',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          );
        }
      }
    }
  }

  @override
Widget build(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final isTablet = size.width > 600;

  return Scaffold(
    backgroundColor: const Color.fromRGBO(11, 18, 32, 100),
    body: SafeArea(
      child: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              "assets/images/bgLoginScreen.png",
              fit: BoxFit.cover,
            ),
          ),

         
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                vertical: 20,
                horizontal: isTablet ? size.width * 0.25 : 20,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color.fromRGBO(20, 28, 47, 100),
                ),
                
                width: isTablet ? 500 : double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 40,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        "assets/images/bgLoginScreen.png",
                        width: isTablet ? 180 : 150,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "GAMING",
                            style: TextStyle(
                              color: const Color.fromRGBO(226, 19, 136, 100),
                              fontSize: isTablet ? 34 : 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "X",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 36 : 32,
                              fontFamily: "Poppins",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "CAFE",
                            style: TextStyle(
                              color: const Color.fromRGBO(0, 224, 198, 100),
                              fontSize: isTablet ? 34 : 30,
                              fontWeight: FontWeight.bold,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 290,
                        child: Divider(color: Colors.white, thickness: 2),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "WELCOME",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontFamily: "Poppins",
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 70,
                            child: Divider(
                              color: const Color.fromRGBO(112, 215, 2003, 100),
                              thickness: 2,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Text(
                            "Please Sign In To Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: "Poppins",
                            ),
                          ),
                          const SizedBox(width: 20),
                          SizedBox(
                            width: 70,
                            child: Divider(
                              color: const Color.fromRGBO(226, 19, 136, 100),
                              thickness: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Username
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color.fromRGBO(44, 54, 75, 100),
                          hintText: "Username",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.person_2_outlined,
                            color: Color.fromRGBO(112, 215, 2003, 100),
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? "Username tidak boleh kosong"
                            : null,
                      ),
                      const SizedBox(height: 15),

                      // Password
                      TextFormField(
                        style: const TextStyle(color: Colors.white),
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color.fromRGBO(44, 54, 75, 100),
                          hintText: "Password",
                          hintStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outlined,
                            color: Color.fromRGBO(112, 215, 2003, 100),
                          ),
                        ),
                        validator: (value) => value!.isEmpty
                            ? "Password tidak boleh kosong"
                            : null,
                      ),
                      const SizedBox(height: 25),

                      // Tombol Login
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(226, 19, 136, 90),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  "SIGN IN",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}
