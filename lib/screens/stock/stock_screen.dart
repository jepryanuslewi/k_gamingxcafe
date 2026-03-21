import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/cafe_provider.dart';
import 'package:k_gamingxcafe/providers/shift_provider.dart';
import 'package:k_gamingxcafe/screens/stock/stock_masuk_screen.dart';
import 'package:k_gamingxcafe/widgets/dialog/add_product_dialog.dart';
import 'package:k_gamingxcafe/widgets/stock/button_stock.dart';
import 'package:k_gamingxcafe/widgets/search_widget.dart';
import 'package:k_gamingxcafe/widgets/stock/stock_table.dart';
import 'package:provider/provider.dart';

class StockScreen extends StatelessWidget {
  final String shiftName;
  const StockScreen({super.key, required this.shiftName});

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
                              'STOCK',
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
                        SizedBox(height: 10),

                        // Pencarian
                        SizedBox(
                          height: 50,
                          child: SearchWidget(
                            text: "Cari Barang",
                            onPressed: () {},
                          ),
                        ),
                        SizedBox(height: 5),
                        // Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 1
                            Row(
                              children: [
                                ButtonStock(
                                  text: "MASUK",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StockMasukScreen(
                                          shiftName: shiftName,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(width: 10),
                                ButtonStock(text: "KELUAR", onPressed: () {}),
                              ],
                            ),
                            // 2
                            Row(
                              children: [
                                ButtonStock(
                                  text: "ITEM",
                                  onPressed: () {
                                    null;
                                  },
                                ),
                                SizedBox(width: 10),
                                ButtonStock(
                                  text: "BACK",
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Daftar Barang
                        Container(
                          margin: EdgeInsets.only(top: 5, bottom: 5),
                          padding: EdgeInsets.only(
                            top: 2,
                            left: 10,
                            right: 10,
                            bottom: 10,
                          ),
                          height: 250,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(
                              color: const Color.fromARGB(255, 113, 112, 112),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                "DATA BARANG",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
                              StockTable(),
                            ],
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
