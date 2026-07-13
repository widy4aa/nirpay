import 'package:flutter/material.dart';

abstract class AppGradients {
  static const background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF4F7FB), Colors.white, Color(0xFFC7F4ED)],
  );
}
