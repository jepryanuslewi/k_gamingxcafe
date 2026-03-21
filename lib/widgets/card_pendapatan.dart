import 'package:flutter/material.dart';

class CardPendapatan extends StatelessWidget {
  final String text;
  final int total;
  const CardPendapatan({super.key, required this.text, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 15),
      height: 80,
      width: 250,
      decoration: BoxDecoration(
        color: Color.fromRGBO(20, 28, 47, 100),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color.fromRGBO(90, 88, 88, 100)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text
          Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          // Pendapatan
          Text(
            'Rp. ${total.toString()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
