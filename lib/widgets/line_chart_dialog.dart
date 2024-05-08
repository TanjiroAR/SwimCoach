import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:SwimCoach/data/db.dart';

class MyWidget extends StatefulWidget {
  final String swimmerName;
  final String raceName;
  final String raceNameAR;

  const MyWidget({
    super.key,
    required this.swimmerName,
    required this.raceName,
    required this.raceNameAR,
  });

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  SqlDb sqlDb = SqlDb();

  Future<List<Map>> readDataLineChart() async {
    String tableName = widget.swimmerName.replaceAll(RegExp(r'\s+'), '');
    List<Map> response = await sqlDb.readData('''
      SELECT date, ${widget.raceName} FROM $tableName
    ''');
    List<Map> editableResponse =
        List<Map>.from(response.map((map) => Map.from(map)));
    editableResponse.sort((a, b) => DateFormat('dd/MM/yyyy')
        .parse(a['date'])
        .compareTo(DateFormat('dd/MM/yyyy').parse(b['date'])));
    return editableResponse;
  }

  double convertTimeToSeconds(String time) {
    try {
      List<String> parts = time.split(':');
      if (parts.length != 3) {
        throw const FormatException(
            'Time string does not have the correct format');
      }
      int minutes = int.parse(parts[0]);
      int seconds = int.parse(parts[1]);
      int milliseconds = int.parse(parts[2]);
      return (minutes * 60) + seconds + milliseconds / 1000;
    } catch (e) {
      if (kDebugMode) {
        print('Error converting time to seconds: $e');
      }
      return 0;
    }
  }

  String convertSecondsToFormattedString(double seconds) {
    int totalSeconds = seconds.toInt();
    double min = totalSeconds / 60;
    int sec = totalSeconds % 60;
    int milliseconds = ((seconds - totalSeconds) * 1000).toInt();
    // if(milliseconds < 233){
    //   milliseconds++;
    // }
    return '${min.toInt().toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}:${milliseconds.toString().padLeft(3, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    double heightScreen = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.raceNameAR),
        backgroundColor: Colors.transparent,
      ),
      body: FutureBuilder<List<Map>>(
        future: readDataLineChart(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            var filteredData = snapshot.data!.where((data) => data[widget.raceName] != null).toList();
            if (filteredData.isNotEmpty) {
              double maxY = filteredData.map((data) => convertTimeToSeconds(data[widget.raceName].toString())).reduce(max);
              double interval = (maxY / 10).ceil().toDouble();
              if(interval == 0){
                return const Center(child: Text('لا يوجد بيانات لهذا السباق'));
              }
              return Padding(
                padding: EdgeInsets.all(heightScreen * 0.05),
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: filteredData.length.toDouble() - 1,
                    minY: 0,
                    maxY: interval * 10,
                    gridData: const FlGridData(show: false),
                    titlesData:

                    FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            final DateTime date = DateFormat('dd/MM/yyyy').parse(filteredData[value.toInt()]['date']);
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 10.0,
                              child: Text(DateFormat('dd/MM').format(date)),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 10.0,
                              child: Text(value.toString()),
                            );
                          },
                          interval: interval,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: filteredData.asMap().entries.map((e) {
                          double timeInSeconds = convertTimeToSeconds(
                              e.value[widget.raceName].toString());
                          return FlSpot(e.key.toDouble(), timeInSeconds);
                        }).toList(),
                        isCurved: false,
                        color: Colors.blue,
                        barWidth: 5,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(show: true),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (List<LineBarSpot> touchedSpots) {
                          return touchedSpots.map((spot) {
                            final String time = convertSecondsToFormattedString(spot.y);
                            return LineTooltipItem(time, const TextStyle(color: Colors.white));
                          }).toList();
                        },
                        getTooltipColor: (LineBarSpot spot) {
                          return Colors.blueGrey.withOpacity(0.8);
                        },
                      ),
                    ),
                  ),
                ),
              );
            } else {
              return const Center(child: Text('No data available'));
            }
          }
        },
      ),
    );
  }
}
