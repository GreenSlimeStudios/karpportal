import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karpportal/HomeScreen.dart';
import 'package:karpportal/LoginScreen.dart';
import 'package:karpportal/UserModel.dart';
import 'globals.dart' as globals;

class InitUserPage extends StatefulWidget {
  const InitUserPage({Key? key}) : super(key: key);

  @override
  State<InitUserPage> createState() => _InitUserPageState();
}

class _InitUserPageState extends State<InitUserPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    makeUserGlobal();
  }

  makeUserGlobal() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      UserModel loggedInUser = UserModel();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get()
          .then(
        (value) async {
          loggedInUser = UserModel.fromMap(value.data());
          globals.myUser = loggedInUser;
          print('//////////////////////////////////////////////////');
          print(globals.myUser!.toMap());
          print('HEY!!!!!!!!!!!!');
          print('////////////////////////////////////////////////');

          //User? authUser = await FirebaseAuth.instance.currentUser;
          globals.authUser = user;
          await Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
          goToHomePage();
        },
      );
    } on FirebaseAuthException {
      await Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
      goToLoginPage();
    }
  }

  goToLoginPage() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
    goToLoginPage();
  }

  goToHomePage() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
    goToHomePage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Hero(
            tag: 'karpPortal',
            child: Card(
              color: Colors.transparent,
              elevation: 0,
              margin: EdgeInsets.zero,
              child: Text(
                'Karp\nPortal',
                textAlign: TextAlign.center,
                style: GoogleFonts.leagueScript(
                    fontSize: 60, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Text(
            'logging in ...',
            // style: TextStyle(color: Colors.black),
          ),
          Padding(
              padding: EdgeInsets.only(left: 20, top: 5, right: 20),
              child: LinearProgressIndicator())
        ]),
      ),
    );
  }
}
