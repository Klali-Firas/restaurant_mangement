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
  DateTime now = DateTime.now();
  late DateTime pickedDate = DateTime(1977, 1);

  late List<FlSpot> spots = [];
  void inializeSpots() {
    if (pickedDate == DateTime(1977, 1)) {
      pickedDate = DateTime(now.year, now.month);
    }
    DateTime nextMonth = DateTime(pickedDate.year, pickedDate.month + 1);

    getData("Tables").onValue.listen((value) {
      var tables = Map<dynamic, dynamic>.from(
          value.snapshot.value as Map<dynamic, dynamic>);
      Map<dynamic, dynamic> orders = {};
      tables.forEach((key, value) {
        if (value["Orders"] != null) {
          orders.addAll(value["Orders"] as Map<dynamic, dynamic>);
        }
      });
      List<FlSpot> newSpots = [];
      orders.forEach((key, value) {
        DateTime orderdate =
            DateTime.fromMillisecondsSinceEpoch(value['orderDate']);
        if (orderdate.isAfter(pickedDate) && orderdate.isBefore(nextMonth)) {
          newSpots
              .add(FlSpot(orderdate.day.toDouble(), value['price'].toDouble()));
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
      setState(() {
        spots.sort((a, b) => a.x.compareTo(b.x));
      });
    });
  }

  @override
  void initState() {
    inializeSpots();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.4,
              child: Chart(
                spots: spots,
              ),
            )
          ],
        ),
      )),
    );
  }
}
