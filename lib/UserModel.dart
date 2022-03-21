import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? secondName;
  String? nickname;
  String? avatarUrl;
  String? fullName;
  List<dynamic>? newMessages;

  UserModel(
      {this.uid,
      this.email,
      this.firstName,
      this.secondName,
      this.nickname,
      this.avatarUrl,
      this.fullName,
      this.newMessages});

  // receiving data from server
  factory UserModel.fromMap(map) {
    //globals.fullName = map['fullName'];
    //globals.avatarUrl = map['avatarUrl'];
    return UserModel(
        uid: map['uid'],
        email: map['email'],
        firstName: map['firstName'],
        secondName: map['secondName'],
        nickname: map['nickname'],
        avatarUrl: map['avatarUrl'],
        newMessages: map['newMessages'],
        fullName: map['fullName']);
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'secondName': secondName,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'newMessages': newMessages,
      'fullName': '${firstName} ${secondName}',
    };
  }
}
