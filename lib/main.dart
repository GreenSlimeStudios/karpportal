import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:karpportal/SplashScreen.dart';
import 'firebase_options.dart';

import 'HomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isIOS) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'karp portal',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const SplashScreen(),
    );
  }
}
