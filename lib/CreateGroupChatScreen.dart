import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'ChatScreen.dart';
import 'MessagesScreen.dart';
import 'Stylings.dart';
import 'UserModel.dart';
import 'globals.dart' as globals;

class GroupChatCreator extends StatefulWidget {
  const GroupChatCreator({Key? key}) : super(key: key);

  @override
  State<GroupChatCreator> createState() => _GroupChatCreatorState();
}

TextEditingController groupNameController = TextEditingController();
TextEditingController groupDescriptionController = TextEditingController();

final formKey = GlobalKey<FormState>();

class _GroupChatCreatorState extends State<GroupChatCreator> {
  String? imageUrl;
  bool selected = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cretate Group Chat"), actions: [
        IconButton(
            icon: Icon(Icons.warning),
            onPressed: () {
              setState(() {
                selected = !selected;
              });
            })
      ]),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  // margin: EdgeInsets.only(top: 20),
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: globals.isDarkTheme! ? Colors.grey.shade900 : Colors.grey.shade300,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        left: selected ? 20 : null,
                        right: selected ? null : 20,
                        child: Text(groupNameController.text.trim().toUpperCase(),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ),
                      Positioned(
                        top: 10,
                        left: 20,
                        child: Container(
                          width: MediaQuery.of(context).size.width - 60,
                          alignment: Alignment.center,
                          child: AnimatedAlign(
                            // curve: Curves.fastOutSlowIn,
                            curve: Curves.bounceOut,
                            duration: Duration(seconds: 1),
                            alignment: selected ? Alignment.centerRight : Alignment.centerLeft,
                            child: ClipOval(
                              child: Image.network(
                                imageUrl ??
                                    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse4.explicit.bing.net%2Fth%3Fid%3DOIP.TolLwDCaTfUkxM3v-ZCqUgAAAA%26pid%3DApi&f=1",
                                fit: BoxFit.fill,
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 5, top: 10 + 60),
                  child: Text("GROUP NAME",
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                ),
                TextFormField(
                  controller: groupNameController,
                  decoration: InputDecoration(
                    hintText: "Group Name",
                    border: inactiveRoundBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val == "") return "value can not be null";
                    if (val.length > 25) {
                      return "name too long";
                    }
                  },
                  onChanged: (val) {
                    setState(() {
                      selected = !selected;
                    });
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 5, top: 10),
                  child: Text("GROUP DESCRIPTION",
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                ),
                TextFormField(
                  controller: groupDescriptionController,
                  decoration: InputDecoration(
                    hintText: "Group Description",
                    border: inactiveRoundBorder(),
                  ),
                  validator: (val) {
                    if (val == null || val == "") return "value can not be null";
                    if (val.length > 200) {
                      return "description too long";
                    }
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape:
                          MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(),
                      )),
                    ),
                    onPressed: createGroupChat,
                    child: Text("Create Group Chat"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void createGroupChat() async {
    if (formKey.currentState?.validate() == false) {
      return;
    }

    String chatRoomId = getChatRoomId();
    print("got room id");

    List<String> users = [globals.myUser!.nickname ?? "none"];
    //users.sort();
    List<String> uids = [
      globals.myUser!.uid!,
    ];
    print("created list of uids");
    //uids.sort();

    Map<String, dynamic> chatRoomMap = {
      "adminIDs": [globals.myUser!.uid!],
      "users": users,
      "uids": uids,
      "chatRoomId": chatRoomId,
      "isGroupChat": true,
      "groupName": groupNameController.text,
      "groupDescription": groupDescriptionController.text,
      "groupAvatarUrl":
          "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse4.explicit.bing.net%2Fth%3Fid%3DOIP.TolLwDCaTfUkxM3v-ZCqUgAAAA%26pid%3DApi&f=1"
    };
    print("created chat room map");

    await databaseMethods.createChatRoom(chatRoomId, chatRoomMap);
    Fluttertoast.showToast(msg: "Creation of group");
    //globals.index = 3;

    Map<String, UserModel> userModels = {
      globals.myUser!.uid!: globals.myUser!,
      // "njsbR2mPfSPdJRAfHtKsKeksfRn2": await FirebaseFirestore.instance
      //     .collection("users")
      //     .doc("njsbR2mPfSPdJRAfHtKsKeksfRn2")
      //     .get()
      //     .then((valur) {
      //   print("returning srtefan");
      //   return UserModel.fromMap(valur.data());
      // }),
      // "83jnvcAHO7O0H5A284klQOhNXcs2": await FirebaseFirestore.instance
      //     .collection("users")
      //     .doc("83jnvcAHO7O0H5A284klQOhNXcs2")
      //     .get()
      //     .then((valur) {
      //   print("returning gandalf");
      //   return UserModel.fromMap(valur.data());
      // })
    };
    print("created user models");
    for (String userID in uids) {
      print("notifying user");
      await FirebaseFirestore.instance.collection("users").doc(userID).set({
        "recentRooms": FieldValue.arrayUnion([chatRoomId])
      }, SetOptions(merge: true));
    }
    print("notified users");

    // await Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         ChatPage(chatRoomId: chatRoomId, chatUserDatas: userModels, isGroupChat: true),
    //   ),
    // );
    imageUrl = "";
    groupDescriptionController.text = "";
    groupNameController.text = "";
    Navigator.pop(context);

    setState(() {});
  }

  String getChatRoomId() {
    return "${globals.myUser!.uid!}-${DateTime.now().millisecondsSinceEpoch}";
  }
}
