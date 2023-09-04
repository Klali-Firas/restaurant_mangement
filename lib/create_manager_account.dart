import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/authentification.dart';
import 'package:restaurant_mangement/utility/realtime_database.dart';
import 'package:restaurant_mangement/utility/toast.dart';

class CreateManagerAccount extends StatefulWidget {
  const CreateManagerAccount({Key? key}) : super(key: key);

  @override
  State<CreateManagerAccount> createState() => _CreateManagerAccountState();
}

class _CreateManagerAccountState extends State<CreateManagerAccount> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  //prefent existing the current screen when creating new user
  bool isCreatingUser = false;

//controls visibilty of the password input text
  bool visible = true;
  void changeVisibility() {
    setState(() {
      visible = !visible;
    });
  }

  void changeScreen() {
    Navigator.pushNamed(context, "/Manager");
  }

//create Mnager account.
  void useCreateUser() async {
    try {
      setState(() {
        isCreatingUser = true; // Disable the button and form fields
      });

      final email = emailController.value.text.trim().toLowerCase();
      final pass = passController.value.text.trim();
      final displayName = nameController.value.text.trim();

      final UserCredential credential =
          await fbAuth.createUserWithEmailAndPassword(
        email: email,
        password: pass,
      );

      await credential.user!.updateDisplayName(displayName);

      // Add data to the database only if account creation is successful
      await addData('accounts/$displayName', {
        'type': 'Manager',
        'password': pass,
        'email': email,
        'deleted': false,
      });

      // Clear the input fields
      nameController.clear();
      emailController.clear();
      passController.clear();

      setState(() {
        isCreatingUser = false; // Disable the button and form fields
      });
      showToast("Account Created Successfully");
      changeScreen();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      }
    } catch (e) {
      showToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return !isCreatingUser;
      },
      child: Scaffold(
        body: _buildAddManagerTab(),
      ),
    );
  }

  Widget _buildAddManagerTab() {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset("assets/images/teal_logo.png",
              width: MediaQuery.of(context).size.width * 0.3),
          const SizedBox(height: 20),
          _buildInputFormField(
            controller: nameController,
            prefixIcon: Icons.account_circle_outlined,
            labelText: "UserName",
          ),
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
            onPressed: useCreateUser,
            buttonText: "Create Manager Account",
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account ? "),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/Home'),
                child: const Text(
                  "Login",
                  style: TextStyle(color: Colors.teal),
                ),
              )
            ],
          )
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
        obscuringCharacter: "*",
        enabled: !isCreatingUser,
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
          fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 45),
          textStyle: const TextStyle(fontSize: 18.0),
        ),
        onPressed: () {
          //checking whether all the fields are filled or not before creating the account
          if (isCreatingUser) {
            null;
          } else {
            if (emailController.text.isNotEmpty &&
                passController.text.isNotEmpty) {
              if (EmailValidator.validate(emailController.text.trim())) {
                useCreateUser();
              } else {
                showToast("Please enter a valid Email");
              }
            } else {
              showToast("All fields must be filled!");
            }
          }
        },
        child: Text(buttonText),
      ),
    );
  }
}
