// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, deprecated_member_use, avoid_print, unused_local_variable

import 'dart:convert';
import 'package:animated_card/animated_card.dart';
import 'package:flutter/services.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:glassmorphism_widgets/glassmorphism_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:iot_mobile_app/pages/lang_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgotpassword.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class SingIN extends StatefulWidget {
  const SingIN({super.key});

  @override
  State<SingIN> createState() => _SingINState();
}

class _SingINState extends State<SingIN> {
  final formkey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();

  final _passwordController = TextEditingController();
  bool _obscureText = true; // Initially obscure text
  @override
  void initState() {
    super.initState();
    checkLoggedInStatus(); // Check the login status when the screen initializes
  }

  // Function to check the login status
  void checkLoggedInStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? password = prefs.getString('password');

    if (username != null && password != null) {
      login(username, password);
    }
  }

  void login(String user, password) async {
    final Map<String, dynamic> requestData = {
      "pin": password,
      "userId": user,
    };
    String finalText = "Logged In".tr;
    try {
      final response = await http.post(
        Uri.parse('https://console-api.theja.in/login'),
        body: jsonEncode(requestData),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        print(data);
        print('account login sucessfully');
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('username', user);
        prefs.setString('password', password);
        prefs.setString('jwt_token', data['token']);

        // Decode the token to check user role
        final Map<String, dynamic> decodedToken =
            JwtDecoder.decode(data['token']);
        List<dynamic> authorities = decodedToken['authorities'];

        if (authorities.contains('superAdmin') ||
            (authorities.contains('admin'))) {
          // Navigate to the admin panel (Adminlandingpage)
          Navigator.pushNamedAndRemoveUntil(
              context, '/adminlandingpage', (route) => false);
        } else {
          // Navigate to the user panel (Landingpage)
          Navigator.pushNamedAndRemoveUntil(
              context, '/landingpage', (route) => false);
        }
      } else {
        // Show a toast message for wrong credentials
        // Fluttertoast.showToast(
        //   msg: "Wrong credentials. Try again!",
        //   toastLength: Toast.LENGTH_SHORT,
        //   gravity: ToastGravity.BOTTOM,
        //   timeInSecForIosWeb: 3,
        //   backgroundColor: Colors.red,
        //   textColor: Colors.white,
        // );
        //Simple to use, no global configuration

        finalText = "Login failed";
        showToast(
          "Wrong credentials. Try again!",
          position: StyledToastPosition.center,
          context: context,
          animation: StyledToastAnimation.scale,
          reverseAnimation: StyledToastAnimation.scale,
          duration: Duration(seconds: 4),
          animDuration: Duration(seconds: 1),
          curve: Curves.elasticOut,
          reverseCurve: Curves.linear,
          // backgroundColor: Colors.red,
          textStyle: TextStyle(color: Colors.white, fontSize: 16),
        );

//Customize toast content widget, no global configuration
        // showToastWidget(Text('hello styled toast'), context: context);
      }
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      // Update the finalText property of the AnimatedButton
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Color.fromARGB(255, 165, 227, 106),
      //   iconTheme: IconThemeData(color: Colors.black),
      //   automaticallyImplyLeading: false,
      //   title: Text(
      //     'sign_in'.tr,
      //     style: TextStyle(
      //         fontWeight: FontWeight.bold, fontSize: 25, color: Colors.black),
      //   ),
      //   actions: [
      //     Padding(
      //       padding: EdgeInsets.only(right: 30),
      //       child: GestureDetector(
      //         onTap: () {
      //           Navigator.of(context).push(
      //             MaterialPageRoute(
      //               builder: (context) => Langscreen(),
      //             ),
      //           );
      //         },
      //         child: CircleAvatar(
      //           radius: 18,
      //           backgroundColor: Color.fromARGB(255, 165, 227, 106),
      //           // backgroundImage: AssetImage('assets/language-icon.png'),
      //           child: SvgPicture.asset(
      //             'assets/language-icon.svg',
      //             // width: 100.0, // Adjust the width as needed
      //             // height: 100.0, // Adjust the height as needed
      //           ),
      //         ),
      //       ),
      //     ),
      //   ],
      // ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "assets/bg.png",
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: size.height * 0.1,
                ),
                SvgPicture.asset(
                  "assets/logo.svg",
                ),
                SizedBox(
                  height: size.height * 0.01,
                ),
                Text(
                  'THEJA TECHNOLOGIES',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
                    height: 0,
                    letterSpacing: 0.18,
                  ),
                ),
                SizedBox(
                  height: size.height * 0.04,
                ),
                Form(
                  key: formkey,
                  child: Center(
                    child: AnimatedCard(
                      direction: AnimatedCardDirection.left,
                      initDelay: Duration(milliseconds: 300),
                      curve: Curves.decelerate,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: GlassContainer(
                          height: MediaQuery.of(context).size.height * 0.51,
                          // border: 0,
                          // constraints: BoxConstraints.expand(),
                          // blur: 30,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'log_in_to_console'.tr,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                // Text(
                                //   "mobile/email".tr,
                                //   style: TextStyle(
                                //     fontSize: 20,
                                //     color: Colors.white,
                                //   ),
                                // ),
                                // SizedBox(
                                //   height: 10,
                                // ),
                                TextFormField(
                                  controller: _usernameController,
                                  keyboardType: TextInputType.text,
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.zero,
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                    ),
                                    hintText: "enter_mobile/email".tr,
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return '${'mobile/email'.tr} is Required';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(
                                  height: 30,
                                ),
                                // Text(
                                //   "pin".tr,
                                //   style: TextStyle(
                                //     fontSize: 20,
                                //     color: Colors.white,
                                //   ),
                                // ),
                                // SizedBox(
                                //   height: 10,
                                // ),
                                TextFormField(
                                  controller: _passwordController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  obscureText: _obscureText,
                                  cursorColor: Colors.white,
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.zero,
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      borderSide: BorderSide(
                                        color: Colors.white,
                                        width: 2.0,
                                      ),
                                    ),
                                    hintText: 'enter_pin'.tr,
                                    hintStyle: TextStyle(
                                      color: Colors.white,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureText = !_obscureText;
                                        });
                                      },
                                      icon: Icon(
                                        color: Colors.white,
                                        _obscureText
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                    ),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return '${'pin'.tr} is required';
                                    }
                                    return null;
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ForgotPasswordPage(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        "forgot_password".tr,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                          decorationColor: Colors.white,
                                          height: 0.10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: 20,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (formkey.currentState!.validate()) {
                                      login(
                                        _usernameController.text.toString(),
                                        _passwordController.text.toString(),
                                      );
                                    }
                                  },
                                  child: Container(
                                    height: size.height * 0.06,
                                    width: size.width * 0.5,
                                    decoration: ShapeDecoration(
                                      color: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "sign_in".tr,
                                        style: TextStyle(
                                          color: Color(0xFF1E2138),
                                          fontSize: 18,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Center(
                                //   child: AnimatedButton(
                                //       onTap: () {
                                //         if (formkey.currentState!.validate()) {
                                //           login(
                                //             _usernameController.text.toString(),
                                //             _passwordController.text.toString(),
                                //           );
                                //         }
                                //       },
                                //       animationDuration:
                                //           const Duration(milliseconds: 2000),
                                //       initialText: "sign_in".tr,
                                //       finalText: _finalText,
                                //       iconData: Icons.check,
                                //       iconSize: 32.0,
                                //       buttonStyle: buttonstyle(
                                //         primaryColor: Colors.green.shade600,
                                //         secondaryColor: Colors.white,
                                //         initialTextStyle: TextStyle(
                                //           fontSize: 22.0,
                                //           color: Colors.white,
                                //         ),
                                //         finalTextStyle: TextStyle(
                                //           fontSize: 22.0,
                                //           color: Colors.green.shade600,
                                //         ),
                                //         elevation: 20.0,
                                //         borderRadius: 10.0,
                                //       )),
                                // ),
                                SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
