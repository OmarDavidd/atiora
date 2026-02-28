import 'package:flutter/material.dart';

class CustomStateWidget extends StatelessWidget {
  final Color color;
  final String text;
  const CustomStateWidget({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 30,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color, width: 2),
      ),

      child: Center(
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
