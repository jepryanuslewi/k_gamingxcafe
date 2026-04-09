import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final String text;

  final Function(String)? onChanged; // Tambahkan parameter ini

  const SearchWidget({
    super.key,
    required this.text,

    this.onChanged, // Masukkan ke constructor
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            style: const TextStyle(color: Colors.white),
            onChanged: onChanged, // Hubungkan ke TextFormField
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromRGBO(
                44,
                54,
                75,
                1,
              ), // Perbaikan nilai opasitas
              hintText: text, // Gunakan hintText, bukan hint
              hintStyle: const TextStyle(color: Colors.white54, fontSize: 16),
              prefixIcon: const Icon(Icons.search, color: Colors.white54),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
