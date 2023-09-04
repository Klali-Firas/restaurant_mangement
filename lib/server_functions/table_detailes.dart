import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/realtime_database.dart'
    as realtimedatabase;

//show'sthe selected table status, orders details

class TableDetails extends StatefulWidget {
  const TableDetails({super.key});

  @override
  State<TableDetails> createState() => _TableDetailsState();
}

class _TableDetailsState extends State<TableDetails> {
  double paycheck = 0;

  @override
  Widget build(BuildContext context) {
    final String id = ModalRoute.of(context)!.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(id),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 5),
          _buildOrdersWidget(id),
          _buildPayInfoWidget(id),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/placeOrder',
              arguments: {"id": id, "paycheck": paycheck});
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOrdersWidget(String id) {
    return StreamBuilder(
      stream: realtimedatabase.getData("Tables/$id").onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final data = Map<String, dynamic>.from(
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
        if (data["empty"]) {
          return Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "Table Is Empty!",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal),
              ),
            ],
          ));
        }
        paycheck = (data["paycheck"]) / 1.0;
        Map<dynamic, dynamic> orders = data['Orders'];

        Map<String, dynamic> allOrders = _calculateAllOrders(orders);

        return StreamBuilder(
          stream: realtimedatabase.getData("Menu").onValue,
          builder: (context, menuSnapshot) {
            if (!menuSnapshot.hasData) {
              return const CircularProgressIndicator();
            }
            final menuData = (menuSnapshot.data!.snapshot).value;
            if (menuData == null) {
              return const Center(child: Text("No data available."));
            }

            final menuItems =
                Map<String, dynamic>.from(menuData as Map<dynamic, dynamic>);

            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: min((allOrders.length ~/ 3.00011) * 170 + 170,
                    170 * 3), // Set an appropriate height
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 7.0,
                    crossAxisSpacing: 7.0,
                    childAspectRatio: 0.7,
                  ),
                  shrinkWrap: true,
                  itemCount: allOrders.length,
                  itemBuilder: (context, index) {
                    String orderKey = allOrders.keys.elementAt(index);
                    final menuItem = menuItems[orderKey];
                    return _buildMenuItemCard(allOrders, orderKey, menuItem);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

// Calculate and consolidate all orders.
  Map<String, dynamic> _calculateAllOrders(Map<dynamic, dynamic> orders) {
    Map<String, dynamic> allOrders = {};

    orders.forEach((orderKey, orderValue) {
      if (!orders[orderKey]["done"]) {
        final order = Map<String, dynamic>.from(
            orders[orderKey]["orders"] as Map<dynamic, dynamic>);

        order.forEach((dishName, dishCount) {
          allOrders.update(
            dishName,
            (count) => count + dishCount,
            ifAbsent: () => dishCount,
          );
        });
      }
    });

    return allOrders;
  }

// Build a card for a menu item showing its details.
  Widget _buildMenuItemCard(
      Map<String, dynamic> allOrders, String orderKey, dynamic menuItem) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, "/dishOverview", arguments: orderKey),
      child: Material(
        color: Colors.transparent,
        elevation: 6,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(9), topRight: Radius.circular(9)),
              child: CachedNetworkImage(
                imageUrl: menuItem?["image"] ?? "",
                progressIndicatorBuilder: (context, url, downloadProgress) =>
                    SizedBox(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                    ),
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(9),
                      bottomRight: Radius.circular(9))),
              width: double.infinity,
              child: Column(children: [
                const SizedBox(height: 3),
                Text(
                  "${allOrders[orderKey]} x $orderKey",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                    "${(menuItem["price"] * allOrders[orderKey]).toString()} DT"),
                const SizedBox(height: 3)
              ]),
            ),
          ],
        ),
      ),
    );
  }

// Check if all orders for the table are served.
  Future<bool> _areAllOrdersServed(
      String id, Map<dynamic, dynamic> orders) async {
    for (String orderKey in orders.keys) {
      final orderData = orders[orderKey];
      if (orderData['served'] != true) {
        return false; // Return false if any order is not served
      }
    }
    return true; // Return true if all orders are served
  }

  Widget _buildPayInfoWidget(String id) {
    return StreamBuilder(
      stream: realtimedatabase.getData("Tables/$id").onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final data = Map<dynamic, dynamic>.from(
            snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
        if (data["empty"]) return const SizedBox();

        bool isPaid = data['paid'];
        double currentPaycheck = data['paycheck'].toDouble();
        Map<dynamic, dynamic> orders = data['Orders'];

        return Column(
          children: [
            GestureDetector(
              onTap: () async {
                if (!isPaid) {
                  // Update paycheck to 0 and mark orders as done

                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Confirm Payment"),
                        content: const Text(
                            "Are you sure you want to mark this table as paid?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false); // Not confirmed
                            },
                            child: const Text("Cancel"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true); // Confirmed
                            },
                            child: const Text("Mark as Paid"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    // Update paycheck to 0 and mark orders as done
                    await realtimedatabase.updateData("Tables/$id", {
                      "paid": true,
                      "paycheck": 0,
                    });
                  }
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isPaid
                      ? Column(
                          children: [
                            Row(children: const [
                              Text(
                                "Paycheck : ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Text(
                                "Paid ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              Icon(
                                Icons.done_outline_rounded,
                                color: Colors.teal,
                                size: 25,
                              ),
                            ]),
                            ElevatedButton(
                              onPressed: () async {
                                if (await _areAllOrdersServed(id, orders)) {
                                  await _markOrdersAsDone(id, orders);
                                } else {
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text("Error"),
                                        content: const Text(
                                            "We cannot empty this table as some orders hasn't been served yet."),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                }
                              },
                              child: const Text("Empty Table"),
                            )
                          ],
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              "Paycheck : ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Text(
                              currentPaycheck.toStringAsFixed(3),
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
                            ),
                            const Text(
                              " DT",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            )
                          ],
                        ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

// Mark all orders for the table as done and set the table as empty.
  Future<void> _markOrdersAsDone(
      String id, Map<dynamic, dynamic> orders) async {
    for (String orderKey in orders.keys) {
      await realtimedatabase.updateData("Tables/$id/Orders/$orderKey", {
        "done": true,
      });
    }
    await realtimedatabase.updateData("Tables/$id", {
      "empty": true,
    });
  }
}
