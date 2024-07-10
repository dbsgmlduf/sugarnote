import 'package:flutter/material.dart';
import 'package:client/mainPages/login_page.dart';
import 'package:client/mainPages/signup_page.dart';

class LoginOrSignup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '환영합니다!',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text('로그인', style: TextStyle(color: Colors.blue)),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignupPage()));
              },
              child: Text('회원가입', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
