// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iot_mobile_app/Auth/singin.dart';
// import 'package:iot_mobile_app/pages/Home_page.dart';
import 'package:iot_mobile_app/pages/admin_landing_pages/manage_device.dart';
import 'package:iot_mobile_app/pages/admin_landing_pages/map_devices.dart';
import 'package:iot_mobile_app/pages/admin_landing_pages/manage_user.dart';
import 'package:iot_mobile_app/pages/landing_page.dart';
import 'package:iot_mobile_app/pages/lang_page.dart';
import 'package:iot_mobile_app/providers/firebase_message.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Adminlandingpage extends StatefulWidget {
  const Adminlandingpage({Key? key}) : super(key: key);

  @override
  State<Adminlandingpage> createState() => _AdminlandingpageState();
}

class _AdminlandingpageState extends State<Adminlandingpage> {
  FirebaseApi firebaseApi = FirebaseApi();

  void logout() async {
    // Clear user login details from shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('username');
    prefs.remove('password');
    prefs.remove('jwt_token');

    // Navigate back to the login page
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SingIN()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(
          'manage_users'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: MediaQuery.of(context).size.width * 0.06,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.green,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const Langscreen(),
                  ),
                );
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.green,

                // backgroundImage: AssetImage('assets/language-icon.png'),
                child: SvgPicture.asset(
                  'assets/language-icon.svg',
                  // width: 100.0, // Adjust the width as needed
                  // height: 100.0, // Adjust the height as needed
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 10),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green,
              child: IconButton(
                  onPressed: () async {
                    logout();
                  },
                  icon: const Icon(
                    Icons.logout,
                    size: 30,
                    color: Colors.black,
                  )),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,

              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.width * 0.33,
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Users(),
                        ),
                      );

                      // Provide a valid function for the button
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'manage_users'.tr,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.07,
                          color: Colors.black),
                    ),
                  ),
                ),

                // SizedBox(height: 10),

                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.width * 0.33,
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const Managedevice(),
                        ),
                      );

                      // Provide a valid function for the button
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'manage_devices'.tr,
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.07,
                          color: Colors.black),
                    ),
                  ),
                ),

                // SizedBox(height: 10),

                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.width * 0.33,
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MapDevices(),
                        ),
                      );

                      // Provide a valid function for the button
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'map_a_device'.tr,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.07,
                      ),
                    ),
                  ),
                ),

                // SizedBox(height: 10),

                Container(
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.width * 0.33,
                  padding: const EdgeInsets.all(10),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                // Landingpage(id: ""),
                                const Landingpage(
                                  id: '',
                                )),
                      );

                      // Provide a valid function for the button
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: Text(
                      'view_mapped_device'.tr,
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: MediaQuery.of(context).size.width * 0.07),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
