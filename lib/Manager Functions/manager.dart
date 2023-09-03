import 'package:flutter/material.dart';
import 'package:restaurant_mangement/Manager%20Functions/all.dart';
import 'package:restaurant_mangement/presentation/chef_icon.dart';

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
          title: const Text("Manager", style: TextStyle()),
        ),
        body: WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: const SingleChildScrollView(
            child: Earnings(),
          ),
        ),
        drawer: Drawer(
          elevation: 2,
          child: Column(
            children: [
              DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.teal),
                  child: Center(
                      child: Text(
                    fbAuth.currentUser?.displayName ?? "Manager",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ))),
              Tile(
                onTap: () => Navigator.pop(context),
                title: "Monthly Earnings",
                icon: Icons.attach_money_rounded,
              ),
              Tile(
                onTap: () => Navigator.pushNamed(context, '/ARCook'),
                title: "Manage Cooks",
                icon: CustomIcons.chef,
              ),
              Tile(
                onTap: () => Navigator.pushNamed(context, '/ARServer'),
                title: "Manage Servers",
                icon: CustomIcons.waiter,
              ),
              Tile(
                onTap: () => Navigator.pushNamed(context, '/UTables'),
                title: "Manage Tables",
                icon: Icons.table_restaurant_rounded,
              ),
              Tile(
                onTap: () => Navigator.pushNamed(context, '/UMenu'),
                title: "Manage Menu",
                icon: Icons.restaurant_rounded,
              ),
              const Expanded(child: SizedBox()),
              Container(
                width: double.infinity,
                color: Colors.teal,
                child: IconButton(
                  icon: const Icon(Icons.power_settings_new_rounded),
                  color: Colors.white,
                  onPressed: () async {
                    Navigator.pop(context);

                    Navigator.pop(context);
                    await signOut();
                  },
                ),
              )
            ],
          ),
        ));
  }
}

class Tile extends StatelessWidget {
  const Tile({
    super.key,
    required this.title,
    required this.onTap,
    required this.icon,
  });
  final IconData? icon;
  final String title;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
      onTap: onTap,
    );
  }
}
