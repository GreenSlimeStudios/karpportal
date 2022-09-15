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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/karpportallogofinal.png', height: 120, width: 120),
                SizedBox(height: 8),
              ],
            ),
            SizedBox(width: 20),
            Hero(
              tag: 'karpPortal',
              child: Card(
                color: Colors.transparent,
                elevation: 0,
                margin: EdgeInsets.zero,
                child: Text(
                  'Karp\nPortal',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.leagueScript(fontSize: 50, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
