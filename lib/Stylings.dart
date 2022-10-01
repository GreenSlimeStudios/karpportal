import 'package:flutter/material.dart';
import 'package:karpportal/enums.dart';
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

Widget getKarpportalLogo() {
  if (globals.primaryColorID == AccentColor.Orange) {
    return Image.asset('assets/karpportallogofinal.png', height: 120, width: 120);
  }
  if (globals.primaryColorID == AccentColor.DeepOrange) {
    return Image.asset('assets/karpportallogofinal.png', height: 120, width: 120);
  }
  if (globals.primaryColorID == AccentColor.Lime) {
    return Image.asset('assets/karpportallogofinal.png', height: 120, width: 120);
  }
  if (globals.primaryColorID == AccentColor.Cyan) {
    return Image.asset('assets/karpportallogofinal_blue.png', height: 120, width: 120);
  }
  if (globals.primaryColorID == AccentColor.Blue) {
    return Image.asset('assets/karpportallogofinal_blue.png', height: 120, width: 120);
  }
  if (globals.primaryColorID == AccentColor.Indigo) {
    return Image.asset('assets/karpportallogofinal_purple.png', height: 120, width: 120);
  }
  if (globals.primaryColorID == AccentColor.DeepPurple) {
    return Image.asset('assets/karpportallogofinal_purple.png', height: 120, width: 120);
  }
  if (globals.primaryColorID == AccentColor.Purple) {
    return Image.asset('assets/karpportallogofinal_purple.png', height: 120, width: 120);
  }
  if (globals.primaryColorID == AccentColor.Pink) {
    return Image.asset('assets/karpportallogofinal_pink.png', height: 120, width: 120);
  }
  return Image.asset('assets/karpportallogofinal.png', height: 120, width: 120);
}

String getKarpportalLogoPath() {
  if (globals.primaryColorID == AccentColor.Orange) {
    return 'assets/karpportallogofinal.png';
  }
  if (globals.primaryColorID == AccentColor.DeepOrange) {
    return 'assets/karpportallogofinal.png';
  }
  if (globals.primaryColorID == AccentColor.Lime) {
    return 'assets/karpportallogofinal.png';
  }
  if (globals.primaryColorID == AccentColor.Cyan) {
    return 'assets/karpportallogofinal_blue.png';
  }
  if (globals.primaryColorID == AccentColor.Blue) {
    return 'assets/karpportallogofinal_blue.png';
  }
  if (globals.primaryColorID == AccentColor.Indigo) {
    return 'assets/karpportallogofinal_purple.png';
  }
  if (globals.primaryColorID == AccentColor.DeepPurple) {
    return 'assets/karpportallogofinal_purple.png';
  }
  if (globals.primaryColorID == AccentColor.Purple) {
    return 'assets/karpportallogofinal_purple.png';
  }
  if (globals.primaryColorID == AccentColor.Pink) {
    return 'assets/karpportallogofinal_pink.png';
  }
  return 'assets/karpportallogofinal.png';
}
