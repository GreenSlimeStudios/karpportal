import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'globals.dart' as globals;

Future<File> compressFile(File file) async {
  final filePath = file.absolute.path;

  // Create output file path
  // eg:- "Volume/VM/abcd_out.jpeg"
  final lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
  final splitted = filePath.substring(0, (lastIndex));
  final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    outPath,
    quality: 50,
  );

  print(file.lengthSync());
  print(result?.lengthSync());

  return result ?? file;
}

Future<String?> pickGaleryImage(String folder) async {
  File? imageTemporary;
  final storage = FirebaseStorage.instance;

  try {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return null;

    // image = await compressFile(image as File) as XFile;

    imageTemporary = File(image.path);

    print("FILE SIZE BEFORE COMPRESSION: ${imageTemporary.lengthSync()}");
    // Compress the fie if its bigger that 800kb
    if (imageTemporary.lengthSync() > 800000) {
      imageTemporary = await compressFile(imageTemporary);
    }
    print("FILE SIZE AFTER COMPRESSION: ${imageTemporary.lengthSync()}");

    if (imageTemporary.lengthSync() > 4000000) {
      Fluttertoast.showToast(msg: 'bruh are you tryin to fuck up my cloud storage?');
      return null;
    }
  } on PlatformException catch (e) {
    print('failed tp pick image $e');
  }
  Fluttertoast.showToast(msg: "Uploading image... stay on page");
  //final ref = FirebaseStorage
  var snapshot = await storage
      .ref()
      .child('${folder}/${globals.myUser!.uid! + DateTime.now().millisecondsSinceEpoch.toString()}')
      .putFile(imageTemporary!);

  var downloadurl = await snapshot.ref.getDownloadURL();

  Fluttertoast.showToast(msg: "succesfully uploaded image");

  return downloadurl;
}

Future<List<String>?> pickGaleryImages(String folder) async {
  File? imageTemporary;
  final storage = FirebaseStorage.instance;
  List<String> imageURLs = [];

  try {
    final images = await ImagePicker().pickMultiImage();
    if (images == null) return null;

    // image = await compressFile(image as File) as XFile;
    for (int i = 0; i < images.length; i++) {
      imageTemporary = File(images[i].path);

      print("FILE SIZE BEFORE COMPRESSION: ${imageTemporary.lengthSync()}");
      // Compress the fie if its bigger that 800kb
      if (imageTemporary.lengthSync() > 800000) {
        imageTemporary = await compressFile(imageTemporary);
      }
      print("FILE SIZE AFTER COMPRESSION: ${imageTemporary.lengthSync()}");

      if (imageTemporary.lengthSync() > 4000000) {
        Fluttertoast.showToast(msg: 'bruh are you tryin to fuck up my cloud storage?');
        return null;
      }
      Fluttertoast.showToast(msg: "Uploading image(${i + 1})... stay on page");
      //final ref = FirebaseStorage
      var snapshot = await storage
          .ref()
          .child(
              '${folder}/${globals.myUser!.uid! + DateTime.now().millisecondsSinceEpoch.toString()}')
          .putFile(imageTemporary);

      var downloadurl = await snapshot.ref.getDownloadURL();
      imageURLs.add(downloadurl);
    }
    Fluttertoast.showToast(msg: "succesfully uploaded images");
    return imageURLs;
  } on PlatformException catch (e) {
    print('failed tp pick image $e');
  }
}
