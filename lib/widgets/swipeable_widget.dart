// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class SwipeableWidget extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final void Function()? onSwipedLeft;
  final void Function()? onSwipedRight;
  final void Function()? onSwipedUp;
  final void Function()? onPreSwipe;

  const SwipeableWidget({
    required this.child,
    required this.animationDuration,
    this.onSwipedLeft,
    this.onSwipedRight,
    this.onSwipedUp,
    this.onPreSwipe,
  });

  @override
  State<SwipeableWidget> createState() => _SwipeableWidgetState();
}

class _SwipeableWidgetState extends State<SwipeableWidget> {
  Offset offset = Offset.zero;
  bool animate = false;
  double rotation = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onDragStart,
      onPanUpdate: _onDragUpdate,
      onPanEnd: _onDragEnd,
      child: Stack(
        children: widget.child == null
            ? []
            : [
                AnimatedPositioned(
                  onEnd: _onAnimEnd,
                  left: offset.dx,
                  right: -offset.dx,
                  bottom: -offset.dy,
                  top: offset.dy,
                  duration: animate ? widget.animationDuration : Duration.zero,
                  child: AnimatedRotation(
                      duration:
                          animate ? widget.animationDuration : Duration.zero,
                      turns: rotation,
                      child: widget.child as Widget),
                ),
              ],
      ),
    );
  }

  void _onDragStart(DragStartDetails details) {}

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      animate = false;
      offset += details.delta;
      rotation = -offset.dx * 0.0001;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isVelocityBig(details.velocity) || _isOffsetBig(offset)) {
      _swipeAway();
    } else {
      _resetOffset(true);
    }
  }

  void _onAnimEnd() {
    if (_isSwiped()) {
      if (offset.dx < 0) {
        widget.onSwipedLeft?.call();
      } else {
        widget.onSwipedRight?.call();
      }
      _resetOffset(false);
    }
  }

  void _swipeAway() {
    setState(() {
      animate = true;
      double screenWidth = MediaQuery.of(context).size.width;
      offset = offset / offset.distance * screenWidth * 2;
      widget.onPreSwipe?.call();
    });
  }

  void _resetOffset(bool animated) {
    setState(() {
      animate = animated;
      offset = Offset.zero;
      rotation = 0;
    });
  }

  bool _isSwiped() {
    return animate && offset != Offset.zero;
  }

  bool _isVelocityBig(Velocity velocity) {
    double velX = _getXVelocity(velocity);
    return velX < -1000 || 1000 < velX;
  }

  bool _isOffsetBig(Offset offset) {
    double width = MediaQuery.of(context).size.width;
    return offset.dx < -width * 0.25 || width * 0.25 < offset.dx;
  }

  double _getXVelocity(Velocity velocity) {
    final intInStr = RegExp(r"-?[0-9]+.[0-9]+");
    final velString = velocity.toString();
    final velArray = intInStr.allMatches(velString).map((m) => m.group(0));
    return double.parse(velArray.first as String);
  }
}
