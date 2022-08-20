import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:karpportal/secrets/apiKeys.dart';
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
      {Key? key,
      required this.chatRoomId,
      required this.chatUserDatas,
      required this.isGroupChat,
      this.chatRoomData})
      : super(key: key);
  final String chatRoomId;
  final Map<String, UserModel> chatUserDatas;
  final bool isGroupChat;
  final Map<String, dynamic>? chatRoomData;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

final ScrollController _scrollController = ScrollController();
bool isLink = false;
String time3 = "";
TextEditingController messageController = TextEditingController();
List<String> imageUrls = [];

class _ChatPageState extends State<ChatPage> {
  int messagesLimit = 40;
  bool hasToJumpToTop = false;
  DatabaseMethods databaseMethods = DatabaseMethods();
  r() {
    setState(() {});
  }

  //Stream<QuerySnapshot>? chatMessagesStream;

  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.atEdge) {
        bool isTop = _scrollController.position.pixels == 0;
        if (isTop) {
          print('At the top');
        } else {
          print('At the bottom');
          // messagesLimit += 40;
          // setState(() {
          //   hasToJumpToTop = true;
          // });
          // // _scrollController.animateTo(_scrollController.position.minScrollExtent,
          //     duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
        }
      }
    });

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
    await FirebaseFirestore.instance.collection("users").doc(user!.uid).get().then(
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
    if (imageUrls.isEmpty) {
      if (messageController.text.isNotEmpty) {
        messageMap = {
          "message": databaseMethods.encrypt(messageController.text.trim()),
          "sendBy": globals.myUser!.fullName!,
          "time": DateTime.now().millisecondsSinceEpoch,
          "time2": '${DateTime.now().year}/$month/$day $hour:$minute',
          "time3": time3,
          "authorID": globals.myUser!.uid!,
          "isLink": isLink,
          // "images": imageUrls,
          "supportsEncryption": true,
        };
        databaseMethods.addConversationMessages(widget.chatRoomId, messageMap, isImage);
        print("lasagna");
        notifyUser(messageController.text);
        messageController.text = "";
        imageUrls = [];
        // setState(() {
        //   //scrollToBottom();
        // });
      }
    } else {
      messageMap = {
        "message": databaseMethods.encrypt(messageController.text.trim()),
        "sendBy": globals.myUser!.fullName!,
        "authorID": globals.myUser!.uid!,
        "time": DateTime.now().millisecondsSinceEpoch,
        "time2": '${DateTime.now().year}/$month/$day $hour:$minute',
        "time3": time3,
        "images": imageUrls,
        "isLink": isLink,
        "supportsEncryption": true,
      };

      databaseMethods.addConversationMessages(widget.chatRoomId, messageMap, isImage);
      if (messageController.text != "") {
        notifyUser("image sent (${imageUrls.length})\n${messageController.text}");
      } else {
        notifyUser("image sent (${imageUrls.length})");
      }
      messageController.text = "";
      imageUrls = [];
      setState(() {});
      // setState(() {
      //   isImage == false;
      //   //scrollToBottom();
      // });
    }
    isImage = false;
    imageUrls = [];
  }

  scroll() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
  }

  @override
  Widget build(BuildContext context) {
    if (hasToJumpToTop) {
      print("JUMPING TO TOP");
      // _scrollController.jumpTo(100);
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500), curve: Curves.fastOutSlowIn);
      hasToJumpToTop = false;
    }
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: (() => () {
                    setState(() {});
                  }),
              icon: const Icon(Icons.refresh)),
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
              Text((widget.isGroupChat)
                  ? widget.chatRoomData!["groupName"]
                  : widget.chatUserDatas.values.toList()[0].nickname!),
              const Padding(padding: EdgeInsets.only(right: 10)),
              Hero(
                tag: widget.chatUserDatas.values.toList()[0].uid!,
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: (widget.isGroupChat)
                        ? widget.chatRoomData!["groupAvatarUrl"]
                        : widget.chatUserDatas.values.toList()[0].avatarUrl!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("ChatRoom")
                .doc(widget.chatRoomId)
                .collection("chat")
                .orderBy('time', descending: true)
                // .limit(messagesLimit)
                .snapshots(),
            builder: (context, snapshot) {
              return (snapshot.connectionState == ConnectionState.waiting)
                  ? const Expanded(
                      child: Center(child: CircularProgressIndicator(color: Colors.white)))
                  : Expanded(
                      child: ListView.builder(
                        reverse: true,
                        controller: _scrollController,
                        itemCount: snapshot.data!.docs.length,
                        // itemCount: 2,

                        itemBuilder: (context, index) {
                          var data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                          Map<String, dynamic>? dataAfter;
                          Map<String, dynamic>? dataPrevious;
                          if (index > 1)
                            dataAfter =
                                snapshot.data!.docs[index - 2].data() as Map<String, dynamic>;
                          if (index != 0)
                            dataPrevious =
                                snapshot.data!.docs[index - 1].data() as Map<String, dynamic>;
                          if (data != null) {
                            return (data['sendBy'] != globals.myUser!.fullName)
                                ? ChatMessage(
                                    data: data,
                                    chatRoomId: widget.chatRoomId,
                                    chatUserDatas: widget.chatUserDatas,
                                    isGroupChat: widget.isGroupChat,
                                    isMyMessage: false,
                                    dataPrevious: dataPrevious,
                                    dataAfter: dataAfter,
                                  )
                                : ChatMessage(
                                    data: data,
                                    chatRoomId: widget.chatRoomId,
                                    chatUserDatas: widget.chatUserDatas,
                                    isGroupChat: widget.isGroupChat,
                                    isMyMessage: true,
                                    dataPrevious: dataPrevious,
                                    dataAfter: dataAfter,
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
          ),
          (imageUrls.isEmpty == false) ? const ImagesPreview() : Container(),
          Container(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
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
                              // isCollapsed: true,

                              border: OutlineInputBorder(
                                borderSide: BorderSide(width: 5, color: Colors.grey),
                                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.only(left: 5)),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
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
        Fluttertoast.showToast(msg: 'bruh are you tryin to fuck up my cloud storage?');
        return;
      }

      globals.image = imageTemporary;
    } on PlatformException catch (e) {
      print('failed tp pick image $e');
    }
    Fluttertoast.showToast(msg: "Uploading image... stay on page");
    //final ref = FirebaseStorage
    var snapshot = await _storage
        .ref()
        .child('ChatImages/${loggedInUser.uid} $time3 ${widget.chatUserDatas['uid']}')
        .putFile(imageTemporary!);

    var downloadurl = await snapshot.ref.getDownloadURL();

    imageUrl = downloadurl;
    imageUrls.add(databaseMethods.encrypt(imageUrl!));
    Fluttertoast.showToast(msg: "succesfully uploaded image");
    setState(() {});
    // isImage = true;
    // sendMessage();
    // isImage = false;
  }

  static Future downloadFile(Reference ref) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${ref.name}');

    await ref.writeToFile(file);
  }

  void notifyUser(String content) async {
    print("Notifying users");
    // return;
    isImage = false;
    final roomData =
        await FirebaseFirestore.instance.collection('ChatRoom').doc(widget.chatRoomId).get();

    // print(roomData.metadata.isFromCache);

    for (UserModel user in widget.chatUserDatas.values) {
      if (user.uid != globals.myUser!.uid!) {
        UserModel targetUserModel = UserModel();

        await FirebaseFirestore.instance.collection("users").doc(user.uid).get().then(
          (value) {
            // print(value.metadata.isFromCache);
            targetUserModel = UserModel.fromMap(value.data());
          },
        );
        bool hasTargetUserChanged = false;
        if (targetUserModel.newMessages != null) {
          if (targetUserModel.newMessages!.contains(widget.chatRoomId) == false) {
            targetUserModel.newMessages?.add(widget.chatRoomId);
            hasTargetUserChanged = true;
          }
        } else {
          targetUserModel.newMessages = [widget.chatRoomId];
          hasTargetUserChanged = true;
        }
        print("check1");
        //Make room most recent in both users

        if (targetUserModel.recentRooms != null && targetUserModel.recentRooms != []) {
          if (targetUserModel.recentRooms![targetUserModel.recentRooms!.length - 1] !=
              widget.chatRoomId) {
            targetUserModel.recentRooms!.remove(widget.chatRoomId);
            hasTargetUserChanged = true;
            print("MOOOVE");
          }
          if (hasTargetUserChanged) {
            targetUserModel.recentRooms?.add(widget.chatRoomId);
          }
        } else {
          targetUserModel.recentRooms = [widget.chatRoomId];
          hasTargetUserChanged = true;
        }
        print("check2");

        if (hasTargetUserChanged) {
          await firebaseFirestore
              .collection("users")
              .doc(targetUserModel.uid)
              .set(targetUserModel.toMap());
        }
        print("check3");

        String title = "";
        if (widget.isGroupChat == true) {
          title = "${widget.chatRoomData!["groupName"]!}: ${globals.myUser!.nickname}";
        } else {
          title = "new message from: ${globals.myUser!.nickname}";
        }

        databaseMethods.sendNotification(title, content, targetUserModel.token!);
      }
    }

    var myData = await firebaseFirestore.collection('users').doc(globals.myUser!.uid).get();
    globals.myUser = UserModel.fromMap(myData.data());

    bool hasMyUserChanged = false;

    if (globals.myUser!.recentRooms != null && globals.myUser!.recentRooms != []) {
      if (globals.myUser!.recentRooms![globals.myUser!.recentRooms!.length - 1] !=
          widget.chatRoomId) {
        globals.myUser!.recentRooms!.remove(widget.chatRoomId);
        hasMyUserChanged = true;
        print("MOOOVE");
      }
      if (hasMyUserChanged) {
        globals.myUser!.recentRooms?.add(widget.chatRoomId);
      }
    } else {
      globals.myUser!.recentRooms = [widget.chatRoomId];
      hasMyUserChanged = true;
    }
    print("check4");
    await firebaseFirestore
        .collection("users")
        .doc(globals.myUser!.uid)
        .set(globals.myUser!.toMap());
    setState(() {});
  }

  Future sendImage() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("pick image type"),
          content: SizedBox(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    pickImage();
                    Navigator.pop(context);
                  },
                  child: const Text('image from gallery'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    //copyMessage(data,"");
                    await pickImageUrl();
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text('image from url'),
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
          content: SizedBox(
            height: 100,
            child: Column(
              children: [
                TextField(
                  controller: urlController,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: globals.primarySwatch!, width: 2),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Fluttertoast.showToast(msg: "mmmmmmmmmmmmmmmmmmmmmm");
                    Navigator.of(context).pop();
                    imageUrl = urlController.text;
                    imageUrls.add(databaseMethods.encrypt(imageUrl!));
                    urlController.text = "";
                  },
                  child: const Text('accept'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ImagesPreview extends StatefulWidget {
  const ImagesPreview({Key? key}) : super(key: key);

  @override
  State<ImagesPreview> createState() => _ImagesPreviewState();
}

class _ImagesPreviewState extends State<ImagesPreview> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: globals.primaryColor!, width: 2),
      ),
      // color: globals.primaryColor,
      constraints: const BoxConstraints(maxHeight: 200),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              for (String url in imageUrls)
                GestureDetector(
                  onTap: () async {
                    await preImageOptions(context, url);
                    setState(() {});
                  },
                  onLongPress: () async {
                    await preImageOptions(context, url);
                    setState(() {});
                  },
                  child: CachedNetworkImage(
                    imageUrl: databaseMethods.decrypt(url, {"supportsEncryption": true}),
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

preImageOptions(context, url) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('what do you?'),
        content: SizedBox(
          height: 50,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton(
                  child: const Text("REMOVE"),
                  onPressed: () {
                    imageUrls.remove(url);
                    Navigator.of(context).pop();
                  })
            ],
          ),
        ),
      );
    },
  );
}

void sendPushMessage(String token, String body, String title) async {
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': Secrets().cloudMessagingApiKey,
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

class ChatMessage extends StatefulWidget {
  ChatMessage(
      {Key? key,
      required this.data,
      required this.chatRoomId,
      required this.chatUserDatas,
      required this.isGroupChat,
      required this.isMyMessage,
      this.dataPrevious,
      this.dataAfter})
      : super(key: key);
  final Map<String, dynamic> data;
  final String chatRoomId;
  final Map<String, UserModel> chatUserDatas;
  final bool isGroupChat;
  final bool isMyMessage;
  final Map<String, dynamic>? dataPrevious;
  final Map<String, dynamic>? dataAfter;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage> {
  bool isExpanded = false;
  bool isAvatarVisible = true;
  bool isBottomStack = false;

  @override
  void initState() {
    super.initState();

    if (widget.dataPrevious != null) {
      // if (widget.dataAfter == null) {
      //   if (DateTime.now().millisecondsSinceEpoch - widget.data["time"] > 180000) {
      //     isBottomStack = true;
      //     isExpanded = true;
      //   }
      //   return;
      // }
      if (widget.dataPrevious!["time"] - widget.data["time"] < 180000) {
        if (widget.dataPrevious!["authorID"] != null) {
          if (widget.dataPrevious!["authorID"] == widget.data["authorID"]) {
            isAvatarVisible = false;
          } else {
            isBottomStack = true;
            isExpanded = true;
          }
        } else {
          if (widget.data["sendBy"] != globals.myUser!.fullName!) {
            if (widget.dataPrevious!["sendBy"] != globals.myUser!.fullName!) {
              isAvatarVisible = false;
            } else {
              isBottomStack = true;
              isExpanded = true;
            }
          } else {
            if (widget.dataPrevious!["sendBy"] == globals.myUser!.fullName!) {
              isAvatarVisible = false;
            } else {
              isBottomStack = true;
              isExpanded = true;
            }
          }

          // isExpanded = true;
          // isBottomStack = true;
        }
        // else {
        // if (globals.loadedUsers[widget.data["authorID"]] != null) {
        // print("loaded");
        // if (widget.dataPrevious!["sendBy"] ==
        // globals.loadedUsers[widget.data["authorID"]]!.fullName) {
        // isAvatarVisible = false;
        // } else {
        // isBottomStack = true;
        // isExpanded = true;
        // }
        // } else {
        // print("not loaded");
        // isBottomStack = true;
        // isExpanded = true;
        // }
        // }
      } else {
        isBottomStack = true;
        isExpanded = true;
      }
    } else {
      if (DateTime.now().millisecondsSinceEpoch - widget.data["time"] > 180000) {
        isBottomStack = true;
        isExpanded = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // return (!widget.isMyMessage)
    return GestureDetector(
      onTap: () {
        isExpanded = !isExpanded;
        setState(() {});
      },
      child: Container(
        alignment: (widget.isMyMessage) ? Alignment.centerRight : Alignment.centerLeft,
        margin: EdgeInsets.only(
          left: 10,
          right: 10,
          // bottom: getBottomExpansion(),

          bottom: (isBottomStack) ? 10 : 0,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (!widget.isMyMessage)
              Positioned(left: 0, bottom: 0, child: generateAvatar(widget.data)),
            if (widget.isMyMessage)
              Positioned(right: 0, bottom: 0, child: generateAvatar(widget.data)),
            Column(
              children: [
                Row(
                  mainAxisAlignment:
                      (widget.isMyMessage) ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // generateAvatar(widget.data),
                    if (widget.isMyMessage == false) SizedBox(width: 33),
                    Container(
                      //height: 30,
                      decoration: getDecoration(widget.isMyMessage),

                      margin: (isExpanded)
                          ? const EdgeInsets.only(
                              left: 10,
                              right: 10,
                              bottom: 10,
                            )
                          : const EdgeInsets.only(
                              left: 10,
                              right: 10,
                            ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 250),
                          child: generateMessage(widget.data),
                        ),
                      ),
                    ),
                    if (widget.isMyMessage) SizedBox(width: 33),
                  ],
                ),
                const Padding(padding: EdgeInsets.only(bottom: 5)),
              ],
            ),
            if (widget.data['time2'] != null && isExpanded == true)
              (widget.isMyMessage)
                  ? Positioned(
                      bottom: 1,
                      right: 43,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.data['time2'].toString(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w200),
                          ),
                        ],
                      ),
                    )
                  : Positioned(
                      bottom: 1,
                      left: 43,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            widget.data['time2'].toString(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w200),
                          ),
                        ],
                      ),
                    ),
          ],
        ),
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
          placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    } else {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: (data['authorID'] != null)
              ? widget.chatUserDatas[data['authorID']]!.avatarUrl!
              : widget.chatUserDatas.values.toList()[0].avatarUrl!,
          width: 35,
          height: 35,
          fit: BoxFit.cover,
          placeholder: (context, url) => const CircularProgressIndicator(color: Colors.white),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        ),
      );
    }
  }

  generateMessage(data) {
    if (data["isImage"] != null) {
      return (data["isImage"] == false)
          ? GestureDetector(
              onLongPress: () => messageActions(data),
              child: pureText(data),
            )
          : GestureDetector(
              onLongPress: () =>
                  messageActions(data, url: databaseMethods.decrypt(data["message"], data)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InteractiveViewer(
                      maxScale: 10,
                      child: CachedNetworkImage(
                        imageUrl: databaseMethods.decrypt(data["message"], data),
                        //fit: BoxFit.fill,
                        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                          child: CircularProgressIndicator(
                              value: downloadProgress.progress, color: Colors.white),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: CachedNetworkImage(
                  imageUrl: databaseMethods.decrypt(data["message"], data),
                  fit: BoxFit.fill,
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(
                          value: downloadProgress.progress, color: Colors.white),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            );
    } else {
      if (data["images"] != null) {
        return Column(
          crossAxisAlignment: (data["authorID"] != globals.myUser!.uid!)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            for (String url in data["images"])
              GestureDetector(
                onLongPress: () =>
                    messageActions(data, url: databaseMethods.decryptImageIfNeeded(url)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InteractiveViewer(
                        maxScale: 10,
                        child: GestureDetector(
                          onLongPress: () =>
                              messageActions(data, url: databaseMethods.decryptImageIfNeeded(url)),
                          child: CachedNetworkImage(
                            imageUrl: databaseMethods.decryptImageIfNeeded(url), //fit: BoxFit.fill,
                            progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                              child: CircularProgressIndicator(
                                  value: downloadProgress.progress, color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: CachedNetworkImage(
                    imageUrl: databaseMethods.decryptImageIfNeeded(url),
                    fit: BoxFit.fill,
                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                        CircularProgressIndicator(
                            value: downloadProgress.progress, color: Colors.white),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            if (data["message"].isNotEmpty)
              GestureDetector(onLongPress: () => messageActions(data), child: pureText(data))
          ],
        );
      } else {
        return GestureDetector(
          onLongPress: () => messageActions(data),
          child: pureText(data),
        );
      }
    }
  }

  Widget pureText(data) {
    if (data["isLink"] != null) {
      return (data["isLink"] == true)
          ? GestureDetector(
              onTap: () {
                launch(databaseMethods.decrypt(data['message'], data));
              },
              child: Text(
                databaseMethods.decrypt(data["message"], data),
                style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Color.fromARGB(255, 0, 102, 255),
                    decoration: TextDecoration.underline),
              ),
            )
          : Text(
              databaseMethods.decrypt(data["message"], data),
              style: const TextStyle(color: Colors.white),
            );
    } else {
      return Text(
        databaseMethods.decrypt(data["message"], data),
        style: const TextStyle(color: Colors.white),
      );
    }
  }

  void messageActions(Map<String, dynamic> data, {String? url}) {
    if (data["isImage"] != null) {
      if (data["isImage"] == true) {
        createAlertDialog(data, context);
      } else {
        copyMessage(data, "message");
      }
    } else {
      if (url != null) {
        createAlertDialog(data, context, url: url);
      } else {
        copyMessage(data, "message");
      }
    }
  }

  copyMessage(Map<String, dynamic> data, String message, {String? url}) {
    Clipboard.setData(
        ClipboardData(text: (url != null) ? url : databaseMethods.decrypt(data["message"], data)));
    Fluttertoast.showToast(msg: '$message copied succesfully');
  }

  createAlertDialog(Map<String, dynamic> data, BuildContext context, {String? url}) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('what do you?'),
          content: SizedBox(
            height: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (url != null) {
                      copyMessage(data, 'image url', url: url);
                    } else {
                      copyMessage(data, 'image url');
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('copy image url'),
                ),
                ElevatedButton(
                  onPressed: () {
                    //copyMessage(data,"");
                    Navigator.pop(context);
                    downloadImage(
                      data,
                      (url != null)
                          ? url
                          : (url != null)
                              ? url
                              : data["message"],
                    );
                    //Navigator.pop(context);
                  },
                  child: const Text('download image'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  downloadImage(Map<String, dynamic> data, String url) async {
    try {
      await ImageDownloader.downloadImage(url,
          destination: AndroidDestinationType.directoryDownloads..subDirectory("karpportal.png"));
      Fluttertoast.showToast(msg: "image downloaded succesfully");
    } on PlatformException catch (error) {
      print(error);
    }

    //ImageDownloader.downloadImage(url,destination: );

    Fluttertoast.showToast(msg: 'Image downloaded sucessfully');
    Navigator.pop(context);
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

  Widget generateAvatar(Map<String, dynamic> data) {
    if (isAvatarVisible) {
      return (isExpanded)
          ? Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MessageImage(data),
            )
          : MessageImage(data);
    } else {
      return SizedBox(width: 35);
    }
  }

  getDecoration(bool isNewMessage) {
    return (isNewMessage)
        ? BoxDecoration(color: getColor(), borderRadius: BorderRadius.circular(10))
        : BoxDecoration(color: globals.primarySwatch, borderRadius: BorderRadius.circular(10));
  }

  double getBottomExpansion() {
    if (isBottomStack)
      return 10;
    else
      return 0;
  }
}
