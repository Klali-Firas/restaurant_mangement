import 'package:cloud_firestore/cloud_firestore.dart';

final db = FirebaseFirestore.instance;

Future<void> addData(
    String collectionpath, String docpath, Map<String, dynamic> data) async {
  await db
      .collection(collectionpath)
      .doc(docpath)
      .set(data)
      .onError((error, stackTrace) => print("error : $error"));
}

Future<void> updateData(
    String collectionpath, String docpath, Map<String, dynamic> data) async {
  await db
      .collection(collectionpath)
      .doc(docpath)
      .update(data)
      .onError((error, stackTrace) => print("error : $error"));
}

CollectionReference getData(String collectionPath) {
  return db.collection(collectionPath);
}

remeoveData(String collectionPath, String docID) async {
  await db.collection(collectionPath).doc(docID).delete();
}
