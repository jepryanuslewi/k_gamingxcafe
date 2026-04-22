import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  const ButtonWidget({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.white10),
        ),
        backgroundColor: Color.fromRGBO(26, 37, 64, 100),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          color: Color.fromRGBO(0, 224, 198, 100),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
