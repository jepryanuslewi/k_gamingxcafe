import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/providers/auth_provider.dart';
import 'package:k_gamingxcafe/services/database_service.dart';
import 'package:k_gamingxcafe/widgets/laporan/tabel_laporan_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class LaporanScreen extends StatefulWidget {
  final String shiftName;
  const LaporanScreen({super.key, required this.shiftName});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  DateTime? tanggalAwal;
  DateTime? tanggalAkhir;

  String? selectedKategori; // Jadwal, Stock, Transaksi
  String? selectedSubKategori;
  String? selectedKaryawan = "Semua";

  // State untuk mengontrol tampilan tabel
  bool isTableVisible = false;

  List<String> listKaryawan = ["Semua"];
  Future<void> _loadKaryawan() async {
    final names = await DatabaseService.instance
        .getAllStaffNames(); // Pakai instance
    setState(() {
      listKaryawan = names;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadKaryawan(); // Panggil fungsi saat screen dibuka
  }

  final List<String> listKategori = ["Jadwal", "Stock", "Transaksi"];

  List<String> getSubKategori() {
    if (selectedKategori == "Jadwal") {
      return ["Walk-In", "Booking", "Semua"];
    } else if (selectedKategori == "Stock") {
      return ["Stock Masuk", "Stock Keluar", "Semua"];
    } else if (selectedKategori == "Transaksi") {
      return ["Makanan", "Minuman", "Semua"];
    }
    return [];
  }

  Future<void> _selectDate(BuildContext context, bool isAwal) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E0C6),
              onPrimary: Color(0xFF0B1220),
              surface: Color(0xFF141C2F),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isAwal) {
          tanggalAwal = picked;
        } else {
          tanggalAkhir = picked;
        }
        isTableVisible = false; 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tanggal = DateTime.now();
    final authprovider = context.watch<AuthProvider>();
    final String username = authprovider.user?.username ?? "User";

    return Scaffold(
      backgroundColor: const Color.fromRGBO(11, 18, 32, 1),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
          child: Column(
            children: [
              _buildHeader(username),
              const SizedBox(height: 30),
              _buildMainForm(tanggal),

              // Tampilkan widget tabel yang dipisah jika tombol sudah ditekan
              if (isTableVisible && selectedKategori != null)
                TabelLaporanWidget(
                  kategori: selectedKategori!,
                  subKategori: selectedSubKategori, // Tambahkan ini
                  tanggalAwal: tanggalAwal, // Tambahkan ini
                  tanggalAkhir: tanggalAkhir, // Tambahkan ini
                  karyawan: selectedKaryawan, // INI YANG PALING PENTING
                ),

              const SizedBox(height: 50), // Padding bawah agar tidak mepet
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String username) {
    return SizedBox(
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset("assets/images/bgLoginScreen.png", height: 60),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Poppins",
                      ),
                      children: [
                        TextSpan(
                          text: "GAMING ",
                          style: TextStyle(
                            color: Color.fromRGBO(226, 19, 136, 1),
                          ),
                        ),
                        TextSpan(
                          text: "X ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        TextSpan(
                          text: "CAFE",
                          style: TextStyle(
                            color: Color.fromRGBO(0, 224, 198, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    "Booking & Transaction App",
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
                  Text(
                    widget.shiftName,
                    style: const TextStyle(
                      color: Color(0xFF00E0C6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              const Icon(Icons.person_pin, size: 60, color: Color(0xFF00E0C6)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainForm(DateTime tanggal) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(20, 28, 47, 1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(0, 224, 198, 1)),
      ),
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LAPORAN LENGKAP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${tanggal.day}/${tanggal.month}/${tanggal.year}',
                style: const TextStyle(color: Colors.white70, fontSize: 18),
              ),
            ],
          ),
          const Divider(color: Colors.white10, height: 40),

          Row(
            children: [
              Expanded(
                child: _buildDateTile(
                  "Tanggal Awal",
                  tanggalAwal,
                  () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildDateTile(
                  "Tanggal Akhir",
                  tanggalAkhir,
                  () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  "Pilih Kategori",
                  selectedKategori,
                  listKategori,
                  (val) {
                    setState(() {
                      selectedKategori = val;
                      selectedSubKategori = null;
                      isTableVisible = false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildDropdown(
                  "Sub Kategori",
                  selectedSubKategori,
                  getSubKategori(),
                  (val) {
                    setState(() {
                      selectedSubKategori = val;
                      isTableVisible = false;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),

          _buildDropdown(
            "Pilih Nama Karyawan",
            selectedKaryawan,
            listKaryawan,
            (val) {
              setState(() {
                selectedKaryawan = val;
                isTableVisible = false;
              });
            },
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E0C6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // Validasi input sebelum menampilkan
                if (tanggalAwal == null ||
                    tanggalAkhir == null ||
                    selectedKategori == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Lengkapi semua filter terlebih dahulu"),
                    ),
                  );
                  return;
                }
                setState(() {
                  isTableVisible = true;
                });
              },
              child: const Text(
                "TAMPILKAN LAPORAN",
                style: TextStyle(
                  color: Color(0xFF0B1220),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date == null
                      ? "Pilih Tanggal"
                      : DateFormat('dd/MM/yyyy').format(date),
                  style: const TextStyle(color: Colors.white),
                ),
                const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF00E0C6),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(
    String label,
    String? value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF141C2F),
              hint: const Text(
                "Pilih",
                style: TextStyle(color: Colors.white38),
              ),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF00E0C6)),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
