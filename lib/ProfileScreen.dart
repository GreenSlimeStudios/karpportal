import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:karpportal/LoginScreen.dart';
import 'package:karpportal/ProfileTitle.dart';
import 'package:karpportal/SearchScreen.dart';
import 'package:karpportal/UserModel.dart';
import 'package:karpportal/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ImageActions.dart';
import 'globals.dart' as globals;

class ProfilePage extends StatefulWidget {
  //final VoidCallback notifyParent;
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

TextEditingController reportBugContentController = TextEditingController();
TextEditingController reportBugTitleController = TextEditingController();
final bugKey = GlobalKey<FormState>();

TextEditingController reportIdeaContentController = TextEditingController();
TextEditingController reportIdeaTitleController = TextEditingController();
final ideaKey = GlobalKey<FormState>();
bool isDarkTheme = false;

TextEditingController descriptionController = TextEditingController();

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  //UserModel loggedInUser = UserModel();
  String? url;

  // @override
  // void initState() {
  //   super.initState();
  //   FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then(
  //     (value) {
  //       this.loggedInUser = UserModel.fromMap(value.data());
  //       setState(() {});
  //     },
  //   );
  // }
  @override
  void initState() {
    isDarkTheme = globals.isDarkTheme!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: CachedNetworkImage(
              imageUrl: getBackroundUrl(),
              colorBlendMode: BlendMode.clear,
              fit: BoxFit.cover,
              placeholder: (context, url) => SizedBox(
                  width: 50, height: 50, child: const Center(child: CircularProgressIndicator())),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: globals.themeColor!.withOpacity(0.9),
                      // color: Colors.transparent,
                      //border: Border.all(width: 1, color: Colors.black),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(children: [
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      if (globals.myUser!.avatarUrl != null)
                        Stack(
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InteractiveViewer(
                                    maxScale: 10,
                                    child: CachedNetworkImage(
                                        imageUrl: globals.myUser!.avatarUrl!,
                                        progressIndicatorBuilder: (context, url, progress) =>
                                            CircularProgressIndicator(value: progress.progress)),
                                  ),
                                ),
                              ),
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: globals.myUser!.avatarUrl!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              ),
                            ),
                            Positioned(
                              right: -10,
                              bottom: -10,
                              child: IconButton(
                                  icon: const Icon(
                                    FontAwesomeIcons.penToSquare,
                                    // Icons.handyman,
                                  ),
                                  iconSize: 25,
                                  onPressed: pickImage),
                            ),
                          ],
                        )
                      else
                        const Icon(
                          Icons.account_circle,
                          size: 140,
                          color: Color.fromARGB(255, 141, 141, 141),
                        ),
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: const BoxConstraints(maxHeight: 90, maxWidth: 200),
                              child: NotificationListener<OverscrollIndicatorNotification>(
                                onNotification: (overscroll) {
                                  overscroll.disallowIndicator();
                                  return true;
                                },
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        //'big fat and very very moch of a long text',
                                        globals.myUser!.nickname!,
                                        // softWrap: true,
                                        style: const TextStyle(
                                            fontSize: 30,
                                            // color: Colors.black,
                                            fontWeight: FontWeight.w400),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        (globals.myUser!.description != null)
                                            ? (globals.myUser!.description! != "")
                                                ? globals.myUser!.description!
                                                : "No description entered mmmmmmmmmmm \n~"
                                            : "No description entered mmmmmmmmmmm \n~",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          // color: Colors.black
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 25,
                              child: ElevatedButton(
                                onPressed: changeDescription,
                                child: const Text(
                                  'Change Description',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]),
                  ),
                  const Padding(padding: EdgeInsets.only(top: 10)),

                  Container(
                    margin: const EdgeInsets.only(left: 5, right: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: globals.themeColor!.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(children: [
                      const Padding(padding: EdgeInsets.only(top: 15)),

                      // Follower actions
                      // Container(
                      //   padding: const EdgeInsets.all(5),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      //     children: [
                      //       Row(children: const [
                      //         Icon(Icons.account_circle),
                      //         SizedBox(width: 5),
                      //         Text("0"),
                      //       ]),
                      //       Row(children: const [
                      //         Icon(Icons.account_circle),
                      //         SizedBox(width: 5),
                      //         Text("0"),
                      //       ]),
                      //       Row(children: const [
                      //         Icon(Icons.account_circle),
                      //         SizedBox(width: 5),
                      //         Text("0"),
                      //       ]),
                      //     ],
                      //   ),
                      // ),

                      // ProfileTitle(
                      //     title: 'First name',
                      //     param: globals.myUser!.firstName ?? "none",
                      //     func: changeName),
                      // ProfileTitle(
                      //     title: 'Last name',
                      //     param: globals.myUser!.secondName ?? "none",
                      //     func: changeSurName),
                      ProfileTitle(
                          title: 'Email', param: globals.myUser!.email!, func: changeEmail),
                      ProfileTitle(
                          title: 'Nickname',
                          param: globals.myUser!.nickname!,
                          func: changeNickname),

                      Container(
                        // margin: EdgeInsets.only(left: 20),
                        child: Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              colorSwatchPick(Colors.pink),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              colorSwatchPick(Colors.purple),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              colorSwatchPick(Colors.deepPurple),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              colorSwatchPick(Colors.indigo),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              colorSwatchPick(Colors.blue),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              colorSwatchPick(Colors.cyan),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              colorSwatchPick(Colors.lime),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              colorSwatchPick(Colors.deepOrange),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              colorSwatchPick(Colors.orange),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.only(top: 5)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              primaryColorPick(Colors.pink),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              primaryColorPick(Colors.purple),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              primaryColorPick(Colors.deepPurple),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              primaryColorPick(Colors.indigo),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              primaryColorPick(Colors.blue),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              primaryColorPick(Colors.cyan),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              primaryColorPick(Colors.lime),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              primaryColorPick(Colors.deepOrange),
                              const Padding(padding: EdgeInsets.only(right: 5)),
                              primaryColorPick(Colors.orange),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.only(top: 10)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              themeColorPick(ThemeColor.Light, Colors.white),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              themeColorPick(ThemeColor.Dark, Colors.grey.shade900),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              themeColorPick(ThemeColor.Contrast, Colors.black),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.only(top: 15)),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.center,
                          //   children: [
                          //     Text(
                          //       'dark theme',
                          //       style: TextStyle(fontWeight: FontWeight.bold),
                          //     ),
                          //     Switch(value: isDarkTheme, onChanged: changeDarkTheme),
                          //   ],
                          // ),
                          // Padding(padding: EdgeInsets.only(top: 10)),
                        ]),
                      )
                    ]),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.transparent, backgroundBlendMode: BlendMode.darken),
                    child: Column(
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 20)),
                        ProfileButton(
                            function: signOut,
                            icon: Icons.groups_rounded,
                            color: Colors.pinkAccent,
                            title: 'Sign Out'),
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        ProfileButton(
                            function: updateKarpportal,
                            icon: Icons.download,
                            color: const Color.fromARGB(255, 64, 255, 105),
                            title: 'Update Karpportal (google drive)'),
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        ProfileButton(
                            function: reportBug,
                            icon: Icons.bug_report,
                            color: Colors.orange,
                            title: 'Report Bug'),
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        ProfileButton(
                            function: reportIdea,
                            icon: Icons.construction,
                            color: Colors.yellow,
                            title: 'Report Idea For A Feature'),
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        ProfileButton(
                            function: setToken,
                            icon: Icons.token,
                            color: const Color.fromARGB(255, 64, 255, 239),
                            title: 'Set Token'),
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        const Padding(padding: EdgeInsets.only(bottom: 5)),
                        GestureDetector(
                          onTap: changeBackgroundImage,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'change background image ',
                                style: TextStyle(color: Colors.white),
                              ),
                              Icon(
                                Icons.edit,
                                color: Colors.white,
                              )
                            ],
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(bottom: 10)),
                      ],
                    ),
                  )

                  //Image.network(imageUrl!),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  void changeAvatar() async {
    pickImage();
  }

  String? imageUrl;

  Future pickImage() async {
    var downloadurl = await pickGaleryImage("AvatarImages");
    if (downloadurl == null) {
      Fluttertoast.showToast(msg: "We have encountered a problem while trying to upoad the image");
      return;
    }
    setState(() {
      imageUrl = downloadurl;
    });
    globals.myUser!.avatarUrl = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(globals.myUser!.uid)
        .set(globals.myUser!.toMap());
    Fluttertoast.showToast(
        msg: "Account updated successfully :) ",
        textColor: Colors.black,
        backgroundColor: Colors.white);
    Fluttertoast.showToast(
        msg: "Restart karpportal to see changes:) ",
        textColor: Colors.black,
        backgroundColor: Colors.white);
  }

  void signOut() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.remove('logindetails');
    final _auth = FirebaseAuth.instance;
    _auth.signOut();
    Navigator.push(context, MaterialPageRoute(builder: ((context) => const LoginPage())));
  }

  void changeName() {}

  TextEditingController newEmailController = TextEditingController();
  void changeEmail() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('reset email'),
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                TextField(
                  controller: newEmailController,
                ),
                ElevatedButton(onPressed: changeToNewEmail, child: const Text('resetEmail'))
              ],
            ),
          ),
        );
      },
    );
  }

  changeToNewEmail() async {
    // EmailAuthProvider.getCredential(email: 'email', password: 'password');
    Fluttertoast.showToast(
        msg: 'if you restart the app and the email changed it means it worked :)');
    var authUser = FirebaseAuth.instance.currentUser;
    try {
      await authUser
          ?.updateEmail(newEmailController.text)
          .then((value) => updateEmailInFirestore());
      print('bruh');
    } on FirebaseAuthException {
      print(e.toString());
    }
  }

  updateEmailInFirestore() async {
    UserModel loggedInUser = UserModel();
    await FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then((value) async {
      loggedInUser = UserModel.fromMap(value.data());

      User? user = FirebaseAuth.instance.currentUser;

      loggedInUser.email = user!.email;
      globals.myUser = loggedInUser;
      globals.authUser = user;

      await FirebaseFirestore.instance
          .collection("users")
          .doc(globals.myUser!.uid)
          .set(globals.myUser!.toMap());
    });
  }

  void changeNickname() {}

  void changeSurName() {}

  void updateKarpportal() {
    if (Platform.isIOS) {
      launch(
          'https://drive.google.com/drive/folders/1WgqMYXzfzDirmRJv7616Mb6MFBgUF9uM?usp=sharing');
    } else {
      launch('https://drive.google.com/file/d/1p4C2rfIsIHSQbkxtieRhLnPeLT-JcWr8/view?usp=sharing');
    }
  }

  Widget colorSwatchPick(MaterialColor color) {
    return GestureDetector(
      onTap: () {
        changeSwatchColor(color);
        setState(() {});
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Container(
              height: 30,
              width: 30,
              color: color,
            ),
          ),
          if (globals.primarySwatch.toString() == color.toString())
            Positioned(
              left: 11,
              top: 11,
              // alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  alignment: Alignment.center,
                  height: 8,
                  width: 8,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget primaryColorPick(MaterialColor color) {
    return GestureDetector(
      onTap: () {
        changePrimaryColor(color);
        setState(() {});
      },
      child: Stack(
        children: [
          ClipRRect(
            child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: color,
                  // border: Border.all(width: 1, color: Colors.white),
                )),
          ),
          if (globals.primaryColor.toString() == color.toString())
            Positioned(
              left: 11,
              top: 11,
              // alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  alignment: Alignment.center,
                  height: 8,
                  width: 8,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget themeColorPick(ThemeColor theme, Color backgroundColor) {
    return GestureDetector(
      onTap: () {
        changeThemeColor(theme);
        setState(() {});
      },
      child: Stack(
        children: [
          ClipRRect(
            child: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(width: 1, color: Colors.white),
                  color: backgroundColor,
                )),
          ),
          if (globals.theme == theme)
            Positioned(
              left: 11,
              top: 11,
              // alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  alignment: Alignment.center,
                  height: 8,
                  width: 8,
                  color: (theme != ThemeColor.Light) ? Colors.white : Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  changeThemeColor(ThemeColor theme) async {
    globals.theme = theme;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (theme == ThemeColor.Light)
      prefs.setBool('isDarkTheme', false);
    else
      prefs.setBool('isDarkTheme', true);
    prefs.setString('theme', theme.toString());
    Fluttertoast.showToast(msg: 'restart app to see changes');
    setState(() {});
  }

  void changePrimaryColor(MaterialColor color) async {
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
    prefs.setString('sha/fde2', shade100.toString());
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
    // prefs.setString('primaryColorString', color.toString());
  }

  void changeSwatchColor(MaterialColor color) async {
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

    prefs.setString('swatchColor', color.toString());
    // print(color.shade100.toString());
    // prefs.setString('swatchColorString', color.toString());
  }

  Future changeBackgroundImage() async {
    var downloadurl = await pickGaleryImage("BackgroundImages");
    if (downloadurl == null) {
      Fluttertoast.showToast(msg: "We have encountered a problem while trying to upoad the image");
      return;
    }
    setState(() {
      imageUrl = downloadurl;
    });
    globals.myUser!.backgroundUrl = imageUrl;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(globals.myUser!.uid)
        .set(globals.myUser!.toMap());
    Fluttertoast.showToast(
        msg: "Account updated successfully :) ",
        textColor: Colors.black,
        backgroundColor: Colors.white);
    setState(() {});
  }

  String getBackroundUrl() {
    if (globals.myUser!.backgroundUrl != null) {
      return globals.myUser!.backgroundUrl!;
    } else {
      return 'https://c4.wallpaperflare.com/wallpaper/500/442/354/outrun-vaporwave-hd-wallpaper-preview.jpg';
    }
  }

  void saveToken(String token) async {
    // UserModel myUser = UserModel();
    // await FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then(
    //   (value) {
    //     myUser = UserModel.fromMap(value.data());
    //   },
    // );
    // myUser.token = token;
    // await FirebaseFirestore.instance.collection("users").doc(user!.uid).set(myUser.toMap());

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .set({"token": token}, SetOptions(merge: true));

    Fluttertoast.showToast(msg: 'token created succesfully');
  }

  Future<void> setToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    saveToken(token!);
  }

  void changeDarkTheme(bool value) async {
    isDarkTheme = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkTheme', isDarkTheme);
    Fluttertoast.showToast(msg: 'restart app to see changes');
    setState(() {});
  }

  reportBug() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Report a bug"),
          content: Form(
            key: bugKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    validator: (val) {
                      if (val == null) return "title cannot be null";
                      if (val.isEmpty) return "title cannot be empty";
                      if (val == " ") return "tfuj stary winiary";
                    },
                    controller: reportBugTitleController,
                    decoration: const InputDecoration(
                        hintText: "title",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 2))),
                  ),
                  TextFormField(
                    minLines: 1,
                    maxLines: 15,
                    validator: (val) {
                      if (val == null) return "content cannot be null";
                      if (val.isEmpty) return "content cannot be empty";
                      if (val == " ") return "tfuj stary winiary";
                    },
                    controller: reportBugContentController,
                    decoration: const InputDecoration(
                        hintText: "content",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 2))),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                      "Make sure you are up to date with the latest version of karpportal to check if the bug hasn't been already resolved"),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("OK", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if (bugKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await FirebaseFirestore.instance.collection("bugReports").add({
                    "title": reportBugTitleController.text,
                    "content": reportBugContentController.text,
                    "authorNickname": globals.myUser!.nickname,
                    "authorID": globals.myUser!.uid,
                    "time": DateTime.now().millisecondsSinceEpoch,
                  });
                  databaseMethods.sendNotification(
                      "New bug report from ${globals.myUser!.nickname!}",
                      "${reportBugTitleController.text}: ${reportBugContentController.text}",
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc("iH0WyWRmRbU8aGZHzvMupbrAkMZ2")
                          .get()
                          .then((value) {
                        return value.data()!["token"];
                      }));
                  reportBugContentController.text = "";
                  reportBugTitleController.text = "";
                  Fluttertoast.showToast(msg: "reported bug successfully");
                }
              },
            ),
          ],
        );
      },
    );
  }

  void reportIdea() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Report Idea for a new feature"),
          content: Form(
            key: bugKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    validator: (val) {
                      if (val == null) return "title cannot be null";
                      if (val.isEmpty) return "title cannot be empty";
                      if (val == " ") return "tfuj stary winiary";
                    },
                    controller: reportIdeaTitleController,
                    decoration: const InputDecoration(
                        hintText: "title",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 2))),
                  ),
                  TextFormField(
                    minLines: 1,
                    maxLines: 15,
                    validator: (val) {
                      if (val == null) return "content cannot be null";
                      if (val.isEmpty) return "content cannot be empty";
                      if (val == " ") return "tfuj stary winiary";
                    },
                    controller: reportIdeaContentController,
                    decoration: const InputDecoration(
                        hintText: "content",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 2))),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                      "Make sure you are up to date with the latest version of karpportal to check if the feature hasn't been already implemented"),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                if (bugKey.currentState!.validate()) {
                  Navigator.of(context).pop();
                  await FirebaseFirestore.instance.collection("ideaReports").add({
                    "title": reportIdeaContentController.text,
                    "content": reportIdeaContentController.text,
                    "authorNickname": globals.myUser!.nickname,
                    "authorID": globals.myUser!.uid,
                    "time": DateTime.now().millisecondsSinceEpoch,
                  });
                  databaseMethods.sendNotification(
                      "New feature idea report from ${globals.myUser!.nickname!}",
                      "${reportIdeaTitleController.text}: ${reportIdeaContentController.text}",
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc("iH0WyWRmRbU8aGZHzvMupbrAkMZ2")
                          .get()
                          .then((value) {
                        return value.data()!["token"];
                      }));
                  reportIdeaContentController.text = "";
                  reportIdeaTitleController.text = "";
                  Fluttertoast.showToast(msg: "reported bug successfully");
                }
              },
            ),
          ],
        );
      },
    );
  }

  void changeDescription() {
    if (globals.myUser!.description != null) {
      descriptionController.text = globals.myUser!.description!;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Change Description"),
          content: TextFormField(
            minLines: 1,
            maxLines: 15,
            controller: descriptionController,
            decoration: const InputDecoration(
                hintText: "enter description",
                focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 2))),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text("OK", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                Navigator.of(context).pop();
                await FirebaseFirestore.instance.collection("users").doc(globals.myUser!.uid).set({
                  "description": descriptionController.text,
                }, SetOptions(merge: true));
                Fluttertoast.showToast(msg: "changed description successfully");
                globals.myUser!.description = descriptionController.text;
                setState(() {});
              },
            ),
          ],
        );
      },
    );
  }
}

class ProfileButton extends StatefulWidget {
  const ProfileButton(
      {Key? key,
      required this.function,
      required this.icon,
      required this.color,
      required this.title})
      : super(key: key);
  final function;
  final IconData icon;
  final Color color;
  final String title;
  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: globals.themeColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: TextButton(
        onPressed: widget.function,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              color: widget.color,
            ),
            const Padding(padding: EdgeInsets.only(right: 5)),
            Text(
              widget.title,
              style: TextStyle(color: widget.color),
            ),
          ],
        ),
      ),
    );
  }
}
