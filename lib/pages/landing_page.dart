// ignore_for_file: unnecessary_type_check, prefer_const_constructors

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:iot_mobile_app/pages/admin_landing_pages/landing.dart';
import 'package:iot_mobile_app/pages/lang_page.dart';
import 'package:iot_mobile_app/providers/firebase_message.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Landingpage extends StatefulWidget {
  final String id;
  static final GlobalKey<_LandingpageState> landingpageKey =
      GlobalKey<_LandingpageState>();
  const Landingpage({Key? key, required this.id}) : super(key: key);

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  bool isSwitched = false;
  FirebaseApi firebaseApi = FirebaseApi();
  bool isDeviceSwitched = false;
  final GlobalKey<DeviceListState> deviceListKey = GlobalKey<DeviceListState>();
  late StreamController<bool> _refreshController;
  late Stream<bool> _refreshStream;
  Future<List<Map<String, dynamic>>>? devices;
  late bool isAdminOrSuperAdmin;
  GlobalKey<RefreshIndicatorState> refreshKey =
      GlobalKey<RefreshIndicatorState>();
  late Timer _timer;
  @override
  void initState() {
    super.initState();
    isAdminOrSuperAdmin = false;
    devices = fetchDevices();
    firebaseApi.initNotifications();
    firebaseApi.isTokenRefresh();
    firebaseApi.firebaseInit(context);
    firebaseApi.setupInteractMessage(context);
    firebaseApi.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token');
        print(value);
      }
    });
    _refreshController = StreamController<bool>.broadcast();
    _refreshStream = _refreshController.stream;

    // Refresh the data periodically
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      refreshData();
      setState(() {
        // Update the devices list
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer to avoid memory leaks
    _refreshController.close(); // Close the stream controller
    super.dispose();
  }

  @override
  void didPopNext() {
    // Trigger refresh when returning from the homepage
    refreshData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Add the following line to refresh data when returning to this page
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await refreshData();
    });
  }

  Map<String, dynamic> decodeJwt(String token) {
    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      print('Error decoding JWT: $e');
      return {};
    }
  }

  Future<bool> checkUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('jwt_token');

    if (jwtToken != null) {
      Map<String, dynamic> decodedToken = decodeJwt(jwtToken);
      List<dynamic> authorities = decodedToken['authorities'];

      return authorities.contains('admin') ||
          authorities.contains('superAdmin');
    }

    return false;
  }

  Future<List<Map<String, dynamic>>> fetchDevices() async {
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

  SwitchonState switchonState = SwitchonState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(

        iconTheme: IconThemeData(color: Colors.black),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          "map_device".tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.05,
          ),
        ),
        actions: [
          FutureBuilder<bool>(
            future: checkUserRole(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.data == true) {
                  return Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => Adminlandingpage(),
                            ),
                          );
                        },
                        child: Icon(Icons.home)),
                  );
                }
              }
              return Container(); // Return an empty container if not admin or superadmin
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Langscreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: SvgPicture.asset(
                  'assets/language-icon.svg',
                ),
              ),
            ),
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          // When the back button is pressed, trigger the refresh
          await refreshData();
          return true; // Allow the page to be popped
        },
        child: StreamBuilder<bool>(
            stream: _refreshStream,
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data == true) {
                refreshData();
                _refreshController.add(false); // Reset the value
              }
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
                      return Center(child: Text('No devices found.'));
                    }
                    return RefreshIndicator(
                      key: refreshKey,
                      onRefresh: () async {
                        await refreshData();
                        setState(() {
                          // Update the devices list
                          devices = devices;
                        });
                      },
                      child: DeviceList(
                        key: deviceListKey,
                        deviceList: deviceList,
                      ),
                    );
                  }
                },
              );
            }),
      ),
    );
  }

  Future<void> refreshData() async {
    setState(() {
      devices = fetchDevices();
    });
  }
}

class DeviceList extends StatefulWidget {
  final List<Map<String, dynamic>> deviceList;

  const DeviceList({Key? key, required this.deviceList}) : super(key: key);

  @override
  State<DeviceList> createState() => DeviceListState();
}

class DeviceListState extends State<DeviceList> {
  void refreshList() {
    setState(() {
      // Trigger a rebuild of the widget with the new data
      // refreshData()
    });
  }

