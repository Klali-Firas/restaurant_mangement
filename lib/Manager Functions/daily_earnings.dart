import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/realtime_database.dart';
import 'package:intl/intl.dart';
import 'chart.dart';

class Earnings extends StatefulWidget {
  const Earnings({super.key});
  @override
  State<Earnings> createState() => _Earnings();
}

class _Earnings extends State<Earnings> {
  Map<String, dynamic> highestSoldDish = {};
  Map<String, dynamic> highestPaidDish = {};
  double totalEarnings = 0;
  DateTime now = DateTime.now();
  late DateTime pickedDate = DateTime(1977, 1);

  late List<FlSpot> spots = [];
  Map<String, dynamic> findMaxOrder(Map<dynamic, dynamic> orders) {
    String maxKey = '';
    num maxValue = 0;

    orders.forEach((key, value) {
      if (value > maxValue) {
        maxKey = key;
        maxValue = value;
      }
    });

    return {maxKey: maxValue};
  }

  void inializeSpots() {
    if (pickedDate == DateTime(1977, 1)) {
      pickedDate = DateTime(now.year, now.month);
    }
    DateTime nextMonth = DateTime(pickedDate.year, pickedDate.month + 1);

    getData("Tables").onValue.listen((value) async {
      var tables = Map<dynamic, dynamic>.from(
          value.snapshot.value as Map<dynamic, dynamic>);
      Map<dynamic, dynamic> orders = {};
      tables.forEach((key, value) {
        if (value["Orders"] != null) {
          orders.addAll(value["Orders"] as Map<dynamic, dynamic>);
        }
      });
      List<FlSpot> newSpots = [];
      Map<String, dynamic> allOrders = {};
      highestSoldDish.clear();
      highestPaidDish.clear();
      totalEarnings = 0;
      orders.forEach((key, value) {
        DateTime orderdate =
            DateTime.fromMillisecondsSinceEpoch(value['orderDate']);
        if (orderdate.isAfter(pickedDate) && orderdate.isBefore(nextMonth)) {
          totalEarnings += value["price"];
          newSpots
              .add(FlSpot(orderdate.day.toDouble(), value['price'].toDouble()));
          final order = Map<String, dynamic>.from(
              value["orders"] as Map<dynamic, dynamic>);
          order.forEach((dishName, dishCount) {
            allOrders.update(
              dishName,
              (count) => count + dishCount,
              ifAbsent: () => dishCount,
            );
          });
        }
      });

      spots.clear();
      for (var newSpot in newSpots) {
        int existingIndex = spots.indexWhere((spot) => spot.x == newSpot.x);

        if (existingIndex != -1) {
          // Update existing spot
          spots[existingIndex] = FlSpot(
              spots[existingIndex].x, spots[existingIndex].y + newSpot.y);
        } else {
          // Add new spot
          spots.add(newSpot);
        }
      }

      spots.sort((a, b) => a.x.compareTo(b.x));

      Map<dynamic, dynamic> ordersPays = {};
      if (allOrders.isNotEmpty) {
        highestSoldDish = findMaxOrder(allOrders);
        Map<dynamic, dynamic> data = {};
        await getData("Menu").once().then((value) {
          data = Map<dynamic, dynamic>.from(
              value.snapshot.value as Map<dynamic, dynamic>);
        });

        for (var entry in allOrders.entries) {
          final key = entry.key;
          final count = entry.value;

          ordersPays.addAll({key: data[key]["price"] * count});
        }

        highestPaidDish = findMaxOrder(ordersPays);
      }
      setState(() {});
    });
  }

  @override
  void initState() {
    inializeSpots();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      pickedDate =
                          DateTime(pickedDate.year, pickedDate.month - 1);
                      inializeSpots();
                    });
                  },
                  icon: const Icon(Icons.arrow_back_ios_new_rounded)),
              const Expanded(child: SizedBox()),
              Text(
                "${DateFormat.MMMM().format(pickedDate)}, ",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 40, 40, 40)),
              ),
              Text(pickedDate.year.toString(),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal)),
              const Expanded(child: SizedBox()),
              IconButton(
                  onPressed: () {
                    setState(() {
                      pickedDate =
                          DateTime(pickedDate.year, pickedDate.month + 1);
                      inializeSpots();
                    });
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded)),
            ],
          ),
          const SizedBox(height: 15),
          Material(
            color: const Color.fromARGB(255, 245, 255, 254),
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.4,
                child: spots.isNotEmpty
                    ? Chart(
                        spots: spots,
                      )
                    : const Center(
                        child: Text(
                        "No Data Available!",
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 87, 79),
                            fontSize: 20,
                            fontWeight: FontWeight.w600),
                      )),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                const Text(
                  "Total Month Earnings :",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 40, 40, 40)),
                ),
                const Expanded(child: SizedBox()),
                Text(
                  totalEarnings.toStringAsFixed(3),
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal),
                ),
                const Text(
                  "DT",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 40, 40, 40)),
                )
              ],
            ),
          ),
          if (highestSoldDish.isNotEmpty)
            tile(highestSoldDish, "Highest Sold Dish :",
                "x${highestSoldDish.values.elementAt(0)}"),
          const SizedBox(height: 12),
          if (highestPaidDish.isNotEmpty)
            tile(highestPaidDish, "Highest Paid Dish :",
                "${highestPaidDish.values.elementAt(0)}DT")
        ],
      ),
    );
  }

  Material tile(Map<String, dynamic> element, String desc, String trail) {
    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      color: const Color.fromARGB(255, 245, 255, 254),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8),
            child: Text(
              desc,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ),
          ListTile(
            tileColor: Colors.transparent,
            title: Text(
              element.keys.elementAt(0),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            trailing: Text(
              trail,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.teal),
            ),
            onTap: () => Navigator.pushNamed(context, "/dishOverview",
                arguments: element.keys.elementAt(0)),
          ),
        ],
      ),
    );
  }
}
