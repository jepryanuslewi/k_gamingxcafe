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
  // Controller untuk pencarian
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _allBahan = []; // Data asli dari DB
  List<Map<String, dynamic>> _filteredBahan = []; // Data yang difilter untuk UI
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshBahan();
    // Listener untuk pencarian otomatis saat mengetik
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi filtering
  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBahan = _allBahan.where((bahan) {
        final namaBahan = (bahan['nama'] ?? '').toString().toLowerCase();
        return namaBahan.contains(query);
      }).toList();
    });
  }

  // Ambil data dari Database
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
              const SizedBox(height: 30),

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
                      // Header Tabel: Judul & Tanggal
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

                      // Input Pencarian yang sudah diperbaiki
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

                      // Tombol Navigasi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ButtonStock(
                                text: "MASUK",
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StockMasukScreen(
                                        shiftName: widget.shiftName,
                                      ),
                                    ),
                                  );
                                  _refreshBahan(); // Refresh setelah kembali
                                },
                              ),
                              const SizedBox(width: 10),
                              ButtonStock(
                                text: "KELUAR",
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => StockKeluarScreen(
                                        shiftName: widget.shiftName,
                                      ),
                                    ),
                                  );
                                  _refreshBahan(); // Refresh setelah kembali
                                },
                              ),
                            ],
                          ),
                          ButtonStock(
                            text: "BACK",
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Section Data Table
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
                                    columnSpacing: 15,
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
                                          "NAMA",
                                          style: TextStyle(
                                            color: Color(0xFF00E0C6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "KAT",
                                          style: TextStyle(
                                            color: Color(0xFF00E0C6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "STOK",
                                          style: TextStyle(
                                            color: Color(0xFF00E0C6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          "SATUAN",
                                          style: TextStyle(
                                            color: Color(0xFF00E0C6),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: List<DataRow>.generate(
                                      _filteredBahan.length,
                                      (index) {
                                        final item = _filteredBahan[index];
                                        return DataRow(
                                          cells: [
                                            DataCell(
                                              Text(
                                                "${index + 1}",
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                item['nama'] ?? '-',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                item['kategori'] ?? '-',
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                item['stok_saat_ini']
                                                    .toString(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            DataCell(
                                              Text(
                                                item['satuan'] ?? '-',
                                                style: const TextStyle(
                                                  color: Colors.white54,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
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
                height: 60,
                errorBuilder: (c, e, s) =>
                    const Icon(Icons.broken_image, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "GAMING X CAFE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Stock Management",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
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