  bool isSwitched = false;
  FirebaseApi firebaseApi = FirebaseApi();
  bool isDeviceSwitched = false;
  @override
  Widget build(BuildContext context) {
    final switchonState = context.read<SwitchonState>();

    return Container(
        height: MediaQuery.of(context).size.height,
        child: ListView.builder(
            itemCount: widget.deviceList.length,
            itemBuilder: (context, index) {
              final device = widget.deviceList[index];
              return GestureDetector(
                onTap: () async {
                  Navigator.pushNamed(
                    context,
                    '/homepage',
                    arguments: device["deviceId"],
                  );
                  // Trigger refresh when returning from the homepage
                  Landingpage.landingpageKey.currentState?.refreshData();
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 99,
                  height: 120,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 191, 188, 188),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03,
                            ),
                            Text(
                              'device_id:'.tr,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              device["deviceId"] ?? "",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.03,
                            ),
                            Text(
                              'name'.tr,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              device["name"] ?? "",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.01,
                            ),
                            Container(
                              height: 45,
                              width: MediaQuery.of(context).size.width * 0.3,
                              decoration: BoxDecoration(
                                  color: device["powerStatusn"]
                                      ? Colors.green
                                      : const Color.fromARGB(255, 253, 18, 1),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/power.png"),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.01,
                            ),
                            Container(
                              height: 45,
                              width: MediaQuery.of(context).size.width * 0.3,
                              decoration: BoxDecoration(
                                  color: device["motorbox"]
                                      ? Colors.green
                                      : const Color.fromARGB(255, 253, 18, 1),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset("assets/motor.jpeg"),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.01,
                            ),
                            Container(
                              height: 45,
                              width: MediaQuery.of(context).size.width * 0.3,
                              decoration: BoxDecoration(
                                  color: device["isDeviceSwitched"]
                                      ? const Color.fromARGB(255, 245, 247, 245)
                                      : Color.fromARGB(255, 255, 254, 253),
                                  borderRadius: BorderRadius.circular(30)),
                              child: Switch(
                                  activeTrackColor: Colors.green,
                                  activeColor: Colors.white,
                                  inactiveTrackColor: Colors.red,
                                  inactiveThumbColor: Colors.white,
                                  value: device["isDeviceSwitched"],
                                  onChanged: (value) async {
                                    try {
                                      await switchonState.updateDevicetatus(
                                          device["deviceId"] ?? "", value);

                                      setState(() {
                                        // Update the device status
                                        widget.deviceList[index]
                                            ["isDeviceSwitched"] = value;
                                        // isDeviceSwitched = value;
                                      });
                                    } catch (e) {
                                      print('Error: $e');
                                    }
                                  }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }
}

class SwitchonState extends ChangeNotifier {
  bool _isSwitched = false;

  bool get isSwitched => _isSwitched;

  Future<bool> updateDevicetatus(String deviceId, bool isSwitched) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('jwt_token');

    if (jwtToken == null) {
      // Handle the case where the token is not found
      // return null;
    }

    String url = '/motor/${isSwitched ? 'onCommand' : 'offCommand'}/$deviceId';

    try {
      final response = await http.get(
        Uri.https('console-api.theja.in', url),
        headers: {
          "Authorization": "$jwtToken",
        },
      );

      print('Request URL: ${response.request?.url}');
      print('Request Headers: ${response.request?.headers}');
      print('Request Body: ${response.request?.isBlank}');

      if (response.statusCode == 200) {
        isSwitched = json.decode(response.body);
        notifyListeners();
        print('Switch status: $_isSwitched');

        return isSwitched;
      } else {
        print('API Response (Error): ${response.body}');
        throw Exception('Failed to update device status');
      }
    } catch (e) {
      print('Error updating device status: $e');
      throw Exception('Failed to update device status');
    }
  }
}

class LandingpageNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    if (previousRoute?.settings.name == '/landingpage') {
      _notifyLandingpageRefresh();
    }
  }

  void _notifyLandingpageRefresh() {
    final landingpageState =
        _LandingpageState(); // Replace with the actual state class name
    landingpageState.refreshData();
  }
}
