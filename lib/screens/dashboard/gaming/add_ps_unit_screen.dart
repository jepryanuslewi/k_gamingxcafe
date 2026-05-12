import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class AddPsUnitScreen extends StatefulWidget {
  const AddPsUnitScreen({super.key});

  @override
  State<AddPsUnitScreen> createState() => _AddPsUnitScreenState();
}

class _AddPsUnitScreenState extends State<AddPsUnitScreen> {
  List<Map<String, dynamic>> units = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUnits();
  }

  Future<void> loadUnits() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final db = await DatabaseService.instance.database;
    final data = await db.query("ps_units", orderBy: "name ASC");

    if (mounted) {
      setState(() {
        units = data;
        isLoading = false;
      });
    }
  }

  Future<void> deleteUnit(int id) async {
    final db = await DatabaseService.instance.database;
    await db.delete("ps_units", where: "id = ?", whereArgs: [id]);
    loadUnits();
  }

  void showEditUnitForm(Map<String, dynamic> unit) {
    final nameController = TextEditingController(text: unit["name"]);
    final priceController = TextEditingController(
      text: unit["price_per_hour"].toString(),
    );
    final formKey = GlobalKey<FormState>();
    String type = unit["type"];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xff141c2f),
          title: Text(
            "Edit Unit: ${unit['name']}",
            style: const TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.30,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Nama Unit",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                  ),
                  TextFormField(
                    controller: priceController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Harga per Jam",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xff141c2f),
                    value: type,
                    style: const TextStyle(color: Colors.white),
                    items: ["REGULAR", "VIP 1", "VIP 2"]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setModalState(() => type = val!),
                    decoration: const InputDecoration(
                      labelText: "Tipe",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffe21388),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final db = await DatabaseService.instance.database;
                  await db.update(
                    "ps_units",
                    {
                      "name": nameController.text,
                      "type": type,
                      "price_per_hour": int.parse(priceController.text),
                    },
                    where: "id = ?",
                    whereArgs: [unit["id"]],
                  );
                  if (mounted) {
                    Navigator.pop(context);
                    loadUnits();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF00E0C6),
                      content: Center(
                        child: Text(
                          'Unit berhasil diperbarui!',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                "Update",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddUnitForm() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String type = "REGULAR";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: const Color(0xff141c2f),
          title: const Text(
            "Tambah Unit Baru",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.30,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextField(nameController, "Nama Unit"),
                  _buildTextField(
                    priceController,
                    "Harga per Jam",
                    isNumber: true,
                    extraValidator: (v) {
                      final harga = int.tryParse(v!);
                      if (harga == null || harga <= 0) {
                        return "Harga harus lebih dari 0";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xff141c2f),
                    value: type,
                    style: const TextStyle(color: Colors.white),
                    items: ["REGULAR", "VIP 1", "VIP 2"]
                        .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                        .toList(),
                    onChanged: (val) => setModalState(() => type = val!),
                    decoration: const InputDecoration(
                      labelText: "Tipe",
                      labelStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffe21388),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final db = await DatabaseService.instance.database;
                  await db.insert("ps_units", {
                    "name": nameController.text,
                    "type": type,
                    "price_per_hour": int.parse(priceController.text),
                    "status": "idle",
                    "duration_seconds": 0,
                  });
                  if (mounted) {
                    Navigator.pop(context);
                    loadUnits();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      duration: Duration(seconds: 2),
                      backgroundColor: Color(0xFF00E0C6),
                      content: Center(
                        child: Text(
                          'Unit baru berhasil ditambahkan!',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }
              },
              child: const Text(
                "Simpan",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    String? Function(String?)? extraValidator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "Wajib diisi";
        if (extraValidator != null) return extraValidator(v);
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.only(top: 16, left: 20, right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  const Text(
                    "Manajemen Unit PS",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: const [
                      Text(
                        "GAMING",
                        style: TextStyle(
                          color: Color.fromRGBO(226, 19, 136, 100),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "X",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "CAFE",
                        style: TextStyle(
                          color: Color.fromRGBO(0, 224, 198, 100),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
                  ),
                  Divider(color: Colors.white10, thickness: 1, height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xffe21388),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: showAddUnitForm,
                      child: Text(
                        "Tambah Unit PS",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 16),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                    itemCount: units.length,
                    itemBuilder: (context, index) => unitCard(units[index]),
                  ),
                ],
              ),
            ),
    );
  }

  Widget unitCard(Map unit) {
    return GestureDetector(
      onTap: () => showEditUnitForm(Map<String, dynamic>.from(unit)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // CARD UTAMA
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xff1c273d),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unit["name"],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unit["type"],
                  style: const TextStyle(color: Colors.cyanAccent),
                ),
                const Spacer(),
                Text(
                  "Rp ${NumberFormat("#,###", "id_ID").format(unit["price_per_hour"])}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          // 🔥 MENU 3 TITIK
          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert,
                color: Colors.white70,
                size: 20,
              ),
              color: const Color(0xff1c273d),
              onSelected: (value) {
                if (value == 'edit') {
                  showEditUnitForm(Map<String, dynamic>.from(unit));
                  const SnackBar(
                    duration: Duration(seconds: 2),
                    backgroundColor: Color.fromRGBO(226, 19, 136, 100),
                    content: Center(
                      child: Text(
                        'Unit baru berhasil diperbaharui!',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  );
                } else if (value == 'delete') {
                  _confirmDeleteUnit(unit);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.amber, size: 18),
                      SizedBox(width: 8),
                      Text("Edit", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.redAccent, size: 18),
                      SizedBox(width: 8),
                      Text("Hapus", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteUnit(Map unit) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff141c2f),
        title: const Text("Hapus Unit?", style: TextStyle(color: Colors.white)),
        content: Text(
          "Yakin ingin menghapus ${unit["name"]}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              deleteUnit(unit["id"]);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF00E0C6),
                  content: Center(
                    child: Text(
                      'Unit berhasil dihapus!',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              "Hapus",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
