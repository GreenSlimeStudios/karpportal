import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseMethods {
  getByUserName(String username) async {
    // var x = await FirebaseFirestore.instance
    //     .collection('users')
    //     .where('nickname', isEqualTo: username)
    //     .get;

    // print(x.toString());
    //return x;

    var documentList = (await FirebaseFirestore.instance
        .collection("users")
        .where("firstName", arrayContains: username)
        .snapshots());

    print(documentList.toString());
    print('=======================================');
    print(documentList);

    return documentList;
  }

  createChatRoom(String chatRoomId, chatRoomMap) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .set(chatRoomMap)
        .onError((error, stackTrace) => print(error.toString()));
  }

  getLogin() async {
    final prefs = await SharedPreferences.getInstance();
  }

  addConversationMessages(String chatRoomId, messageMap, bool isImage) {
    FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chat")
        .add(messageMap)
        .catchError((e) {
      print(e.toString());
    });
  }

  getConversationMessages(String chatRoomId) async {
    return await FirebaseFirestore.instance
        .collection("ChatRoom")
        .doc(chatRoomId)
        .collection("chat")
        .snapshots();
  }

  getPosts() async {
    return await FirebaseFirestore.instance
        .collection("Posts")
        .orderBy("timeMil", descending: true)
        .snapshots();
  }

  createPost(postMap) {
    FirebaseFirestore.instance.collection("Posts").add(postMap).catchError((e) {
      print(e.toString());
    });
  }
}
