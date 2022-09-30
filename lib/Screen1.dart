import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globals.dart' as globals;

class Page1 extends StatefulWidget {
  const Page1({Key? key}) : super(key: key);

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(onPressed: () {
      //   setState(() => {});
      // }),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                getLogo(),
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

Widget getLogo() {
  if (globals.primaryColor.toString == Colors.orange.toString()) {
    return Image.asset('assets/karpportallogofinal.png', height: 120, width: 120);
  }
  if (globals.primaryColor.toString == Colors.deepOrange.toString()) {
    return Image.asset('assets/karpportallogofinal.png', height: 120, width: 120);
  }
  if (globals.primaryColor.toString == Colors.lime.toString()) {
    return Image.asset('assets/karpportallogofinal.png', height: 120, width: 120);
  }
  if (globals.primaryColor.toString == Colors.cyan.toString()) {
    return Image.asset('assets/karpportallogofinal_blue.png', height: 120, width: 120);
  }
  if (globals.primaryColor.toString == Colors.blue.toString()) {
    return Image.asset('assets/karpportallogofinal_blue.png', height: 120, width: 120);
  }
  if (globals.primaryColor.toString == Colors.indigo.toString()) {
    return Image.asset('assets/karpportallogofinal_purple.png', height: 120, width: 120);
  }
  if (globals.primaryColor.toString == Colors.deepPurple.toString()) {
    return Image.asset('assets/karpportallogofinal_purple.png', height: 120, width: 120);
  }
  if (globals.primaryColor.toString == Colors.purple.toString()) {
    return Image.asset('assets/karpportallogofinal_purple.png', height: 120, width: 120);
  }
  if (globals.primaryColor.toString == Colors.pink.toString()) {
    return Image.asset('assets/karpportallogofinal_pink.png', height: 120, width: 120);
  }
  return Image.asset('assets/karpportallogofinal.png', height: 120, width: 120);
}
