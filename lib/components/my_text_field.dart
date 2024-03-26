// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:okeys/colors.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final int? maxLength;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.obscureText,
    this.maxLength,
  }) : super(key: key);

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  bool _showHint = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: widget.obscureText,
      style: TextStyle(color: Palette.text),
      onChanged: (value) {
        setState(() {
          _showHint = value.isEmpty;
        });
      },
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Palette.text, width: 1.5),
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Palette.primary),
          borderRadius: BorderRadius.circular(20.0),
        ),
        fillColor: Palette.background,
        filled: true,
        hintText: _showHint ? widget.hintText : '',
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(widget.icon, color: Palette.text),
      ),
    );
  }
}
