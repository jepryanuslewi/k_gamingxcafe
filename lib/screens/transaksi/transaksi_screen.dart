import 'package:flutter/material.dart';

class TransaksiScreen extends StatefulWidget {
  final String shiftName;
  const TransaksiScreen({super.key, required this.shiftName});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  @override
  Widget build(BuildContext context) {
    final tanggal = DateTime.now();
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
                                    "Pegawai",
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // username
                            Text(
                              'TRANSAKSI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
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
