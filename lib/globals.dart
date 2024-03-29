import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karpportal/UserModel.dart';

import 'enums.dart';

File? image;
int index = 2;
String? fullName;
String? avatarUrl;
MaterialColor? primarySwatch;
MaterialColor? primaryColor;
Color? themeColor;
bool? isDarkTheme;
// Colors.grey.shade900;
User? authUser;
ThemeColor? theme;
int localversion = 100;
int? version;
AccentColor? primaryColorID;
AccentColor? swatchColorID;
UserModel? myUser;

Map<String, UserModel> loadedUsers = {};
