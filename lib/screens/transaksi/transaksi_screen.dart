import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
  List<dynamic> _filteredRiwayat = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().fetchRiwayatTransaksi().then((_) {
        _updateFilter();
      });
    });

    _searchController.addListener(_updateFilter);
  }

  void _updateFilter() {
    final menuProv = context.read<MenuProvider>();
    final daftarRiwayat = menuProv.riwayatTransaksi;
    final query = _searchController.text.toLowerCase();

    setState(() {
      if (query.isEmpty) {
        _filteredRiwayat = daftarRiwayat;
      } else {
        _filteredRiwayat = daftarRiwayat.where((data) {
          final namaProduk = (data['nama_produk'] ?? '')
              .toString()
              .toLowerCase();
          return namaProduk.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_updateFilter);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuProv = context.watch<MenuProvider>();

    // Sync filtered list saat data provider berubah
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final query = _searchController.text.toLowerCase();
      final daftarRiwayat = menuProv.riwayatTransaksi;
      final filtered = query.isEmpty
          ? daftarRiwayat
          : daftarRiwayat.where((data) {
              final namaProduk = (data['nama_produk'] ?? '')
                  .toString()
                  .toLowerCase();
              return namaProduk.contains(query);
            }).toList();

      if (mounted && _filteredRiwayat.length != filtered.length) {
        setState(() {
          _filteredRiwayat = filtered;
        });
      }
    });

    final tanggal = DateTime.now();
    final String username =
        context.read<AuthProvider>().user?.username ?? "Pegawai";

    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 18, 32, 100),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Column(
                  children: [
                    Container(
                      color: Colors.transparent,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.15,
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
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(
                                11,
                                18,
                                32,
                                100,
                              ),
                            ),
                            onPressed: () {},
                            child: Row(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      username,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.shiftName,
                                      style: const TextStyle(
                                        color: Color(0xFF00E0C6),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.person_pin,
                                  size: 50,
                                  color: Color(0xFF00E0C6),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),

                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(20, 28, 47, 100),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white10),
                      ),
                      padding: EdgeInsets.only(left: 50, right: 50, top: 20),
                      constraints: BoxConstraints(
                        minHeight: 400,
                        maxHeight: MediaQuery.of(context).size.height * 0.70,
                      ),
                      width: double.infinity,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TRANSAKSI',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                              decoration: InputDecoration(
                                hintText: "Cari Nama Menu...",
                                hintStyle: TextStyle(color: Colors.white38),
                                border: InputBorder.none,
                                icon: Icon(
                                  Icons.search,
                                  color: Color(0xFF00E0C6),
                                ),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.white38,
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ButtonStock(
                                text: "Kembali",
                                onPressed: () => Navigator.pop(context),
                              ),
                              ButtonStock(
                                text: "+ Transaksi",
                                onPressed: () {
                                  TransactionDialog.show(
                                    context,
                                    shiftName: widget.shiftName,
                                  );
                                  _updateFilter();
                                },
                              ),
                            ],
                          ),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              child: _filteredRiwayat.isEmpty
                                  ? Center(
                                      child: Text(
                                        _searchController.text.isNotEmpty
                                            ? "Menu \"${_searchController.text}\" tidak ditemukan"
                                            : "Belum ada transaksi",
                                        style: const TextStyle(
                                          color: Colors.white54,
                                        ),
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
                                        rows: _filteredRiwayat.asMap().entries.map((
                                          entry,
                                        ) {
                                          int index = entry.key;
                                          var data = entry.value;

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
                                                  "Rp ${NumberFormat("#,###", "id_ID").format(data['total_harga'])}",
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
      ),
    );
  }

  static const _headerStyle = TextStyle(
    color: Color(0xFF00E0C6),
    fontWeight: FontWeight.bold,
    fontSize: 14,
  );

  static const _cellStyle = TextStyle(color: Colors.white, fontSize: 13);
}
