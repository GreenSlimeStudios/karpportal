import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karpportal/UserModel.dart';

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

UserModel? myUser;
