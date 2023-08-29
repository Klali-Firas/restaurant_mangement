import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_mangement/cook_functions/dish_overview.dart';
import 'package:restaurant_mangement/cook_functions/order_detailes.dart';
import 'package:restaurant_mangement/home_screen.dart';
import 'firebase_options.dart';
import 'utility/authentification.dart';
import 'Manager Functions/all.dart';
import 'server_functions/main_server.dart';
import 'utility/notification.dart';
import 'server_functions/table_detailes.dart';
import 'server_functions/place_order.dart';
import 'cook_functions/main_cook.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().initNotification();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          // const MyHomePage( title: 'Flutter Demo Home Page'),
          '/Manager': (context) => const Manager(),
          '/ARServer': (context) => const ARServer(),
          '/ARCook': (context) => const ARCook(),
          '/UTables': (context) => const UpdateTables(),
          '/UMenu': (context) => const UpdateMenu(),
          '/Earnings': (context) => const Earnings(),
          '/Server': (context) => const Server(),
          '/tableDetailes': (context) => const TableDetails(),
          '/placeOrder': (context) => const PlaceOrder(),
          '/Cook': (context) => const Cook(),
          '/AddNewDish': (context) => const AddNewDish(),
          "/orderDetailes": (context) => const OrderDetailes(),
          '/dishOverview': (context) => const DishOverview(),
        },
        theme: ThemeData(
          fontFamily: "Product Sans",
          listTileTheme: const ListTileThemeData(
            iconColor: Colors.teal,
            dense: true,
          ),
          tabBarTheme: const TabBarTheme(
            labelColor: Color.fromARGB(255, 25, 25, 25),
          ),
          appBarTheme: const AppBarTheme(
            iconTheme: IconThemeData(
              color: Colors.teal,
            ),
            color: Colors.white,
            centerTitle: true,
            titleTextStyle: TextStyle(
                color: Color.fromARGB(255, 25, 25, 25),
                fontSize: 22,
                fontWeight: FontWeight.w500),
          ),
          primarySwatch: Colors.teal, // Button color

          scaffoldBackgroundColor:
              const Color.fromARGB(255, 243, 243, 243), // Background color
          textTheme: const TextTheme(
            titleLarge: TextStyle(color: Colors.pink),
            bodyLarge: TextStyle(color: Colors.black), // Change text color
            bodyMedium: TextStyle(color: Colors.black), // Change text color
            // Add more text styles as needed
          ),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? name = "";
  bool signed = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  void useSignIn() {
    signIn(
        _emailController.value.text.trim(), _passController.value.text.trim());
  }

  void useCreateUser() {
    createUser(_emailController.value.text.trim(),
        _passController.value.text.trim(), 'wtf');
  }

  @override
  void initState() {
    super.initState();
    fbAuth.userChanges().listen((user) {
      setState(() {
        name = user!.displayName != null ? user.displayName.toString() : "";
      });
    });
    fbAuth.authStateChanges().listen((user) {
      setState(() {
        signed = user != null;
      });
    });
  }

  int count = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("$name"),
              TextFormField(
                controller: _emailController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: "Email"),
              ),
              TextFormField(
                controller: _passController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(hintText: "Password"),
              ),
              ElevatedButton(
                  onPressed: useSignIn, child: const Text("sign in")),
              const ElevatedButton(onPressed: signOut, child: Text("sign out")),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/Manager');
                  },
                  child: const Text("Manager")),
              ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/Server'),
                  child: const Text("Server")),
              ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/Cook'),
                  child: const Text("Cook")),
              ElevatedButton(
                  onPressed: () async {
                    await NotificationService().showNotification(
                        groupid: 0,
                        id: count,
                        title: "testing...",
                        body: "it worked :${count * 11}");
                    print(count);
                    count += 10;
                  },
                  child: const Text("notification test"))
            ],
          ),
        ),
      ),
    );
  }
}
