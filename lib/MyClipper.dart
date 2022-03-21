import 'package:flutter/material.dart';

class MyClipper extends CustomClipper<Rect> {
  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, 55, 55);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    // TODO: implement shouldReclip
    throw UnimplementedError();
  }
}
