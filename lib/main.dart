import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karpportal/SplashScreen.dart';
import 'package:karpportal/services/localPushNotification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'enums.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// import 'package:hive/hive.dart';

import 'globals.dart' as globals;

import 'HomeScreen.dart';

int? valuePrimary;
String? primary;
Color? otherColor;
MaterialColor? colorCustom;
Map<int, Color>? materialColor;

int? valuePrimaryS;
String? primaryS;
Color? otherColorS;
MaterialColor? colorCustomS;
Map<int, Color>? materialColorS;

String? themeSring;
ThemeColor? theme;
// bool isDarkTheme = false;

void main() async {
  // debugRepaintRainbowEnabled = true;
  if (kIsWeb) {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    final Future<FirebaseApp> initializiation = Firebase.initializeApp();

    runApp(const MyApp());
  } else {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isIOS) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      if (!Platform.isLinux) {
        await Firebase.initializeApp();
      }
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('isDarkTheme') != null) {
      // isDarkTheme = prefs.getBool('isDarkTheme')!;
      themeSring = prefs.getString('theme');
    }
    if (themeSring != null) {
      switch (themeSring) {
        case "ThemeColor.Light":
          {
            globals.theme = ThemeColor.Light;
            globals.themeColor = Colors.white;
            globals.isDarkTheme = false;
          }
          break;
        case "ThemeColor.Dark":
          {
            globals.theme = ThemeColor.Dark;
            globals.themeColor = Colors.grey.shade900;
            globals.isDarkTheme = true;
          }
          break;
        case "ThemeColor.Contrast":
          {
            globals.theme = ThemeColor.Contrast;
            globals.themeColor = Colors.black;
            globals.isDarkTheme = true;
          }
          break;
      }
    } else {
      globals.theme = ThemeColor.Dark;
      globals.themeColor = Colors.grey.shade900;
      globals.isDarkTheme = true;
    }
    // if (isDarkTheme) {
    //   globals.themeColor = Colors.grey.shade900;
    // } else {
    //   globals.themeColor = Colors.white;
    // }
    // globals.isDarkTheme = isDarkTheme;

    List<Color> colorShades = [
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black
    ];
    if (prefs.getString('shade1') != null) {
      for (int i = 1; i < 11; i++) {
        String? colorString = prefs.getString('shade$i');
        print(colorString);
        String? valueString = colorString?.split('(0x')[1].split(')')[0]; // kind of hacky..
        if (i == 6) {
          //Color(0xffe91e63)
          primary = colorString!.substring(6, 16);
          print(primary);
          valuePrimary = int.parse(valueString!, radix: 16);
        }
        int value = int.parse(valueString!, radix: 16);
        otherColor = Color(value);
        colorShades[i - 1] = otherColor!;
      }
      print(colorShades);

      materialColor = {
        50: colorShades[0],
        100: colorShades[1],
        200: colorShades[2],
        300: colorShades[3],
        400: colorShades[4],
        500: colorShades[5],
        600: colorShades[6],
        700: colorShades[7],
        800: colorShades[8],
        900: colorShades[9]
      };
      colorCustom = MaterialColor(valuePrimary!, materialColor!);
      globals.primaryColor = colorCustom;
    } else {
      colorCustom = Colors.deepOrange;
      globals.primaryColor = Colors.deepOrange;
    }
    //primarySwatch
    List<Color> colorSwatchShades = [
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black,
      Colors.black
    ];
    if (prefs.getString('shadeS1') != null) {
      for (int i = 1; i < 11; i++) {
        String? colorStringS = prefs.getString('shadeS$i');
        print(colorStringS);
        String? valueString = colorStringS?.split('(0x')[1].split(')')[0]; // kind of hacky..
        if (i == 6) {
          //Color(0xffe91e63)
          primaryS = colorStringS!.substring(6, 16);
          print(primaryS);
          valuePrimaryS = int.parse(valueString!, radix: 16);
        }
        int value = int.parse(valueString!, radix: 16);
        otherColorS = Color(value);
        colorSwatchShades[i - 1] = otherColor!;
      }
      print(colorSwatchShades);

      materialColorS = {
        50: colorSwatchShades[0],
        100: colorSwatchShades[1],
        200: colorSwatchShades[2],
        300: colorSwatchShades[3],
        400: colorSwatchShades[4],
        500: colorSwatchShades[5],
        600: colorSwatchShades[6],
        700: colorSwatchShades[7],
        800: colorSwatchShades[8],
        900: colorSwatchShades[9]
      };
      colorCustomS = MaterialColor(valuePrimaryS!, materialColorS!);
      globals.primarySwatch = colorCustomS;
    } else {
      colorCustomS = Colors.orange;
      globals.primarySwatch = Colors.orange;
    }
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
    });
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    LocalNotificationService.initialize();
    // var debugRepaintRainbowEnable = true;
    if (Platform.isAndroid && globals.isDarkTheme == true) {
      SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(systemNavigationBarColor: Colors.black));
    }
    runApp(const MyApp());
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // final Future<FirebaseApp> _initializiation = Firebase.initializeApp();

