import 'package:flutter/material.dart';
import 'package:nhentai/support/ShapesPainter.dart';
import 'dart:math' as math;

class TriangleBackgroundWidget extends StatelessWidget {
  final double width;
  final double height;
  final Color color;
  final EdgeInsetsGeometry padding;
  final Widget child;

  TriangleBackgroundWidget(
      {Key? key,
      required this.width,
      required this.height,
      required this.color,
      required this.padding,
      required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: ShapesPainter(color),
        child: Container(
            padding: padding,
            height: height,
            width: width,
            child: Stack(
              alignment: Alignment.topRight,
              children: [Transform.rotate(angle: math.pi / 4), child],
            )));
  }
}
