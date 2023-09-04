import 'package:cloud_firestore/cloud_firestore.dart';

//firestore is like realtime db that i ended up using, a little difrent in db structure with it's own benefits
//didn't suit my needs
//the file can be deleted

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
