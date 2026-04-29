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
  final _usernameController = TextEditingController(text: "pegawai1");
  final _passwordController = TextEditingController(text: "1234");
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
            const SnackBar(content: Text('Username atau Password salah!')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(11, 18, 32, 100),
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset("assets/images/bgLoginScreen.png"),
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: Color.fromRGBO(20, 28, 47, 100),
                ),
                height: 748,
                width: 450,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/bgLoginScreen.png",
                          width: 250,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "GAMING",
                              style: TextStyle(
                                color: Color.fromRGBO(226, 19, 136, 100),
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                fontFamily: "Poppins",
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              "X",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.normal,
                                fontFamily: "Poppins",
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              "CAFE",
                              style: TextStyle(
                                color: Color.fromRGBO(0, 224, 198, 100),
                                fontSize: 30,
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
                            fontWeight: FontWeight.normal,
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
                                color: Color.fromRGBO(112, 215, 2003, 100),
                                thickness: 2,
                              ),
                            ),
                            const SizedBox(width: 20),
                            const Text(
                              "Please Sign In To Continue",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                fontFamily: "Poppins",
                              ),
                            ),
                            const SizedBox(width: 20),
                            SizedBox(
                              width: 70,
                              child: Divider(
                                color: Color.fromRGBO(226, 19, 136, 100),
                                thickness: 2,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        // Input Username
                        Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 50),
                          child: Column(
                            children: [
                              TextFormField(
                                style: TextStyle(color: Colors.white),
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Color.fromRGBO(44, 54, 75, 100),
                                  hint: Text(
                                    "Username",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
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
                              const SizedBox(height: 10),

                              // Input Password
                              TextFormField(
                                style: TextStyle(color: Colors.white),
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Color.fromRGBO(44, 54, 75, 100),
                                  hint: Text(
                                    "Password",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
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
                              const SizedBox(height: 20),
                              // Tombol Login
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromRGBO(
                                      226,
                                      19,
                                      136,
                                      90,
                                    ),
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
