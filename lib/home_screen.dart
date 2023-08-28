import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/authentification.dart';
import 'package:restaurant_mangement/utility/toast.dart';
import 'utility/realtime_database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  bool visible = true;

  void changeVisibility() {
    setState(() {
      visible = !visible;
    });
  }

  void changeScreen(String path) {
    Navigator.pushNamed(context, path);
  }

  void useSignIn() async {
    var data = await getUserData();
    if (data != null) {
      await signIn(emailController.text.trim(), passController.text.trim());
      if (isSIgnedIn()) {
        if (data[fbAuth.currentUser?.displayName]["deleted"]) {
          getData("accounts")
              .child("${fbAuth.currentUser?.displayName}")
              .remove();
          await fbAuth.currentUser!.delete();
          showToast('this account has been deleted by the Manager !');
        } else {
          showToast("Loged In Successfully");
          changeScreen("/${data[fbAuth.currentUser?.displayName]["type"]}");
        }
      }
    } else {
      showToast("There's no account with the given cedentiels!");
    }
  }

  Future<Map<dynamic, dynamic>?> getUserData({String? email}) async {
    Map<dynamic, dynamic>? data;

    await getData("accounts")
        .orderByChild("email")
        .equalTo(email ?? emailController.text.trim())
        .once()
        .then((value) {
      if (value.snapshot.value != null) {
        data = Map<dynamic, dynamic>.from(
            (value.snapshot.value) as Map<dynamic, dynamic>);
      }
    });

    return data;
  }

  @override
  void initState() {
    super.initState();
    if (isSIgnedIn()) {
      getUserData(email: fbAuth.currentUser?.email).then((userData) {
        if (userData != null) {
          if (userData[fbAuth.currentUser?.displayName]["deleted"]) {
            getData("accounts")
                .child("${fbAuth.currentUser?.displayName}")
                .remove();
            fbAuth.currentUser!.delete();
          } else {
            showToast("Logged In Successfully");
            changeScreen(
                "/${userData[fbAuth.currentUser?.displayName]["type"]}");
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome!"),
        centerTitle: true,
      ),
      body: _buildAddServerTab(),
    );
  }

  Widget _buildAddServerTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildInputFormField(
            controller: emailController,
            prefixIcon: Icons.alternate_email,
            labelText: "Email",
          ),
          _buildInputFormField(
            controller: passController,
            prefixIcon: Icons.lock_outlined,
            labelText: "Password",
            isPassword: true,
          ),
          _buildElevatedButton(
            onPressed: useSignIn,
            buttonText: "Login!",
          ),
        ],
      ),
    );
  }

  Widget _buildInputFormField({
    required TextEditingController controller,
    required IconData prefixIcon,
    required String labelText,
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? visible : false,
        decoration: InputDecoration(
          prefixIcon: Icon(prefixIcon),
          labelText: labelText,
          border: const OutlineInputBorder(),
          suffixIcon: isPassword
              ? GestureDetector(
                  onTap: changeVisibility,
                  child:
                      Icon(visible ? Icons.visibility : Icons.visibility_off),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildElevatedButton({
    required VoidCallback onPressed,
    required String buttonText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(250, 50),
          textStyle: const TextStyle(fontSize: 18.0),
        ),
        onPressed: onPressed,
        child: Text(buttonText),
      ),
    );
  }
}
