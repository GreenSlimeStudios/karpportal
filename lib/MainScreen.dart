import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:karpportal/MessagesScreen.dart';

import 'CreatePostScreen.dart';
import 'UserModel.dart';
import 'globals.dart' as globals;

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Add the app bar to the CustomScrollView.
          SliverAppBar(
            foregroundColor: Colors.white,
            title: Text(
              "What's poppin?",
              style: GoogleFonts.permanentMarker(
                color: Colors.white,
                // fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() {});
                  })
            ], // snap: true,

            floating: true,
            flexibleSpace: Container(
              color: globals.primarySwatch,
              child: Container(
                alignment: Alignment.bottomCenter,
                color: globals.themeColor,
                margin: const EdgeInsets.only(top: 55),
                padding: const EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: createPost,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: globals.themeColor,
                      border: Border.all(width: 4, color: globals.primarySwatch!.shade700),
                    ),
                    child: const Text("Tell the world something cool what's going on!"),
                  ),
                ),
              ),
            ),
            // Make the initial height of the SliverAppBar larger than normal.
            expandedHeight: 140,
          ),
          content(),
          const SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),
        ],
      ),
    );
  }

  Widget content() => SliverToBoxAdapter(
        child: Container(
          // constraints: BoxConstraints(maxHeight: 10000),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("Posts")
                .orderBy('timeMil', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              return (snapshot.connectionState == ConnectionState.waiting)
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      // constraints: BoxConstraints(
                      // maxHeight: 1000,
                      // ),

                      child: Column(
                        children: [
                          for (int i = 0; i < snapshot.data!.docs.length; i++)
                            renderPosts(snapshot.data!.docs[i].data() as Map<String, dynamic>),
                        ],
                      ),
                    );
            },
          ),
        ),
      );
  void createPost() async {
    var info = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const CreatePostPage()));
  }

  Widget renderPosts(Map<String, dynamic> data) {
    return FutureBuilder<UserModel>(
      future: getAuthor(data["authorID"]),
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        if (snapshot.hasData) {
          return PostInstance(data: data, snapshot: snapshot);
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
}

Future<UserModel> getAuthor(uid) async {
  UserModel author = UserModel();
  await FirebaseFirestore.instance.collection("users").doc(uid).get().then(
    (value) {
      print(value.metadata.isFromCache);

      author = UserModel.fromMap(value.data());
    },
  );
  return author;
}

// Future heart(Map<String, dynamic> data) async {}

// Future share(Map<String, dynamic> data) async {}

class PostInstance extends StatefulWidget {
  PostInstance({Key? key, required this.data, required this.snapshot}) : super(key: key);

  final Map<String, dynamic> data;
  final AsyncSnapshot<UserModel> snapshot;

  @override
  State<PostInstance> createState() => _PostInstanceState();
}

class _PostInstanceState extends State<PostInstance> {
  bool isExpanded = false;
  bool addComment = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (() => showOptions(widget.data, widget.snapshot)),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: globals.themeColor,
              border: Border.all(
                width: 2,
                color: widget.data["authorID"] == globals.myUser!.uid
                    ? globals.primaryColor!
                    : globals.primarySwatch!,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: widget.snapshot.data!.avatarUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.fill,
                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                              CircularProgressIndicator(value: downloadProgress.progress),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.snapshot.data!.nickname!,
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                            ),
                            Container(
                              constraints: const BoxConstraints(maxWidth: 250),
                              child: Text(
                                widget.data["title"],
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  // padding: EdgeInsets.symmetric(horizontal: 10),
                  constraints: const BoxConstraints(maxWidth: 3000),
                  child: (widget.data["content"] != null && widget.data["content"] != " ")
                      ? Container(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            widget.data["content"],
                          ),
                        )
                      : Container(),
                ),
                // const SizedBox(height: 10),
                if (widget.data["ImageURLs"].length > 0)
                  Container(
                    constraints: (isExpanded) ? BoxConstraints() : BoxConstraints(maxHeight: 300),
                    padding: const EdgeInsets.only(
                      // top: 10,
                      bottom: 5,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      // controller:
                      child: Column(
                        children: [
                          for (String url in widget.data["ImageURLs"])
                            Container(
                              // padding: EdgeInsets.symmetric(vertical: 5),
                              child: GestureDetector(
                                child: Hero(
                                  tag: url,
                                  child: CachedNetworkImage(
                                    imageUrl: url,
                                    progressIndicatorBuilder: (context, url, downloadProgress) =>
                                        Container(
                                      height: 180,
                                      alignment: Alignment.center,
                                      child: CircularProgressIndicator(
                                          value: downloadProgress.progress),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => InteractiveViewer(
                                        child: Hero(
                                          tag: url,
                                          child: CachedNetworkImage(
                                            imageUrl: url,
                                            progressIndicatorBuilder:
                                                (context, url, downloadProgress) =>
                                                    CircularProgressIndicator(
                                                        value: downloadProgress.progress),
                                            errorWidget: (context, url, error) =>
                                                const Icon(Icons.error),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                (isExpanded)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Row(
                            children: [
                              Text("Comments ${widget.data["comments"].length}"),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    addComment = !addComment;
                                  });
                                },
                                child: Text((addComment) ? "hide comment" : "add comment",
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                              ),
                            ],
                          ),
                          (addComment)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(width: 2, color: globals.primaryColor!),
                                      ),
                                      child: Form(
                                        key: formKey,
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: TextFormField(
                                            minLines: 1,
                                            maxLines: 10,
                                            controller: commentController,
                                            scrollPadding: EdgeInsets.symmetric(vertical: 0),
                                            decoration: InputDecoration(
                                              isDense: true,
                                              hintText: "enter your comment here",
                                              focusedBorder: InputBorder.none,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    Container(
                                      height: 25,
                                      child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(globals.primaryColor!),
                                          ),
                                          child: Text("post comment"),
                                          onPressed: (() => postComment(commentController.text))),
                                    ),
                                  ],
                                )
                              : Container(),
                          for (Map<String, dynamic> comment in widget.data["comments"].reversed)
                            CommentInstance(postData: widget.data, commentData: comment),
                          SizedBox(height: 5),
                        ],
                      )
                    : Container(),
                const SizedBox(height: 15),
              ],
            ),
          ),
          Positioned(
            bottom: -20,
            left: 20,
            child: Container(
              // width: 120,
              height: 40,
              decoration: BoxDecoration(
                color: (globals.myUser!.uid == widget.data["authorID"])
                    ? globals.primaryColor
                    : globals.primarySwatch,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(children: [
                      const SizedBox(width: 10),
                      Text("L: ${widget.data["reactions"]["likeIDs"].length.toString()}"),
                    ]),
                    Row(children: [
                      const SizedBox(width: 10),
                      Text("H: ${widget.data["reactions"]["heartIDs"].length.toString()}"),
                    ]),
                    Row(children: [
                      const SizedBox(width: 10),
                      Text("S: ${widget.data["reactions"]["shareIDs"].length.toString()}"),
                    ]),
                    const SizedBox(width: 10),
                    // Row(children: [
                    //   SizedBox(width: 10),
                    //   Text("C: ${widget.data["comments"].length.toString()}"),
                    // ]),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 20,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Row(
                    children: [
                      (!isExpanded) ? Text("expand") : Text("close"),
                      Icon((!isExpanded) ? Icons.expand_more : Icons.expand_less),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  showOptions(Map<String, dynamic> data, AsyncSnapshot<UserModel> snapshot) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('what do you?'),
          content: SizedBox(
            height: 250,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data["title"]));
                    Fluttertoast.showToast(msg: 'title copied succesfully');
                    Navigator.pop(context);
                  },
                  child: const Text('copy title'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data["content"]));
                    Fluttertoast.showToast(msg: 'content copied succesfully');
                    Navigator.pop(context);
                  },
                  child: const Text('copy content (text)'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await like(data);
                    // setState(() {});
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.thumb_up),
                      SizedBox(width: 5),
                      Text('like'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await heart(data);
                    // setState(() {});
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(CupertinoIcons.heart),
                      SizedBox(width: 5),
                      Text('heart'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await share(data);
                    // setState(() {});
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.share),
                      SizedBox(width: 5),
                      Text('share'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future like(Map<String, dynamic> data) async {
    await addReaction(data, "likeIDs");
  }

  Future heart(Map<String, dynamic> data) async {
    await addReaction(data, "heartIDs");
  }

  Future share(Map<String, dynamic> data) async {
    await addReaction(data, "shareIDs");
  }

  Future addReaction(Map<String, dynamic> data, String reaction) async {
    List<String> placeholder = ["fsfs", "dada"];
    // placeholder.remove(…)
    if (data["uid"] == null) {
      return;
    }
    if (data["reactions"][reaction].contains(globals.myUser!.uid)) {
      Map<String, dynamic> postData = await databaseMethods.getPost(data["uid"]);
      postData["reactions"][reaction].remove(globals.myUser!.uid);
      await databaseMethods.setPost(postData["uid"], postData);
    } else {
      // Map<String, dynamic> postData = await databaseMethods.getPost(data["uid"]);
      // if (postData["reactions"][reaction] != null &&
      //     postData["reactions"][reaction] != [] &&
      //     postData["reactions"][reaction].isEmpty == false) {
      //   postData["reactions"][reaction].add(globals.myUser!.uid);
      // } else {
      //   postData["reactions"][reaction] = [globals.myUser!.uid];
      // }
      // await databaseMethods.setPost(postData["uid"], postData);

      await FirebaseFirestore.instance.collection("Posts").doc(data["uid"]).set({
        "reactions": {
          reaction: FieldValue.arrayUnion([globals.myUser!.uid!]),
        }
      }, SetOptions(merge: true));
    }
  }

  TextEditingController commentController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  postComment(String content) {
    Map<String, dynamic> commentMap = {
      "authorID": globals.myUser!.uid!,
      "time": DateTime.now().millisecondsSinceEpoch,
      "time2": getCurrentTime(),
      "content": content,
    };
    FirebaseFirestore.instance.collection("Posts").doc(widget.data["uid"]).set({
      "comments": FieldValue.arrayUnion([commentMap])
    }, SetOptions(merge: true));
    commentController.text = "";
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

class CommentInstance extends StatefulWidget {
  CommentInstance({Key? key, required this.postData, required this.commentData}) : super(key: key);
  final Map<String, dynamic> postData;
  final Map<String, dynamic> commentData;
  @override
  State<CommentInstance> createState() => _CommentInstanceState();
}

class _CommentInstanceState extends State<CommentInstance> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: globals.themeColor,
        border: Border.all(
          width: 2,
          color: widget.commentData["authorID"] == globals.myUser!.uid
              ? globals.primaryColor!
              : globals.primarySwatch!,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FutureBuilder(
            future: getAuthor(widget.commentData["authorID"]),
            builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
              if (snapshot.hasData) {
                return Row(
                  children: [
                    Column(
                      children: [
                        ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: snapshot.data!.avatarUrl!,
                            height: 25,
                            width: 25,
                            fit: BoxFit.fill,
                            placeholder: (context, value) {
                              return CircularProgressIndicator();
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 5),
                    Text(snapshot.data!.nickname!),
                  ],
                );
              } else {
                return Container(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
          SizedBox(height: 5),
          // Text(widget.commentData["title"]),
          Text(widget.commentData["content"]),
        ],
      ),
    );
  }
}
