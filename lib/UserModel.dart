import 'package:flutter/material.dart';
import 'globals.dart' as globals;

class UserModel {
  String? uid;
  String? email;
  String? firstName;
  String? secondName;
  String? nickname;
  String? token;
  String? avatarUrl;
  String? backgroundUrl;
  String? fullName;
  String? dateCreated;
  List<dynamic>? newMessages;
  List<dynamic>? recentRooms;
  String? description;

  UserModel({
    this.uid,
    this.email,
    this.firstName,
    this.secondName,
    this.nickname,
    this.token,
    this.avatarUrl,
    this.backgroundUrl,
    this.fullName,
    this.newMessages,
    this.recentRooms,
    this.dateCreated,
    this.description,
  });

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
      token: map['token'],
      avatarUrl: map['avatarUrl'],
      backgroundUrl: map['backgroundUrl'],
      newMessages: map['newMessages'],
      recentRooms: map['recentRooms'],
      dateCreated: map['dateCreated'],
      fullName: map['fullName'],
      description: map['description'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'secondName': secondName,
      'nickname': nickname,
      'token': token,
      'avatarUrl': avatarUrl,
      'backgroundUrl': backgroundUrl,
      'newMessages': newMessages,
      'recentRooms': recentRooms,
      'dateCreated': dateCreated,
      'fullName': '${firstName} ${secondName}',
      'description': description,
    };
  }
}
