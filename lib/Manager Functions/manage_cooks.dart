import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/authentification.dart';

import '../utility/realtime_database.dart';
import '../utility/toast.dart';

class ARCook extends StatefulWidget {
  const ARCook({super.key});
  @override
  State<ARCook> createState() => _ARCookState();
}

class _ARCookState extends State<ARCook>
    with AutomaticKeepAliveClientMixin<ARCook> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool isCreatingUser = false;

  //toogle obsecure text visibility
  bool visible = true;
  void changeVisibility() {
    setState(() {
      visible = !visible;
    });
  }

//create new Cook
  void useCreateUser() async {
    try {
      setState(() {
        isCreatingUser = true; // Disable the button and form fields
      });
      var managerEmail = "${fbAuth.currentUser?.email}";
      late String managerPassword;
      await getData("accounts/${fbAuth.currentUser?.displayName}/password")
          .once()
          .then((value) => managerPassword = value.snapshot.value.toString());
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
        'type': 'Cook',
        'password': pass,
        'email': email,
        'deleted': false,
      });

      // Clear the input fields
      nameController.clear();
      emailController.clear();
      passController.clear();
      await signOut();
      await signIn(managerEmail,
          managerPassword); // Replace with actual manager email and password
      setState(() {
        isCreatingUser = false; // Disable the button and form fields
      });
      showToast("Account Created Successfully");
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
    return DefaultTabController(
      length: tabs.length,
      child: WillPopScope(
        onWillPop: () async {
          return !isCreatingUser;
        },
        child: Scaffold(
          appBar: AppBar(
            bottom: TabBar(tabs: tabs),
            title: const Text("Cook Configuration"),
            centerTitle: true,
          ),
          body: TabBarView(
            children: [
              _buildAddCookTab(),
              _BuildRemoveCookTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddCookTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            buttonText: "Add New Cook!",
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
          fixedSize: const Size(250, 50),
          textStyle: const TextStyle(fontSize: 18.0),
        ),
        onPressed: isCreatingUser ? null : onPressed,
        child: Text(buttonText),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

final tabs = <Tab>[
  const Tab(icon: Icon(Icons.add_circle_outline)),
  const Tab(icon: Icon(Icons.remove_circle_outline)),
];

class _BuildRemoveCookTab extends StatefulWidget {
  @override
  _BuildRemoveCookTabState createState() => _BuildRemoveCookTabState();
}

class _BuildRemoveCookTabState extends State<_BuildRemoveCookTab>
    with AutomaticKeepAliveClientMixin<_BuildRemoveCookTab> {
  //set's the account delete cariable to true in the db so when he tries to login he's account will be deleted
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getData("accounts")
                  .orderByChild("type")
                  .equalTo("Cook")
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.all(16),
                    child: const CircularProgressIndicator(),
                  );
                }
                Map<dynamic, dynamic> data = Map<dynamic, dynamic>.from(
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
                if (data.isEmpty) {
                  return const Text("There are no cooks for the moment...");
                }
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Material(
                        elevation: 8,
                        shadowColor: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          margin: const EdgeInsets.all(8),
                          child: ListTile(
                            title: Text(
                              data.keys.elementAt(index),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                            subtitle: data[data.keys.elementAt(index)]
                                    ["deleted"]
                                ? Text(
                                    "This account will be deleted when ${data.keys.elementAt(index)} tries to login.")
                                : null,
                            trailing: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                    left: BorderSide(color: Colors.grey)),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: () => showDeleteConfirmationDialog(
                                    data.keys.elementAt(index)),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

//delete confirmation dialog
  void showDeleteConfirmationDialog(String name) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this cook?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Mark the cook as deleted in the database
                updateData("accounts/$name", {"deleted": true});
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
