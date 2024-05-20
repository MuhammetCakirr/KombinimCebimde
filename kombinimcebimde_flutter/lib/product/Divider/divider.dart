import 'package:flutter/material.dart';

class MyDivider extends StatelessWidget {
  final double height;
  final double thickness;
  final Color color;

  const MyDivider({Key? key, required this.height, required this.color, required this.thickness}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: height,
      color: color,
      thickness: thickness,
    );
  }
}