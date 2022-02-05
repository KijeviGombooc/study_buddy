// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class CardText extends StatelessWidget {
  final String text;

  const CardText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.justify,
      style: const TextStyle(fontSize: 24),
    );
  }
}
