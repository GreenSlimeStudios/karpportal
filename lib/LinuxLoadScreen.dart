import 'package:flutter/material.dart';
import 'package:firedart/firedart.dart';
import 'package:karpportal/LoginScreen.dart';
import 'package:karpportal/preferences_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'InitUserScreen.dart';

class LinuxLoadPage extends StatefulWidget {
  const LinuxLoadPage({Key? key}) : super(key: key);

  @override
  State<LinuxLoadPage> createState() => _LinuxLoadPageState();
}

class _LinuxLoadPageState extends State<LinuxLoadPage> {
  @override
  Widget build(BuildContext context) {
    // initApp();
    return Scaffold(
      body: FloatingActionButton(onPressed: initApp),
    );
  }

  void initApp() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> logindetailstouse;

    if (await prefs.getStringList('logindetails') != null) {
      logindetailstouse = await prefs.getStringList('logindetails') as List<String>;

      // FirebaseAuth.initialize(
      //     'AIzaSyA151Up5KqDmbiKEub8g6WzwIOZZc4HgDA', await HiveStore.create());
      // await FirebaseAuth.instance
      //     .signIn(logindetailstouse[0], logindetailstouse[1]);
      // var user = await FirebaseAuth.instance.getUser();

      var firebaseAuth =
          FirebaseAuth('AIzaSyA151Up5KqDmbiKEub8g6WzwIOZZc4HgDA', await PreferencesStore.create());
      await firebaseAuth.signIn(logindetailstouse[0], logindetailstouse[1]);
      var user = await firebaseAuth.getUser();

      Navigator.push(await context, MaterialPageRoute(builder: (context) => InitUserPage()));
    } else {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => Text('bruh')));
    }
  }
}
