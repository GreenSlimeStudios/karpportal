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
  bool addComment = false;
  initState() {
    isExpanded = widget.isExpanded;
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
                          appBar: AppBar(title: Text("Karpportal")),
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
                  // padding: EdgeInsets.symmetric(horizontal: 10),
                  constraints: const BoxConstraints(maxWidth: 3000),
                  child: (widget.data["content"] != null && widget.data["content"] != " ")
                      ? Container(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            widget.data["content"],
                          ),
                        )
                      : Container(),
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
                          const SizedBox(height: 5),
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
                                    style: const TextStyle(
                                        fontStyle: FontStyle.italic, color: Colors.grey)),
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
                                  ],
                                )
                              : Container(),
                          if (widget.data["comments"] != null)
                            StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection("Posts")
                                    .doc(widget.data["uid"])
                                    .collection("comments")
                                    .orderBy('time', descending: true)
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
                                                      postData: widget.data,
                                                      commentData: snapshot.data!.docs[i].data()
                                                          as Map<String, dynamic>),
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
                          if (widget.data["comments"].length > 0)
                            Row(children: [
                              const SizedBox(width: 10),
                              const Icon(Icons.comment, size: 17, color: Colors.white),
                              const SizedBox(width: 2),
                              Text(
                                widget.data["comments"].length.toString(),
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
      "comments": FieldValue.arrayUnion([commentID])
    }, SetOptions(merge: true));
    commentController.text = "";
    addComment = false;

    FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.data["uid"])
        .collection("comments")
        .doc(commentID)
        .set(commentMap);

    String title = "${globals.myUser!.nickname!} has commented on your post: '$content'";
    databaseMethods.sendNotification(title, content, widget.snapshot.data!.token!);
  }
}

class CommentInstance extends StatefulWidget {
  const CommentInstance({Key? key, required this.postData, required this.commentData})
      : super(key: key);
  final Map<String, dynamic> postData;
  final Map<String, dynamic> commentData;
  @override
  State<CommentInstance> createState() => _CommentInstanceState();
}

class _CommentInstanceState extends State<CommentInstance> {
  TextEditingController commentController = TextEditingController();
  bool addComment = false;
  bool isExpanded = false;
  final formKey = GlobalKey<FormState>();
  UserModel? author;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: (() => showOptions(widget.postData)),
      onTap: (() => showOptions(widget.commentData)),
      child: Stack(
        children: [
          Container(
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
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
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
                    (isExpanded)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  (widget.commentData["comments"] != null)
                                      ? Text("Comments ${widget.commentData["comments"].length}")
                                      : Text("comments 0"),
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
                              (addComment)
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(top: 10),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border:
                                                Border.all(width: 2, color: globals.primaryColor!),
                                          ),
                                          child: Form(
                                            key: formKey,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                              child: TextFormField(
                                                minLines: 1,
                                                maxLines: 10,
                                                controller: commentController,
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
                                                  postComment(commentController.text)),
                                              child: const Text("post comment")),
                                        ),
                                      ],
                                    )
                                  : Container(),
                              if (widget.commentData["comments"] != null)
                                StreamBuilder(
                                    stream: FirebaseFirestore.instance
                                        .collection("Posts")
                                        .doc(widget.postData["uid"])
                                        .collection("comments")
                                        .orderBy('time', descending: true)
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
                                                          postData: widget.postData,
                                                          commentData: snapshot.data!.docs[i].data()
                                                              as Map<String, dynamic>),
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
              ],
            ),
          ),
          Positioned(
            bottom: -20,
            left: 10,
            child: Row(
              children: [
                Container(
                    // width: 120,
                    height: 40,
                    decoration: BoxDecoration(
                      color: (globals.myUser!.uid == widget.commentData["authorID"])
                          ? globals.primaryColor
                          : globals.primarySwatch,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 18),
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
                                      widget.commentData["reactions"]["likeIDs"].length.toString(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ]),
                                if (widget.commentData["reactions"]["heartIDs"].length > 0)
                                  Row(children: [
                                    const SizedBox(width: 10),
                                    const Icon(CupertinoIcons.heart, size: 17, color: Colors.white),
                                    const SizedBox(width: 2),
                                    Text(
                                      widget.commentData["reactions"]["heartIDs"].length.toString(),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ]),
                                if (widget.commentData["comments"] != null)
                                  if (widget.commentData["comments"].length > 0)
                                    Row(children: [
                                      const SizedBox(width: 10),
                                      Icon(Icons.comment, size: 17),
                                      SizedBox(width: 2),
                                      Text("${widget.commentData["comments"].length.toString()}"),
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
                const SizedBox(width: 5),
                Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  child: Text(
                    (widget.commentData["time2"] != null)
                        ? widget.commentData["time2"]
                        : "2022/07/12 00:00",
                    style: const TextStyle(
                        color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 5,
            right: 10,
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
          .collection("comments")
          .doc(widget.commentData["uid"])
          .set({
        "reactions": {
          reaction: FieldValue.arrayRemove([globals.myUser!.uid!]),
        }
      }, SetOptions(merge: true));
    } else {
      await FirebaseFirestore.instance
          .collection("Posts")
          .doc(widget.postData["uid"])
          .collection("comments")
          .doc(widget.commentData["uid"])
          .set({
        "reactions": {
          reaction: FieldValue.arrayUnion([globals.myUser!.uid!]),
        }
      }, SetOptions(merge: true));
    }
  }

  postComment(String content) {
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

    FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.postData["uid"])
        .collection("comments")
        .doc(widget.commentData["uid"])
        .set({
      "comments": FieldValue.arrayUnion([commentID])
    }, SetOptions(merge: true));
    commentController.text = "";
    addComment = false;

    FirebaseFirestore.instance
        .collection("Posts")
        .doc(widget.postData["uid"])
        .collection("comments")
        .doc(commentID)
        .set(commentMap);

    String title = "${globals.myUser!.nickname!} has commented on your comment: '$content'";
    databaseMethods.sendNotification(title, content, author!.token!);
  }
}
