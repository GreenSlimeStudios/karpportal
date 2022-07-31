import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karpportal/LoginScreen.dart';
import 'package:karpportal/ProfileTitle.dart';
import 'package:karpportal/SearchScreen.dart';
import 'package:karpportal/UserModel.dart';
import 'package:karpportal/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'HomeScreen.dart' as home;

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
  //   // TODO: implement initState
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
    // TODO: implement initState
    isDarkTheme = globals.isDarkTheme!;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade100,
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: CachedNetworkImage(
              imageUrl: getBackroundUrl(),
              colorBlendMode: BlendMode.clear,
              fit: BoxFit.cover,
              placeholder: (context, url) =>
                  Container(width: 50, height: 50, child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Icon(Icons.error),
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
                          offset: Offset(0, 3), // changes position of shadow
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
                                    child: CachedNetworkImage(imageUrl: globals.myUser!.avatarUrl!),
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
                                  errorWidget: (context, url, error) => Icon(Icons.error),
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
                              constraints: BoxConstraints(maxHeight: 90, maxWidth: 200),
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
                                      SizedBox(height: 3),
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
                            Container(
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
                    margin: EdgeInsets.only(left: 5, right: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: globals.themeColor!.withOpacity(0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: Column(children: [
                      const Padding(padding: EdgeInsets.only(top: 15)),
                      ProfileTitle(
                          title: 'First name', param: globals.myUser!.firstName!, func: changeName),
                      ProfileTitle(
                          title: 'Last name',
                          param: globals.myUser!.secondName!,
                          func: changeSurName),
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
                              ColorSwatchPick(Colors.pink),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              ColorSwatchPick(Colors.purple),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              ColorSwatchPick(Colors.deepPurple),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              ColorSwatchPick(Colors.indigo),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              ColorSwatchPick(Colors.blue),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              ColorSwatchPick(Colors.cyan),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              ColorSwatchPick(Colors.lime),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              ColorSwatchPick(Colors.deepOrange),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              ColorSwatchPick(Colors.orange),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(top: 5)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PrimaryColorPick(Colors.pink),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              PrimaryColorPick(Colors.purple),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              PrimaryColorPick(Colors.deepPurple),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              PrimaryColorPick(Colors.indigo),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              PrimaryColorPick(Colors.blue),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              PrimaryColorPick(Colors.cyan),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              PrimaryColorPick(Colors.lime),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              PrimaryColorPick(Colors.deepOrange),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              PrimaryColorPick(Colors.orange),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(top: 10)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ThemeColorPick(ThemeColor.Light, Colors.white),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              ThemeColorPick(ThemeColor.Dark, Colors.grey.shade900),
                              Padding(padding: EdgeInsets.only(right: 5)),
                              ThemeColorPick(ThemeColor.Contrast, Colors.black),
                            ],
                          ),
                          Padding(padding: EdgeInsets.only(top: 10)),
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
                        const Padding(padding: EdgeInsets.only(top: 40)),
                        ProfileButton(
                            function: signOut,
                            icon: Icons.groups_rounded,
                            color: Colors.pinkAccent,
                            title: 'Sign Out'),
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        ProfileButton(
                            function: updateKarpportal,
                            icon: Icons.download,
                            color: Color.fromARGB(255, 64, 255, 105),
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
                            color: Color.fromARGB(255, 64, 255, 239),
                            title: 'Set Token'),
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        Padding(padding: EdgeInsets.only(bottom: 5)),
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
                        Padding(padding: EdgeInsets.only(bottom: 10)),
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
  final _storage = FirebaseStorage.instance;
  File? imageTemporary;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future pickImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      imageTemporary = File(image.path);
      if (imageTemporary!.lengthSync() > 5000000) {
        Fluttertoast.showToast(msg: 'bruh are you tryin to fuck up my cloud storage?');
        return;
      }
      setState(() {
        globals.image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('failed tp pick image $e');
    }
    //final ref = FirebaseStorage
    var snapshot = await _storage
        .ref()
        .child('AvatarImages/${globals.myUser!.uid}avatar')
        .putFile(imageTemporary!);

    var downloadurl = await snapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = downloadurl;
    });
    globals.myUser!.avatarUrl = imageUrl;

    await firebaseFirestore
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
          title: Text('reset email'),
          content: Container(
            height: 100,
            child: Column(
              children: [
                TextField(
                  controller: newEmailController,
                ),
                ElevatedButton(onPressed: changeToNewEmail, child: Text('resetEmail'))
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
    var authUser = await FirebaseAuth.instance.currentUser;
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

      await firebaseFirestore
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

  Widget ColorSwatchPick(MaterialColor color) {
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

  Widget PrimaryColorPick(MaterialColor color) {
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

  Widget ThemeColorPick(ThemeColor theme, Color backgroundColor) {
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
    // prefs.setBool('isDarkTheme', isDarkTheme);
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

    prefs.setString('primaryColor', color.toString());
    // print(color.shade100.toString());
  }

  Future changeBackgroundImage() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      imageTemporary = File(image.path);
      if (imageTemporary!.lengthSync() > 5000000) {
        Fluttertoast.showToast(msg: 'bruh are you tryin to fuck up my cloud storage?');
        return;
      }
      setState(() {
        globals.image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('failed tp pick image $e');
    }
    //final ref = FirebaseStorage
    var snapshot = await _storage
        .ref()
        .child('BackgroundImages/${globals.myUser!.uid}-background')
        .putFile(imageTemporary!);

    var downloadurl = await snapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = downloadurl;
    });
    globals.myUser!.backgroundUrl = imageUrl;

    await firebaseFirestore
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
                    decoration: InputDecoration(
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
                    decoration: InputDecoration(
                        hintText: "content",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 2))),
                  ),
                  SizedBox(height: 10),
                  Text(
                      "Make sure you are up to date with the latest version of karpportal to check if the bug hasn't been already resolved"),
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
          title: Text("Report Idea for a new feature"),
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
                    decoration: InputDecoration(
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
                    decoration: InputDecoration(
                        hintText: "content",
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey, width: 2))),
                  ),
                  SizedBox(height: 10),
                  Text(
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
          title: Text("Change Description"),
          content: TextFormField(
            minLines: 1,
            maxLines: 15,
            controller: descriptionController,
            decoration: InputDecoration(
                hintText: "enter description",
                focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 2))),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text("OK", style: TextStyle(color: Colors.white)),
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
  ProfileButton(
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
      margin: EdgeInsets.only(left: 5, right: 5),
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: globals.themeColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: Offset(0, 3), // changes position of shadow
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
            Padding(padding: EdgeInsets.only(right: 5)),
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
