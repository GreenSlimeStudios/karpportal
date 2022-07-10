import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
            ), // snap: true,

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
          return Stack(
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: globals.themeColor,
                  border: Border.all(
                    width: 2,
                    color: data["authorID"] == globals.myUser!.uid
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
                              imageUrl: snapshot.data!.avatarUrl!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.fill,
                              placeholder: (builder, url) => const CircularProgressIndicator(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data!.nickname!,
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                Container(
                                  constraints: const BoxConstraints(maxWidth: 250),
                                  child: Text(
                                    data["title"],
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
                      child: Text(
                        data["content"],
                      ),
                    ),
                    // const SizedBox(height: 10),
                    if (data["ImageURLs"].length > 0)
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        padding: const EdgeInsets.only(
                          top: 10,
                          bottom: 5,
                        ),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              for (String url in data["ImageURLs"])
                                Container(
                                  // padding: EdgeInsets.symmetric(vertical: 5),
                                  child: GestureDetector(
                                    child: CachedNetworkImage(
                                      imageUrl: url,
                                      placeholder: (builder, url) =>
                                          const CircularProgressIndicator(),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => InteractiveViewer(
                                                  child: CachedNetworkImage(imageUrl: url))));
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 15),
                  ],
                ),
              ),
              Positioned(
                bottom: -20,
                left: 20,
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: (globals.myUser!.uid == data["authorID"])
                        ? globals.primaryColor
                        : globals.primarySwatch,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(children: [
                          SizedBox(width: 10),
                          Text("L: ${data["reactions"]["likeIDs"].length.toString()}"),
                        ]),
                        Row(children: [
                          SizedBox(width: 10),
                          Text("H: ${data["reactions"]["heartIDs"].length.toString()}"),
                        ]),
                        Row(children: [
                          SizedBox(width: 10),
                          Text("S: ${data["reactions"]["shareIDs"].length.toString()}"),
                        ]),
                        // Row(children: [
                        //   SizedBox(width: 10),
                        //   Text("C: ${data["comments"].length.toString()}"),
                        // ]),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
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
}

class Reaction extends StatefulWidget {
  Reaction({Key? key, required this.icon}) : super(key: key);

  final Icon icon;

  @override
  State<Reaction> createState() => _ReactionState();
}

class _ReactionState extends State<Reaction> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
