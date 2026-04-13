import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../../models/cafe/menu_model.dart';

class DropdownMenuWidget extends StatelessWidget {
  final List<MenuModel> items;
  final MenuModel? selectedItem;
  final bool isLoading;
  final Function(MenuModel?) onSelected;

  const DropdownMenuWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.isLoading,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<MenuModel>(
      items: (filter, loadProps) => items,
      itemAsString: (MenuModel m) => m.nama,
      selectedItem: selectedItem,
      compareFn: (item, selectedItem) => item.id == selectedItem.id,
      onSelected: onSelected,

      // Tampilan di field utama saat item dipilih
      dropdownBuilder: (context, selectedItem) {
        return Text(
          selectedItem?.nama ?? (isLoading ? "Loading..." : "Pilih Menu..."),
          style: const TextStyle(color: Colors.white, fontSize: 14),
        );
      },

      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        constraints: const BoxConstraints(maxHeight: 350),
        listViewProps: const ListViewProps(
          shrinkWrap: true,
        ),
        menuProps: const MenuProps(
          backgroundColor: Color.fromRGBO(11, 18, 32, 1),
        ),
        searchFieldProps: TextFieldProps(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Cari menu...",
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color.fromRGBO(26, 37, 64, 1),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        // Tampilan list item di dalam popup
        itemBuilder: (context, item, isSelected, isFocused) {
          return ListTile(
            title: Text(item.nama, style: const TextStyle(color: Colors.white)),
            subtitle: Text(
              "Harga: Rp ${item.harga} | Stok: ${item.stok}",
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            trailing: Text(
              item.kategori ?? "-",
              style: const TextStyle(color: Color(0xFF00E0C6), fontSize: 10),
            ),
          );
        },
      ),
      decoratorProps: DropDownDecoratorProps(
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color.fromRGBO(26, 37, 64, 1),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Color(0xFF00E0C6), width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
