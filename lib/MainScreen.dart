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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
          slivers: [
            // Add the app bar to the CustomScrollView.
            SliverAppBar(
              title: const Text("What's poppin ?"),
              // snap: true,

              // Allows the user to reveal the app bar if they begin scrolling
              // back up the list of items
              floating: true,
              // Display a placeholder widget to visualize the shrinking size.
              flexibleSpace: Container(
                color: globals.primarySwatch,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  color: globals.themeColor,
                  margin: EdgeInsets.only(top: 60),
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
                        border:
                            Border.all(width: 4, color: globals.primarySwatch!.shade700 as Color),
                      ),
                      child: Text("Tell the world something cool what's going on!"),
                    ),
                  ),
                ),
              ),
              // Make the initial height of the SliverAppBar larger than normal.
              expandedHeight: 200,
            ),
            content(),
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: createPost));
  }

  Widget content() => SliverToBoxAdapter(child: Container(height: 1000));
  void createPost() async {
    var info = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const CreatePostPage()));
  }
}
