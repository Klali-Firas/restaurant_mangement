import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:restaurant_mangement/utility/realtime_database.dart'
    as realtimedatabase;

class UpdateMenu extends StatefulWidget {
  const UpdateMenu({super.key});

  @override
  State<UpdateMenu> createState() => _UpdateMenuState();
}

class _UpdateMenuState extends State<UpdateMenu> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu List"),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              child: const Icon(Icons.add),
              onTap: () => Navigator.pushNamed(context, "/AddNewDish"),
            ),
          )
        ],
      ),
      body: _buildMenuList(),
    );
  }

  Widget _buildMenuList() {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: realtimedatabase.getData("Menu").onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return _buildLoadingIndicator(); // Display a loading indicator while data is loading.
                }
                final menuData = snapshot.data!.snapshot.value;
                if (menuData == null) {
                  return _buildNoDataAvailable(); // Display a message when there's no menu data.
                }
                print(menuData);

                final menuItems = _parseMenuItems(
                    menuData); // Parse menu data into a sorted map.

                return ListView.builder(
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final menuItemKey = menuItems.keys.elementAt(index);
                    final menuItem = menuItems[menuItemKey];
                    return _buildMenuItemDismissible(menuItemKey,
                        menuItem); // Build a dismissible menu item.
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 5),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
            Text("Swipe "), // Instruction for swipe action.
            Text(
              "left",
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
            ),
            Text(" to delete a dish!") // Instruction for deleting a dish.
          ]),
          const SizedBox(
            height: 15,
          )
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(16),
      child: const CircularProgressIndicator(),
    );
  }

  Widget _buildNoDataAvailable() {
    return const Center(
        child: Text(
            "The Menu is empty!\nTry adding new dishes.")); // Message when no menu data is available.
  }

  Map<String, dynamic> _parseMenuItems(dynamic menuData) {
    return SplayTreeMap<String, dynamic>.from(menuData
        as Map<dynamic, dynamic>); // Parse menu data into a sorted map.
  }

  Widget _buildMenuItemDismissible(String menuItemKey, dynamic menuItem) {
    return Dismissible(
      confirmDismiss: (direction) async {
        final bool? ret = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Delete"),
              content: const Text(
                  "Confirm action ?"), // Confirmation dialog for deletion.
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("OK"),
                ),
              ],
            );
          },
        );
        return ret ?? false;
      },
      key: UniqueKey(),
      onDismissed: (direction) {
        realtimedatabase.removeData(
            "Menu/$menuItemKey"); // Delete the menu item when dismissed.
      },
      direction: DismissDirection.endToStart,
      background: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          height: 30,
          alignment: Alignment.centerRight,
          color: const Color.fromARGB(255, 236, 236, 236),
          child: const Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: Icon(
              Icons.delete_outline_rounded, // Delete icon for swipe action.
              color: Colors.teal,
              size: 25,
            ),
          ),
        ),
      ),
      child:
          _buildMenuItemTile(menuItemKey, menuItem), // Display the menu item.
    );
  }

  Widget _buildMenuItemTile(String menuItemKey, dynamic menuItem) {
    return Padding(
      padding: const EdgeInsets.all(7.0),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          margin: const EdgeInsets.all(6),
          child: ListTile(
            leading: CachedNetworkImage(
              imageUrl: menuItem["image"].toString(),
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  CircularProgressIndicator(
                value: downloadProgress.progress,
              ),
            ),
            trailing: Text(
              "${menuItem["price"].toStringAsFixed(3)}DT",
              style: const TextStyle(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
            onTap: () => Navigator.pushNamed(context, "/dishOverview",
                arguments: menuItemKey),
            subtitle: Text(
              menuItem["Description"].toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            style: ListTileStyle.list,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 4.0,
              horizontal: 10,
            ),
            title: Text(
              menuItemKey,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
