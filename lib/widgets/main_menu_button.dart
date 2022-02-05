// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class MainMenuButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  const MainMenuButton({required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: 300.0,
      height: 70.0,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
