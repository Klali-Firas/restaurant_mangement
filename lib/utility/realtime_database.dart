import 'package:firebase_database/firebase_database.dart';

//all functionalies required for the db manipulation

final FirebaseDatabase database = FirebaseDatabase.instance;

//writing data
Future<void> addData(String path, Map<String, dynamic> data) async {
  final DatabaseReference reference = database.ref().child(path);
  await reference.set(data).catchError((error) => print("Error: $error"));
}

//updating data
Future<void> updateData(String path, Map<String, dynamic> data) async {
  final DatabaseReference reference = database.ref().child(path);
  await reference.update(data).catchError((error) => print("Error: $error"));
}

//reading data
DatabaseReference getData(String path) {
  return database.ref().child(path);
}

//deleting data
Future<void> removeData(String path) async {
  final DatabaseReference reference = database.ref().child(path);
  await reference.remove().catchError((error) => print("Error: $error"));
}
