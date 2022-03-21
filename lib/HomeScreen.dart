import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karpportal/ChatScreen.dart';
import 'package:karpportal/MessagesScreen.dart';
import 'package:karpportal/ProfileScreen.dart';
import 'package:karpportal/Screen1.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karpportal/SearchScreen.dart';
import 'package:karpportal/UserModel.dart';

import 'globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

//int _index = 2;

class _HomePageState extends State<HomePage> {
  var screens = [Page1(), SearchPage(), Page1(), MessagesPage(), ProfilePage()];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //makeUserGlobal();
  }

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  makeUserGlobal() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then(
      (value) {
        loggedInUser = UserModel.fromMap(value.data());
        globals.myUser = loggedInUser;

        setState(() {});
      },
    );
  }

  refresh() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then(
      (value) {
        loggedInUser = UserModel.fromMap(value.data());
        globals.myUser = loggedInUser;

        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: refresh,
            icon: Icon(Icons.refresh),
          )
        ],
        title: Text(
          'Karp Portal',
          textAlign: TextAlign.center,
          style: GoogleFonts.leagueScript(
              fontSize: 22, fontWeight: FontWeight.bold),
        ),
        foregroundColor: Colors.white,
      ),
      //drawerScrimColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              child: Center(child: setIcon()),
              decoration: BoxDecoration(color: Colors.orange),
            ),
            ListTile(
                title: Container(
                  child: Row(
                    children: [
                      Padding(padding: EdgeInsets.only(right: 10)),
                      Icon(
                        Icons.home,
                        color: drawerTextColor(0),
                      ),
                      Padding(padding: EdgeInsets.only(right: 10)),
                      Text(
                        'Home',
                        style:
                            TextStyle(color: drawerTextColor(0), fontSize: 18),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.orange),
                      borderRadius: BorderRadius.circular(10),
                      color: drawerBackColor(0)),
                  height: 40,
                  width: double.infinity,
                  //color: Colors.orange,
                ),
                onTap: () {
                  setState(() {
                    globals.index = 0;
                    Navigator.pop(context);
                  });
                }),
            ListTile(
              title: Container(
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Icon(
                      Icons.search,
                      color: drawerTextColor(1),
                    ),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Text(
                      'Search',
                      style: TextStyle(color: drawerTextColor(1), fontSize: 18),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.orange),
                    borderRadius: BorderRadius.circular(10),
                    color: drawerBackColor(1)),
                height: 40,
                width: double.infinity,
                //color: Colors.orange,
              ),
              onTap: () => setState(() {
                globals.index = 1;
                Navigator.pop(context);
              }),
            ),
            ListTile(
              title: Container(
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.only(right: 10)),
                    FaIcon(
                      FontAwesomeIcons.fish,
                      color: drawerTextColor(2),
                    ),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Text(
                      'Karp',
                      style: TextStyle(color: drawerTextColor(2), fontSize: 18),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.orange),
                    borderRadius: BorderRadius.circular(10),
                    color: drawerBackColor(2)),
                height: 40,
                width: double.infinity,
                //color: Colors.orange,
              ),
              onTap: () => setState(() {
                globals.index = 2;
                Navigator.pop(context);
              }),
            ),
            ListTile(
              title: Container(
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Icon(
                      Icons.comment,
                      color: drawerTextColor(3),
                    ),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Text(
                      'Messages',
                      style: TextStyle(color: drawerTextColor(3), fontSize: 18),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.orange),
                    borderRadius: BorderRadius.circular(10),
                    color: drawerBackColor(3)),
                height: 40,
                width: double.infinity,
                //color: Colors.orange,
              ),
              onTap: () => setState(() {
                globals.index = 3;
                Navigator.pop(context);
              }),
            ),
            ListTile(
              title: Container(
                child: Row(
                  children: [
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Icon(
                      Icons.account_circle,
                      color: drawerTextColor(4),
                    ),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Text(
                      'Profile',
                      style: TextStyle(color: drawerTextColor(4), fontSize: 18),
                    )
                  ],
                ),
                decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.orange),
                    borderRadius: BorderRadius.circular(10),
                    color: drawerBackColor(4)),
                height: 40,
                width: double.infinity,
                //color: Colors.orange,
              ),
              onTap: () => setState(() {
                globals.index = 4;
                Navigator.pop(context);
              }),
            ),
            //Text('s'),
          ],
        ),
      ),
      body: IndexedStack(index: globals.index, children: screens),
      // appBar: AppBar(
      //   title: Text(
      //     'Karp Portal',
      //     style: TextStyle(color: Colors.white),
      //   ),
      // ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: Color.fromARGB(255, 255, 136, 56),
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: Color.fromARGB(255, 244, 130, 54),
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: const TextStyle(color: Colors.yellow))),
        child: BottomNavigationBar(
          currentIndex: globals.index,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
            BottomNavigationBarItem(
                icon: FaIcon(FontAwesomeIcons.fish), label: 'karp'),
            BottomNavigationBarItem(
                icon: Icon(Icons.comment), label: 'messages'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'profile'),
          ],
          onTap: (index) => setState(() => globals.index = index),
        ),
      ),
    );
  }

  void pop() {
    Navigator.pop(context);
  }

  drawerTextColor(int i) {
    if (globals.index == i) {
      return Colors.orange;
    } else
      return Colors.white;
  }

  drawerBackColor(int i) {
    if (globals.index == i) {
      return Colors.white;
    } else
      return Colors.orange;
  }

  setIcon() {
    if (globals.image != null)
      return ClipOval(
        child: Image.file(
          globals.image!,
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
      );
    else
      return Icon(
        Icons.account_circle,
        size: 120,
        color: Colors.white,
      );
  }
}
