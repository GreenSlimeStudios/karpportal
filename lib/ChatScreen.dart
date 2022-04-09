import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:pinch_zoom/pinch_zoom.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:http/http.dart' as http;
// import 'package:photo_view/photo_view.dart';
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

bool isLink = false;
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
    // FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then(
    //   (value) {
    //     loggedInUser = UserModel.fromMap(value.data());

    //     setState(() {});
    //   },
    // );
    // scrollToBottom();
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
    isLink = false;
    if (messageController.text.startsWith('https://')) {
      isLink = true;
      if (messageController.text.endsWith('.png') ||
          messageController.text.endsWith('.jpg') ||
          messageController.text.endsWith('.webp') ||
          messageController.text.endsWith('.svg') ||
          messageController.text.endsWith('.pjp') ||
          messageController.text.endsWith('.pjpeg') ||
          messageController.text.endsWith('.jfif') ||
          messageController.text.endsWith('.avif') ||
          messageController.text.endsWith('.apng') ||
          messageController.text.endsWith('.jpeg') ||
          messageController.text.endsWith('.gif')) {
        isImage = true;
        imageUrl = messageController.text;
        messageController.text = "";
      }
    }

    if (isImage) isLink = true;

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
          "isLink": isLink,
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
        "isLink": isLink,
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
    isImage = false;
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
              Hero(
                tag: 'targetAvatar',
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.chatUserData['avatarUrl'],
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),

                  //   widget.chatUserData['avatarUrl'],
                  //   width: 40,
                  //   height: 40,
                  //   fit: BoxFit.cover,
                  //   loadingBuilder: (BuildContext context, Widget child,
                  //       ImageChunkEvent? loadingProgress) {
                  //     if (loadingProgress == null) return child;
                  //     return Center(
                  //       child: CircularProgressIndicator(
                  //         value: loadingProgress.expectedTotalBytes != null
                  //             ? loadingProgress.cumulativeBytesLoaded /
                  //                 loadingProgress.expectedTotalBytes!
                  //             : null,
                  //       ),
                  //     );
                  //   },
                  // ),
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
                      onPressed: sendImage,
                      child: Icon(
                        Icons.image,
                        color: globals.primarySwatch,
                      ),
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
                              hintText: 'message',
                              border: OutlineInputBorder(
                                // borderSide: BorderSide(color: globals.primarySwatch!),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15.0)),
                              ),
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
                      backgroundColor: globals.primarySwatch,
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
        child: CachedNetworkImage(
          imageUrl: globals.myUser!.avatarUrl!,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        // Image.network(
        //   globals.myUser!.avatarUrl!,
        //   width: 35,
        //   height: 35,
        //   fit: BoxFit.cover,
        //   loadingBuilder: (BuildContext context, Widget child,
        //       ImageChunkEvent? loadingProgress) {
        //     if (loadingProgress == null) return child;
        //     return Center(
        //       child: CircularProgressIndicator(
        //         value: loadingProgress.expectedTotalBytes != null
        //             ? loadingProgress.cumulativeBytesLoaded /
        //                 loadingProgress.expectedTotalBytes!
        //             : null,
        //       ),
        //     );
        //   },
        // ),
      );
    } else {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: widget.chatUserData['avatarUrl'],
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
        // child: Image.network(
        //   widget.chatUserData['avatarUrl'],
        //   width: 35,
        //   height: 35,
        //   fit: BoxFit.cover,
        //   loadingBuilder: (BuildContext context, Widget child,
        //       ImageChunkEvent? loadingProgress) {
        //     if (loadingProgress == null) return child;
        //     return Center(
        //       child: CircularProgressIndicator(
        //         value: loadingProgress.expectedTotalBytes != null
        //             ? loadingProgress.cumulativeBytesLoaded /
        //                 loadingProgress.expectedTotalBytes!
        //             : null,
        //       ),
        //     );
        //   },
        // ),
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
      if (imageTemporary!.lengthSync() > 20000000) {
        Fluttertoast.showToast(
            msg: 'bruh are you tryin to fuck up my cloud storage?');
        return;
      }

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
          ? pureText(data)
          : GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PinchZoom(
                      child: CachedNetworkImage(
                        imageUrl: data["message"],
                        //fit: BoxFit.fill,
                        progressIndicatorBuilder:
                            (context, url, downloadProgress) =>
                                CircularProgressIndicator(
                                    value: downloadProgress.progress),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(top: 5, bottom: 5),
                child: CachedNetworkImage(
                  imageUrl: data["message"],
                  fit: BoxFit.fill,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            );
    } else {
      return pureText(data);
    }
  }

  Widget pureText(data) {
    if (data["isLink"] != null) {
      return (data["isLink"] == true)
          ? GestureDetector(
              onTap: () {
                launch(data['message']);
              },
              child: Text(
                data["message"],
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Color.fromARGB(255, 0, 102, 255),
                    decoration: TextDecoration.underline),
              ),
            )
          : Text(
              data["message"],
              style: const TextStyle(color: Colors.white),
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

    // print(roomData.metadata.isFromCache);

    bool isAlready = false;
    UserModel targetUserModel = UserModel();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(globals.myUser!.uid)
        .get()
        .then(
      (value) {
        globals.myUser = UserModel.fromMap(value.data());
      },
    );

    if (roomData["uids"][0] != loggedInUser.uid) {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(roomData["uids"][0])
          .get()
          .then(
        (value) {
          // print(value.metadata.isFromCache);
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
          // print(value.metadata.isFromCache);
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
    //Make room most recent in both users
    if (targetUserModel.recentRooms != null) {
      for (int i = 0; i < targetUserModel.recentRooms!.length; i++) {
        if (targetUserModel.recentRooms![i] == widget.chatRoomId) {
          targetUserModel.recentRooms!.remove(targetUserModel.recentRooms![i]);
        }
      }
      targetUserModel.recentRooms?.add(widget.chatRoomId);
    } else {
      targetUserModel.recentRooms = [widget.chatRoomId];
    }
    if (globals.myUser!.recentRooms != null) {
      for (int i = 0; i < globals.myUser!.recentRooms!.length; i++) {
        if (globals.myUser!.recentRooms![i] == widget.chatRoomId) {
          globals.myUser!.recentRooms!.remove(globals.myUser!.recentRooms![i]);
        }
      }
      globals.myUser!.recentRooms?.add(widget.chatRoomId);
    } else {
      globals.myUser!.recentRooms = [widget.chatRoomId];
    }

    await firebaseFirestore
        .collection("users")
        .doc(targetUserModel.uid)
        .set(targetUserModel.toMap());

    await firebaseFirestore
        .collection("users")
        .doc(globals.myUser!.uid)
        .set(globals.myUser!.toMap());

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

  Future sendImage() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //title: Text('what do you?'),
          content: Container(
            height: 100,
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    pickImage();
                    Navigator.pop(context);
                  },
                  child: Text('image from gallery'),
                ),
                TextButton(
                  onPressed: () {
                    //copyMessage(data,"");
                    pickImageUrl();
                    //Navigator.pop(context);
                  },
                  child: Text('image from url'),
                ),
              ],
            ),
          ),
        );
      },
    );
    //pickImage();
  }

  TextEditingController urlController = TextEditingController();

  Future pickImageUrl() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //title: Text('what do you?'),
          content: Container(
            height: 100,
            child: Column(
              children: [
                TextField(controller: urlController),
                ElevatedButton(
                  onPressed: () async {
                    imageUrl = urlController.text;
                    isImage = true;
                    sendMessage();
                    isImage = false;
                    Navigator.pop(context);
                  },
                  child: Text('accept'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void sendPushMessage(String token, String body, String title) async {
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAA9xPglTQ:APA91bEuI1Hg2Mw6dLpBuh2bDvJfgcYOUm_rEUhq3glaPRzICYtTUQEG6iFF1r_EeWx3B_wC9sTDVxk0x1PYgcSh-N9Di4qG-GNF3LVDjhc9F5B_cfEqvdky-Rc1ILwdAc1oqtB5Ho8v',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          "to": token,
        },
      ),
    );
  } catch (e) {
    print("error push notification");
  }
}
