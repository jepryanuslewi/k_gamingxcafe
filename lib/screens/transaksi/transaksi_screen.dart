import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/providers/cafe/menu_provider.dart';
import 'package:k_gamingxcafe/widgets/transaksi/transaksi_dialog.dart';
import 'package:k_gamingxcafe/widgets/stock/button_stock.dart';
import 'package:provider/provider.dart';

class TransaksiScreen extends StatefulWidget {
  final String shiftName;
  const TransaksiScreen({super.key, required this.shiftName});

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> {
  final TextEditingController _searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().fetchRiwayatTransaksi();
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuProv = context.watch<MenuProvider>();
    final daftarRiwayat = menuProv.riwayatTransaksi;
    final tanggal = DateTime.now();
    final String username =
        context.read<AuthProvider>().user?.username ?? "Pegawai";

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
                                    "$username",
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
                        // Search
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(30, 38, 57, 1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: "Cari Nama Bahan...",
                              hintStyle: TextStyle(color: Colors.white38),
                              border: InputBorder.none,
                              icon: Icon(
                                Icons.search,
                                color: Color(0xFF00E0C6),
                              ),
                            ),
                          ),
                        ),
                        // Add transaksi
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ButtonStock(
                              text: "Back",
                              onPressed: () => Navigator.pop(context),
                            ),
                            ButtonStock(
                              text: "+ Transaksi",
                              onPressed: () {
                                TransactionDialog.show(
                                  context,
                                  shiftName: username,
                                );
                              },
                            ),
                          ],
                        ),
                        // Tabel Riwayat Transaksi(No, Nama Menu, oty, Total Harga, Pegawai, jam)
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            child: daftarRiwayat.isEmpty
                                ? const Center(
                                    child: Text(
                                      "Belum ada transaksi",
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  )
                                : SingleChildScrollView(
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(
                                          label: Text(
                                            'NO',
                                            style: _headerStyle,
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'NAMA MENU',
                                            style: _headerStyle,
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'QTY',
                                            style: _headerStyle,
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'TOTAL',
                                            style: _headerStyle,
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'JAM',
                                            style: _headerStyle,
                                          ),
                                        ),
                                        DataColumn(
                                          label: Text(
                                            'PEGAWAI',
                                            style: _headerStyle,
                                          ),
                                        ),
                                      ],
                                      rows: daftarRiwayat.asMap().entries.map((
                                        entry,
                                      ) {
                                        int index = entry.key;
                                        var data = entry.value;

                                        // Parsing jam dari created_at (ISO8601)
                                        DateTime dt = DateTime.parse(
                                          data['created_at'],
                                        );
                                        String jam =
                                            "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                "${index + 1}",
                                                style: _cellStyle,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${data['nama_produk']}",
                                                style: _cellStyle,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "${data['jumlah']}",
                                                style: _cellStyle,
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                "Rp ${data['total_harga']}",
                                                style: _cellStyle,
                                              ),
                                            ),
                                            DataCell(
                                              Text(jam, style: _cellStyle),
                                            ),
                                            DataCell(
                                              Text(
                                                "${data['shift_name']}",
                                                style: _cellStyle,
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
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
    );
  }

  // Style untuk header tabel
  static const _headerStyle = TextStyle(
    color: Color(0xFF00E0C6),
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  // Style untuk isi tabel
  static const _cellStyle = TextStyle(color: Colors.white, fontSize: 13);
}
