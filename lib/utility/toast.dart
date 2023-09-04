import 'package:fluttertoast/fluttertoast.dart';

//Library to show messages with in the app

void showToast(String msg) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 16.0);
}
