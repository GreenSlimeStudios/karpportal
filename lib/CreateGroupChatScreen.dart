import 'package:flutter/material.dart';

import 'Stylings.dart';

class GroupChatCreator extends StatefulWidget {
  const GroupChatCreator({Key? key}) : super(key: key);

  @override
  State<GroupChatCreator> createState() => _GroupChatCreatorState();
}

TextEditingController groupNameController = TextEditingController();
final formKey = GlobalKey<FormState>();

class _GroupChatCreatorState extends State<GroupChatCreator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cretate Group Chat"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Image.network(
                    "https://external-content.duckduckgo.com/iu/?u=https%3A%2F%2Ftse4.explicit.bing.net%2Fth%3Fid%3DOIP.TolLwDCaTfUkxM3v-ZCqUgAAAA%26pid%3DApi&f=1",
                    fit: BoxFit.fill,
                    width: 100,
                    height: 100,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 5, top: 10),
                  child: Text("GROUP NAME",
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                ),
                TextFormField(
                  controller: groupNameController,
                  decoration: InputDecoration(
                    hintText: "Group Name",
                    border: inactiveRoundBorder(),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10, bottom: 5, top: 10),
                  child: Text("GROUP DESCRIPTION",
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                ),
                TextFormField(
                  controller: groupNameController,
                  decoration: InputDecoration(
                    hintText: "Group Description",
                    border: inactiveRoundBorder(),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  height: 40,
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      shape:
                          MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(),
                      )),
                    ),
                    onPressed: () {},
                    child: Text("Create Group Chat"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
