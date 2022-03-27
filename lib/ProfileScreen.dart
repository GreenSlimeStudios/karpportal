import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karpportal/LoginScreen.dart';
import 'package:karpportal/ProfileTitle.dart';
import 'package:karpportal/UserModel.dart';
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

class _ProfilePageState extends State<ProfilePage> {
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  String? url;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then(
      (value) {
        this.loggedInUser = UserModel.fromMap(value.data());
        setState(() {});
      },
    );
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
            child: Image.network(
              getBackroundUrl(),
              colorBlendMode: BlendMode.clear,
              fit: BoxFit.cover,
            ),
          ),
          ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(
                        top: 10, left: 10, right: 10, bottom: 10),
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100.withOpacity(0.9),
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
                      if (loggedInUser.avatarUrl != null)
                        ClipOval(
                          child: Image.network(
                            loggedInUser.avatarUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Icon(
                          Icons.account_circle,
                          size: 140,
                          color: const Color.fromARGB(255, 141, 141, 141),
                        ),
                      const Padding(padding: EdgeInsets.only(left: 10)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            //'big fat and very very moch of a long text',
                            loggedInUser.firstName!,
                            style: const TextStyle(
                                fontSize: 30,
                                color: Colors.black,
                                fontWeight: FontWeight.w300),
                          ),
                          Text(
                            loggedInUser.secondName!,
                            style: const TextStyle(
                                fontSize: 30, color: Colors.black),
                          ),
                          ElevatedButton(
                            onPressed: changeAvatar,
                            child: const Text(
                              'Change Avatar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      )
                    ]),
                  ),
                  const Padding(padding: const EdgeInsets.only(top: 10)),

                  Container(
                    margin: EdgeInsets.only(left: 5, right: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Colors.white.withOpacity(0.9),
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
                      const Padding(padding: const EdgeInsets.only(top: 15)),
                      ProfileTitle(
                          title: 'First name',
                          param: loggedInUser.firstName!,
                          func: changeName),
                      ProfileTitle(
                          title: 'Last name',
                          param: loggedInUser.secondName!,
                          func: changeSurName),
                      ProfileTitle(
                          title: 'Email',
                          param: loggedInUser.email!,
                          func: changeEmail),
                      ProfileTitle(
                          title: 'Nickname',
                          param: loggedInUser.nickname!,
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
                        ]),
                      )
                    ]),
                  ),
                  Container(
                    decoration: const BoxDecoration(
                        color: Colors.transparent,
                        backgroundBlendMode: BlendMode.darken),
                    child: Column(
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 40)),
                        Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: signOut,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.groups_rounded,
                                  color: Colors.pinkAccent,
                                ),
                                const Padding(
                                    padding: EdgeInsets.only(right: 5)),
                                const Text(
                                  'Sign Out',
                                  style:
                                      const TextStyle(color: Colors.pinkAccent),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10)),
                        Container(
                          margin: EdgeInsets.only(left: 5, right: 5),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 5,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: updateKarpportal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.upload,
                                  color:
                                      const Color.fromARGB(255, 64, 255, 105),
                                ),
                                const Padding(
                                    padding: const EdgeInsets.only(right: 5)),
                                const Text(
                                  'Update Karpportal (google drive)',
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 64, 255, 105)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 5)),
                        GestureDetector(
                          onTap: changeBackgroundImage,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                        Padding(padding: EdgeInsets.only(bottom: 5)),
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
      setState(() {
        globals.image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('failed tp pick image $e');
    }
    //final ref = FirebaseStorage
    var snapshot = await _storage
        .ref()
        .child('AvatarImages/${loggedInUser.uid}avatar')
        .putFile(imageTemporary!);

    var downloadurl = await snapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = downloadurl;
    });
    loggedInUser.avatarUrl = imageUrl;

    await firebaseFirestore
        .collection("users")
        .doc(loggedInUser.uid)
        .set(loggedInUser.toMap());
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
    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => const LoginPage())));
  }

  void changeName() {}

  void changeEmail() {}

  void changeNickname() {}

  void changeSurName() {}

  void updateKarpportal() {
    if (Platform.isIOS) {
      launch(
          'https://drive.google.com/drive/folders/1WgqMYXzfzDirmRJv7616Mb6MFBgUF9uM?usp=sharing');
    } else {
      launch(
          'https://drive.google.com/file/d/1p4C2rfIsIHSQbkxtieRhLnPeLT-JcWr8/view?usp=sharing');
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
            borderRadius: BorderRadius.circular(30),
            child: Container(
              height: 30,
              width: 30,
              color: color,
            ),
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
      setState(() {
        globals.image = imageTemporary;
      });
    } on PlatformException catch (e) {
      print('failed tp pick image $e');
    }
    //final ref = FirebaseStorage
    var snapshot = await _storage
        .ref()
        .child('BackgroundImages/${loggedInUser.uid}-background')
        .putFile(imageTemporary!);

    var downloadurl = await snapshot.ref.getDownloadURL();
    setState(() {
      imageUrl = downloadurl;
    });
    loggedInUser.backgroundUrl = imageUrl;

    await firebaseFirestore
        .collection("users")
        .doc(loggedInUser.uid)
        .set(loggedInUser.toMap());
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
}
