import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({Key? key}) : super(key: key);

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
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
    ));
  }

  Widget content() => SliverToBoxAdapter(
        child: Container(height: 1000),
      );
}
