import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/authentification.dart';
import 'package:restaurant_mangement/utility/toast.dart';
import 'utility/realtime_database.dart';
import 'package:email_validator/email_validator.dart';
import 'dart:math';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// Function to generate random orders for 3 months (June, July, August 2023)
  Future<void> generateRandomOrders() async {
    // Seed the random number generator for reproducibility
    final random = Random(42);

    // Loop through the months of June, July, and August
    for (int month = 6; month <= 8; month++) {
      // Determine the number of days in the current month
      int daysInMonth;
      if (month == 6 || month == 8) {
        daysInMonth = 30; // June and August have 30 days
      } else {
        daysInMonth = 31; // July has 31 days
      }

      // Generate random orders for each day in the month
      for (int day = 1; day <= daysInMonth; day++) {
        // Generate a random number of orders for the day (between 1 and 10)

        // Generate orders for the day

        // Generate a unique order ID (you can use your own logic here)
        int time = DateTime(2023, month, day).millisecondsSinceEpoch;
        int numEscalope = random.nextInt(7) + 7;
        int numDorade = random.nextInt(8) + 8;
        int numVerte = random.nextInt(7) + 9;
        await addData("Tables/Cabane 1/Orders/Cabane 1_$time", {
          "orders": {
            "Escalope": numEscalope,
            'Plat Dorade': numDorade,
            'Salade Verte': numVerte
          },
          'done': true,
          "ready": true,
          "served": true,
          "price": 30 * numEscalope + 35 * numDorade + 5.5 * numVerte,
          "orderDate": time,
        });
        // Generate other random order data

        // Add the order to your database (you can use your own database logic here)
        // Replace this line with your database logic
      }
    }
  }

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
          passController.clear();
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
        automaticallyImplyLeading: false,
        title: const Text("Welcome Back!"),
      ),
      body: _buildAddServerTab(),
    );
  }

  Widget _buildAddServerTab() {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Center(
        child: SingleChildScrollView(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Lottie.network(
            //   "https://lottie.host/aabc2130-aa36-4194-a650-c9f7e5f7c265/BKWGW3F2eZ.json",
            //   animate: true,
            //   repeat: true,
            //   width: 200,
            //   height: 200,
            //   fit: BoxFit.cover,
            // ),
            // Lottie.asset(
            //   'assets/animation/teal logo.json', // Replace with your animation file

            // ),
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
              buttonText: "LOGIN",
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("New Manager ? "),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, '/CreateManagerAccount'),
                  child: const Text(
                    "Create Account",
                    style: TextStyle(color: Colors.teal),
                  ),
                )
              ],
            ),
            ElevatedButton(
                onPressed: () => generateRandomOrders(),
                child: const Text("Generate"))
          ]),
        ),
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
    required String buttonText,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          fixedSize: const Size(250, 50),
          textStyle: const TextStyle(fontSize: 18.0),
        ),
        onPressed: () {
          if (emailController.text.isNotEmpty &&
              passController.text.isNotEmpty) {
            if (EmailValidator.validate(emailController.text.trim())) {
              useSignIn();
            } else {
              showToast("Please enter a valid Email");
            }
          } else {
            showToast("All fields must be filled!");
          }
        },
        child: Text(buttonText,
            style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
