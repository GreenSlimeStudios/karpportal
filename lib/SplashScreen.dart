import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karpportal/HomeScreen.dart';
import 'package:karpportal/InitUserScreen.dart';
import 'package:karpportal/LoginScreen.dart';
import 'package:karpportal/Screen1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    changeScreen();
    return Scaffold(
      body: Center(
        child: Text(
          'Karp\nPortal',
          textAlign: TextAlign.center,
          // style: GoogleFonts.leagueScript(
          //     fontSize: 60, fontWeight: FontWeight.bold),
          style: TextStyle(
              fontFamily: 'LeagueScript',
              fontSize: 60,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void changeScreen() async {
    final _auth = FirebaseAuth.instance;

    //WidgetsFlutterBinding.ensureInitialized();
    List<String> logindetailstouse;

    final prefs = await SharedPreferences.getInstance();

    if (await prefs.getStringList('logindetails') != null) {
      logindetailstouse =
          await prefs.getStringList('logindetails') as List<String>;

      try {
        _auth.signInWithEmailAndPassword(
            email: logindetailstouse[0], password: logindetailstouse[1]);

        Navigator.push(await context,
            MaterialPageRoute(builder: (context) => InitUserPage()));
      } on FirebaseAuthException catch (error) {
        Navigator.push(await context,
            MaterialPageRoute(builder: (context) => LoginPage()));
      }
    } else {
      Navigator.push(
          await context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
