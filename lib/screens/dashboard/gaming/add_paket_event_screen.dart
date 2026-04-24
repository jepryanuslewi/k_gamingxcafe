import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/services/database_service.dart';

class AddPaketEventScreen extends StatefulWidget {
  const AddPaketEventScreen({super.key});

  @override
  State<AddPaketEventScreen> createState() => _AddPaketEventScreenState();
}

class _AddPaketEventScreenState extends State<AddPaketEventScreen> {
  List<Map<String, dynamic>> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPackages();
  }

  Future<void> loadPackages() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final db = await DatabaseService.instance.database;
    final data = await db.query("packages", orderBy: "price ASC");

    if (mounted) {
      setState(() {
        packages = data;
        isLoading = false;
      });
    }
  }

  Future<void> deletePackage(int id) async {
    final db = await DatabaseService.instance.database;
    // Hapus juga relasi menu event sebelum hapus paket
    await db.delete("package_menus", where: "package_id = ?", whereArgs: [id]);
    await db.delete("packages", where: "id = ?", whereArgs: [id]);
    loadPackages();
  }

  // ─────────────────────────────────────────────
  //  FORM TAMBAH PAKET
  // ─────────────────────────────────────────────
  void showAddPackageForm() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Daftar menu yang dipilih untuk paket ini: [{menu_id, qty: controller}]
    List<Map<String, dynamic>> menuInput = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildPackageDialog(
            title: "Tambah Paket Event",
            nameController: nameController,
            priceController: priceController,
            durationController: durationController,
            formKey: formKey,
            menuInput: menuInput,
            setModalState: setModalState,
            accentColor: const Color(0xffe21388),
            saveLabel: "Simpan",
            onSave: () async {
              if (formKey.currentState!.validate()) {
                final db = await DatabaseService.instance.database;

                // 1. Insert paket
                final packageId = await db.insert("packages", {
                  "name": nameController.text,
                  "price": int.parse(priceController.text),
                  "duration_hours": int.parse(durationController.text),
                });

                // 2. Insert relasi menu paket
                for (final item in menuInput) {
                  if (item["menu_id"] != null) {
                    final qty =
                        int.tryParse(
                          (item["qty"] as TextEditingController).text,
                        ) ??
                        1;
                    await db.insert("package_menus", {
                      "package_id": packageId,
                      "menu_id": item["menu_id"],
                      "qty": qty,
                    });
                  }
                }

                if (mounted) {
                  Navigator.pop(context);
                  loadPackages();
                }
              }
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FORM EDIT PAKET
  // ─────────────────────────────────────────────
  void showEditPackageForm(Map<String, dynamic> pkg) async {
    final nameController = TextEditingController(text: pkg["name"]);
    final priceController = TextEditingController(
      text: pkg["price"].toString(),
    );
    final durationController = TextEditingController(
      text: pkg["duration_hours"].toString(),
    );
    final formKey = GlobalKey<FormState>();

    // Ambil menu yang sudah ada di paket ini
    final db = await DatabaseService.instance.database;
    final existingMenus = await db.query(
      "package_menus",
      where: "package_id = ?",
      whereArgs: [pkg["id"]],
    );

    List<Map<String, dynamic>> menuInput = existingMenus.map((row) {
      return {
        "menu_id": row["menu_id"],
        "qty": TextEditingController(text: row["qty"].toString()),
      };
    }).toList();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return _buildPackageDialog(
            title: "Edit Paket: ${pkg['name']}",
            nameController: nameController,
            priceController: priceController,
            durationController: durationController,
            formKey: formKey,
            menuInput: menuInput,
            setModalState: setModalState,
            accentColor: Colors.amber,
            saveLabel: "Update",
            onSave: () async {
              if (formKey.currentState!.validate()) {
                // 1. Update data paket
                await db.update(
                  "packages",
                  {
                    "name": nameController.text,
                    "price": int.parse(priceController.text),
                    "duration_hours": int.parse(durationController.text),
                  },
                  where: "id = ?",
                  whereArgs: [pkg["id"]],
                );

                // 2. Hapus relasi menu lama lalu insert ulang
                await db.delete(
                  "package_menus",
                  where: "package_id = ?",
                  whereArgs: [pkg["id"]],
                );
                for (final item in menuInput) {
                  if (item["menu_id"] != null) {
                    final qty =
                        int.tryParse(
                          (item["qty"] as TextEditingController).text,
                        ) ??
                        1;
                    await db.insert("package_menus", {
                      "package_id": pkg["id"],
                      "menu_id": item["menu_id"],
                      "qty": qty,
                    });
                  }
                }

                if (mounted) {
                  Navigator.pop(context);
                  loadPackages();
                }
              }
            },
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  WIDGET DIALOG (digunakan Add & Edit)
  // ─────────────────────────────────────────────
  Widget _buildPackageDialog({
    required String title,
    required TextEditingController nameController,
    required TextEditingController priceController,
    required TextEditingController durationController,
    required GlobalKey<FormState> formKey,
    required List<Map<String, dynamic>> menuInput,
    required StateSetter setModalState,
    required Color accentColor,
    required String saveLabel,
    required VoidCallback onSave,
  }) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      // Ambil daftar menu cafe dari database
      future: DatabaseService.instance.database.then(
        (db) => db.query("menu", orderBy: "nama ASC"),
      ),
      builder: (context, snapshot) {
        final listMenu = snapshot.data ?? [];

        return AlertDialog(
          backgroundColor: const Color(0xff141c2f),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.40,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Info Paket ──
                    _formField(nameController, "Nama Paket"),
                    _formField(
                      durationController,
                      "Durasi (Jam)",
                      isNumber: true,
                    ),
                    _formField(priceController, "Harga Paket", isNumber: true),

                    const SizedBox(height: 24),

                    // ── Header Menu Paket ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Menu Dalam Paket",
                          style: TextStyle(
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setModalState(() {
                              menuInput.add({
                                "menu_id": null,
                                "qty": TextEditingController(text: "1"),
                              });
                            });
                          },
                          icon: Icon(Icons.add_circle, color: accentColor),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white24),

                    if (menuInput.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          "Belum ada menu dalam paket",
                          style: TextStyle(color: Colors.white30, fontSize: 12),
                        ),
                      ),

                    // ── List Menu Dinamis ──
                    ...menuInput.asMap().entries.map((entry) {
                      final index = entry.key;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            // Dropdown pilih menu
                            Expanded(
                              flex: 3,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<int>(
                                  isExpanded: true,
                                  dropdownColor: const Color(0xff141c2f),
                                  hint: const Text(
                                    "Pilih Menu",
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  value: menuInput[index]["menu_id"],
                                  items: listMenu.map((m) {
                                    return DropdownMenuItem<int>(
                                      value: m["id"] as int,
                                      child: Text(
                                        "${m["nama"]}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) => setModalState(
                                    () => menuInput[index]["menu_id"] = val,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Input qty
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: menuInput[index]["qty"],
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Qty",
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  isDense: true,
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.white24,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              onPressed: () => setModalState(
                                () => menuInput.removeAt(index),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
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
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: onSave,
              child: Text(
                saveLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _formField(
    TextEditingController ctrl,
    String label, {
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
      ),
      validator: (v) => v!.isEmpty ? "Wajib diisi" : null,
    );
  }

  // ─────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0b1220),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffe21388),
        onPressed: showAddPackageForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : packages.isEmpty
          ? const Center(
              child: Text(
                "Belum ada paket",
                style: TextStyle(color: Colors.white54),
              ),
            )
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
                  SizedBox(height: 10),
                  ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: packages.length,
                    itemBuilder: (context, index) {
                      final pkg = packages[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: const Color(0xff1c273d),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white10),
                        ),
                        child: ListTile(
                          leading: const Icon(
                            Icons.confirmation_number,
                            color: Color(0xffe21388),
                          ),
                          title: Text(
                            pkg["name"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "${pkg["duration_hours"]} Jam • Rp ${pkg["price"]}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: PopupMenuButton<String>(
                            color: const Color(0xff1c273d),
                            onSelected: (val) {
                              if (val == 'edit')
                                showEditPackageForm(pkg);
                              else if (val == 'delete')
                                deletePackage(pkg["id"]);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text(
                                  "Edit",
                                  style: TextStyle(color: Colors.greenAccent),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  "Hapus",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
