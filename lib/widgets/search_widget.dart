import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final String text;

  final Function(String)? onChanged;

  const SearchWidget({super.key, required this.text, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            style: const TextStyle(color: Colors.white),
            onChanged: onChanged,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromRGBO(44, 54, 75, 1),
              hintText: text,
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
