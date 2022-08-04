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
                margin: const EdgeInsets.only(top: 80),
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
                      border: Border.all(width: 4, color: globals.primaryColor!),
                    ),
                    child: const Text("Tell the world something cool what's going on!"),
                  ),
                ),
              ),
            ),
            // Make the initial height of the SliverAppBar larger than normal.
            expandedHeight: 120,
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
                            renderPost(snapshot.data!.docs[i].data() as Map<String, dynamic>),
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

  Widget renderPost(Map<String, dynamic> data) {
    return FutureBuilder<UserModel>(
      future: getAuthor(data["authorID"]),
      builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
        if (snapshot.hasData) {
          return PostInstance(data: data, snapshot: snapshot, isExpanded: false);
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
  const PostInstance(
      {Key? key, required this.data, required this.snapshot, required this.isExpanded})
      : super(key: key);

  final Map<String, dynamic> data;
  final AsyncSnapshot<UserModel> snapshot;
  final bool isExpanded;

  @override
  State<PostInstance> createState() => _PostInstanceState();
}

class _PostInstanceState extends State<PostInstance> {
  bool isExpanded = false;
  bool isImageExpanded = false;
  bool addComment = true;
  bool isOnce = false;
  initState() {
    if (isOnce == false) {
      isOnce = true;
      isExpanded = widget.isExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (() => showOptions(widget.data, widget.snapshot, false)),
      onTap: (widget.isExpanded)
          ? () {}
          : () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                          appBar: AppBar(
                            foregroundColor: Colors.white,
                            title: Text(
                              'Karp Portal',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.leagueScript(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          body: SingleChildScrollView(
                              child: Column(
                            children: [
                              PostInstance(
                                  data: widget.data, snapshot: widget.snapshot, isExpanded: true),
                              SizedBox(height: 10),
                            ],
                          )))));
            },
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
            padding: const EdgeInsets.only(left: 5, top: 10, bottom: 10, right: 5),
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
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
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
                                errorWidget: (context, url, error) => const Icon(Icons.error),
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
                        alignment: Alignment.centerLeft,
                        // padding: EdgeInsets.symmetric(horizontal: 10),
                        constraints: const BoxConstraints(maxWidth: 3000),
                        child: (widget.data["content"] != null &&
                                widget.data["content"] != " " &&
                                widget.data["content"] != "")
                            ? Container(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  widget.data["content"],
                                ),
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
                // const SizedBox(height: 10),
                if (widget.data["ImageURLs"].length > 0)
                  Container(
                    constraints: (isExpanded)
                        ? const BoxConstraints()
                        : const BoxConstraints(maxHeight: 300),
                    padding: const EdgeInsets.only(
                      // top: 10,
                      bottom: 5,
                      left: 5,
                    ),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: (isExpanded)
                        ? getImagesColumn()
                        : SingleChildScrollView(
                            // controller:
                            child: getImagesColumn(),
                          ),
                  ),

                (isExpanded)
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      "Comments ${(widget.data["allComments"] != null) ? widget.data["allComments"].length : "none"}"),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        addComment = !addComment;
                                      });
                                    },
                                    child: Text((addComment) ? "hide comment" : "add comment",
                                        style: const TextStyle(
                                            fontStyle: FontStyle.italic, color: Colors.grey)),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isExpanded = !isExpanded;
                                  });
                                },
                                child: Row(
                                  children: [
                                    (!isExpanded) ? const Text("expand") : const Text("collapse"),
                                    Icon((!isExpanded) ? Icons.expand_more : Icons.expand_less),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          (addComment)
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(width: 2, color: globals.primaryColor!),
                                      ),
                                      child: Form(
                                        key: formKey,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                          child: TextFormField(
                                            validator: (value) {
                                              if (value == null) return "enter a valid comment";
                                              if (value.isEmpty)
                                                return "put a thing into the comment dum dum";
                                              if (value == " ")
                                                return "please enter a valid comment";
                                            },
                                            minLines: 1,
                                            maxLines: 10,
                                            controller: commentController,
                                            scrollPadding: const EdgeInsets.symmetric(vertical: 0),
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              hintText: "enter your comment here",
                                              focusedBorder: InputBorder.none,
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    SizedBox(
                                      height: 25,
                                      child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(globals.primaryColor!),
                                          ),
                                          onPressed: (() => postComment(commentController.text)),
                                          child: const Text("post comment")),
                                    ),
                                    SizedBox(height: 5),
                                  ],
                                )
                              : Container(),
                          if (widget.data["allComments"] != null)
                            FutureBuilder<List<Map<String, dynamic>>>(
                                future: getRepliesAndAllComments(),
                                builder:
                                    (builder, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                                  if (snapshot.hasData) {
                                    return Column(children: [
                                      optimizedComments(snapshot.data![0], snapshot.data![1]),
                                    ]);
                                  }
                                  return CircularProgressIndicator();
                                }),
                          if (widget.data["comments"] != null)
                            StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("Posts")
                                    .doc(widget.data["uid"])
                                    .collection("comments")
                                    .orderBy('time', descending: false)
                                    .snapshots(),
                                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                                                if (widget.data["comments"]
                                                    .contains(snapshot.data!.docs[i].data()["uid"]))
                                                  CommentInstance(
                                                      replies: {},
                                                      allComments: {},
                                                      postData: widget.data,
                                                      commentData: snapshot.data!.docs[i].data()
                                                          as Map<String, dynamic>,
                                                      isExpanded: true),
                                            ],
                                          ),
                                        );
                                }),
                          // for (Map<String, dynamic> comment in widget.data["comments"].reversed)
                          //   CommentInstance(postData: widget.data, commentData: comment),
                          const SizedBox(height: 5),
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
            child: Row(
              children: [
                GestureDetector(
                  onTap: (() => showOptions(widget.data, widget.snapshot, false)),
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
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (widget.data["reactions"]["likeIDs"].length > 0)
                            Row(children: [
                              const SizedBox(width: 10),
                              const Icon(Icons.thumb_up, size: 17, color: Colors.white),
                              const SizedBox(width: 2),
                              // if (widget.data["reactions"]["likeIDs"].length > 1)
                              Text(
                                widget.data["reactions"]["likeIDs"].length.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ]),
                          if (widget.data["reactions"]["heartIDs"].length > 0)
                            Row(children: [
                              const SizedBox(width: 10),
                              const Icon(CupertinoIcons.heart, size: 17, color: Colors.white),
                              const SizedBox(width: 2),
                              Text(
                                widget.data["reactions"]["heartIDs"].length.toString(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ]),
                          if (widget.data["allComments"] != null)
                            if (widget.data["allComments"].length > 0)
                              Row(children: [
                                const SizedBox(width: 10),
                                const Icon(Icons.comment, size: 17, color: Colors.white),
                                const SizedBox(width: 2),
                                Text(
                                  widget.data["allComments"].length.toString(),
                                  style: const TextStyle(color: Colors.white),
                                ),
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
                const SizedBox(width: 5),
                Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  child: Text(
                    (widget.data["time2"] != null) ? widget.data["time2"] : "2022/07/12 00:00",
                    style: const TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13),
                  ),
                ),
              ],
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
                      (!isExpanded) ? const Text("expand") : const Text("collapse"),
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

  Widget getImagesColumn() {
    return Column(
      children: [
        for (String url in widget.data["ImageURLs"])
          Container(
            // padding: EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              child: Hero(
                tag: url,
                child: CachedNetworkImage(
                  imageUrl: url,
                  progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                    height: 180,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(value: downloadProgress.progress),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InteractiveViewer(
                      maxScale: 10,
                      child: Hero(
                        tag: url,
                        child: CachedNetworkImage(
                          imageUrl: url,
                          progressIndicatorBuilder: (context, url, downloadProgress) =>
                              CircularProgressIndicator(value: downloadProgress.progress),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  showOptions(Map<String, dynamic> data, AsyncSnapshot<UserModel> snapshot, bool isComment) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('what do you?'),
          content: SizedBox(
            height: (isComment) ? 220 : 250,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isComment == false)
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
                  child: const Text('copy content'),
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
      await FirebaseFirestore.instance.collection("Posts").doc(data["uid"]).set({
        "reactions": {
          reaction: FieldValue.arrayRemove([globals.myUser!.uid!]),
        }
      }, SetOptions(merge: true));
    } else {
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
    if (formKey.currentState!.validate() == false) return;
    String commentID = "${globals.myUser!.uid!}${DateTime.now().millisecondsSinceEpoch}";
    Map<String, dynamic> commentMap = {
      "uid": commentID,
      "authorID": globals.myUser!.uid!,
      "time": DateTime.now().millisecondsSinceEpoch,
      "time2": databaseMethods.getCurrentTime(),
      "content": content,
      "reactions": {
        "likeIDs": [globals.myUser!.uid!],
        "heartIDs": [],
        "shareIDs": []
      },
    };
    FirebaseFirestore.instance.collection("Posts").doc(widget.data["uid"]).set({
      // "fullComments": FieldValue.arrayUnion([commentMap]),
      "comments": FieldValue.arrayUnion([commentID]),
      "allComments": FieldValue.arrayUnion([commentID]),
      "mainComments": FieldValue.arrayUnion([commentID]),
    }, SetOptions(merge: true));

    FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.data["uid"])
        .collection("Comments")
        .doc("Comments")
        .set({commentID: commentMap}, SetOptions(merge: true));
    // FirebaseFirestore.instance.collection("Posts").doc(…)

    commentController.text = "";
    addComment = false;

    // FirebaseFirestore.instance
    //     .collection("Posts")
    //     .doc(widget.data["uid"])
    //     .collection("comments")
    //     .doc(commentID)
    //     .set(commentMap);

    String title = "${globals.myUser!.nickname!} has commented on your post: '$content'";
    databaseMethods.sendNotification(title, content, widget.snapshot.data!.token!);
  }

  Widget optimizedComments(Map<String, dynamic> replies, Map<String, dynamic> allComments) {
    print("generating comments gcc");
    if (widget.data["mainComments"] != null) {
      List<dynamic> commentIDs = widget.data["mainComments"];
      print("COMMENTIDS INCOMING ===================================================:");
      print(commentIDs);
      // List<String> commentIDs = ["njsbR2mPfSPdJRAfHtKsKeksfRn21659295141390"];
      // commentIDs.sort((a, b) => (b['time']).compareTo(a['time']));

      print("loading comments");
      List<Map<String, dynamic>> comments = [];
      print("printing comments");
      for (Map<String, dynamic> comment in allComments.values) {
        // for (Map<String, dynamic> pointer in commentIDs) {
        //   if (pointer["commentID"] == comment["uid"]) comments.add(comment);
        // }
        if (commentIDs.contains(comment["uid"])) {
          comments.add(comment);
        }
      }
      print(comments.toString());

      comments.sort((b, a) => (b['time']).compareTo(a['time']));
      // comments = comments.reversed.toList();
      return Column(children: [
        for (int i = 0; i < comments.length; i++)
          CommentInstance(
              allComments: allComments,
              replies: replies,
              postData: widget.data,
              commentData: comments[i],
              isExpanded: true),
      ]);

      return CircularProgressIndicator();

      // return Column(children: [
      //   for (int i = 0; i < commentIDs.length; i++)
      //     CommentInstance(
      //         postData: widget.data, commentData: widget.data["full"], isExpanded: true),
      // ]);
    }
    return Container();
  }

  Future<Map<String, dynamic>> getAllComments() async {
    Map<String, dynamic> comments = await FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.data["uid"])
        .collection("Comments")
        .doc("Comments")
        .get()
        .then((value) {
      return value.data()! as Map<String, dynamic>;
    });

    return comments;
  }

  Future<List<Map<String, dynamic>>> getRepliesAndAllComments() async {
    List<Map<String, dynamic>> mapList = [];
    mapList.add(await FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.data["uid"])
        .collection("Replies")
        .doc("Replies")
        .get()
        .then((snapshot) {
      if (snapshot.exists) {
        return snapshot.data()!;
      }
      return {};
    }));
    Map<String, dynamic> comments = await FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.data["uid"])
        .collection("Comments")
        .doc("Comments")
        .get()
        .then((value) {
      return value.data()! as Map<String, dynamic>;
    });
    mapList.add(comments);

    return mapList;
  }
}

TextEditingController commentOnCommentController = TextEditingController();

class CommentInstance extends StatefulWidget {
  const CommentInstance(
      {Key? key,
      required this.postData,
      required this.commentData,
      required this.isExpanded,
      required this.replies,
      required this.allComments})
      : super(key: key);
  final Map<String, dynamic> postData;
  final Map<String, dynamic> commentData;
  final bool isExpanded;
  final Map<String, dynamic> replies;
  final Map<String, dynamic> allComments;
  @override
  State<CommentInstance> createState() => _CommentInstanceState();
}

class _CommentInstanceState extends State<CommentInstance> {
  TextEditingController commentController = TextEditingController();
  bool addComment = false;
  bool isExpanded = true;
  final formKey = GlobalKey<FormState>();
  UserModel? author;

  initState() {
    if (widget.isExpanded) isExpanded = true;
  }

  Color getBorderColor() {
    return widget.commentData["authorID"] == globals.myUser!.uid
        ? globals.primaryColor!
        : globals.primarySwatch!;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (() => showOptions(widget.commentData)),
      // onTap: (() => showOptions(widget.commentData)),
      onTap: (widget.isExpanded)
          ? () {}
          : () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Scaffold(
                          appBar: AppBar(
                            foregroundColor: Colors.white,
                            title: Text(
                              'Karp Portal',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.leagueScript(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          body: SingleChildScrollView(
                              child: Column(
                            children: [
                              CommentInstance(
                                  allComments: widget.allComments,
                                  replies: widget.replies,
                                  postData: widget.postData,
                                  commentData: widget.commentData,
                                  isExpanded: true),
                              SizedBox(height: 10),
                            ],
                          )))));
            },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
              ),
              color: getBorderColor(),
              // gradient: LinearGradient(…)
              // gradient: LinearGradient(
              //     colors: [getBorderColor(), globals.themeColor!],
              //     begin: Alignment(0.0, 0.997),
              //     end: Alignment.bottomCenter,
              //     tileMode: TileMode.clamp),
            ),
            margin: const EdgeInsets.only(top: 5),
            width: double.infinity,
            child: Container(
              margin: EdgeInsets.only(left: 2, top: 2),
              width: double.infinity,
              padding: const EdgeInsets.only(left: 5, top: 10, bottom: 5),
              decoration: BoxDecoration(
                color: globals.themeColor,
                // border: Border(
                //   left: BorderSide(
                //     width: 2,
                //     color: getBorderColor(),
                //   ),
                //   // bottom: BorderSide(
                //   //   width: 2,
                //   //   color: getBorderColor(),
                //   // ),
                //   top: BorderSide(
                //     width: 2,
                //     color: getBorderColor(),
                //   ),
                // ),

                // border: Border.merge(
                //   Border(top: BorderSide(color: getBorderColor(), width: 2)),
                //   Border(left: BorderSide(color: getBorderColor(), width: 2)),
                // ),

                // border: Border.all(width: 2, color: getBorderColor()),

                // Border.all(
                // width: 2,
                // color: widget.commentData["authorID"] == globals.myUser!.uid
                // ? globals.primaryColor!
                // : globals.primarySwatch!,
                // ),

                // borderRadius: BorderRadius.circular(10),
                // shape: BoxShape.circle,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                ),
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.only(left: 5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                              future: getAuthor(widget.commentData["authorID"]),
                              builder: (BuildContext context, AsyncSnapshot<UserModel> snapshot) {
                                if (snapshot.hasData) {
                                  author = snapshot.data!;
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
                                                return const CircularProgressIndicator();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 5),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(snapshot.data!.nickname!),
                                          Text(widget.commentData["time2"],
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontStyle: FontStyle.italic,
                                                  color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return const SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 5),
                            Text(widget.commentData["content"]),
                            if (isExpanded == false)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isExpanded = !isExpanded;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        (!isExpanded)
                                            ? const Text("expand")
                                            : const Text("collapse"),
                                        Icon((!isExpanded) ? Icons.expand_more : Icons.expand_less),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      (isExpanded)
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            addComment = !addComment;
                                          });
                                        },
                                        child: Text((addComment) ? "hide comment" : "add comment",
                                            style: const TextStyle(
                                                fontStyle: FontStyle.italic, color: Colors.grey)),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isExpanded = !isExpanded;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            (!isExpanded)
                                                ? const Text("expand")
                                                : const Text("collapse"),
                                            Icon((!isExpanded)
                                                ? Icons.expand_more
                                                : Icons.expand_less),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                (addComment)
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            // margin: const EdgeInsets.only(top: 10),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(
                                                  width: 2, color: globals.primaryColor!),
                                            ),
                                            child: Form(
                                              key: formKey,
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                                child: TextFormField(
                                                  minLines: 1,
                                                  maxLines: 10,
                                                  controller: commentOnCommentController,
                                                  validator: (value) {
                                                    if (value == null)
                                                      return "enter a valid comment";
                                                    if (value.isEmpty)
                                                      return "put a thing into the comment dum dum";
                                                    if (value == " ")
                                                      return "please enter a valid comment";
                                                  },
                                                  scrollPadding:
                                                      const EdgeInsets.symmetric(vertical: 0),
                                                  decoration: const InputDecoration(
                                                    isDense: true,
                                                    hintText: "enter your comment here",
                                                    focusedBorder: InputBorder.none,
                                                    border: InputBorder.none,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          SizedBox(
                                            height: 25,
                                            child: ElevatedButton(
                                                style: ButtonStyle(
                                                  backgroundColor: MaterialStateProperty.all(
                                                      globals.primaryColor!),
                                                ),
                                                onPressed: (() =>
                                                    postComment(commentOnCommentController.text)),
                                                child: const Text("post comment")),
                                          ),
                                        ],
                                      )
                                    : Container(),
                                optimizedComments(),
                                if (widget.commentData["comments"] != null)
                                  StreamBuilder(
                                      stream: FirebaseFirestore.instance
                                          .collection("Posts")
                                          .doc(widget.postData["uid"])
                                          .collection("comments")
                                          .orderBy('time', descending: false)
                                          .snapshots(),
                                      builder:
                                          (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
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
                                                    for (int i = 0;
                                                        i < snapshot.data!.docs.length;
                                                        i++)
                                                      if (widget.commentData["comments"].contains(
                                                          snapshot.data!.docs[i].data()["uid"]))
                                                        CommentInstance(
                                                            allComments: widget.allComments,
                                                            replies: widget.replies,
                                                            postData: widget.postData,
                                                            commentData: snapshot.data!.docs[i]
                                                                .data() as Map<String, dynamic>,
                                                            isExpanded: false),
                                                  ],
                                                ),
                                              );
                                      }),
                                // for (Map<String, dynamic> comment in widget.data["comments"].reversed)
                                //   CommentInstance(postData: widget.data, commentData: comment),
                                // const SizedBox(height: 5),
                              ],
                            )
                          : Container(),
                      // const SizedBox(height: 15),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 10,
            child: Row(
              children: [
                GestureDetector(
                  onTap: (() => showOptions(widget.commentData)),
                  child: Container(
                      // width: 120,
                      height: 20,
                      decoration: BoxDecoration(
                        color: (globals.myUser!.uid == widget.commentData["authorID"])
                            ? globals.primaryColor
                            : globals.primarySwatch,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(10),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.only(top: 0),
                        child: (widget.commentData["reactions"] != null)
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (widget.commentData["reactions"]["likeIDs"].length > 0)
                                    Row(children: [
                                      const SizedBox(width: 10),
                                      const Icon(Icons.thumb_up, size: 17, color: Colors.white),
                                      const SizedBox(width: 2),
                                      // if (widget.commentData["reactions"]["likeIDs"].length > 1)
                                      Text(
                                        widget.commentData["reactions"]["likeIDs"].length
                                            .toString(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ]),
                                  if (widget.commentData["reactions"]["heartIDs"].length > 0)
                                    Row(children: [
                                      const SizedBox(width: 10),
                                      const Icon(CupertinoIcons.heart,
                                          size: 17, color: Colors.white),
                                      const SizedBox(width: 2),
                                      Text(
                                        widget.commentData["reactions"]["heartIDs"].length
                                            .toString(),
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ]),
                                  if (widget.replies[widget.commentData["uid"]] != null)
                                    // Text(widget.replies[widget.commentData["uid"]].toString()),
                                    if (getRepliesLengt(widget.replies[widget.commentData["uid"]]) >
                                        0)
                                      Row(children: [
                                        const SizedBox(width: 10),
                                        Icon(Icons.comment, size: 17, color: Colors.white),
                                        SizedBox(width: 2),
                                        Text(
                                          "${getRepliesLengt(widget.replies[widget.commentData["uid"]])}",
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ]),

                                  const SizedBox(width: 10),
                                  // Row(children: [
                                  //   SizedBox(width: 10),
                                  //   Text("C: ${widget.commentData["comments"].length.toString()}"),
                                  // ]),
                                ],
                              )
                            : Container(
                                child: const SizedBox(
                                width: 10,
                              )),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  showOptions(Map<String, dynamic> data) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('what do you?'),
          content: SizedBox(
            height: 150,
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: data["content"]));
                    Fluttertoast.showToast(msg: 'content copied succesfully');
                    Navigator.pop(context);
                  },
                  child: const Text('copy comment content'),
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
      await FirebaseFirestore.instance
          .collection("Posts")
          .doc(widget.postData["uid"])
          .collection("Comments")
          .doc("Comments")
          .set({
        widget.commentData["uid"]: {
          "reactions": {
            reaction: FieldValue.arrayRemove([globals.myUser!.uid!]),
          },
        }
      }, SetOptions(merge: true));
    } else {
      await FirebaseFirestore.instance
          .collection("Posts")
          .doc(widget.postData["uid"])
          .collection("Comments")
          .doc("Comments")
          .set({
        widget.commentData["uid"]: {
          "reactions": {
            reaction: FieldValue.arrayUnion([globals.myUser!.uid!]),
          },
        }
      }, SetOptions(merge: true));
    }
    // setState(() {});
  }

  postComment(String content) {
    if (formKey.currentState!.validate() == false) return;
    String commentID = "${globals.myUser!.uid!}${DateTime.now().millisecondsSinceEpoch}";
    Map<String, dynamic> commentMap = {
      "uid": commentID,
      "authorID": globals.myUser!.uid!,
      "time": DateTime.now().millisecondsSinceEpoch,
      "time2": databaseMethods.getCurrentTime(),
      "content": content,
      "reactions": {
        "likeIDs": [globals.myUser!.uid!],
        "heartIDs": [],
        "shareIDs": []
      },
    };

    FirebaseFirestore.instance.collection("Posts").doc(widget.postData["uid"]).set({
      // "fullComments": FieldValue.arrayUnion([commentMap]),
      "allComments": FieldValue.arrayUnion([commentID])
    }, SetOptions(merge: true));
    FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.postData["uid"])
        .collection("Replies")
        .doc("Replies")
        .set({
      widget.commentData["uid"]: FieldValue.arrayUnion([commentID]),
    }, SetOptions(merge: true));

    FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.postData["uid"])
        .collection("Comments")
        .doc("Comments")
        .set({commentID: commentMap}, SetOptions(merge: true));

    // FirebaseFirestore.instance
    //     .collection("Posts")
    //     .doc(widget.postData["uid"])
    //     .set({
    //   "fullComments":
    // }, SetOptions(merge: true));
    commentOnCommentController.text = "";
    addComment = false;

    // FirebaseFirestore.instance
    //     .collection("Posts")
    //     .doc(widget.postData["uid"])
    //     .collection("comments")
    //     .doc(commentID)
    //     .set(commentMap);

    String title = "${globals.myUser!.nickname!} has commented on your comment: '$content'";
    databaseMethods.sendNotification(title, content, author!.token!);
  }

  Widget optimizedComments() {
    // List<dynamic>? commentIDs = await FirebaseFirestore.instance
    //     .collection("Posts")
    //     .doc(widget.postData["uid"])
    //     .collection("Replies")
    //     .doc("Replies")
    //     .get()
    //     .then((value) {
    //   return value.data()![widget.commentData["uid"]];
    // });
    List<dynamic>? commentIDs = widget.replies[widget.commentData["uid"]];
    // List<String> commentIDs = ["njsbR2mPfSPdJRAfHtKsKeksfRn21659295141390"];
    // commentIDs.sort((a, b) => (b['time']).compareTo(a['time']));
    if (commentIDs == null) return Container();

    List<Map<String, dynamic>> comments = [];
    print("printing comments");
    for (Map<String, dynamic> comment in widget.allComments.values) {
      // for (Map<String, dynamic> pointer in commentIDs) {
      //   if (pointer["commentID"] == comment["uid"]) comments.add(comment);
      // }
      if (commentIDs.contains(comment["uid"])) {
        comments.add(comment);
      }
    }
    print(comments.toString());

    comments.sort((b, a) => (b['time']).compareTo(a['time']));
    // comments = comments.reversed.toList();
    return Column(children: [
      for (int i = 0; i < comments.length; i++)
        CommentInstance(
            allComments: widget.allComments,
            replies: widget.replies,
            postData: widget.postData,
            commentData: comments[i],
            isExpanded: true),
    ]);
  }

  Future<Map<String, dynamic>> getAllComments() async {
    Map<String, dynamic> comments = await FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.postData["uid"])
        .collection("Comments")
        .doc("Comments")
        .get()
        .then((value) {
      return value.data()! as Map<String, dynamic>;
    });
    return comments;
  }

  int getRepliesLengt(replies) {
    int length = 0;
    List<dynamic> repliesList = replies;
    length += repliesList.length;
    // print(repliesList.length);
    if (repliesList.length > 0) {
      for (String id in repliesList) {
        if (widget.replies[id] != null) {
          length += getRepliesLengt(widget.replies[id]);
        }
      }
    }

    return length;
  }
}
