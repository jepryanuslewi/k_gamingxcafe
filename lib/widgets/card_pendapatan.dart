import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CardPendapatan extends StatelessWidget {
  final String text;
  final int total;
  const CardPendapatan({super.key, required this.text, required this.total});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 15),
      height: height * 0.15,
      decoration: BoxDecoration(
        color: Color.fromRGBO(20, 28, 47, 100),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white),
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
            "Rp. ${NumberFormat("#,###", "id_ID").format(total)}",
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
