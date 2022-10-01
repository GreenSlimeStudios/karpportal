import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'globals.dart' as globals;
import 'UserModel.dart';

class ChatSettingsPage extends StatefulWidget {
  ChatSettingsPage(
      {Key? key, required this.chatUserDatas, required this.isGroupChat, this.chatRoomData})
      : super(key: key);

  final Map<String, UserModel> chatUserDatas;
  final bool isGroupChat;
  final Map<String, dynamic>? chatRoomData;
  @override
  State<ChatSettingsPage> createState() => _ChatSettingsPageState();
}

class _ChatSettingsPageState extends State<ChatSettingsPage> {
  bool isAdmin = false;
  @override
  void initState() {
    if (widget.chatRoomData?['adminIDs'] != null &&
        widget.chatRoomData?['adminIDs'].contains(globals.myUser!.uid)) {
      isAdmin = true;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("settings"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: SingleChildScrollView(
          child: Column(
            children: [
              (widget.isGroupChat) ? groupChatOptions() : privChatOptions(),
            ],
          ),
        ),
      ),
    );
  }

  groupChatOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        imageUrl: widget.chatRoomData!["groupAvatarUrl"] ??
                            " https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse4.explicit.bing.net%2Fth%3Fid%3DOIP.TolLwDCaTfUkxM3v-ZCqUgAAAA%26pid%3DApi&f=1"),
                  ),
                  if (isAdmin)
                    Positioned(
                      bottom: -10,
                      right: -10,
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(FontAwesomeIcons.penToSquare),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.chatRoomData?["groupName"] ?? "unknown group name",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  if (isAdmin)
                    IconButton(
                      onPressed: () {},
                      icon: Icon(FontAwesomeIcons.penToSquare),
                    ),
                ],
              ),
            ],
          ),
        ),
        generateUserPreviews(widget.chatUserDatas),
      ],
    );
  }

  privChatOptions() {}

  generateUserPreviews(Map<String, UserModel> chatUserDatas) {
    return Column(children: [
      for (UserModel user in chatUserDatas.values)
        UserActionInstance(user: user, chatRoomData: widget.chatRoomData)
    ]);
  }
}

class UserActionInstance extends StatefulWidget {
  UserActionInstance({Key? key, required this.user, this.chatRoomData}) : super(key: key);
  final UserModel user;
  final Map<String, dynamic>? chatRoomData;
  @override
  State<UserActionInstance> createState() => _UserActionInstanceState();
}

class _UserActionInstanceState extends State<UserActionInstance> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Row(
        children: [
          ClipOval(
            child: CachedNetworkImage(
                imageUrl: widget.user.avatarUrl!, width: 40, height: 40, fit: BoxFit.cover),
          ),
          SizedBox(width: 10),
          Text(
            widget.user.nickname!,
            style: TextStyle(fontSize: 17),
          ),
          SizedBox(width: 3),
          if (widget.chatRoomData?['adminIDs'] != null &&
              widget.chatRoomData?['adminIDs'].contains(widget.user.uid ?? "none"))
            Icon(Icons.verified_user, size: 15),
        ],
      ),
    );
  }
}
