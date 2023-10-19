// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, unused_local_variable, unnecessary_type_check


import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'labels.dart/load.dart';
import 'labels.dart/motor.dart';
import 'labels.dart/power.dart';

class Logs extends StatefulWidget {
   final String deviceId;

  Logs(this.deviceId, {super.key});
  

  @override
  State<Logs> createState() => _LogsState();
}

class _LogsState extends State<Logs>  
   with SingleTickerProviderStateMixin {
   
   

  late TabController tabController;
   DateTime _dateTime = DateTime.now();
  late String _formattedDate = DateFormat('yyyy/MM/dd').format(_dateTime);
  

  @override
 void initState() {
   tabController = TabController(length: 3, vsync: this);
    deviceIds = fetchDeviceIds();

   super.initState();
   
 }
 @override
 void dispose(){
   tabController.dispose();
   super.dispose();

 }
//  DateTime _dateTime = DateTime.now();
//   String _formattedDate = '';
void _showDatePicker() {
  showDatePicker(
    context: context,
    initialDate: _dateTime,
    firstDate: DateTime(2021),
    lastDate: DateTime(2025),
  ).then((value) {
    if (value != null) {
      // Format the date to display only the date part
      final formattedDate = DateFormat('yyyy/MM/dd').format(value);
      
      setState(() {
        _dateTime = value;
        _formattedDate = formattedDate; // Store the formatted date
      });
    }
  });
}
Future<List<String>>? deviceIds;

  // @override
  // void initState() {
  //   super.initState();
  // }

 Future<List<String>> fetchDeviceIds() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? jwtToken = prefs.getString('jwt_token'); // Retrieve the JWT token from local storage

  if (jwtToken == null) {
    // Handle the case where the token is not found
    // return null;
  }
  final response = await http.get(
    Uri.https('console-api.theja.in', '/user/getInfo'), // Use the correct endpoint
    headers: {
      "Authorization": "Bearer $jwtToken",
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> deviceIdsJson = jsonResponse["deviceIds"];


    if (deviceIdsJson is List) {
      final deviceIds = deviceIdsJson.map((deviceIdJson) => deviceIdJson.toString()).toList();
      return deviceIds;
    } else {
      return <String>[];
    }
  } else {
    print('API Response (Error): ${response.body}');
    throw Exception('Failed to load device IDs');
  }
}



  @override
  Widget build(BuildContext context) {
    // final statusData = statusProvider.statusData;
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
    return Container(
      color:Color.fromARGB(255, 247, 242, 242),
      child: Column(
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 30,top: 45),
    
              child: Row(
                children: [
                  Text(
                    'device_no:1'.tr,
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                   Text(
                  '${widget.deviceId}',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                 
                  
                ],
              ),
            ),

                      Padding(
            padding: const EdgeInsets.only(left: 30,top: 0),

            child: Row(
              children: [
                Text(
                  'log_date'.tr,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 100),
               
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: TextButton(
                     onPressed: _showDatePicker,
                             child: Text(
                             _formattedDate,
                              
                            style: TextStyle(
                             color: Colors.black, // Change the text color as needed
                          fontSize: 18, // Adjust the text size as needed
                           ),
                             ),
                          ),                                                                    
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),

          Padding(
            padding: const EdgeInsets.only(left: 15,right: 20),
            child: Container(
              //  height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 180, 179, 179),
                borderRadius: BorderRadius.circular(5)
                ),
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.all(5),
                  child: TabBar(
                    unselectedLabelColor: Colors.black,
                    labelColor: Colors.white,
                    indicatorColor: Colors.black38,
                    // indicatorWeight: 3,
                    indicator: BoxDecoration(
                      color: Color.fromARGB(181, 51, 42, 55),
                      borderRadius: BorderRadius.circular(5)
                      
                      ),
                    controller: tabController,
                     tabs: [
                          Tab( child: Text( 'power'.tr,  style: TextStyle(fontSize: 20, ), ), ),
                          Tab( child: Text( 'motor'.tr,  style: TextStyle(fontSize: 20, ), ), ),
                          Tab( child: Text( 'load'.tr,  style: TextStyle(fontSize: 20, ), ), ),
                           ],
                    ),)
                ],
              ),
            ),
          ),
            Expanded(child: TabBarView(
              controller: tabController,
              children: [
              Power(),
              Motor(),
              Load(),
            ]) ,)

        ],
      ),
    );
  }
}
     );
  }
   }