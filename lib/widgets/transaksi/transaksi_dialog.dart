import 'package:flutter/material.dart';
import 'package:k_gamingxcafe/models/cafe/menu_model.dart';
import 'package:k_gamingxcafe/providers/cafe/menu_provider.dart';
import 'package:k_gamingxcafe/widgets/transaksi/dropdown_menu_widget.dart';
import 'package:provider/provider.dart';

class TransactionDialog {
  static void show(BuildContext context, {required String shiftName}) {
    List<Map<String, dynamic>> items = [
      {'selectedProduk': null, 'qty': 0},
    ];

    // ✅ error state di luar builder (biar tidak reset)
    String? errorMessage;

    context.read<MenuProvider>().fetchMenu();
    int getSisaStok(List<Map<String, dynamic>> items, MenuModel product) {
      int totalDipakai = 0;

      for (var item in items) {
        final MenuModel? p = item['selectedProduk'];
        if (p != null && p.id == product.id) {
          totalDipakai += item['qty'] as int;
        }
      }

      return (product.stok ?? 0) - totalDipakai;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final menuProv = context.watch<MenuProvider>();

            return AlertDialog(
              backgroundColor: const Color.fromRGBO(11, 18, 32, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(color: Colors.white10),
              ),
              contentPadding: const EdgeInsets.all(20),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/images/bgLoginScreen.png", height: 60),
                    const SizedBox(height: 10),
                    const Text(
                      "TRANSAKSI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const Divider(color: Colors.white24, height: 30),
                    // ✅ ERROR MESSAGE DALAM DIALOG
                    if (errorMessage != null)
                      Container(
                        width: 300,
                        padding: const EdgeInsets.all(5),
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    Flexible(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 15,
                          runSpacing: 15,
                          alignment: WrapAlignment.center,
                          children: items.asMap().entries.map((entry) {
                            int index = entry.key;
                            var item = entry.value;

                            return KeyedSubtree(
                              key: ValueKey("item_$index"),
                              child: _buildProductCard(
                                context: context,
                                produk: item['selectedProduk'],
                                qty: item['qty'],
                                menuList: menuProv.listMenu,
                                isLoading: menuProv.isLoading,
                                onProdukChanged: (val) {
                                  final MenuModel? menu = val as MenuModel?;

                                  if (menu != null) {
                                    int sisaStok = getSisaStok(items, menu);

                                    if (sisaStok <= 0) {
                                      setState(() {
                                        errorMessage =
                                            "${menu.nama} stok habis di transaksi ini!";
                                      });
                                      return;
                                    }
                                  }

                                  setState(() {
                                    items[index]['selectedProduk'] = val;
                                    errorMessage = null;
                                  });
                                },
                                onQtyChanged: (newQty) {
                                  final MenuModel? p = item['selectedProduk'];

                                  if (p != null) {
                                    int sisaStok = getSisaStok(items, p);

                                    // Tambahkan kembali qty lama item ini (biar tidak double hitung)
                                    sisaStok += item['qty'] as int;

                                    if (newQty > sisaStok) {
                                      setState(() {
                                        errorMessage =
                                            "Stok ${p.nama} tidak cukup!\nSisa: $sisaStok";
                                      });
                                      return;
                                    }
                                  }

                                  if (newQty >= 0) {
                                    setState(() {
                                      items[index]['qty'] = newQty;
                                      errorMessage = null;
                                    });
                                  }
                                },
                                onRemove: () {
                                  if (items.length > 1) {
                                    setState(() {
                                      items.removeAt(index);
                                      errorMessage = null;
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ➕ Tambah item
                    InkWell(
                      onTap: () {
                        setState(() {
                          items.add({'selectedProduk': null, 'qty': 0});
                          errorMessage = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Color(0xFF00E0C6),
                          size: 30,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(flex: 3, child: _buildTotalInput(items)),
                        const SizedBox(width: 15),
                        _buildButton(
                          label: "BATAL",
                          color: const Color(0xFFD81B72),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        _buildButton(
                          label: "SIMPAN",
                          color: const Color(0xFF00E0C6),
                          textColor: const Color.fromRGBO(11, 18, 32, 1),
                          onPressed: () async {
                            for (var item in items) {
                              final MenuModel? p = item['selectedProduk'];
                              final int qty = item['qty'] as int;

                              if (p == null || qty <= 0) continue;

                              if (qty > (p.stok ?? 0)) {
                                setState(() {
                                  errorMessage =
                                      "Stok ${p.nama} tidak cukup!\n"
                                      "Diminta: $qty, Tersedia: ${p.stok ?? 0}";
                                });
                                return;
                              }
                            }

                            num totalAkhir = items.fold<num>(0, (sum, item) {
                              final MenuModel? p = item['selectedProduk'];
                              return sum +
                                  ((p?.harga ?? 0) * (item['qty'] as int));
                            });

                            if (totalAkhir <= 0) return;

                            bool sukses = await context
                                .read<MenuProvider>()
                                .simpanTransaksi(items, totalAkhir, shiftName);

                            if (sukses && context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  backgroundColor: Colors.green,
                                  content: Text("Transaksi Berhasil!"),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildProductCard({
    required BuildContext context,
    required dynamic produk,
    required int qty,
    required List<MenuModel> menuList,
    required bool isLoading,
    required Function(dynamic) onProdukChanged,
    required Function(int) onQtyChanged,
    required VoidCallback onRemove,
  }) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(20, 28, 47, 1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.fastfood, color: Colors.white38, size: 18),
              GestureDetector(
                onTap: onRemove,
                child: const Icon(
                  Icons.close,
                  color: Colors.redAccent,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownMenuWidget(
            items: menuList,
            selectedItem: produk,
            isLoading: isLoading,
            onSelected: onProdukChanged,
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.remove_circle_outline,
                  color: Color(0xFF00E0C6),
                ),
                onPressed: () => onQtyChanged(qty - 1),
              ),
              Text(
                "$qty",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.add_circle_outline,
                  color: Color(0xFF00E0C6),
                ),
                onPressed: () => onQtyChanged(qty + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildTotalInput(List<Map<String, dynamic>> items) {
    num total = items.fold<num>(0, (sum, item) {
      final MenuModel? p = item['selectedProduk'];
      final int q = item['qty'] as int;
      return sum + ((p?.harga ?? 0) * q);
    });

    return TextField(
      readOnly: true,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        hintText: "Total: Rp ${total.toInt()}",
        hintStyle: const TextStyle(color: Color(0xFF00E0C6), fontSize: 16),
        filled: true,
        fillColor: const Color.fromRGBO(20, 28, 47, 1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
      ),
    );
  }

  static Widget _buildButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
    Color textColor = Colors.white,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
      ),
    );
  }
}
