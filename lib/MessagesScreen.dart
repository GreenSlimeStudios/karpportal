import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:karpportal/ChatScreen.dart';
import 'package:karpportal/CreateGroupChatScreen.dart';
import 'package:karpportal/Database.dart';
import 'package:fluttertoast/fluttertoast.dart';

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

DatabaseMethods databaseMethods = DatabaseMethods();
UserModel? searchModel;

class _MessagesPageState extends State<MessagesPage> {
  TextEditingController searchController = TextEditingController();

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   () async {
  //     await FirebaseFirestore.instance
  //         .collection("users")
  //         .doc(user!.uid)
  //         .get()
  //         .then(
  //       (value) {
  //         globals.myUser = UserModel.fromMap(value.data());
  //         //setState(() {});
  //       },
  //     );
  //   };
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: globals.primarySwatch,
        onPressed: refresh,
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20),
            //child: Form(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              child: const Text(
                'Recent Messages',
                style: TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 10)),
          //for (int i = 0; i < 4; i++)
          Expanded(
            child: ListView(
              children: [
                createGroupChatTab(),
                if (globals.myUser!.recentRooms != null)
                  if (globals.myUser!.recentRooms != [])
                    //Return New Messages
                    for (int i = 0; i < globals.myUser!.recentRooms!.length; i++)
                      if (isNewMessage(globals.myUser!.recentRooms!.reversed.toList()[i]) == true)
                        getRooms(globals.myUser!.recentRooms!.reversed.toList()[i]),
                if (globals.myUser!.recentRooms != null)
                  if (globals.myUser!.recentRooms != [])
                    //Return other most recent Messages
                    for (int i = 0; i < globals.myUser!.recentRooms!.length; i++)
                      if (isNewMessage(globals.myUser!.recentRooms!.reversed.toList()[i]) == false)
                        getRooms(globals.myUser!.recentRooms!.reversed.toList()[i])
              ],
            ),
          )
        ],
      ),
    );
  }

  getRooms(room) {
    return FutureBuilder(
      future: getRecentRooms(room),
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasData) {
          return snapshot.data;
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
              child: SizedBox(
                  height: 60,
                  width: 60,
                  child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator())));
        }
      },
    );
  }

  // QuerySnapshot? searchSnapshot;
  // void initSearch() {
  //   databaseMethods.getByUserName(searchController.text).then((val) {
  //     print(val.toString());
  //     searchSnapshot = val;
  //     print(searchSnapshot);
  //   });
  // }

  void createGroupChatRoom(Map<String, dynamic> data) async {
    String chatRoomId = data["chatRoomId"];

    //List<String> users = [data['fullName'], globals.myUser!.fullName!];
    ////users.sort();
    //List<String> uids = [data['uid'], globals.myUser!.uid!];
    //uids.sort();

    // Map<String, dynamic> chatRoomMap = {
    //   "users": users,
    //   "uids": uids,
    //   "chatRoomId": chatRoomId,
    // };

    // databaseMethods.createChatRoom(chatRoomId, chatRoomMap);
    //globals.index = 3;

    Map<String, UserModel> userModels = {};
    for (String userID in data['uids']) {
      userModels[userID] = (globals.loadedUsers.containsKey(userID))
          ? globals.loadedUsers[userID]!
          : await FirebaseFirestore.instance.collection("users").doc(userID).get().then((valur) {
              globals.loadedUsers[userID] = UserModel.fromMap(valur.data()!);
              return UserModel.fromMap(valur.data());
            });
    }

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                chatRoomId: chatRoomId,
                chatUserDatas: userModels,
                isGroupChat: true,
                chatRoomData: data)));

    setState(() {});
  }

  void createChatRoom(Map<String, dynamic> data) async {
    String chatRoomId = getChatRoomId('${data['uid']}', '${globals.myUser!.uid}');

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

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(
                chatRoomId: chatRoomId,
                chatUserDatas: {data['uid']: UserModel.fromMap(data)},
                isGroupChat: false)));

    setState(() {});
  }

  Future<Widget> getRecentRooms(chatRoomId) async {
    bool isGroupChat = false;
    UserModel targetUserModel = UserModel();

    final roomData = await FirebaseFirestore.instance.collection('ChatRoom').doc(chatRoomId).get();
    print(roomData.metadata.isFromCache);
    // print(roomData.data());
    if (roomData.data()!["isGroupChat"] != null) {
      print("GROUP CHAT FOUND");
      isGroupChat = roomData.data()!["isGroupChat"];
    }
    if (isGroupChat == false) {
      if (roomData["uids"][0] != globals.myUser!.uid) {
        if (globals.loadedUsers.keys.contains(roomData["uids"][0])) {
          targetUserModel = globals.loadedUsers[roomData["uids"][0]]!;
          print("LOADED USER FROM cache");
        } else {
          await FirebaseFirestore.instance.collection("users").doc(roomData["uids"][0]).get().then(
            (value) {
              print(value.metadata.isFromCache);

              targetUserModel = UserModel.fromMap(value.data());
              globals.loadedUsers[roomData["uids"][0]] = targetUserModel;
              print("LOADED USER FROM firebase");
            },
          );
        }
      } else {
        if (globals.loadedUsers.keys.contains(roomData["uids"][1])) {
          targetUserModel = globals.loadedUsers[roomData["uids"][1]]!;
          print("LOADED USER FROM cache");
        } else {
          await FirebaseFirestore.instance.collection("users").doc(roomData["uids"][1]).get().then(
            (value) {
              print(value.metadata.isFromCache);

              targetUserModel = UserModel.fromMap(value.data());
              globals.loadedUsers[roomData["uids"][1]] = targetUserModel;
              print("LOADED USER FROM firebase");
            },
          );
        }
      }
      // print('///////////////////////////////////////////////////');
      // print(targetUserModel.toMap());
      // print('///////////////////////////////////////////////////');
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
    }

    //globals.myUser?.newMessages?.forEach((element) {
    return GestureDetector(
      onTap: () {
        if (isGroupChat) {
          createGroupChatRoom(roomData.data()!);
        } else {
          createChatRoom(
            targetUserModel.toMap(),
          );
        }
      },
      onLongPress: () {
        copyRoomId(roomData.data()!["chatRoomId"]);
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
                  Text(
                    (isGroupChat) ? roomData.data()!["groupName"] : targetUserModel.nickname!,
                    style: getRoomTextStyle(chatRoomId),
                  ),
                  Text(
                    (isGroupChat)
                        ? (roomData.data()!["groupDescription"] != null &&
                                roomData.data()!["groupDescription"]!.trim() != "")
                            ? (roomData.data()!["groupDescription"]!.trim().length < 66)
                                ? roomData.data()!["groupDescription"]!.trim().replaceAll("\n", " ")
                                : "${roomData.data()!["groupDescription"]!.trim().replaceAll("\n", " ").substring(0, 65)}..."
                            : "karpportal enjoyer"
                        : (targetUserModel.description != null &&
                                targetUserModel.description!.trim() != "")
                            ? (targetUserModel.description!.trim().length < 66)
                                ? targetUserModel.description!.trim().replaceAll("\n", " ")
                                : "${targetUserModel.description!.trim().replaceAll("\n", " ").substring(0, 65)}..."
                            : "karpportal enjoyer",
                    style: const TextStyle(fontWeight: FontWeight.w300, fontSize: 14),
                  ),
                ],
              ),
              leading: Hero(
                tag: (isGroupChat) ? roomData.data()!["groupDescription"] : targetUserModel.uid!,
                child: ClipOval(
                  //clipper: MyClipper(),
                  child: CachedNetworkImage(
                    imageUrl: (isGroupChat)
                        ? roomData.data()!["groupAvatarUrl"] ??
                            "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse4.explicit.bing.net%2Fth%3Fid%3DOIP.TolLwDCaTfUkxM3v-ZCqUgAAAA%26pid%3DApi&f=1"
                        : targetUserModel.avatarUrl!,
                    width: 55,
                    height: 55,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              trailing: Icon(Icons.message,
                  color: (globals.isDarkTheme!) ? Colors.white : Colors.grey.shade900),
            ),
          ],
        ),
      ),
    );
  }

  copyRoomId(String? id) {
    if (id != null) {
      String copyID = "!#id!*" + id;
      Clipboard.setData(ClipboardData(text: copyID));
      Fluttertoast.showToast(msg: "Chat Room Id copied succesfully ($id)");
    }
  }

  void refresh() async {
    await FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then(
      (value) {
        loggedInUser = UserModel.fromMap(value.data());
        globals.myUser = loggedInUser;

        setState(() {});
      },
    );
  }

  getRoomTextStyle(String chatRoomId) {
    bool isNewMessage = false;

    if (globals.myUser!.newMessages != null && globals.myUser!.newMessages != []) {
      for (int i = 0; i < globals.myUser!.newMessages!.length; i++) {
        if (globals.myUser!.newMessages![i] == chatRoomId) {
          isNewMessage = true;
          break;
        }
      }
    }
    if (isNewMessage) {
      return const TextStyle(fontWeight: FontWeight.w800);
    } else {
      return const TextStyle(fontWeight: FontWeight.w400);
    }
  }

  bool isNewMessage(String chatRoomId) {
    bool isNewMessage = false;

    if (globals.myUser!.newMessages != null && globals.myUser!.newMessages != []) {
      for (int i = 0; i < globals.myUser!.newMessages!.length; i++) {
        if (globals.myUser!.newMessages![i] == chatRoomId) {
          isNewMessage = true;
          break;
        }
      }
    }
    return isNewMessage;
  }

  Widget createGroupChatTab() {
    return GestureDetector(
      onTap: createGroupChat,
      child: Container(
        margin: const EdgeInsets.only(left: 20, right: 16),
        height: 55,
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Container(
                    height: 55,
                    width: 55,
                    alignment: Alignment.center,
                    color: globals.primarySwatch,
                    child: const Icon(Icons.add, size: 30),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text("Create Group Chat",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Text("chat with friends all in one go",
                        style: TextStyle(fontWeight: FontWeight.w400)),
                  ],
                ),
              ],
            ),
            const Icon(Icons.add_circle),
          ],
        ),
      ),
    );
  }

  void createGroupChat() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const GroupChatCreator()));
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
