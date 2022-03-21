import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karpportal/HomeScreen.dart';
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
    User? user = FirebaseAuth.instance.currentUser;
    UserModel loggedInUser = UserModel();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then(
      (value) {
        loggedInUser = UserModel.fromMap(value.data());
        globals.myUser = loggedInUser;
        print('//////////////////////////////////////////////////');
        print(globals.myUser!.toMap());
        print('////////////////////////////////////////////////');

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
