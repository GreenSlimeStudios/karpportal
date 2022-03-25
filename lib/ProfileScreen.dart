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
      backgroundColor: Colors.grey.shade100,
      body: ListView(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin:
                    EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  //border: Border.all(width: 1, color: Colors.black),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(children: [
                  Padding(padding: EdgeInsets.only(left: 10)),
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
                    Icon(
                      Icons.account_circle,
                      size: 140,
                      color: Color.fromARGB(255, 141, 141, 141),
                    ),
                  Padding(padding: EdgeInsets.only(left: 10)),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        //'big fat and very very moch of a long text',
                        loggedInUser.firstName!,
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.w300),
                      ),
                      Text(
                        loggedInUser.secondName!,
                        style: TextStyle(fontSize: 30, color: Colors.black),
                      ),
                      ElevatedButton(
                        onPressed: changeAvatar,
                        child: Text(
                          'Change Avatar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  )
                ]),
              ),
              Padding(padding: EdgeInsets.only(top: 10)),

              Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                child: Column(children: [
                  Padding(padding: EdgeInsets.only(top: 10)),
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
                ]),
              ),

              Padding(padding: EdgeInsets.only(top: 20)),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                child: TextButton(
                  onPressed: signOut,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.groups_rounded,
                        color: Colors.pinkAccent,
                      ),
                      Padding(padding: EdgeInsets.only(right: 5)),
                      Text(
                        'Sign Out',
                        style: TextStyle(color: Colors.pinkAccent),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(top: 10)),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white),
                child: TextButton(
                  onPressed: updateKarpportal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.upload,
                        color: Color.fromARGB(255, 64, 255, 105),
                      ),
                      Padding(padding: EdgeInsets.only(right: 5)),
                      Text(
                        'Update Karpportal (google drive)',
                        style:
                            TextStyle(color: Color.fromARGB(255, 64, 255, 105)),
                      ),
                    ],
                  ),
                ),
              ),

              //Image.network(imageUrl!),
            ],
          )
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
  }

  void signOut() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.remove('logindetails');
    final _auth = FirebaseAuth.instance;
    _auth.signOut();
    Navigator.push(
        context, MaterialPageRoute(builder: ((context) => LoginPage())));
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
}
