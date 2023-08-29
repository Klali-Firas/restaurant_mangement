import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/realtime_database.dart';

class OrderDetailes extends StatefulWidget {
  const OrderDetailes({Key? key}) : super(key: key);

  @override
  State<OrderDetailes> createState() => _OrderDetailesState();
}

class _OrderDetailesState extends State<OrderDetailes> {
  late String status = "";

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String order = args["order"];
    if (status == "") status = args["status"];
    return Scaffold(
      appBar: AppBar(title: const Text("Order Detailes")),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: StreamBuilder(
              stream: getData(
                      "Tables/${order.substring(0, order.indexOf('_'))}/Orders/$order/orders")
                  .onValue,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    width: 35,
                    height: 35,
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.all(16),
                    child: const CircularProgressIndicator(),
                  );
                }
                var orders = Map<dynamic, dynamic>.from(
                    snapshot.data!.snapshot.value as Map<dynamic, dynamic>);

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    return StreamBuilder(
                      stream: getData("Menu/${orders.keys.elementAt(index)}")
                          .onValue,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Container(
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.all(16),
                            child: const CircularProgressIndicator(),
                          );
                        }
                        var dish = Map<dynamic, dynamic>.from(snapshot
                            .data!.snapshot.value as Map<dynamic, dynamic>);

                        return Padding(
                          padding: const EdgeInsets.all(7.0),
                          child: Material(
                            elevation: 8,
                            shadowColor: Colors.black,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(3)),
                                  child: CachedNetworkImage(
                                    imageUrl: dish["image"].toString(),
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) =>
                                            CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                    ),
                                  ),
                                ),
                                trailing: Text(
                                  "x${orders[orders.keys.elementAt(index)]}",
                                  style: const TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                                subtitle: Text(dish["Description"].toString()),
                                style: ListTileStyle.list,
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4.0,
                                  horizontal: 10,
                                ),
                                title: Text(
                                  orders.keys.elementAt(index),
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                                onTap: () => Navigator.pushNamed(
                                    context, "/dishOverview",
                                    arguments: orders.keys.elementAt(index)),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (status != 'New Orders')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(100, 20),
                  ),
                  onPressed: () {
                    if (status == 'Ready to Serve') {
                      updateData(
                          "Tables/${order.substring(0, order.indexOf('_'))}/Orders/$order",
                          {"ready": false});
                      setState(() {
                        status = 'New Orders';
                      });
                    } else if (status == 'Served Orders') {
                      updateData(
                          "Tables/${order.substring(0, order.indexOf('_'))}/Orders/$order",
                          {"served": false});
                      setState(() {
                        status = "Ready to Serve";
                      });
                    }
                  },
                  child: Text(
                    status == 'Ready to Serve' ? "Unready" : "Unserve",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              if (status != 'New Orders' && status != "Served Orders")
                const SizedBox(width: 5),
              if (status == 'New Orders' || status == 'Ready to Serve')
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size(100, 20),
                  ),
                  onPressed: () {
                    if (status == 'New Orders') {
                      updateData(
                          "Tables/${order.substring(0, order.indexOf('_'))}/Orders/$order",
                          {"ready": true});
                      setState(() {
                        status = 'Ready to Serve';
                      });
                    } else if (status == 'Ready to Serve') {
                      updateData(
                          "Tables/${order.substring(0, order.indexOf('_'))}/Orders/$order",
                          {"served": true});
                      setState(() {
                        status = "Served Orders";
                      });
                    }
                  },
                  child: Text(
                    status == 'New Orders' ? "Ready" : "Serve",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
