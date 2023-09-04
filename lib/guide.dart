import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

//this the Guide that'll show for the user when he launches the app
//for the very first time.
class Guide extends StatefulWidget {
  const Guide({Key? key}) : super(key: key);

  @override
  State<Guide> createState() => _GuideState();
}

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

class _GuideState extends State<Guide> with SingleTickerProviderStateMixin {
  late final TabController controller;
  int _index = 0;

  // Check if it's the first time the app is launched
  Future<void> _checkFirstTime() async {
    final SharedPreferences prefs = await _prefs;
    final bool firstTime = (prefs.getBool('first_time') ?? true);
    // Commented out to prevent setting 'first_time' again on subsequent app launches
    // prefs.setBool('first_time', true);

    if (!firstTime) {
      // Not the first time, navigate to '/Home'
      Navigator.pushNamed(context, '/Home');
    }
  }

  @override
  void initState() {
    super.initState();
    _checkFirstTime();

    controller = TabController(
      length: widgets.length,
      initialIndex: _index,
      vsync: this,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          TabBarView(
            controller: controller,
            children: widgets,
          ),
          Positioned(
              bottom: 30,
              child: TabPageSelector(
                indicatorSize: 10,
                controller: controller,
              ))
        ],
      ),
      //Button that allows the user to skip the Guide
      floatingActionButton: AnimatedOpacity(
        opacity: _index != widgets.length - 1 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 350),
        child: FloatingActionButton.small(
            onPressed: () {
              if (_index != widgets.length - 1) _index = widgets.length - 1;
              controller.animateTo(_index);
              setState(() {});
            },
            child: const Icon(Icons.arrow_forward_ios_rounded)),
      ),
    );
  }
}

List<Widget> widgets = const [
  Tab(
      description:
          "Elevate your restaurant management with powerful account, menu, and table control.",
      imageName: 'manager functions',
      title: "Manager Functionalities"),
  Tab(
    imageName: "earnings",
    description: "Discover your restaurant's monthly revenue at a glance.",
    title: 'Monthly Earnings',
  ),
  Tab(
    imageName: "cook",
    title: 'Kitchen Chef',
    description:
        'Your central station for preparing orders, with real-time order details.',
  ),
  Tab(
    description: 'Get detailed insights into individual customer orders.',
    imageName: "order detailes",
    title: "Order Details",
  ),
  Tab(
      title: "Dish Overview",
      imageName: "dish overview",
      description: "Explore your menu with dish descriptions and images."),
  Tab(
    imageName: "waiter",
    description:
        'Elevate your service game with instant order confirmations and readiness alerts.',
    title: 'The Waiter',
  ),
  Tab(
      description:
          "Stay informed about table occupancy, payment status, and current orders.",
      imageName: "table detailes",
      title: "Table Details"),
  Tab(
    description: "Easily create new orders for customers.",
    imageName: 'place order',
    title: "Place Order",
  ),
  LetsGetStarted()
];

class Tab extends StatelessWidget {
  const Tab(
      {super.key,
      required this.title,
      required this.description,
      required this.imageName});
  final String title;
  final String description;
  final String imageName;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              // borderRadius: const BorderRadius.all(Radius.circular(40)),
              elevation: 8,
              child: Image.asset("assets/images/$imageName.png",
                  height: MediaQuery.of(context).size.height * 0.6),
            ),
            const SizedBox(height: 15),
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal)),
            Text(
              description,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}

//The last screen of the guide that'll ask the user whether he has an account or not
//and 'll navigate to the next scrren accordingly
class LetsGetStarted extends StatelessWidget {
  const LetsGetStarted({super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Let's Get Started!",
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal)),
          const Text(
            "An Easy Way to Manage All Your Restaurant Needs",
            textAlign: TextAlign.center,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 40),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                Navigator.pushNamed(context, '/CreateManagerAccount');
                final SharedPreferences prefs = await _prefs;
                prefs.setBool('first_time', false);
              },
              child: const Text(
                "Create Account",
                style: TextStyle(fontSize: 20),
              )),
          ElevatedButton(
            onPressed: () async {
              Navigator.pushNamed(context, "/Home");
              final SharedPreferences prefs = await _prefs;
              prefs.setBool('first_time', false);
            },
            style: ElevatedButton.styleFrom(
              fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 40),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              elevation: 0,
              foregroundColor: Colors.teal,
              backgroundColor:
                  const Color.fromARGB(255, 243, 243, 243), // Text color
              side: const BorderSide(
                  color: Colors.teal, width: 0.5), // Border color
            ),
            child: const Text(
              "Login",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }
}
