import 'dart:async';

import 'package:client/mainpage.dart';
import 'package:client/mainPages/login_or_signup.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Landingpage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<Landingpage>{
  @override
  void initState(){
    Timer(Duration(seconds: 3),(){
      //Get.offAll(LoginOrSignup());
      Get.offAll(Mainpage());
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(color: Colors.orange[100],
            child: Center(child: Text('오늘의 당')),
          ),
          CircularProgressIndicator()
        ]

      ),

    );
  }
}