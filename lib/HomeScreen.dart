import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karpportal/MessagesScreen.dart';
import 'package:karpportal/ProfileScreen.dart';
import 'package:karpportal/Screen1.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karpportal/SearchScreen.dart';
import 'package:karpportal/UserModel.dart';
import 'package:karpportal/services/localPushNotification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

import 'MainScreen.dart';
import 'enums.dart';
import 'globals.dart' as globals;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

//int _index = 2;

class _HomePageState extends State<HomePage> {
  var screens = [
    const MainPage(),
    const SearchPage(),
    const Page1(),
    const MessagesPage(),
    const ProfilePage()
  ];

  @override
  initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((event) {
      print("MessageRecived");
      LocalNotificationService.display(event);
    });
  }

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  // makeUserGlobal() async {
  //   await FirebaseFirestore.instance
  //       .collection("users")
  //       .doc(user!.uid)
  //       .get()
  //       .then(
  //     (value) {
  //       loggedInUser = UserModel.fromMap(value.data());
  //       globals.myUser = loggedInUser;

  //       setState(() {});
  //     },
  //   );
  // }

  refresh() {
    setState(() {});
  }

  // bool hasNewMessages = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: (globals.index != 0)
          ? AppBar(
              actions: [
                IconButton(
                  onPressed: refresh,
                  icon: const Icon(Icons.refresh),
                )
              ],
              title: Text(
                'Karp Portal',
                textAlign: TextAlign.center,
                style: GoogleFonts.leagueScript(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              foregroundColor: Colors.white,
            )
          : null,
      //drawerScrimColor: Colors.white,
      drawer: Drawer(
        backgroundColor: globals.themeColor!,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: globals.primaryColor,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    globals.primaryColor!,

                    globals.primarySwatch!
                    // Colors.blue,
                    // Colors.red,
                  ],
                ),
              ),
              // child: Center(child: setIcon()),
              // child:
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(
                    'Karp\nPortal',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.leagueScript(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 20),
                  Image.asset('assets/karpportallogofinal.png', height: 100, width: 100),
                ],
              ),
            ),
            ListTile(
                title: Container(
                  decoration: BoxDecoration(
                    border: (globals.index != 0)
                        ? null
                        : Border.all(width: 2, color: globals.primarySwatch as Color),
                    borderRadius: BorderRadius.circular(10),
                    color: drawerBackColor(0),
                    gradient: (globals.index == 0)
                        ? null
                        : LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              globals.primaryColor!,

                              globals.primarySwatch!
                              // Colors.blue,
                              // Colors.red,
                            ],
                          ),
                  ),
                  height: 40,
                  width: double.infinity,
                  child: Row(
                    children: [
                      const Padding(padding: EdgeInsets.only(right: 10)),
                      Icon(
                        Icons.home,
                        color: drawerTextColor(0),
                      ),
                      const Padding(padding: EdgeInsets.only(right: 10)),
                      Text(
                        'Home',
                        style: TextStyle(color: drawerTextColor(0), fontSize: 18),
                      )
                    ],
                  ),
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
                decoration: BoxDecoration(
                    border: (globals.index != 1)
                        ? null
                        : Border.all(width: 2, color: globals.primarySwatch as Color),
                    borderRadius: BorderRadius.circular(10),
                    gradient: (globals.index == 1)
                        ? null
                        : LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              globals.primaryColor!,

                              globals.primarySwatch!
                              // Colors.blue,
                              // Colors.red,
                            ],
                          ),
                    color: drawerBackColor(1)),
                height: 40,
                width: double.infinity,
                child: Row(
                  children: [
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    Icon(
                      Icons.search,
                      color: drawerTextColor(1),
                    ),
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    Text(
                      'Search',
                      style: TextStyle(color: drawerTextColor(1), fontSize: 18),
                    )
                  ],
                ),
                //color: Colors.orange,
              ),
              onTap: () => setState(() {
                globals.index = 1;
                Navigator.pop(context);
              }),
            ),
            ListTile(
              title: Container(
                decoration: BoxDecoration(
                    border: (globals.index != 2)
                        ? null
                        : Border.all(width: 2, color: globals.primarySwatch as Color),
                    borderRadius: BorderRadius.circular(10),
                    gradient: (globals.index == 2)
                        ? null
                        : LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              globals.primaryColor!,

                              globals.primarySwatch!
                              // Colors.blue,
                              // Colors.red,
                            ],
                          ),
                    color: drawerBackColor(2)),
                height: 40,
                width: double.infinity,
                child: Row(
                  children: [
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    FaIcon(
                      FontAwesomeIcons.fish,
                      color: drawerTextColor(2),
                    ),
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    Text(
                      'Karp',
                      style: TextStyle(color: drawerTextColor(2), fontSize: 18),
                    )
                  ],
                ),
                //color: Colors.orange,
              ),
              onTap: () => setState(() {
                globals.index = 2;
                Navigator.pop(context);
              }),
            ),
            ListTile(
              title: Container(
                decoration: BoxDecoration(
                    border: (globals.index != 3)
                        ? null
                        : Border.all(width: 2, color: globals.primarySwatch as Color),
                    borderRadius: BorderRadius.circular(10),
                    gradient: (globals.index == 3)
                        ? null
                        : LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              globals.primaryColor!,

                              globals.primarySwatch!
                              // Colors.blue,
                              // Colors.red,
                            ],
                          ),
                    color: drawerBackColor(3)),
                height: 40,
                width: double.infinity,
                child: Row(
                  children: [
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    Icon(
                      Icons.comment,
                      color: drawerTextColor(3),
                    ),
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    Text(
                      'Messages',
                      style: TextStyle(color: drawerTextColor(3), fontSize: 18),
                    )
                  ],
                ),
                //color: Colors.orange,
              ),
              onTap: () => setState(() {
                globals.index = 3;
                Navigator.pop(context);
              }),
            ),
            ListTile(
              title: Container(
                decoration: BoxDecoration(
                    border: (globals.index != 4)
                        ? null
                        : Border.all(width: 2, color: globals.primarySwatch as Color),
                    borderRadius: BorderRadius.circular(10),
                    gradient: (globals.index == 4)
                        ? null
                        : LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              globals.primaryColor!,

                              globals.primarySwatch!
                              // Colors.blue,
                              // Colors.red,
                            ],
                          ),
                    color: drawerBackColor(4)),
                height: 40,
                width: double.infinity,
                child: Row(
                  children: [
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    Icon(
                      Icons.account_circle,
                      color: drawerTextColor(4),
                    ),
                    const Padding(padding: EdgeInsets.only(right: 10)),
                    Text(
                      'Profile',
                      style: TextStyle(color: drawerTextColor(4), fontSize: 18),
                    )
                  ],
                ),
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
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
            // sets the background color of the `BottomNavigationBar`
            canvasColor: globals.primaryColor,
            // sets the active color of the `BottomNavigationBar` if `Brightness` is light
            primaryColor: globals.primaryColor,
            textTheme: Theme.of(context)
                .textTheme
                .copyWith(caption: const TextStyle(color: Colors.yellow))),
        child: BottomNavigationBar(
          unselectedItemColor: getColor(),
          selectedItemColor: getColor(),
          currentIndex: globals.index,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
            const BottomNavigationBarItem(icon: Icon(Icons.search), label: 'search'),
            const BottomNavigationBarItem(icon: FaIcon(FontAwesomeIcons.fish), label: 'karp'),
            BottomNavigationBarItem(icon: pickIcon(), label: 'messages'),
            const BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'profile'),
          ],
          onTap: (index) => setState(() => globals.index = index),
        ),
      ),
    );
  }

  Color getColor() {
    return (globals.themeColor == Colors.white) ? Colors.white : Colors.grey.shade900;
  }

  void pop() {
    Navigator.pop(context);
  }

  drawerTextColor(int i) {
    if (globals.index == i) {
      return globals.primarySwatch;
    } else {
      return Colors.white;
    }
  }

  drawerBackColor(int i) {
    if (globals.index == i) {
      return Colors.white;
    } else {
      return globals.primarySwatch;
    }
  }

  setIcon() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: CachedNetworkImage(
        imageUrl: globals.myUser!.avatarUrl!,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }

  Widget pickIcon() {
    if (globals.myUser!.newMessages != null) {
      if (globals.myUser!.newMessages!.isNotEmpty) {
        return Icon(
          Icons.comment,
          color: globals.primaryColor!.shade800,
        );
      } else {
        return const Icon(Icons.comment
            // color: Colors.white,
            );
      }
    } else {
      return Icon(
        Icons.comment, color: getColor(),
        // color: Colors.white,
      );
    }
  }

  void change(MaterialColor color) async {
    globals.primaryColor = color;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Color shade50 = color.shade50;
    Color shade100 = color.shade100;
    Color shade200 = color.shade200;
    Color shade300 = color.shade300;
    Color shade400 = color.shade400;
    Color shade500 = color.shade500;
    Color shade600 = color.shade600;
    Color shade700 = color.shade700;
    Color shade800 = color.shade800;
    Color shade900 = color.shade900;

    prefs.setString('shade1', shade50.toString());
    prefs.setString('shade2', shade100.toString());
    prefs.setString('shade3', shade200.toString());
    prefs.setString('shade4', shade300.toString());
    prefs.setString('shade5', shade400.toString());
    prefs.setString('shade6', shade500.toString());
    prefs.setString('shade7', shade600.toString());
    prefs.setString('shade8', shade700.toString());
    prefs.setString('shade9', shade800.toString());
    prefs.setString('shade10', shade900.toString());

    prefs.setString('primaryColor', color.toString());
    // print(color.shade100.toString());
  }

  void changeSwatch(MaterialColor color) async {
    globals.primarySwatch = color;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Color shade50 = color.shade50;
    Color shade100 = color.shade100;
    Color shade200 = color.shade200;
    Color shade300 = color.shade300;
    Color shade400 = color.shade400;
    Color shade500 = color.shade500;
    Color shade600 = color.shade600;
    Color shade700 = color.shade700;
    Color shade800 = color.shade800;
    Color shade900 = color.shade900;

    prefs.setString('shadeS1', shade50.toString());
    prefs.setString('shadeS2', shade100.toString());
    prefs.setString('shadeS3', shade200.toString());
    prefs.setString('shadeS4', shade300.toString());
    prefs.setString('shadeS5', shade400.toString());
    prefs.setString('shadeS6', shade500.toString());
    prefs.setString('shadeS7', shade600.toString());
    prefs.setString('shadeS8', shade700.toString());
    prefs.setString('shadeS9', shade800.toString());
    prefs.setString('shadeS10', shade900.toString());

    prefs.setString('primaryColor', color.toString());
    // print(color.shade100.toString());
  }
}
