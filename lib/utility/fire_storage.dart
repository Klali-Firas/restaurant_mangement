import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:restaurant_mangement/utility/toast.dart';

Future<XFile?> pickImage() async {
  final ImagePicker picker = ImagePicker();
  try {
    XFile? image = await picker.pickImage(
        source: ImageSource.gallery, maxHeight: 1024, maxWidth: 1024);
    image = await _cropImage(image);
    return image;
  } catch (e) {
    showToast('Error picking image: $e');
    return null;
  }
}

Future<XFile?> _cropImage(XFile? pickedFile) async {
  if (pickedFile != null) {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: pickedFile.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.amber,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
      ],
    );
    if (croppedFile != null) {
      return XFile(croppedFile.path);
    }
  }
}

Future<String?> uploadImageToStorage(
    XFile imageFile, Function(double) progressCallback) async {
  try {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference ref =
        FirebaseStorage.instance.ref().child('images').child(fileName);

    UploadTask uploadTask = ref.putFile(File(imageFile.path));

    uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
      double progress = snapshot.bytesTransferred / snapshot.totalBytes;
      progressCallback(progress);
    });

    await uploadTask;

    String downloadURL = await ref.getDownloadURL();
    return downloadURL;
  } catch (e) {
    print('Error uploading image: $e');
    return null;
  }
}
