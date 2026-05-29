import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Function()? onTap;
  const CardButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 15),
        height: height * 0.10,
        decoration: BoxDecoration(
          color: Color.fromRGBO(26, 37, 64, 100),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon
            Icon(icon, color: Color.fromRGBO(0, 224, 198, 100), size: 40),
            SizedBox(width: 10),
            // Text
            Text(
              text,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(0, 224, 198, 100),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
