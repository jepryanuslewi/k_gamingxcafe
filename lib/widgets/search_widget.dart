import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  const SearchWidget({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: Color.fromRGBO(44, 54, 75, 100),
              hint: Text(
                text,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Color.fromRGBO(44, 54, 75, 100),
            ),
            onPressed: onPressed,
            child: Icon(Icons.search, color: Colors.white, size: 35),
          ),
        ),
      ],
    );
  }
}
