import 'package:flutter/material.dart';

class MyMediaQuery {
  final BuildContext context;

  MyMediaQuery(this.context);

  double get screenWidth => MediaQuery.of(context).size.width;
  double get screenHeight => MediaQuery.of(context).size.height;
  double get bottomviewinsens => MediaQuery.of(context).viewInsets.bottom;

}