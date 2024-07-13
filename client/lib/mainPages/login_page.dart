import 'package:client/mainpage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<void> _login(BuildContext context) async {
    final String id = _idController.text;
    final String pw = _pwController.text;

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/get_user'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'ID': id,
          'PW': pw,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['message'] == '1') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인 성공')));
        print("로그인 성공: $data");
        final user = data['user'];
        final userNo = user['user_no'];
        final userAge = user['age'];
        final userName = user['name'];

        // SharedPreferences에 사용자 정보 저장
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_no', userNo);
        await prefs.setString('user_name', userName);
        await prefs.setInt('user_age', userAge);

        Get.offAll(Mainpage());
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('로그인 실패')));
        print("로그인 실패: ${data['message']}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('오류 발생')));
      print("Error during login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _pwController,
              decoration: InputDecoration(labelText: '비밀번호'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('로그인'),
            ),
          ],
        ),
      ),
    );
  }
}
