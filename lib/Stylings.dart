import 'package:flutter/material.dart';
import 'globals.dart' as globals;

OutlineInputBorder focusedRoundBorder() {
  return OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
    borderSide: BorderSide(color: globals.primarySwatch!, width: 3),
  );
}

OutlineInputBorder inactiveRoundBorder() {
  return OutlineInputBorder(
    borderRadius: const BorderRadius.all(Radius.circular(15.0)),
    borderSide: BorderSide(color: Colors.grey, width: 3),
  );
}

UnderlineInputBorder focusedUnderlineBorder() {
  return UnderlineInputBorder(
    borderSide: BorderSide(color: globals.primarySwatch!, width: 2),
  );
}
