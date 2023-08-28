import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/authentification.dart';
import 'package:restaurant_mangement/utility/notification.dart';
import 'package:restaurant_mangement/utility/realtime_database.dart'
    as realtimedatabase;

class Cook extends StatefulWidget {
  const Cook({Key? key}) : super(key: key);

  @override
  State<Cook> createState() => _CookState();
}

class _CookState extends State<Cook> {
  late StreamSubscription _dataStreamSubscription;
  int idCount = 3;
  List<String> newOrders = [];
  List<String> readyOrders = [];
  List<String> servedOrders = [];
  Map<dynamic, dynamic> sortedTables = {}; // Store sorted tables here
  @override
  void initState() {
    super.initState();

    realtimedatabase.getData("Tables").once().then((value) {
      var tablesdata = value.snapshot.value;
      var tables =
          Map<String, dynamic>.from(tablesdata as Map<dynamic, dynamic>);

      tables.forEach((key, value) {
        // Retrieve the timestamp of the latest order to track new additions
        var latestOrderTime;
        realtimedatabase
            .getData("Tables/$key/Orders")
            .orderByChild("orderDate")
            .limitToLast(1)
            .once()
            .then((latestOrderSnapshot) {
          if (latestOrderSnapshot.snapshot.value != null) {
            latestOrderTime = Map<String, dynamic>.from(
                    latestOrderSnapshot.snapshot.value as Map<dynamic, dynamic>)
                .values
                .first["orderDate"];
          } else {
            latestOrderTime = null;
          }

          // Listen to new child additions using onChildAdded.
          _dataStreamSubscription = realtimedatabase
              .getData("Tables/$key/Orders")
              .orderByChild("orderDate")
              .startAfter(latestOrderTime)
              .onChildAdded
              .listen((event) {
            var newOrdersdata = event.snapshot.value;
            var newOrders = Map<String, dynamic>.from(
                newOrdersdata as Map<dynamic, dynamic>);

            String description = '';
            newOrders["orders"].forEach((dishName, dishCount) {
              description += '$dishCount x $dishName, ';
            });
            description = description.substring(0, description.length - 2);

            NotificationService().showNotification(
                groupid: 2,
                groupKey: "order101",
                id: idCount,
                body: description,
                title: "New Order!");
            idCount += 10;
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _dataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Start Cooking!"),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'New Orders'),
              Tab(text: 'Ready to Serve'),
              Tab(text: 'Served Orders'),
            ],
          ),
        ),
        body: WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            await signOut();
            return true;
          },
          child: StreamBuilder(
            stream: realtimedatabase.getData("Tables").onValue,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
                // Return a loading indicator or an appropriate widget
                return const CircularProgressIndicator();
              }
              final data = snapshot.data!.snapshot.value;
              final dataItems =
                  Map<String, dynamic>.from(data as Map<dynamic, dynamic>);
              final tables = {};
              dataItems.forEach(
                (key, value) {
                  if (dataItems[key]["Orders"] != null) {
                    tables.addAll(dataItems[key]["Orders"]);
                  }
                },
              );

              sortedTables = SplayTreeMap<dynamic, dynamic>((a, b) =>
                  tables[b]["orderDate"].compareTo(tables[a]["orderDate"]))
                ..addAll(tables);

              newOrders.clear();
              readyOrders.clear();
              servedOrders.clear();

              sortedTables.forEach((key, value) {
                final orderDateTime = DateTime.fromMillisecondsSinceEpoch(
                    int.parse(sortedTables[key]["orderDate"]));
                final difference =
                    DateTime.now().difference(orderDateTime).inHours;

                if (difference <= 12) {
                  if (!sortedTables[key]["served"]) {
                    if (sortedTables[key]["ready"]) {
                      readyOrders.add(key);
                    } else {
                      newOrders.add(key);
                    }
                  } else {
                    servedOrders.add(key);
                  }
                }
              });

              return TabBarView(
                children: [
                  _buildOrdersList(newOrders, 'New Orders'),
                  _buildOrdersList(readyOrders, 'Ready to Serve'),
                  _buildOrdersList(servedOrders, 'Served Orders'),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<String> orders, String status) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final orderKey = orders[index];
        final tableName = orderKey.substring(0, orderKey.indexOf('_'));
        final orderDetails = sortedTables[orderKey]["orders"];
        final orderTimestamp = sortedTables[orderKey]["orderDate"];
        final orderDateTime =
            DateTime.fromMillisecondsSinceEpoch(int.parse(orderTimestamp));

        String subtitleText = '';
        orderDetails.forEach((dishName, dishCount) {
          subtitleText += '$dishCount x $dishName, ';
        });
        subtitleText = subtitleText.substring(0, subtitleText.length - 2);

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              tableName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(subtitleText),
            onTap: () {
              if (status == 'New Orders') {
                realtimedatabase.updateData(
                    "Tables/$tableName/Orders/$orderKey", {"ready": true});
              } else if (status == 'Ready to Serve') {
                realtimedatabase.updateData(
                    "Tables/$tableName/Orders/$orderKey", {"served": true});
              }
            },
            trailing: Text(
              '${orderDateTime.hour.toString().padLeft(2, '0')}:${orderDateTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      },
    );
  }
}
