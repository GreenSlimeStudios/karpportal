import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karpportal/HomeScreen.dart';
import 'package:karpportal/InitUserScreen.dart';
import 'package:karpportal/SingUpScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ResetPassword.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

String? errorMessage;
TextEditingController emailController = TextEditingController();
TextEditingController passwordController = TextEditingController();

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (context, constraints) => ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'karpPortal',
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: Colors.transparent,
                          child: Text(
                            'Karp\nPortal',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.leagueScript(
                                fontSize: 60, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        margin:
                            const EdgeInsets.only(left: 30, right: 30, top: 20),
                        child: TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return ("Please Enter Email");
                            }
                            if (!RegExp(
                                    "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                .hasMatch(value)) {
                              return ("Please Enter a valid email");
                            }
                            return null;
                          },
                          controller: emailController,
                          decoration: const InputDecoration(
                            hintText: 'email',
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0))),
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 30, right: 30, top: 10, bottom: 5),
                        child: TextFormField(
                          controller: passwordController,
                          obscureText: _isObscure,
                          validator: (value) {
                            RegExp regex = RegExp(r'^.{6,}$');
                            if (value!.isEmpty) {
                              return ("Please Enter password min 6 char");
                            }
                            if (!regex.hasMatch(value)) {
                              return ("Please Enter valid password (min 6 character)");
                            }
                          },
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.key),
                            hintText: 'password',
                            border: const OutlineInputBorder(
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
                        margin: const EdgeInsets.only(right: 30, left: 30),
                        width: double.infinity,
                        child: Hero(
                          tag: 'accountLoginButton',
                          child: Container(
                            margin: const EdgeInsets.only(top: 5),
                            constraints: const BoxConstraints(
                                maxHeight: 35, minHeight: 35),
                            child: ElevatedButton(
                              onPressed: () {
                                login(emailController.text,
                                    passwordController.text);
                              },
                              child: const Text(
                                'Login',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Hero(
                        tag: 'loginText',
                        child: Card(
                          margin: EdgeInsets.zero,
                          color: Colors.transparent,
                          elevation: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('don\'t have an account yet? '),
                              const Padding(padding: EdgeInsets.only(top: 30)),
                              GestureDetector(
                                onTap: singUp,
                                child: Container(
                                  child: const Text(
                                    'Sing in.',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        child: const Text(
                          'forgor password?',
                          style: TextStyle(
                            // color: Colors.blue,
                            fontWeight: FontWeight.bold,
                            // decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResetPage()));
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ));
  }

  void login(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> loginDetailsToSave = [
      emailController.text,
      passwordController.text
    ];
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .signInWithEmailAndPassword(
                email: emailController.text, password: passwordController.text)
            .then((uid) => {
                  Fluttertoast.showToast(msg: "Login Successful"),
                  prefs.setStringList('logindetails', loginDetailsToSave),
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const InitUserPage())),
                });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage =
                "Your email address appears to be malformed. make sure there is no space after the email";

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

  void singUp() async {
    var info = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const SingUpPage()));

    setState(() {
      emailController.text = info[0];
      passwordController.text = info[1];
    });
  }

  e() {
    Fluttertoast.showToast(msg: 'error');
  }
}
