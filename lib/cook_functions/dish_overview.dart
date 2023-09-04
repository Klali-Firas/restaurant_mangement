import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:restaurant_mangement/utility/realtime_database.dart';
import '../utility/color_picker.dart';

//Dish Details

class DishOverview extends StatefulWidget {
  const DishOverview({Key? key}) : super(key: key);

  @override
  State<DishOverview> createState() => _DishOverviewState();
}

class _DishOverviewState extends State<DishOverview> {
  //function to pick darks and light color from the image,
  //this functions aren't in use for now
  Color darkColor = Colors.teal;
  Color lightColor = Colors.white;
  Future<void> updateDarkColor(String link) async {
    var dominantecolor = await pickDarkColor(link);
    setState(() {
      darkColor = dominantecolor;
    });
  }

  Future<void> updatelightColor(String link) async {
    var dominantecolor = await pickLightColor(link);
    setState(() {
      lightColor = dominantecolor;
    });
  }

  @override
  Widget build(BuildContext context) {
    final String dish = ModalRoute.of(context)!.settings.arguments.toString();
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: StreamBuilder(
          stream: getData("Menu/$dish").onValue,
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
            var dishData = Map<dynamic, dynamic>.from(
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>);
            // updateDarkColor(dishData["image"]);
            // updatelightColor(dishData["image"]);
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(32)),
                          child: CachedNetworkImage(
                            imageUrl: dishData["image"],
                            progressIndicatorBuilder:
                                (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                              value: downloadProgress.progress,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          dish,
                          style: const TextStyle(
                              color: Color.fromARGB(255, 30, 30, 30),
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: const [
                            Text(
                              "Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Expanded(
                              child: SizedBox(),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                dishData["Description"],
                                softWrap: true,
                                style: const TextStyle(color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                        const Expanded(child: SizedBox(height: 65)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dishData["price"].toStringAsFixed(3),
                              style: const TextStyle(
                                  //backgroundColor: darkColor,
                                  fontSize: 25,
                                  color: Colors.teal, //lightColor,
                                  fontWeight: FontWeight.w600),
                            ),
                            const Text(
                              "DT",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Color.fromARGB(255, 30, 30, 30)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
