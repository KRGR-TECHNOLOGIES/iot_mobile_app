// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_local_variable, no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import '../../../models/json.dart';

class Power extends StatefulWidget {
  final Map<String, dynamic>? powerLogs;

  const Power(this.powerLogs, {super.key});

  @override
  State<Power> createState() => _PowerState(powerLogs);
}

class _PowerState extends State<Power> {
  final Map<String, dynamic>? powerLogs;

  _PowerState(this.powerLogs);

  bool isRefreshing = false;
  void handleRefresh() {
    setState(() {
      isRefreshing = true;
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isRefreshing = false;
        });
      });
    });
  }
//   void updateData(Map<String, dynamic> data) {
//   // Update the data in the Power tab
//   // Extract the ON, OFF, duration, and total duration data from 'data' and update your UI accordingly.
// }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> logList =
        (powerLogs?['onOffLogDtos'] as List<dynamic>?)
                ?.map((dynamic item) => (item as Map<String, dynamic>))
                .toList() ??
            [];
    final String powerValueForRollup = logList.isNotEmpty
        ? (logList[0]['difference']['valueForRollup'] as String? ?? "")
        : "";

    return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.42,
                  ),
                  Text(
                    'refresh_logs'.tr,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.w500),
                  ),
                  SizedBox(width: 5),
                  isRefreshing
                      ? CircularProgressIndicator()
                      : SizedBox(
                          height: 25,
                          width: 25,
                          child: GestureDetector(
                              onTap: handleRefresh,
                              child: Image.asset(
                                "assets/refresh.png",
                              )),
                        ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width *
                        0.3, // Adjust the height as needed for the first row
                    color: Color.fromARGB(
                        181, 51, 42, 55), // Background color for the first row
                    child: Center(
                        child: Text("on".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                            ))),
                  ),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width *
                        0.3, // Adjust the height as needed for the first row
                    // Adjust the height as needed for the first row
                    color: Color.fromARGB(181, 51, 42, 55),
                    child: Center(
                        child: Text("off".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                            ))),
                  ),
                  //  SizedBox(width: 10,),
                  Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width *
                        0.3, // Adjust the height as needed for the first row
                    // Adjust the height as needed for the first row
                    color: Color.fromARGB(181, 51, 42, 55),
                    child: Center(
                        child: Text("duration".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.05,
                            ))),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            // if (logList.isEmpty)
            //   Center(
            //     child: Text('No logs found for the selected date.'),
            //   )
            // else
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey),
                bottom: BorderSide(color: Colors.grey),
              ),
              columnWidths: {
                0: FixedColumnWidth(120),
                1: FixedColumnWidth(120),
                2: FixedColumnWidth(120),
              },
              children: [
                for (var item in logList)
                  TableRow(children: [
                    SizedBox(
                      height: 30,
                      child: Center(child: Text(item['onTime'])),
                    ),
                    SizedBox(
                      height: 30,
                      child: Center(child: Text(item['offTime'])),
                    ),
                    SizedBox(
                      height: 30,
                      child: Center(
                          child:
                              Text(item['difference']['valueForRollup'] ?? "")),
                    ),
                  ]),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.1,
                  ),
                  Text(
                    'total_duration'.tr,
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    ': ${powerLogs?['totalTime']}',
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
