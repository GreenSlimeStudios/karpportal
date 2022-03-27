import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karpportal/Database.dart';
import 'package:karpportal/SearchScreen.dart';
import 'package:karpportal/UserModel.dart';
// import 'package:media_scanner/media_scanner.dart';
// import 'package:flutter_media_scanner/flutter_media_scanner.dart';

import 'globals.dart' as globals;

class ChatPage extends StatefulWidget {
  const ChatPage(
      {Key? key, required this.chatRoomId, required this.chatUserData})
      : super(key: key);
  final String chatRoomId;
  final Map<String, dynamic> chatUserData;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

String time3 = "";
TextEditingController messageController = new TextEditingController();

class _ChatPageState extends State<ChatPage> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  r() {
    setState(() {});
  }

  //Stream<QuerySnapshot>? chatMessagesStream;

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then(
      (value) {
        loggedInUser = UserModel.fromMap(value.data());

        setState(() {});
      },
    );
    scrollToBottom();
    removePing();
  }

  scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 300));
    scroll();
  }

  removePing() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then(
      (value) {
        loggedInUser = UserModel.fromMap(value.data());

        setState(() {});
      },
    );
    print(loggedInUser.toMap());
    if (loggedInUser.newMessages != null) {
      //loggedInUser.newMessages?.forEach((element) {if(element == widget.chatRoomId){element.}});
      for (int i = 0; i < loggedInUser.newMessages!.length; i++) {
        if (loggedInUser.newMessages![i].toString() == widget.chatRoomId) {
          loggedInUser.newMessages?.remove(widget.chatRoomId);
          await firebaseFirestore
              .collection("users")
              .doc(loggedInUser.uid)
              .set(loggedInUser.toMap());
        }
      }
    }
    setState(() {
      loggedInUser;
    });
  }

  final ScrollController _scrollController = ScrollController();
  bool isImage = false;

  void sendMessage() {
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
    Map<String, dynamic> messageMap;
    //time3 = DateTime.now().toString();
    if (isImage == false) {
      if (messageController.text.isNotEmpty) {
        messageMap = {
          "message": messageController.text,
          "sendBy": loggedInUser.fullName!,
          "time": DateTime.now().millisecondsSinceEpoch,
          "time2": '${DateTime.now().year}/${month}/${day} ${hour}:${minute}',
          "time3": time3,
          "isImage": isImage,
        };
        databaseMethods.addConversationMessages(
            widget.chatRoomId, messageMap, isImage);
        messageController.text = "";
        notifyUser();
        // setState(() {
        //   //scrollToBottom();
        // });
      }
    } else {
      messageMap = {
        "message": imageUrl,
        "sendBy": loggedInUser.fullName!,
        "time": DateTime.now().millisecondsSinceEpoch,
        "time2": '${DateTime.now().year}/${month}/${day} ${hour}:${minute}',
        "time3": time3,
        "isImage": isImage,
      };

      databaseMethods.addConversationMessages(
          widget.chatRoomId, messageMap, isImage);
      //messageController.text = "";
      notifyUser();
      // setState(() {
      //   isImage == false;
      //   //scrollToBottom();
      // });
    }
  }

  scroll() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn);
  }

  bool showTime = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              //setState(() {});
              r();
            },
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () {
              //setState(() {});
              scroll();
            },
            icon: const Icon(Icons.arrow_downward_rounded),
          )
        ],
        foregroundColor: Colors.white,
        title: Container(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(widget.chatUserData["fullName"]),
              const Padding(padding: const EdgeInsets.only(right: 10)),
              ClipOval(
                child: Image.network(
                  widget.chatUserData['avatarUrl'],
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("ChatRoom")
                .doc(widget.chatRoomId)
                .collection("chat")
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return (snapshot.connectionState == ConnectionState.waiting)
                  ? const Center(
                      child: const CircularProgressIndicator(),
                    )
                  : Expanded(
                      child: ListView.builder(
                        reverse: true,
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length,
                        // itemCount: 2,

                        itemBuilder: (context, index) {
                          var data = snapshot.data!.docs[index].data()
                              as Map<String, dynamic>;
                          if (data != null) {
                            return (data['sendBy'] != globals.myUser!.fullName)
                                ? Container(
                                    margin: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 5),
                                                  child: MessageImage(data),
                                                ),
                                                GestureDetector(
                                                  onLongPress: () {
                                                    messageActions(data);
                                                  },
                                                  child: Container(
                                                    //height: 30,
                                                    decoration: BoxDecoration(
                                                        color: globals
                                                            .primarySwatch,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Padding(
                                                      child: Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                                maxWidth: 250),
                                                        child: generateMessage(
                                                            data),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              top: 5,
                                                              right: 10,
                                                              bottom: 5),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 5)),
                                          ],
                                        ),
                                        if (data['time2'] != null &&
                                            showTime == true)
                                          Positioned(
                                            bottom: 0,
                                            left: 50,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  data['time2'].toString(),
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w200),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                : Container(
                                    alignment: Alignment.centerRight,
                                    margin: const EdgeInsets.only(
                                      left: 10,
                                      right: 10,
                                    ),
                                    child: Stack(
                                      children: [
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                GestureDetector(
                                                  onLongPress: () {
                                                    messageActions(data);
                                                  },
                                                  child: Container(
                                                    //height: 30,
                                                    decoration: BoxDecoration(
                                                        color: getColor(),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    margin:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Padding(
                                                      child: Container(
                                                        constraints:
                                                            const BoxConstraints(
                                                                maxWidth: 250),
                                                        child: generateMessage(
                                                            data),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10,
                                                              top: 5,
                                                              right: 10,
                                                              bottom: 5),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          bottom: 5),
                                                  child: MessageImage(data),
                                                ),
                                              ],
                                            ),
                                            const Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 5)),
                                          ],
                                        ),
                                        if (data['time2'] != null &&
                                            showTime == true)
                                          Positioned(
                                            bottom: 0,
                                            right: 50,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  data['time2'].toString(),
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w200),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
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
              // child: ChatMessageList()
              ),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    width: 50,
                    child: TextButton(
                      onPressed: pickImage,
                      child: Icon(Icons.image),
                    ),
                  ),
                  Container(
                    child: Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Container(
                          child: TextField(
                            controller: messageController,
                            minLines: 1,
                            maxLines: 6,
                            //maxLength: 1000,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.all(8),
                              //isDense: true,
                              hintText: 'message',
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15.0))),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 5)),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 50,
                    width: 50,
                    child: FloatingActionButton(
                      onPressed: sendMessage,
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  MessageImage(data) {
    if (data['sendBy'] == globals.myUser!.fullName) {
      return ClipOval(
        child: Image.network(
          globals.myUser!.avatarUrl!,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return ClipOval(
        child: Image.network(
          widget.chatUserData['avatarUrl'],
          width: 35,
          height: 35,
          fit: BoxFit.cover,
        ),
      );
    }
  }

  void refresh() {
    setState(() {
      loggedInUser = loggedInUser;
    });
  }

  String? imageUrl;
  final _storage = FirebaseStorage.instance;
  File? imageTemporary;
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Future pickImage() async {
    time3 = DateTime.now().toString();
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      imageTemporary = File(image.path);

      globals.image = imageTemporary;
    } on PlatformException catch (e) {
      print('failed tp pick image $e');
    }
    //final ref = FirebaseStorage
    var snapshot = await _storage
        .ref()
        .child(
            'ChatImages/${loggedInUser.uid} $time3 ${widget.chatUserData['uid']}')
        .putFile(imageTemporary!);

    var downloadurl = await snapshot.ref.getDownloadURL();

    imageUrl = downloadurl;
    isImage = true;
    sendMessage();
    isImage = false;
  }

  generateMessage(data) {
    if (data["isImage"] != null) {
      return (data["isImage"] == false)
          ? Text(
              data["message"],
              style: const TextStyle(color: Colors.white),
            )
          : GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Image.network(data["message"])));
              },
              child: Padding(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: Image.network(data["message"])),
            );
    } else {
      return Text(
        data["message"],
        style: const TextStyle(color: Colors.white),
      );
    }
  }

  copyMessage(Map<String, dynamic> data, String message) {
    Clipboard.setData(ClipboardData(text: data["message"]));
    Fluttertoast.showToast(msg: '${message} copied succesfully');
  }

  downloadImage(Map<String, dynamic> data, String url) async {
    // final Reference ref = FirebaseStorage.instance.ref(
    //     'ChatImages/${loggedInUser.uid} ${data["time3"]} ${widget.chatUserData['uid']}');
    // final result = await ref.getDownloadURL();
    // final dir = await getApplicationDocumentsDirectory();
    // File file = File('${dir.path}/${ref.name}');
    // await ref.writeToFile(file);
    // print('///////////////////////////////////////////');
    // print(result);
    // print('///////////////////////////////////////////');
    // // await downloadFile(ref);
    // // Navigator.push(
    // //     context, MaterialPageRoute(builder: (context) => Image.file(file)));
    // Image.file(file);

    // print(dir.path);
    // await ref.writeToFile(file);
    // print(file.toString());
    // await MediaScanner.loadMedia(path: dir.path);

    try {
      await ImageDownloader.downloadImage(url,
          destination: AndroidDestinationType.directoryDownloads
            ..subDirectory("karpportal.png"));
    } on PlatformException catch (error) {
      print(error);
    }

    //ImageDownloader.downloadImage(url,destination: );

    Fluttertoast.showToast(msg: 'Image downloaded sucessfully');
    Navigator.pop(context);
  }

  static Future downloadFile(Reference ref) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${ref.name}');

    await ref.writeToFile(file);
  }

  void messageActions(
    Map<String, dynamic> data,
  ) {
    if (data["isImage"] != null) {
      if (data["isImage"] == true) {
        createAlertDialog(data, context);
      } else {
        copyMessage(data, "message");
      }
    } else {
      copyMessage(data, "message");
    }
  }

  createAlertDialog(Map<String, dynamic> data, BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('what do you?'),
          content: Container(
            height: 200,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    copyMessage(data, 'image url');
                    Navigator.pop(context);
                  },
                  child: Text('copy image url'),
                ),
                TextButton(
                  onPressed: () {
                    //copyMessage(data,"");
                    downloadImage(data, data["message"]);
                    //Navigator.pop(context);
                  },
                  child: Text('download image'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void notifyUser() async {
    isImage = false;
    final roomData = await FirebaseFirestore.instance
        .collection('ChatRoom')
        .doc(widget.chatRoomId)
        .get();
    // print('///////////////////////////////////////////////////');
    // print(roomData.toString());
    // print(roomData["users"][1]);
    // print('///////////////////////////////////////////////////');

    bool isAlready = false;
    UserModel targetUserModel = UserModel();

    if (roomData["uids"][0] != loggedInUser.uid) {
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
    if (targetUserModel.newMessages != null) {
      targetUserModel.newMessages?.forEach((element) {
        if (element == widget.chatRoomId) {
          isAlready = true;
        }
      });
      if (isAlready == false) {
        targetUserModel.newMessages?.add(widget.chatRoomId);
      }
    } else {
      targetUserModel.newMessages = [widget.chatRoomId];
    }

    // await FirebaseFirestore.instance
    //     .collection("users")
    //     .doc(roomData["uids"][0])
    //     .get()
    //     .then(
    //   (value) {
    //     targetUserModel = UserModel.fromMap(value.data());
    //     //setState(() {});
    //   },
    // );

    // bool hasAlready = false;
    // List<String> newMessages;
    // if (targetUserData["newMessages"] != null) {
    //   newMessages = targetUserData["newMessages"] as List<String>;
    //   newMessages.forEach(
    //     (element) {
    //       if (element == widget.chatRoomId) {
    //         hasAlready = true;
    //       }
    //     },
    //   );
    //   if (hasAlready == false) {
    //     newMessages.add(widget.chatRoomId);
    //   }
    // } else {
    //   newMessages = [widget.chatRoomId];
    // }

    //targetUserData["newMessages"] = newMessages;

    await firebaseFirestore
        .collection("users")
        .doc(targetUserModel.uid)
        .set(targetUserModel.toMap());

    // print('///////////////////////////////////////////////////');
    // print(targetUserModel.toMap());
    // print('///////////////////////////////////////////////////');

    setState(() {});
  }

  getColor() {
    if (globals.primaryColor.toString() != globals.primarySwatch.toString()) {
      return globals.primaryColor!;
    } else {
      if (globals.primaryColor.toString() != Colors.deepOrange.toString()) {
        return Colors.deepOrange;
      } else {
        return Colors.orange;
      }
    }
  }
}
