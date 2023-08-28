import 'package:flutter/material.dart';

import '../utility/authentification.dart';

class Manager extends StatefulWidget {
  const Manager({super.key});
  @override
  State<Manager> createState() => _Manager();
}

class _Manager extends State<Manager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Manager", textAlign: TextAlign.center),
          centerTitle: true),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          await signOut();
          return true;
        },
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Button(text: "Add/Remove Server", pressed: '/ARServer'),
            SizedBox(height: 10),
            Button(text: "Add/Remove Cook", pressed: '/ARCook'),
            SizedBox(height: 10),
            Button(text: "Update Tables", pressed: '/UTables'),
            SizedBox(height: 10),
            Button(text: "Update Menu", pressed: '/UMenu'),
            SizedBox(height: 10),
            Button(text: "Daily Earnings", pressed: '/Earnings'),
          ],
        )),
      ),
    );
  }
}

class Button extends StatelessWidget {
  const Button({super.key, required this.text, required this.pressed});
  final String text;
  final String pressed;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 18),
          fixedSize: const Size(250, 50),
        ),
        onPressed: () => Navigator.pushNamed(context, pressed),
        child: Text(text));
  }
}
