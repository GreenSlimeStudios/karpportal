import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karpportal/HomeScreen.dart';
import 'package:karpportal/InitUserScreen.dart';
import 'package:karpportal/UserModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'globals.dart' as globals;

class SingUpPage extends StatefulWidget {
  const SingUpPage({Key? key}) : super(key: key);

  @override
  State<SingUpPage> createState() => _SingUpPageState();
}

bool exists = false;
TextEditingController emailController = TextEditingController();
TextEditingController nameController = TextEditingController();
TextEditingController surnameController = TextEditingController();
TextEditingController nicknameController = TextEditingController();
TextEditingController passwordController = TextEditingController();
TextEditingController confirmPasswordController = TextEditingController();

String? errorMessage;

class _SingUpPageState extends State<SingUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: globals.primarySwatch,
      ),
      body: ListView(
        children: [
          Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(padding: EdgeInsets.only(top: 30)),
                  Text(
                    'Karp\nPortal',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.leagueScript(
                        fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 30, right: 30, top: 20),
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return ("Please Enter Email");
                        }
                        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                            .hasMatch(value)) {
                          return ("Please Enter a valid email");
                        }
                        return null;
                      },
                      controller: emailController,
                      decoration: InputDecoration(
                        hintText: 'email',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                    child: TextFormField(
                      validator: (value) {
                        RegExp regex = new RegExp(r'^.{1,}$');
                        if (value!.isEmpty) {
                          return ("Please Enter Email");
                        }
                      },
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Name',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        // prefixIcon: Icon(Icons.email),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                    child: TextFormField(
                      validator: (value) {
                        RegExp regex = new RegExp(r'^.{1,}$');
                        if (value!.isEmpty) {
                          return ("Please Enter Surname");
                        }
                      },
                      controller: surnameController,
                      decoration: InputDecoration(
                        hintText: 'Surname',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        //prefixIcon: Icon(Icons.email),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 30, right: 30, top: 10),
                    child: TextFormField(
                      validator: (value) {
                        StreamSubscription<DocumentSnapshot> subscription;
                        RegExp regex = new RegExp(r'^.{1,}$');
                        if (value!.isEmpty) {
                          return ("Please Enter username");
                        }
                        // bool exists = false;
                        // QuerySnapshot = FirebaseFirestore.instance
                        //     .collection("users")
                        //     .where('nickname', isEqualTo: value)
                        //     .limit(1)
                        //     .snapshots();
                        // // var exists = doesNameAlreadyExist(value) as bool;
                        // bool exists = existsDocument(value);
                        if (exists) {
                          return ('username already taken :(');
                        }
                      },
                      controller: nicknameController,
                      // onChanged: doesNameAlreadyExist(nicknameController.text),
                      decoration: InputDecoration(
                        hintText: 'nickname',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        //prefixIcon: Icon(Icons.email),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 30, right: 30, top: 10, bottom: 5),
                    child: TextFormField(
                      validator: (value) {
                        RegExp regex = new RegExp(r'^.{6,}$');
                        if (value!.isEmpty) {
                          return ("Please Enter password min 6 char");
                        }
                        if (!regex.hasMatch(value)) {
                          return ("Please Enter valid password (min 6 character)");
                        }
                      },
                      controller: passwordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.key),
                        hintText: 'password',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        // icon: Icon(Icons.email),
                        suffixIcon: IconButton(
                            icon: Icon(_isObscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            }),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        left: 30, right: 30, top: 10, bottom: 5),
                    child: TextFormField(
                      validator: (value) {
                        RegExp regex = new RegExp(r'^.{6,}$');
                        if (value!.isEmpty) {
                          return ("Please Enter password min 6 char");
                        }
                        if (value != passwordController.text) {
                          return ("input doesnt match password");
                        }
                        if (!regex.hasMatch(value)) {
                          return ("Please Enter valid password (min 6 character)");
                        }
                      },
                      controller: confirmPasswordController,
                      obscureText: _isObscure,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.key),
                        hintText: 'confirm password',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0))),
                        // icon: Icon(Icons.email),
                        suffixIcon: IconButton(
                            icon: Icon(_isObscure
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _isObscure = !_isObscure;
                              });
                            }),
                      ),
                    ),
                  ),
                  Container(
                      margin: EdgeInsets.only(right: 30, left: 30),
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: () {
                            signUp(
                                emailController.text, passwordController.text);
                          },
                          child: Text('Sing Up'))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('already have account bruh '),
                      Padding(padding: EdgeInsets.only(top: 30)),
                      GestureDetector(
                          onTap: loginScreen,
                          child: Container(
                            child: Text(
                              'Login',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ))
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void singUp2() {
    if (emailController.text != '' &&
        nameController.text != '' &&
        surnameController.text != '' &&
        nicknameController.text != '' &&
        passwordController != '' &&
        passwordController.text == confirmPasswordController.text) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  void signUp(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        print('///////////////////////////STARTING????????????????????????');
        await _auth
            .createUserWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .then((value) => {postDetailsToFirestore()})
            .catchError((e) {
          Fluttertoast.showToast(msg: e.toString());
        });
        print('///////////////////////////ENDING????????????????????????');

        // Fluttertoast.showToast(
        //     msg: 'succesfully created account',
        //     textColor: Colors.black,
        //     backgroundColor: Colors.white);
        // var ainfo = [email, password];
        // Navigator.pop(context, errorMessage);
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage =
                "Your email address appears to be malformed. chack if you have a space after the email";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(
            msg: errorMessage!,
            textColor: Colors.black,
            backgroundColor: Colors.white);
        print(error.code);
      }
    }
  }

  postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sedning these values
    final prefs = await SharedPreferences.getInstance();

    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    UserModel userModel = UserModel();
    String? token = await FirebaseMessaging.instance.getToken();

    // writing all the values
    userModel.email = user!.email;
    userModel.uid = user.uid;
    userModel.firstName = nameController.text;
    userModel.secondName = surnameController.text;
    userModel.nickname = nicknameController.text;
    userModel.token = token;
    userModel.dateCreated = DateTime.now().toString();
    userModel.avatarUrl =
        'https://firebasestorage.googleapis.com/v0/b/karp-portal.appspot.com/o/AvatarImages%2Fpidgeon.jpg?alt=media&token=263b59b7-beea-46c8-8ed4-4a9e94ae4a39';

    List<String> loginDetailsToSave = [
      emailController.text,
      passwordController.text
    ];
    prefs.setStringList('logindetails', loginDetailsToSave);

    await firebaseFirestore
        .collection("users")
        .doc(user.uid)
        .set(userModel.toMap());

    user.updateDisplayName(nicknameController.text);

    Fluttertoast.showToast(
        msg: "Account created successfully :) ",
        textColor: Colors.black,
        backgroundColor: Colors.white);

    Navigator.pushAndRemoveUntil(
        (context),
        MaterialPageRoute(builder: (context) => InitUserPage()),
        (route) => false);
  }

  void loginScreen() {
    Navigator.pop(context);
  }

  doesNameAlreadyExist(String name) async {
    // String name = nicknameController.text;
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('company')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    exists = documents.length == 1;
    // return documents.length == 1;
  }

  existsDocument(String nickname) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('nickname', isEqualTo: nickname)
        .get();

    final List<DocumentSnapshot> documents = result.docs;

    if (documents.length > 0) {
      return false;
    } else {
      return true;
      //not exists

    }
  }
}
