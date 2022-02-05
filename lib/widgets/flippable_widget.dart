// ignore_for_file: use_key_in_widget_constructors

import 'dart:math';

import 'package:flutter/material.dart';

class FlippableWidget extends StatefulWidget {
  final Widget? front;
  final Widget? back;
  final Duration duration;

  const FlippableWidget({this.front, this.back, required this.duration});

  @override
  State<FlippableWidget> createState() => _FlippableWidgetState();
}

class _FlippableWidgetState extends State<FlippableWidget>
    with TickerProviderStateMixin {
  bool isFront = true;
  double rotation = 0;
  late AnimationController toHalfController;
  late AnimationController fromHalfController;
  late Animation<double> animToHalf =
      Tween<double>(begin: 0, end: -90).animate(toHalfController);
  late Animation<double> animFromHalf =
      Tween<double>(begin: 90, end: 0).animate(fromHalfController);
  late Widget? currentChild;

  @override
  void initState() {
    super.initState();
    _initAnims();
    currentChild = widget.front;
  }

  @override
  Widget build(BuildContext context) {
    if (currentChild != widget.front && currentChild != widget.back) {
      currentChild = widget.front;
    }
    return GestureDetector(
      onTap: _onTap,
      child: Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(rotation / 180 * pi),
          alignment: Alignment.center,
          child: currentChild),
    );
  }

  void _onTap() {
    toHalfController.forward();
  }

  _initAnims() {
    toHalfController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    fromHalfController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    animToHalf.addListener(
      () {
        setState(
          () {
            rotation = animToHalf.value;
          },
        );
      },
    );

    animToHalf.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          fromHalfController.forward();
          currentChild =
              currentChild == widget.front ? widget.back : widget.front;
        }
      },
    );

    animFromHalf.addListener(
      () {
        setState(
          () {
            rotation = animFromHalf.value;
          },
        );
      },
    );

    animFromHalf.addStatusListener(
      (status) {
        if (status == AnimationStatus.completed) {
          fromHalfController.reset();
          toHalfController.reset();
        }
      },
    );
  }
}
