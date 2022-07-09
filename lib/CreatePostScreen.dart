import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
                  padding: EdgeInsets.only(left: 10),
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
                      return null;
                    } else {
                      return "Please create a title";
                    }
                  },
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 10),
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
                  validator: (value) {
                    if (value != null && value != "" && value.isEmpty == false) {
                      return null;
                    } else {
                      return "Please create a title";
                    }
                  },
                ),
                SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "Submit Post",
                    style: GoogleFonts.leagueScript(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: globals.primarySwatch,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  SubmitPost() {
    if (formKey.currentState!.validate()) {
      //do stuff
    }
  }
}
