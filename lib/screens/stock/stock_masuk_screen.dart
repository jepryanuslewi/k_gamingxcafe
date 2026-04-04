import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/widgets/stock/input_stock.dart';
import 'package:provider/provider.dart';

class StockMasukScreen extends StatelessWidget {
  final String shiftName;
  const StockMasukScreen({super.key, required this.shiftName});

  @override
  Widget build(BuildContext context) {
    final tanggal = DateTime.now();
    final authprovider = context.watch<AuthProvider>();
    final String username = authprovider.user?.username ?? "";
    return Scaffold(
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
                    height: 90,
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
                                        color: Color.fromRGBO(0, 224, 198, 100),
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
                                  Text(shiftName),
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
                  SizedBox(height: 30),

                  // menu===================================================
                  Container(
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(20, 28, 47, 100),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color.fromRGBO(0, 224, 198, 100),
                      ),
                    ),
                    padding: EdgeInsets.only(left: 50, right: 50, top: 10),
                    height: 440,
                    width: double.infinity,
                    child: Column(
                      children: [
                        // 1
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // username
                            Text(
                              'STOCK MASUK',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
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
                        SizedBox(height: 5),
                        // Divider
                        Divider(color: Colors.white, thickness: 1),
                        SizedBox(height: 10),
                        // Input
                        Row(
                          children: [
                            Expanded(child: InputStock(text: "BAHAN")),
                            SizedBox(width: 10),
                            Expanded(child: InputStock(text: "STOK")),
                            SizedBox(width: 10),
                            Expanded(child: InputStock(text: "DESKRIPSI")),
                            SizedBox(width: 10),
                          ],
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(26, 37, 64, 100),
                              shadowColor: Colors.white,
                            ),
                            onPressed: () {},
                            child: Text(
                              "Add Item",
                              style: TextStyle(color: Colors.white),
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
    );
  }
}
