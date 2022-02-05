// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final Widget? child;
  const CardWidget({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green[500],
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(child: child),
      ),
    );
  }
}
