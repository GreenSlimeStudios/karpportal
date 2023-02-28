import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'globals.dart' as globals;

class ResetPage extends StatefulWidget {
  const ResetPage({Key? key}) : super(key: key);

  @override
  State<ResetPage> createState() => _ResetPageState();
}

class _ResetPageState extends State<ResetPage> {
  TextEditingController emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: globals.primarySwatch,
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
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
                  margin: const EdgeInsets.only(left: 30, right: 30, top: 20),
                  child: TextFormField(
                    keyboardType: TextInputType.emailAddress,
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
                  margin: const EdgeInsets.only(right: 30, left: 30, top: 5),
                  width: double.infinity,
                  child: Hero(
                    tag: 'accountLoginButton',
                    child: Container(
                      margin: const EdgeInsets.only(top: 5),
                      constraints:
                          const BoxConstraints(maxHeight: 35, minHeight: 35),
                      child: ElevatedButton(
                        onPressed: () => resetPassword(),
                        child: const Text(
                          'Reset Password',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Hero(
                  tag: 'loginText',
                  child: Card(
                    color: Colors.transparent,
                    elevation: 0,
                    margin: EdgeInsets.zero,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Remembered your password? '),
                        const Padding(padding: EdgeInsets.only(top: 30)),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            child: const Text(
                              'Login.',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    try {
      Navigator.pop(context);
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      Fluttertoast.showToast(msg: "email sent succesfully");
    } on FirebaseAuthException {
      Fluttertoast.showToast(msg: "dailed to send reset email");
    }
  }
}
