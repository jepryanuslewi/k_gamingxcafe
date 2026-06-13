import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/screens/stock/stock_masuk_screen.dart';
import 'package:k_gamingxcafe/screens/stock/stok_keluar_screen.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import 'package:k_gamingxcafe/widgets/stock/button_stock.dart';
import 'package:provider/provider.dart';

class StockScreen extends StatefulWidget {
  final String shiftName;
  const StockScreen({super.key, required this.shiftName});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allBahan = [];
  List<Map<String, dynamic>> _filteredBahan = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshBahan();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBahan = _allBahan.where((bahan) {
        final namaBahan = (bahan['nama'] ?? '').toString().toLowerCase();
        return namaBahan.contains(query);
      }).toList();
    });
  }

  Future<void> _refreshBahan() async {
    setState(() => _isLoading = true);
    final data = await DatabaseService.instance.getBahanSemua();
    setState(() {
      _allBahan = data;
      _filteredBahan = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tanggal = DateTime.now();
    final authProvider = context.watch<AuthProvider>();
    final String username = authProvider.user?.username ?? "User";

    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 18, 32, 1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            children: [
              _buildHeader(username, widget.shiftName),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(20, 28, 47, 1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'STOCK BAHAN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

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
                            icon: Icon(Icons.search, color: Color(0xFF00E0C6)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ButtonStock(
                                text: "STOK MASUK",
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StockMasukScreen(
                                        shiftName: widget.shiftName,
                                      ),
                                    ),
                                  );
                                  _refreshBahan();
                                },
                              ),
                              const SizedBox(width: 10),
                              ButtonStock(
                                text: "STOK KELUAR",
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StockKeluarScreen(
                                        shiftName: widget.shiftName,
                                      ),
                                    ),
                                  );
                                  _refreshBahan();
                                },
                              ),
                            ],
                          ),
                          ButtonStock(
                            text: "Kembali",
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: _isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF00E0C6),
                                  ),
                                )
                              : _filteredBahan.isEmpty
                              ? const Center(
                                  child: Text(
                                    "Data tidak ditemukan",
                                    style: TextStyle(color: Colors.white54),
                                  ),
                                )
                              : SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: DataTable(
                                    headingRowColor: MaterialStateProperty.all(
                                      Colors.white.withOpacity(0.05),
                                    ),
                                    columnSpacing: 14,
                                    columns: const [
                                      DataColumn(
                                        label: Text(
                                          "NO",
                                          style: TextStyle(
                                            color: Color(0xFF00E0C6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "NAMA BAHAN",
                                          style: TextStyle(
                                            color: Color(0xFF00E0C6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "KATEGORI",
                                          style: TextStyle(
                                            color: Color(0xFF00E0C6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "QTY",
                                          style: TextStyle(
                                            color: Color(0xFF00E0C6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: List<DataRow>.generate(_filteredBahan.length, (
                                      index,
                                    ) {
                                      final item = _filteredBahan[index];
                                      final qty =
                                          ((item['stok_saat_ini'] /
                                                      item['isi_per_qty'])
                                                  as num)
                                              .toDouble();
                                      final isEmpty = qty <= 0;
                                      final isLow = !isEmpty && qty < 5;

                                      Color? rowColor;
                                      if (isEmpty) {
                                        rowColor = Colors.red.withOpacity(0.08);
                                      } else if (isLow) {
                                        rowColor = Colors.orange.withOpacity(
                                          0.08,
                                        );
                                      }

                                      return DataRow(
                                        color:
                                            MaterialStateProperty.resolveWith(
                                              (states) => rowColor,
                                            ),
                                        cells: [
                                          DataCell(
                                            Text(
                                              "${index + 1}",
                                              style: TextStyle(
                                                color: isEmpty
                                                    ? Colors.white30
                                                    : Colors.white70,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              item['nama'] ?? '-',
                                              style: TextStyle(
                                                color: isEmpty
                                                    ? Colors.redAccent
                                                          .withOpacity(0.6)
                                                    : Colors.white,
                                                decoration: isEmpty
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                decorationColor: Colors.white30,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              item['kategori'] ?? '-',
                                              style: TextStyle(
                                                color: isEmpty
                                                    ? Colors.white24
                                                    : Colors.white70,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  isEmpty
                                                      ? "0 PCS"
                                                      : "${qty.toStringAsFixed(0)} PCS",
                                                  style: TextStyle(
                                                    color: isEmpty
                                                        ? Colors.redAccent
                                                        : isLow
                                                        ? Colors.orange
                                                        : Colors.white54,
                                                    fontWeight:
                                                        (isEmpty || isLow)
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),

                                                if (isEmpty) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.redAccent
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.redAccent,
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      "STOK HABIS",
                                                      style: TextStyle(
                                                        color: Colors.redAccent,
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],

                                                if (isLow) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 6,
                                                          vertical: 2,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.orange
                                                          .withOpacity(0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.orange,
                                                        width: 0.5,
                                                      ),
                                                    ),
                                                    child: const Text(
                                                      "STOK MENIPIS",
                                                      style: TextStyle(
                                                        color: Colors.orange,
                                                        fontSize: 9,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String username, String shift) {
    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                "assets/images/bgLoginScreen.png",
                width: 100,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.broken_image, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Row(
                    children: [
                      Text(
                        "GAMING",
                        style: TextStyle(
                          color: Color.fromRGBO(226, 19, 136, 100),
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        "X",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 35,
                          fontWeight: FontWeight.normal,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
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
                    "Stock Management",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ],
              ),
            ],
          ),
          Row(
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
                  Text(shift, style: const TextStyle(color: Color(0xFF00E0C6))),
                ],
              ),
              const SizedBox(width: 10),
              const Icon(Icons.person_pin, size: 50, color: Color(0xFF00E0C6)),
            ],
          ),
        ],
      ),
    );
  }
}
