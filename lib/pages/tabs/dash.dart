// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unnecessary_brace_in_string_interps, unnecessary_type_check, dead_code

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dash extends StatefulWidget {
  final String deviceId;

  const Dash(this.deviceId, {super.key});
  @override
  State<Dash> createState() => _DashState();
}

class _DashState extends State<Dash> {
  bool isSwitched = false;

  String motorSwitchOnTime = '';
  String powerStatusOnTime = '';
  String motorStatusOnTime = '';
  bool powerStatus = false;
  bool motorStatus = false;
  bool isDeviceSwitched = false;
  Future<List<String>>? deviceIds;

  @override
  void initState() {
    super.initState();
    deviceIds = fetchDeviceIds();
    fetchDeviceStatus();
//   loadTimes();
  }

  void loadTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    motorSwitchOnTime = prefs.getString('motorSwitchOnTime') ?? '';
    powerStatusOnTime = prefs.getString('powerStatusOnTime') ?? '';
    motorStatusOnTime = prefs.getString('motorStatusOnTime') ?? '';
  }

  // Save times to SharedPreferences
  void saveTimes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('motorSwitchOnTime', motorSwitchOnTime);
    prefs.setString('powerStatusOnTime', powerStatusOnTime);
    prefs.setString('motorStatusOnTime', motorStatusOnTime);
  }

  Future<List<String>> fetchDeviceIds() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs
        .getString('jwt_token'); // Retrieve the JWT token from local storage

    if (jwtToken == null) {
      // Handle the case where the token is not found
      // return null;
    }
    final response = await http.get(
      Uri.https(
          'console-api.theja.in', '/user/getInfo'), // Use the correct endpoint
      headers: {
        "Authorization": "Bearer $jwtToken",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print(jsonResponse);

      final List<dynamic> deviceIdsJson = jsonResponse["deviceIds"];

      if (deviceIdsJson is List) {
        final deviceIds = deviceIdsJson
            .map((deviceIdJson) => deviceIdJson.toString())
            .toList();
        // print(deviceIds[2]+'first index of device');
        return deviceIds;
      } else {
        return <String>[];
      }
    } else {
      print('API Response (Error): ${response.body}');
      throw Exception('Failed to load device IDs');
    }
  }

  Future<void> fetchDeviceStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('jwt_token');

    if (jwtToken == null) {
      // Handle the case where the token is not found
      return;
    }

    final response = await http.get(
      Uri.https('console-api.theja.in', '/motor/get/${widget.deviceId}'),
      headers: {
        "Authorization": "Bearer $jwtToken",
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      print(response.body);
      powerStatus = jsonResponse["powerAvailable"];
      motorStatus = jsonResponse["deviceState"];
      isDeviceSwitched = jsonResponse["givenState"];
      motorSwitchOnTime = jsonResponse["lastGivenState"] ?? '';
      powerStatusOnTime = jsonResponse["powerLastPing"] ?? '';
      motorStatusOnTime = jsonResponse["lastDeviceState"] ?? '';
      if (isSwitched) {
        motorSwitchOnTime = DateFormat('HH:mm:ss a').format(DateTime.now());
        saveTimes(); // Save the updated time to SharedPreferences
      }

      if (powerStatus) {
        powerStatusOnTime = DateFormat('HH:mm:ss').format(DateTime.now());
        saveTimes(); // Save the updated time to SharedPreferences
      }

      if (motorStatus) {
        motorStatusOnTime = DateFormat('HH:mm:ss').format(DateTime.now());
        saveTimes(); // Save the updated time to SharedPreferences
      } // Update motor switch time

      setState(() {}); // Update the UI to reflect the new state values
    } else {
      print('API Response (Error): ${response.body}');
      throw Exception('Failed to load device status');
    }
  }
  bool isRefreshing = false;
  void handleRefresh() {
    setState(() {
      isRefreshing = true;
      fetchDeviceStatus();
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          isRefreshing = false;
        });
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
        future: deviceIds,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final deviceIdsList = snapshot.data;

            if (deviceIdsList == null || deviceIdsList.isEmpty) {
              return Center(child: Text('No device IDs found.'));
            }

            final switchState = Provider.of<SwitchState>(context);
            final Size screenSize = MediaQuery.of(context).size;

            return Container(
              width: screenSize.width * 100,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 10),
                      child: Row(
                        children: [
                          Text(
                            'device_no:1'.tr,
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${widget.deviceId}',
                            style: TextStyle(
                                fontSize:
                                    MediaQuery.of(context).size.width * 0.06,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: screenSize.width * 0.38,
                          ),
                          isRefreshing
                              ? CircularProgressIndicator()
                              :
                          SizedBox(
                            width: 30,
                            child: GestureDetector(
                                onTap: handleRefresh,
                                    // Call handleRefresh when the icon is tapped
                                child: Image.asset(
                                  "assets/refresh.png",
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 11),
                      child: Row(
                        children: [
                          Container(
                            height: screenSize.height * 0.22,
                            width: screenSize.width * 0.94,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: screenSize.height * 0.07,
                                  width: screenSize.width * 0.94,
                                  decoration: BoxDecoration(
                                    color: isDeviceSwitched
                                        ? Colors.green
                                        : Color.fromARGB(255, 255, 17, 0),
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(30),
                                        topLeft: Radius.circular(30)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      children: [
                                        Text(
                                          'motor_switch'.tr,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05),
                                        ),
                                        SizedBox(
                                          width: screenSize.width * 0.3,
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 0),
                                          child: Text(
                                            isDeviceSwitched
                                                ? 'on'.tr
                                                : 'off'.tr,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.05),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 30.0, left: 10),
                                      child: Switch(
                                        onChanged: (value) {
                                          setState(() {
                                            switchState.updateDeviceStatus(
                                                widget.deviceId,
                                                isDeviceSwitched);
                                            isDeviceSwitched = value;
                                            if (isDeviceSwitched) {
                                              motorSwitchOnTime =
                                                  DateFormat('HH:mm:ss a')
                                                      .format(DateTime.now());
                                              saveTimes();
                                            }
                                          });
                                        },
                                        activeTrackColor: Colors.green,
                                        activeColor: Colors.white,
                                        inactiveTrackColor: Colors.red,
                                        inactiveThumbColor: Colors.white,
                                        value: isDeviceSwitched,
                                      ),
                                    ),
                                    SizedBox(
                                      width: screenSize.width * 0.08,
                                    ),
                                    Wrap(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 40),
                                          child: isDeviceSwitched
                                              ? Text(
                                                  'last_off'.tr,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                  ),
                                                )
                                              : Text(
                                                  'last_on'.tr,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.05,
                                                  ),
                                                ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 40),
                                          child: Text(
                                            ' $motorSwitchOnTime',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.05,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 11),
                      child: Row(
                        children: [
                          Container(
                            height: screenSize.height * 0.22,
                            width: screenSize.width * 0.94,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: screenSize.height * 0.07,
                                  width: screenSize.width * 0.94,
                                  decoration: BoxDecoration(
                                    color: powerStatus
                                        ? Colors.green
                                        : const Color.fromARGB(255, 253, 18, 1),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(30),
                                      topLeft: Radius.circular(30),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      children: [
                                        Text(
                                          'power_status'.tr,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenSize.width * 0.3,
                                        ),
                                        Text(
                                          powerStatus ? 'on'.tr : 'off'.tr,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(13.0),
                                          child:
                                              Image.asset("assets/power.png")),
                                      SizedBox(
                                        width: screenSize.width * 0.01,
                                      ),
                                      Text(
                                        'last_on'.tr,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                        ),
                                      ),
                                      Text(
                                        ' $powerStatusOnTime',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                        ),
                                      ),
                                      Column(
                                        children: [],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 11),
                      child: Row(
                        children: [
                          Container(
                            height: screenSize.height * 0.22,
                            width: screenSize.width * 0.94,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: screenSize.height * 0.07,
                                  width: screenSize.width * 0.94,
                                  decoration: BoxDecoration(
                                    color: motorStatus
                                        ? Colors.green
                                        : Color.fromARGB(255, 255, 17, 0),
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(30),
                                      topLeft: Radius.circular(30),
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 20),
                                    child: Row(
                                      children: [
                                        Text(
                                          'motor_status'.tr,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenSize.width * 0.3,
                                        ),
                                        Text(
                                          motorStatus ? 'on'.tr : 'off'.tr,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.05,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child:
                                              Image.asset("assets/motor.jpeg")),
                                      SizedBox(
                                        width: screenSize.width * 0.01,
                                        // height: 50,
                                      ),
                                      Text(
                                        'last_on'.tr,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                        ),
                                      ),
                                      Text(
                                        ' $motorStatusOnTime',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.05,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              ),
            );
          }
        });
  }
}

class SwitchState extends ChangeNotifier {
  void toggleSwitch(String deviceId, bool isSwitched) {
    isSwitched = !isSwitched;
    updateDeviceStatus(deviceId, isSwitched);
    notifyListeners();
  }

  Future<bool> updateDeviceStatus(String deviceId, bool isSwitched) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs
        .getString('jwt_token'); // Retrieve the JWT token from local storage

    if (jwtToken == null) {
      // Handle the case where the token is not found
      // return null;
    }
    String url = isSwitched
        ? '/motor/offCommand/${deviceId}'
        : '/motor/onCommand/${deviceId}';
    final response = await http.get(
      Uri.https('console-api.theja.in', url), // Use the correct endpoint
      headers: {
        "Authorization": "$jwtToken",
      },
    );
    print('Request URL: ${response.request?.url}');
    print('Request Headers: ${response.request?.headers}');
    print('Request Body: ${response.request?.isBlank}');

    if (response.statusCode == 200) {
      isSwitched = json.decode(response.body);
      return isSwitched;
      print('Switch staus:  ${isSwitched}');
    } else {
      print('API Response (Error): ${response.body}');
      throw Exception('Failed to update device status');
    }

    return isSwitched;
  }
}
