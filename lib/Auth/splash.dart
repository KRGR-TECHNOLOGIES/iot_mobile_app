// ignore_for_file: prefer_const_constructors, dead_code, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:iot_mobile_app/Auth/singin.dart';
// import 'package:iot_mobile_app/pages/Home_page.dart';
import 'package:iot_mobile_app/pages/admin_landing_pages/landing.dart';
// import 'package:iot_mobile_app/pages/landing_page.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToPage();
  }

  void _navigateToPage() async {
    // Simulate checking the user's login status.
    await Future.delayed(Duration(seconds: 2));
    
    // Replace this with your logic to determine the user's login status.
    bool isLoggedIn = false;

    if (isLoggedIn) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Adminlandingpage()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => SingIN()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/splash_theja.png'),
      ),
    );
  }
}