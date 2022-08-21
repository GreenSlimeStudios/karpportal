import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:karpportal/MessagesScreen.dart';
import 'ImageActions.dart';
import 'globals.dart' as globals;

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

TextEditingController titleController = TextEditingController();
TextEditingController contentController = TextEditingController();

class _CreatePostPageState extends State<CreatePostPage> {
  final formKey = GlobalKey<FormState>();
  List<String> imageURLs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Add the app bar to the CustomScrollView.
          SliverAppBar(
            // Provide a standard title.
            title: Text(
              "Create Post",
              style: GoogleFonts.leagueScript(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            floating: true,
          ),
          content(),
        ],
      ),
    );
  }

  Widget content() => SliverToBoxAdapter(
        child: Form(
          key: formKey,
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Title",
                    style: GoogleFonts.leagueScript(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  minLines: 1,
                  maxLines: 2,
                  controller: titleController,
                  decoration: InputDecoration(
                    hintText: "Enter Post Title",
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: globals.primarySwatch as Color, width: 3),
                    ),
                  ),
                  validator: (value) {
                    if (value != null && value != "" && value.isEmpty == false) {
                      if (value == " ") {
                        return "bruh you tryin to trick me?";
                      }
                      return null;
                    } else {
                      return "Please create a title";
                    }
                  },
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Content",
                    style: GoogleFonts.leagueScript(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  minLines: 1,
                  maxLines: 10,
                  controller: contentController,
                  decoration: InputDecoration(
                    hintText: "Enter Post Content",
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: globals.primarySwatch as Color, width: 3),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: globals.themeColor,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (String url in imageURLs) Image.network(url),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Padding(
                //   padding: EdgeInsets.only(left: 10),
                //   child: Text(
                //     "Submit Post",
                //     style: GoogleFonts.leagueScript(fontSize: 22, fontWeight: FontWeight.bold),
                //   ),
                // ),
                // SizedBox(height: 10),
                GestureDetector(
                  onTap: AddPicture,
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: globals.primaryColor,
                    ),
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(CupertinoIcons.camera),
                        const SizedBox(width: 10),
                        Text(
                          "Add Picture",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dancingScript(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 27,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.camera),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: SubmitPost,
                  child: Container(
                    height: 40,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: globals.primarySwatch,
                    ),
                    padding: const EdgeInsets.only(left: 10),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload),
                        const SizedBox(width: 10),
                        Text(
                          "Submit Post",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dancingScript(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 27,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.upload),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  SubmitPost() async {
    if (formKey.currentState!.validate()) {
      List<String> emptyList = [];
      List<String> lsitWithAuthor = [globals.myUser!.uid!];
      List<Map<String, dynamic>> emptyMapList = [];
      String uid =
          globals.myUser!.uid.toString() + DateTime.now().millisecondsSinceEpoch.toString();
      //do stuff
      Map<String, dynamic> postMap = {
        "uid": uid,
        "authorID": globals.myUser!.uid,
        "timeMil": DateTime.now().millisecondsSinceEpoch,
        "title": titleController.text.trim(),
        "time2": databaseMethods.getCurrentTime(),
        "content": contentController.text.trim(),
        "reactions": {"heartIDs": emptyList, "likeIDs": lsitWithAuthor, "shareIDs": emptyList},
        "ImageURLs": imageURLs,
        "comments": emptyMapList,
      };
      await databaseMethods.createPost(uid, postMap);
      Navigator.pop(context);
      // print("UUUUUUUUUUUUUUUUUUUUUUUUUUDALO SIE CHYBA NWM XD");
    }
  }

  void AddPicture() {
    pickImage();
  }

  String? imageUrl;

  Future pickImage() async {
    var downloadurls = await pickGaleryImages("PostImages");
    if (downloadurls == null) {
      Fluttertoast.showToast(
          msg: "We have encountered a problem while trying to upoad the image/s");
      return;
    }
    for (String downloadurl in downloadurls) {
      imageUrl = downloadurl;
      imageURLs.add(imageUrl!);
    }
    setState(() {});
    Fluttertoast.showToast(msg: "Image uploaded successfully :) ");
  }
}
