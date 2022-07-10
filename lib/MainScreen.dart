import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'CreatePostScreen.dart';
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
                margin: EdgeInsets.only(top: 55),
                padding: EdgeInsets.all(10),
                child: GestureDetector(
                  onTap: createPost,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: globals.themeColor,
                      border: Border.all(width: 4, color: globals.primarySwatch!.shade700 as Color),
                    ),
                    child: Text("Tell the world something cool what's going on!"),
                  ),
                ),
              ),
            ),
            // Make the initial height of the SliverAppBar larger than normal.
            expandedHeight: 170,
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

  renderPosts(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 10, top: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            data["title"],
          ),
          Text(
            data["content"],
          ),
          SizedBox(height: 300),
        ],
      ),
    );
  }
}
