import 'package:flutter/material.dart';

class Palette {
  static var text = const Color.fromARGB(255, 14, 6, 6);
  static var background = const Color.fromARGB(255, 253, 252, 252);
  static var primary = const Color.fromARGB(255, 197, 73, 75);
  static var secondary = const Color.fromARGB(255, 224, 133, 135);
  static var accent = const Color.fromARGB(255, 222, 94, 96);

  static Color getBackground() {
    return background;
  }

  static Color getText() {
    return text;
  }


  static Color getPrimary() {
    return primary;
  }

  static Color getSecondary() {
    return secondary;
  }

   static Color getAccent() {
    return accent;
  }

}
