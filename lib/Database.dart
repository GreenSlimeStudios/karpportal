import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class DatabaseMethods {
  getByUserName(String username) async {
    // var x = await FirebaseFirestore.instance
    //     .collection('users')
    //     .where('nickname', isEqualTo: username)
    //     .get;

    // print(x.toString());
    //return x;

    var documentList = (await FirebaseFirestore.instance
        .collection("users")
        .where("firstName", arrayContains: username)
        .snapshots());

    print(documentList.toString());
    print('=======================================');
    print(documentList);

    return documentList;
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap)
        .onError((error, stackTrace) => print(error.toString()));
  }

  getLogin() async {
    final prefs = await SharedPreferences.getInstance();
  }

  addConversationMessages(String chatRoomId, messageMap, bool isImage) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chat")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessages(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chat")
        .snapshots();
  }

  getPosts() async {
    return await FirebaseFirestore.instance
        .collection("Posts")
        .orderBy("timeMil", descending: true)
        .snapshots();
  }

  createPost(postID, postMap) {
    FirebaseFirestore.instance.collection("Posts").doc(postID).set(postMap).catchError((e) {
      print(e.toString());
    });
  }

  Future<Map<String, dynamic>> getPost(String postID) async {
    Map<String, dynamic> postMap = {};
    await FirebaseFirestore.instance.collection("Posts").doc(postID).get().then((value) {
      postMap = value.data() as Map<String, dynamic>;
    });
    return postMap;
  }

  setPost(postID, Map<String, dynamic> postData) async {
    await FirebaseFirestore.instance.collection("Posts").doc(postID).set(postData);
  }

  sendNotification(String title, String body, String token) async {
    final data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'message': title,
    };

    try {
      http.Response response = await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: <String, String>{
            'Content-Type': 'application/json',
            'Authorization':
                'key=AAAASkfbv0c:APA91bGlzPWhK6D07chlvcnpD6KYZUPt9Xeif4QbadV-Y8QJwlG7qI_YmmFtTooliqjQET5YCXBs4B9GFtkGco7GKntJZeve2LfMeIAtNobDym3-4AxJhPYF25Xz8WOvprQUmDKwIpsU'
          },
          body: jsonEncode(<String, dynamic>{
            'notification': <String, dynamic>{
              'title': title,
              'body': body,
            },
            'priority': 'high',
            'data': data,
            'to': '$token'
          }));

      if (response.statusCode == 200) {
        print("Yeh notificatin is sended");
        print("NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN");
      } else {
        print("Error");
        print("EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE");
      }
    } catch (e) {
      print(e);
    }
  }

  String getCurrentTime() {
    String? hour;
    if (DateTime.now().hour.toString().characters.length == 1) {
      hour = '0${DateTime.now().hour}';
    } else {
      hour = '${DateTime.now().hour}';
    }
    String? minute;
    if (DateTime.now().minute.toString().characters.length == 1) {
      minute = '0${DateTime.now().minute}';
    } else {
      minute = '${DateTime.now().minute}';
    }
    String? month;
    if (DateTime.now().month.toString().characters.length == 1) {
      month = '0${DateTime.now().month}';
    } else {
      month = '${DateTime.now().month}';
    }
    String? day;
    if (DateTime.now().day.toString().characters.length == 1) {
      day = '0${DateTime.now().day}';
    } else {
      day = '${DateTime.now().day}';
    }
    return '${DateTime.now().year}/${month}/${day} ${hour}:${minute}';
  }
}
