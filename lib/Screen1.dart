import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Page1 extends StatefulWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Karp\nPortal',
          textAlign: TextAlign.center,
          style: GoogleFonts.leagueScript(
              fontSize: 60, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
