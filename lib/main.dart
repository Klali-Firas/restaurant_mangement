import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_mangement/cook_functions/dish_overview.dart';
import 'package:restaurant_mangement/cook_functions/order_detailes.dart';
import 'package:restaurant_mangement/create_manager_account.dart';
import 'package:restaurant_mangement/guide.dart';
import 'package:restaurant_mangement/home_screen.dart';
import 'firebase_options.dart';
import 'Manager Functions/all.dart';
import 'server_functions/main_server.dart';
import 'utility/notification.dart';
import 'server_functions/table_detailes.dart';
import 'server_functions/place_order.dart';
import 'cook_functions/main_cook.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the specified options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize the notification service
  await NotificationService().initNotification();

  // Set preferred screen orientation to portrait
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

        //routes to different page screens
        routes: {
          '/': (context) => const Guide(),
          '/CreateManagerAccount': (context) => const CreateManagerAccount(),
          '/Home': (context) => const HomePage(),
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
        //default theme for the whole app.
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
          ),
        ));
  }
}
