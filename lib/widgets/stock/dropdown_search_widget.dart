import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/cafe/bahan_model.dart';

class DropdownBahanWidget extends StatelessWidget {
  final String label;
  final List<Bahan> items;
  final Bahan? selectedItem;
  final bool isLoading;
  final Function(Bahan?) onSelected;

  const DropdownBahanWidget({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.isLoading,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<Bahan>(
      items: (filter, loadProps) => items,
      itemAsString: (Bahan b) => b.nama,
      selectedItem: selectedItem,
      compareFn: (item, selectedItem) => item.id == selectedItem.id,
      onSelected: onSelected,

      // --- PERBAIKAN: Builder untuk teks yang muncul di field utama ---
      dropdownBuilder: (context, selectedItem) {
        return Text(
          selectedItem?.nama ?? (isLoading ? "Loading..." : "Pilih bahan..."),
          style: const TextStyle(
            color: Colors.white, // Warna teks isi jadi putih
            fontSize: 14,
          ),
        );
      },

      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        constraints: const BoxConstraints(maxHeight: 350),
        menuProps: const MenuProps(
          backgroundColor: Color.fromRGBO(11, 18, 32, 1),
        ),
        searchFieldProps: TextFieldProps(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Cari bahan...",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color.fromRGBO(26, 37, 64, 1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        itemBuilder: (context, item, isSelected, isFocused) {
          return ListTile(
            title: Text(
              item.nama,
              style: const TextStyle(
                color: Colors.white,
              ), // Teks di dalam list juga putih
            ),
            subtitle: Text(
              "Stok: ${item.stokSaatIni} ${item.satuan}",
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          );
        },
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          // baseStyle di sini terkadang tidak mempan, maka kita gunakan dropdownBuilder di atas
          labelText: isLoading ? "Loading..." : "",
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color.fromRGBO(26, 37, 64, 1),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: label == "masuk"
                  ? Color.fromRGBO(0, 224, 198, 1)
                  : Colors.orangeAccent,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
