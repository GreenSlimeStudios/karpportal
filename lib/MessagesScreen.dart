import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:karpportal/ChatScreen.dart';
import 'package:karpportal/Database.dart';
import 'package:karpportal/MyClipper.dart';

import 'UserModel.dart';

import 'globals.dart' as globals;

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);
  //final Function() notifyParent;

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

String? name;
var fields = ["firstName", "secondName", "email", "nickname"];

DatabaseMethods databaseMethods = new DatabaseMethods();
UserModel? searchModel;

class _MessagesPageState extends State<MessagesPage> {
  TextEditingController searchController = new TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = new UserModel();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    () async {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get()
          .then(
        (value) {
          globals.myUser = UserModel.fromMap(value.data());
          //setState(() {});
        },
      );
    };
  }

  // setup() async {
  //   FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then(
  //     (value) {
  //       this.loggedInUser = UserModel.fromMap(value.data());
  //       setState(() {});
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: refresh,
        child: Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
      body: Column(children: [
        Container(
          margin: EdgeInsets.only(left: 20, right: 20),
          //child: Form(
          child: Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              'New Messages',
              style: TextStyle(
                  fontSize: 20,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 10)),
        //for (int i = 0; i < 4; i++)
        Expanded(
          child: ListView(
            children: [
              if (globals.myUser!.newMessages != null)
                if (globals.myUser!.newMessages != [])
                  for (int i = 0; i < globals.myUser!.newMessages!.length; i++)
                    FutureBuilder(
                      future: getRecentRooms(globals.myUser!.newMessages![i]),
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data;
                        } else if (snapshot.hasError) {
                          return Text(snapshot.error.toString());
                        } else {
                          return CircularProgressIndicator();
                        }
                      },
                    ),
              // getRecentRooms(globals.myUser!.newMessages![i])
            ],
          ),
        )
      ]),
    );
  }

  QuerySnapshot? searchSnapshot;
  void initSearch() {
    databaseMethods.getByUserName(searchController.text).then((val) {
      print(val.toString());
      searchSnapshot = val;
      print(searchSnapshot);
    });
  }

  void createChatRoom(Map<String, dynamic> data) async {
    String chatRoomId =
        getChatRoomId('${data['uid']}', '${globals.myUser!.uid}');

    List<String> users = [data['fullName'], globals.myUser!.fullName!];
    //users.sort();
    List<String> uids = [data['uid'], globals.myUser!.uid!];
    //uids.sort();

    Map<String, dynamic> chatRoomMap = {
      "users": users,
      "uids": uids,
      "chatRoomId": chatRoomId,
    };

    databaseMethods.createChatRoom(chatRoomId, chatRoomMap);
    //globals.index = 3;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ChatPage(chatRoomId: chatRoomId, chatUserData: data)));
  }

  Future<Widget> getRecentRooms(chatRoomId) async {
    UserModel targetUserModel = UserModel();

    final roomData = await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(chatRoomId)
        .get();
    print('///////////////////////////////////////////////////');
    print(roomData);
    print('///////////////////////////////////////////////////');
    print('///////////////////////////////////////////////////');
    print(globals.myUser!.toMap());
    print('///////////////////////////////////////////////////');

    if (roomData["uids"][0] != globals.myUser!.uid) {
      // targetUserData = await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(roomData["uids"][0])
      //     .get();

      await FirebaseFirestore.instance
          .collection("users")
          .doc(roomData["uids"][0])
          .get()
          .then(
        (value) {
          targetUserModel = UserModel.fromMap(value.data());
        },
      );
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(roomData["uids"][1])
          .get()
          .then(
        (value) {
          targetUserModel = UserModel.fromMap(value.data());
        },
      );
    }
    print('///////////////////////////////////////////////////');
    print(targetUserModel.toMap());
    print('///////////////////////////////////////////////////');
    List<String> users = [targetUserModel.fullName!, globals.myUser!.fullName!];
    //users.sort();
    List<String> uids = [targetUserModel.uid!, globals.myUser!.uid!];
    //uids.sort();

    Map<String, dynamic> chatRoomMap = {
      "time": DateTime.now(),
      "time2": DateTime.now().millisecond,
      "users": users,
      "uids": uids,
      "chatRoomId": chatRoomId,
    };

    //globals.myUser?.newMessages?.forEach((element) {
    return GestureDetector(
      onTap: () {
        createChatRoom(
          targetUserModel.toMap(),
        );
      },
      child: Container(
        padding: EdgeInsets.only(top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(targetUserModel.fullName!),
                  Text(
                    targetUserModel.nickname!,
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
              leading: ClipOval(
                //clipper: MyClipper(),
                child: Image.network(
                  targetUserModel.avatarUrl!,
                  width: 55,
                  height: 55,
                  fit: BoxFit.cover,
                ),
              ),
              trailing: Icon(Icons.message),
            ),
          ],
        ),
      ),
    );
  }

  void refresh() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then(
      (value) {
        loggedInUser = UserModel.fromMap(value.data());
        globals.myUser = loggedInUser;

        setState(() {});
      },
    );
  }
}

getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b - $a";
  } else {
    return "$a - $b";
  }
}

class SearchTitle extends StatelessWidget {
  final String userName;
  final String userEmail;

  SearchTitle({required this.userName, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        children: [
          Column(
            children: [
              Text(userName),
              Text(userEmail),
            ],
          ),
        ],
      ),
    );
  }
}
