// ignore_for_file: prefer_const_constructors, sort_child_properties_last, prefer_const_literals_to_create_immutables, no_leading_underscores_for_local_identifiers, unnecessary_type_check

import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Home_page.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  List<Widget> buttons = [];

  Future<List<Map<String, dynamic>>>? devices;

  @override
  void initState() {
    super.initState();
    devices = fetchDeviceIds();
  }

  Future<List<Map<String, dynamic>>> fetchDeviceIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('jwt_token');

    if (jwtToken == null) {
      // Handle the case where the token is not found
      // return null;
    }

    try {
      final response = await http.get(
        Uri.https('console-api.theja.in', 'device/getAll'),
        headers: {
          "Authorization": "Bearer $jwtToken",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse is List) {
          final devices = jsonResponse.map((device) {
            return {
              "deviceId": device["deviceId"].toString(),
              "name": device["name"].toString(),
              "powerStatusn": device["powerAvailable"],
              "isDeviceSwitched": device["givenState"],
              "motorbox": device["deviceState"],
            };
          }).toList();

          return devices;
        } else {
          print('JSON response is not a List');
          return <Map<String, dynamic>>[];
        }
      } else {
        print('API Response (Error): ${response.body}');
        throw Exception(
            'Failed to load devices. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching devices: $e');
      return <Map<String, dynamic>>[];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: devices,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final deviceList = snapshot.data;

          if (deviceList == null || deviceList.isEmpty) {
            return Center(child: Text('No device IDs found.'));
          }

          return Container(
            child: Center(
              child: ListView(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset("assets/logo.png"),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: deviceList.length,
                  itemBuilder: (context, index) {
                    final device = deviceList[index];
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 15, right: 5, top: 10),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/homepage',
                                    arguments: device["deviceId"]);
                                // Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //       builder: (context) =>
                                //           Homepage(deviceIdsList[index])),
                                // );
                                //
                                // Handle button press for each device
                                // You can navigate to a specific page or perform other actions here
                              },
                              child: Row(
                                children: [
                                  Text(
                                    device["name"],
                                    style: TextStyle(
                                      color: device["motorbox"]
                                          ? const Color.fromARGB(
                                              255, 22, 135, 26)
                                          : const Color.fromARGB(
                                              255, 195, 51, 41),
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              0.04,
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      color: device["motorbox"]
                                          ? Color.fromARGB(255, 121, 209, 124)
                                          : Color.fromARGB(255, 233, 133, 126),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            color: device["motorbox"]
                                                ? Color.fromARGB(
                                                    255, 26, 169, 31)
                                                : Color.fromARGB(
                                                    255, 238, 69, 57),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              style: ElevatedButton.styleFrom(
                                primary: device["motorbox"]
                                    ? Color.fromARGB(255, 222, 242, 201)
                                    : Color.fromARGB(223, 240, 200, 200),
                                fixedSize: Size(770, 60),
                                side: BorderSide(
                                  color: device["motorbox"]
                                      ? Color.fromARGB(255, 22, 135, 26)
                                      : Color.fromARGB(255, 218, 117, 110),
                                  width: 2,
                                  style: BorderStyle.solid,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ]),
            ),
          );
        }
      },
    );
  }
}
