import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

//the Chart widget using FL_Chart Library

class Chart extends StatelessWidget {
  const Chart({
    super.key,
    required this.spots,
  });
  final List<FlSpot> spots;

  double getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return 0.0; // Return 0 if the list is empty
    }

    double maxY = spots[0].y;
    for (var spot in spots) {
      if (spot.y > maxY) {
        maxY = spot.y;
      }
    }

    return maxY;
  }

  double getMinY(List<FlSpot> spots) {
    if (spots.isEmpty) {
      return 0.0; // Return 0 if the list is empty
    }

    double minY = spots[0].y;
    for (var spot in spots) {
      if (spot.y < minY) {
        minY = spot.y;
      }
    }

    return minY;
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
            getTouchLineStart: (data, index) => data.spots[index].y,
            touchTooltipData: LineTouchTooltipData(
                getTooltipItems: (touchedSpots) {
                  String val =
                      "${touchedSpots[0].x.toInt()} : ${touchedSpots[0].y}DT";
                  return [
                    LineTooltipItem(
                      val,
                      const TextStyle(
                          color: Colors.teal, fontWeight: FontWeight.w600),
                    )
                  ];
                },
                tooltipBgColor: Colors.white,
                tooltipBorder: const BorderSide(color: Colors.teal))),
        clipData: FlClipData.all(),
        titlesData: FlTitlesData(
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
                interval: 4,
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      value.toInt() % 4 == 0 ? value.toInt().toString() : "",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              interval: 2,
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                String text = "";
                if (value.toInt() % 100 == 0) {
                  text = value.toInt().toString();
                }
                return Text(
                  text,
                  style: const TextStyle(color: Colors.grey),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
            show: true, drawHorizontalLine: true, drawVerticalLine: false),
        borderData: FlBorderData(
            show: false,
            border: Border.all(
              width: 1,
              style: BorderStyle.solid,
            )),
        lineBarsData: [
          LineChartBarData(
            shadow: const Shadow(
                color: Color.fromARGB(100, 158, 158, 158),
                offset: Offset(0, 15),
                blurRadius: 1),
            gradient:
                const LinearGradient(colors: [Colors.tealAccent, Colors.teal]),
            isCurved: true,
            curveSmoothness: 0.35,
            preventCurveOverShooting: false,
            barWidth: 3,
            dotData: FlDotData(
              show: false,
            ),
            spots: spots,
          )
        ],
        backgroundColor: const Color.fromARGB(255, 245, 255, 254),
        minX: 1,
        maxX: 31,
        minY: getMinY(spots) - 90 < 0 ? 0 : getMinY(spots) - 90,
        maxY: getMaxY(spots) + 100,
      ),
    );
  }
}
