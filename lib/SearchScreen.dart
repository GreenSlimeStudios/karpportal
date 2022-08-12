import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:karpportal/ChatScreen.dart';
import 'package:karpportal/Database.dart';

import 'UserModel.dart';
import 'globals.dart' as globals;

DatabaseMethods databaseMethods = DatabaseMethods();

var fields = ["firstName", "secondName", "email", "nickname"];
String? name;

UserModel? searchModel;
getChatRoomId(String a, String b) {
  if (a.substring(0, 1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return "$b - $a";
  } else {
    return "$a - $b";
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  //final Function() notifyParent;

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class SearchTitle extends StatelessWidget {
  final String userName;
  final String userEmail;

  const SearchTitle({required this.userName, required this.userEmail});

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

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  QuerySnapshot? searchSnapshot;

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then(
  //     (value) {
  //       loggedInUser = UserModel.fromMap(value.data());
  //       //setState(() {});
  //     },
  //   );
  // }

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
      body: Column(children: [
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20),
          //child: Form(
          child: TextFormField(
            decoration: const InputDecoration(
                hintText: 'find user',
                focusedBorder:
                    UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey, width: 1))),
            controller: searchController,
            onChanged: (val) {
              setState(() {
                if (val != null) {
                  name = val;
                } else {
                  name = "";
                }
              });
            },
          ),
        ),
        const Padding(padding: EdgeInsets.only(top: 10)),
        //for (int i = 0; i < 4; i++)
        StreamBuilder<QuerySnapshot>(
          stream: (name != '' && name != null)
              ? FirebaseFirestore.instance
                  .collection("users")
                  .where(
                    'nickname',
                    isGreaterThanOrEqualTo: name,
                  )
                  .limit(10)
                  .snapshots()
              : FirebaseFirestore.instance.collection("users").snapshots(),
          builder: (context, snapshot) {
            return (snapshot.connectionState == ConnectionState.waiting)
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      // itemCount: 2,
                      itemBuilder: (context, index) {
                        var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        print((snapshot.data!.docs[index].metadata.isFromCache)
                            ? "NOT FROM NETWORK"
                            : "FROM NETWORK");
                        if (data != null) {
                          return GestureDetector(
                            onTap: () {
                              createChatRoom(data);
                            },
                            child: Container(
                              padding: const EdgeInsets.only(top: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ListTile(
                                    title: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(data['nickname']),
                                        Text(
                                          (data["description"] != null &&
                                                  data["description"].trim() != "")
                                              ? (data["description"]!.trim().length < 66)
                                                  ? data["description"]!
                                                      .trim()
                                                      .replaceAll("\n", " ")
                                                  : data["description"]!
                                                          .trim()
                                                          .replaceAll("\n", " ")
                                                          .substring(0, 65) +
                                                      "..."
                                              : "karpportal enjoyer",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w300, fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    leading: ClipOval(
                                      //clipper: MyClipper(),
                                      child: Hero(
                                        tag: data['uid'],
                                        child: CachedNetworkImage(
                                          imageUrl: data['avatarUrl'],
                                          width: 55,
                                          height: 55,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              const Icon(Icons.error),
                                        ),
                                      ),
                                    ),
                                    trailing: Icon(Icons.message,
                                        color: (globals.isDarkTheme!)
                                            ? Colors.white
                                            : Colors.grey.shade900),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Container(
                            child: const Text('null'),
                          );
                        }
                      },
                    ),
                  );
          },
        )
      ]),
    );
  }

  void createChatRoom(Map<String, dynamic> data) async {
    String chatRoomId = getChatRoomId('${data['uid']}', '${globals.myUser!.uid}');

    List<String> users = [data['fullName'], globals.myUser!.fullName!];
    //users.sort();
    List<String> uids = [data['uid'], globals.myUser!.uid!];
    //uids.sort();

    Map<String, dynamic> chatRoomMap = {
      "time": DateTime.now(),
      "time2": DateTime.now().millisecond,
      "users": users,
      "uids": uids,
      "chatRoomId": chatRoomId,
    };

    databaseMethods.createChatRoom(chatRoomId, chatRoomMap);
    //globals.index = 3;

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                chatRoomId: chatRoomId,
                chatUserDatas: {data['uid']: UserModel.fromMap(data)},
                isGroupChat: false)));
  }

  void initSearch() {
    databaseMethods.getByUserName(searchController.text).then((val) {
      print(val.toString());
      searchSnapshot = val;
      print(searchSnapshot);
    });
  }
}
