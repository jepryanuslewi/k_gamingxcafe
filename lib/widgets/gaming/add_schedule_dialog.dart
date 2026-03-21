import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/ps_unit_model.dart';
import '../../models/package_model.dart'; // Pastikan Anda sudah membuat model ini

class AddScheduleDialog extends StatefulWidget {
  final List<PsUnitModel> allUnits;
  final List<PackageModel> availablePackages;

  const AddScheduleDialog({
    super.key,
    required this.allUnits,
    required this.availablePackages,
  });

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  // Controller
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // State Form
  String _selectedCategory = 'REGULAR';
  int? _selectedUnitId;
  PackageModel? _selectedPackage;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _selectedDuration = 1;
  int _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _calculatePrice();
  }

  // Fungsi Hitung Harga Otomatis
  void _calculatePrice() {
    setState(() {
      if (_selectedCategory == 'Event') {
        // Jika Event, harga diambil dari paket yang dipilih
        _totalPrice = _selectedPackage?.price ?? 0;
      } else {
        // Jika Reguler/VIP, harga = harga unit * durasi
        final unit = widget.allUnits.firstWhere(
          (u) => u.id == _selectedUnitId,
          orElse: () => PsUnitModel(
            id: 0,
            name: '',
            type: '',
            pricePerHour: 0,
            status: '',
          ),
        );
        _totalPrice = unit.pricePerHour * _selectedDuration;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<PsUnitModel> filteredUnits = widget.allUnits.where((u) {
      String typeFromDb = u.type.trim().toLowerCase();
      String selectedCat = _selectedCategory.trim().toLowerCase();

      // Hanya filter berdasarkan tipe (Reguler/VIP), abaikan status 'occupied'
      return typeFromDb == selectedCat;
    }).toList();

    // Filter Paket berdasarkan Kategori (Event)
    List<PackageModel> filteredPackages = widget.availablePackages
        .where((p) => p.category == _selectedCategory)
        .toList();

    return AlertDialog(
      backgroundColor: const Color(0xFF141C2F),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF00E0C6), width: 1),
      ),
      title: const Text(
        "TAMBAH RESERVASI",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. KATEGORI ---
              _buildLabel("Kategori"),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: const Color(0xFF141C2F),
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco(""),
                items: ['REGULAR', 'VIP 1', 'VIP 2', 'Event']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedCategory = val!;
                    _selectedUnitId = null;
                    _selectedPackage = null;
                    _calculatePrice();
                  });
                },
              ),
              const SizedBox(height: 15),

              // --- 2. UNIT (Hanya jika BUKAN Event) ---
              if (_selectedCategory != 'Event') ...[
                _buildLabel("Pilih Unit PS"),
                DropdownButtonFormField<int>(
                  value: _selectedUnitId,
                  hint: const Text(
                    "Pilih No Unit",
                    style: TextStyle(color: Colors.white54),
                  ),
                  dropdownColor: const Color(0xFF141C2F),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDeco(""),
                  items: filteredUnits
                      .map(
                        (u) =>
                            DropdownMenuItem(value: u.id, child: Text(u.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    setState(() => _selectedUnitId = val);
                    _calculatePrice();
                  },
                ),
              ],

              // --- 3. PAKETAN (Hanya jika Kategori EVENT) ---
              if (_selectedCategory == 'Event') ...[
                _buildLabel("Pilih Paket Event"),
                filteredPackages.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Belum ada paket event di database",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : DropdownButtonFormField<PackageModel>(
                        value: _selectedPackage,
                        hint: const Text(
                          "Pilih Paket",
                          style: TextStyle(color: Colors.white54),
                        ),
                        dropdownColor: const Color(0xFF141C2F),
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDeco(""),
                        items: filteredPackages
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  "${p.name} (Rp ${NumberFormat("#,###").format(p.price)})",
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() => _selectedPackage = val);
                          _calculatePrice();
                        },
                      ),
              ],
              const SizedBox(height: 15),

              // --- 4. DATA CUSTOMER ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Nama Pelanggan"),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDeco("Opsional"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("No Telepon"),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDeco("0812..."),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // --- 5. TANGGAL & JAM ---
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Tanggal"),
                        _buildPickerTile(
                          DateFormat('dd/MM/yyyy').format(_selectedDate),
                          Icons.calendar_month,
                          () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2027),
                            );
                            if (picked != null)
                              setState(() => _selectedDate = picked);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel("Jam Mulai"),
                        _buildPickerTile(
                          _selectedTime.format(context),
                          Icons.access_time,
                          () async {
                            final picked = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (picked != null)
                              setState(() => _selectedTime = picked);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // --- 6. DURASI (Hanya jika BUKAN Event) ---
              if (_selectedCategory != 'Event') ...[
                _buildLabel("Durasi Bermain"),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [1, 2, 3, 5]
                      .map(
                        (h) => ChoiceChip(
                          label: Text("$h Jam"),
                          selected: _selectedDuration == h,
                          onSelected: (s) {
                            setState(() => _selectedDuration = h);
                            _calculatePrice();
                          },
                          selectedColor: const Color(0xFF00E0C6),
                          backgroundColor: Colors.white10,
                          labelStyle: TextStyle(
                            color: _selectedDuration == h
                                ? Colors.black
                                : Colors.white,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],

              const Divider(color: Colors.white24, height: 40),

              // --- 7. TOTAL PEMBAYARAN ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TOTAL:",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    "Rp ${NumberFormat("#,###").format(_totalPrice)}",
                    style: const TextStyle(
                      color: Color(0xFF00E0C6),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("BATAL", style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E0C6),
          ),
          onPressed: () {
            // 1. Validasi: Jika bukan Event, pastikan Unit sudah dipilih
            if (_selectedCategory != 'Event' && _selectedUnitId == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Silakan pilih Unit PS terlebih dahulu"),
                ),
              );
              return;
            }

            // 2. Gabungkan Tanggal & Jam
            final startDT = DateTime(
              _selectedDate.year,
              _selectedDate.month,
              _selectedDate.day,
              _selectedTime.hour,
              _selectedTime.minute,
            );

            // 3. Cari Nama Unit dengan aman (Cegah error unit_name)
            String unitName = "Event/Paket"; // Default jika Event
            if (_selectedCategory != 'Event') {
              try {
                unitName = widget.allUnits
                    .firstWhere((u) => u.id == _selectedUnitId)
                    .name;
              } catch (e) {
                unitName = "Unknown Unit";
              }
            }

            // 4. Kirim Data kembali ke Screen Utama
            Navigator.pop(context, {
              'unit_id':
                  _selectedUnitId, // Akan null jika Event, pastikan DB Anda mengizinkan null
              'unit_name': unitName,
              'customer_name': _nameController.text.trim().isEmpty
                  ? "Walk-In"
                  : _nameController.text.trim(),
              'customer_phone': _phoneController.text
                  .trim(), // Pastikan di trim
              'category': _selectedCategory,
              'package_name': _selectedPackage?.name,
              'start_time': startDT.toIso8601String(),
              'duration': _selectedDuration,
              'total_price': _totalPrice,
              'is_paketan': _selectedCategory == 'Event',
            });
          },
          child: const Text(
            "SIMPAN",
            style: TextStyle(
              color: Color(0xFF0B1220),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Widget Pembantu
  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 12),
    ),
  );

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white10),
      borderRadius: BorderRadius.circular(8),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Color(0xFF00E0C6)),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  Widget _buildPickerTile(String text, IconData icon, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white10),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
              Icon(icon, color: const Color(0xFF00E0C6), size: 18),
            ],
          ),
        ),
      );
}
