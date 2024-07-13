import 'dart:async';

import 'package:client/mainPages/login_or_signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Landingpage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<Landingpage> {
  @override
  void initState() {
    Timer(Duration(seconds: 3), () {
      //Get.offAll(LoginOrSignup());
      Get.offAll(LoginOrSignup());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            color: Colors.orange[100],
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/image/logo.png',
                  width: 500, // 로고의 너비를 설정합니다.
                  height: 500, // 로고의 높이를 설정합니다.
                ),
                SizedBox(height: 20),
                Text(
                  '오늘의 당',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
