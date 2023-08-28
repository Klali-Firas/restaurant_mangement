import 'package:firebase_database/firebase_database.dart';

final FirebaseDatabase database = FirebaseDatabase.instance;

Future<void> addData(String path, Map<String, dynamic> data) async {
  final DatabaseReference reference = database.ref().child(path);
  await reference.set(data).catchError((error) => print("Error: $error"));
}

Future<void> updateData(String path, Map<String, dynamic> data) async {
  final DatabaseReference reference = database.ref().child(path);
  await reference.update(data).catchError((error) => print("Error: $error"));
}

DatabaseReference getData(String path) {
  return database.ref().child(path);
}

Future<void> removeData(String path) async {
  final DatabaseReference reference = database.ref().child(path);
  await reference.remove().catchError((error) => print("Error: $error"));
}
