// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  const CategoryButton({required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      height: 70.0,
      width: 100.0,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 20.0,
          ),
        ),
      ),
    );
  }
}
