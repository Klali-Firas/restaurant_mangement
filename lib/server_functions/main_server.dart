import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/realtime_database.dart'
    as realtimedatabase;

import '../utility/authentification.dart';
import '../utility/notification.dart';

class Server extends StatefulWidget {
  const Server({super.key});
  @override
  State<Server> createState() => _Server();
}

class _Server extends State<Server> {
  int idCount = 4;
  @override
  void initState() {
    super.initState();
    realtimedatabase
        .getData("accounts/${fbAuth.currentUser!.displayName}")
        .onChildChanged
        .listen((event) {
      if (event.snapshot.key == "deleted") {
        if (event.snapshot.value == true) {
          Navigator.pop(context);
          signOut();
        }
      }
    });
    realtimedatabase.getData("Tables").once().then((value) {
      var tablesdata = value.snapshot.value;
      var tables =
          Map<String, dynamic>.from(tablesdata as Map<dynamic, dynamic>);
      tables.forEach((key, value) {
        realtimedatabase
            .getData("Tables/$key/Orders")
            .onChildChanged
            .listen((event) {
          var newOrdersdata = event.snapshot.value;

          var newOrders =
              Map<String, dynamic>.from(newOrdersdata as Map<dynamic, dynamic>);
          String description = '';
          newOrders["orders"].forEach((dishName, dishCount) {
            description += '$dishCount x $dishName, ';
          });
          description = description.substring(0, description.length - 2);

          if (newOrders["ready"] && !newOrders["served"]) {
            NotificationService().showNotification(
                groupKey: "server101",
                groupid: 1,
                id: idCount,
                body: "$key : $description",
                title: "Order Ready to Serve!");
            idCount += 10;
          }
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Server"),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          await signOut();
          return true;
        },
        child: Center(
            child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: StreamBuilder(
                  stream: realtimedatabase.getData("Tables").onValue,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.all(16),
                        child: const CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.data!.snapshot.value == null) {
                      return const Center(child: Text("No data available."));
                    }
                    final data = Map<String, dynamic>.from(
                        snapshot.data!.snapshot.value as Map<dynamic, dynamic>);

                    return GridView.custom(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.90,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10),
                      childrenDelegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, "/tableDetailes",
                                arguments: data.keys.elementAt(index)),
                            child: Card(
                              clipBehavior: Clip.hardEdge,
                              elevation: 8,
                              color: determinColor(Map<String, dynamic>.from(
                                  data[data.keys.elementAt(index)])),
                              child: Stack(children: [
                                Center(
                                  child: Text(
                                    data.keys.elementAt(index),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(bottom: 5),
                                  alignment: Alignment.bottomCenter,
                                  child: Text(
                                      determinSubTitle(
                                          Map<String, dynamic>.from(data[
                                              data.keys.elementAt(index)])),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w400)),
                                )
                              ]),
                            ),
                          );
                        },
                        childCount: data.length,
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        )),
      ),
    );
  }

  Color determinColor(Map<String, dynamic> table) {
    if (table["empty"]) {
      return const Color.fromARGB(
          255, 236, 236, 236); // Scenario 1: Empty Table
    }

    bool allOrdersServed = true;
    bool ordersReadyToServe = false;

    table["Orders"].forEach((key, value) {
      if (!table["Orders"][key]["served"]) {
        allOrdersServed = false;
        if (table["Orders"][key]["ready"]) {
          ordersReadyToServe = true;
        }
      }
    });

    if (allOrdersServed) {
      if (!table["paid"]) {
        return Colors.red; // Scenario 5: All Orders Served but Not Paid
      }
      return Colors.lightGreen; // Scenario 2:  Paid and all orders are served
    }

    if (ordersReadyToServe) {
      return Colors.yellow; // Scenario 4: Orders Not Served but Ready
    }

    return Colors.lightBlue; // Scenario 3: Orders Not Served and Not Ready
  }

  String determinSubTitle(Map<String, dynamic> table) {
    if (table["empty"]) {
      return ""; // Scenario 1: Empty Table
    }

    bool allOrdersServed = true;
    bool ordersReadyToServe = false;

    table["Orders"].forEach((key, value) {
      if (!table["Orders"][key]["served"]) {
        allOrdersServed = false;
        if (table["Orders"][key]["ready"]) {
          ordersReadyToServe = true;
        }
      }
    });

    if (allOrdersServed) {
      if (!table["paid"]) {
        return "Not Paid, Served"; // Scenario 5: All Orders Served but Not Paid
      }
      return "Paid & Served"; // Scenario 2:  Paid and all orders are served
    }

    if (ordersReadyToServe) {
      return "Ready to Serve"; // Scenario 4: Orders Not Served but Ready
    }

    return "Cooking..."; // Scenario 3: Orders Not Served and Not Ready
  }
}