// This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'karp portal',
      theme: globals.isDarkTheme!
          ? (globals.theme == ThemeColor.Dark)
              ? ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.fromSwatch(
                      accentColor: globals.primarySwatch,
                      backgroundColor: globals.themeColor!,
                      primarySwatch: globals.primarySwatch!,
                      brightness: Brightness.dark,
                      cardColor: globals.themeColor!),
                  appBarTheme: AppBarTheme(backgroundColor: Colors.grey.shade800),

                  // accentColor: globals.primaryColor,
                  splashColor: globals.primaryColor,
                  scrollbarTheme: ScrollbarThemeData(
                      trackBorderColor: MaterialStateProperty.all(globals.primaryColor),
                      thumbColor: MaterialStateProperty.all(globals.primaryColor),
                      trackColor: MaterialStateProperty.all(globals.primaryColor)),

                  // primarySwatch: globals.primarySwatch,
                  // accentColor: globals.primarySwatch,
                  // iconTheme: IconThemeData(color: globals.primarySwatch),
                  // textSelectionColor: globals.primarySwatch,
                  textSelectionTheme: TextSelectionThemeData(
                      selectionColor: globals.primarySwatch,
                      cursorColor: globals.primarySwatch,
                      selectionHandleColor: globals.primarySwatch),
                  cardTheme: CardTheme(color: globals.primarySwatch),
                  inputDecorationTheme: InputDecorationTheme(
                      iconColor: globals.primaryColor,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide(color: globals.primarySwatch!, width: 3),
                      ),
                      fillColor: globals.primarySwatch,
                      // filled: true,
                      // focusedBorder: MaterialStateOutlineInputBorder(),
                      // border: InputBorder(borderSide: BorderSide(color: globals.primarySwatch!)),
                      focusColor: globals.primarySwatch,
                      hoverColor: globals.primarySwatch),
                  // textSelectionColor: globals.primarySwatch,
                  switchTheme: SwitchThemeData(
                      thumbColor: MaterialStateProperty.all(globals.primaryColor),
                      trackColor: MaterialStateProperty.all(globals.primarySwatch!.shade600)),
                  progressIndicatorTheme: ProgressIndicatorThemeData(color: globals.primarySwatch),
                  primaryColor: globals.primarySwatch,
                  primaryColorDark: globals.primarySwatch,
                  primaryIconTheme: IconThemeData(color: globals.primarySwatch),
                  buttonTheme: ButtonThemeData(buttonColor: globals.primarySwatch),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(globals.primarySwatch))))
              : ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.fromSwatch(
                      accentColor: globals.primarySwatch,
                      backgroundColor: globals.themeColor!,
                      brightness: Brightness.dark,
                      primarySwatch: globals.primarySwatch!,
                      cardColor: globals.themeColor!),
                  scaffoldBackgroundColor: globals.themeColor,
                  appBarTheme: AppBarTheme(backgroundColor: globals.themeColor),
                  dialogTheme: DialogTheme(backgroundColor: globals.themeColor),
                  // drawerTheme: DialogThemeData(),
                  canvasColor: globals.themeColor,
                  dialogBackgroundColor: globals.themeColor,
                  cardColor: globals.themeColor,

                  // accentColor: globals.primaryColor,
                  splashColor: globals.primaryColor,
                  scrollbarTheme: ScrollbarThemeData(
                      trackBorderColor: MaterialStateProperty.all(globals.primaryColor),
                      thumbColor: MaterialStateProperty.all(globals.primaryColor),
                      trackColor: MaterialStateProperty.all(globals.primaryColor)),

                  // primarySwatch: globals.primarySwatch,
                  // accentColor: globals.primarySwatch,
                  // iconTheme: IconThemeData(color: globals.primarySwatch),
                  // textSelectionColor: globals.primarySwatch,
                  textSelectionTheme: TextSelectionThemeData(
                      selectionColor: globals.primarySwatch,
                      cursorColor: globals.primarySwatch,
                      selectionHandleColor: globals.primarySwatch),
                  cardTheme: CardTheme(color: globals.primarySwatch),
                  inputDecorationTheme: InputDecorationTheme(
                      iconColor: globals.primaryColor,
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                        borderSide: BorderSide(color: globals.primarySwatch!, width: 3),
                      ),
                      fillColor: globals.primarySwatch,
                      // filled: true,
                      // focusedBorder: MaterialStateOutlineInputBorder(),
                      // border: InputBorder(borderSide: BorderSide(color: globals.primarySwatch!)),
                      focusColor: globals.primarySwatch,
                      hoverColor: globals.primarySwatch),
                  // textSelectionColor: globals.primarySwatch,
                  switchTheme: SwitchThemeData(
                      thumbColor: MaterialStateProperty.all(globals.primaryColor),
                      trackColor: MaterialStateProperty.all(globals.primarySwatch!.shade600)),
                  progressIndicatorTheme: ProgressIndicatorThemeData(color: globals.primarySwatch),
                  primaryColor: globals.primarySwatch,
                  primaryColorDark: globals.primarySwatch,
                  primaryIconTheme: IconThemeData(color: globals.primarySwatch),
                  buttonTheme: ButtonThemeData(buttonColor: globals.primarySwatch),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(globals.primarySwatch))))
          : ThemeData(
              primarySwatch: globals.primarySwatch,
            ),
      home: const SplashScreen(),
    );
  }
}
