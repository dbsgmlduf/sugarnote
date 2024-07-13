import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/shared_preferences_helper.dart';

import '../history/pastdatapage.dart';
import '../mainPages/login_or_signup.dart';

class SettingScreen extends StatefulWidget {
  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String userName = '사용자 이름';
  String userAge = '사용자 나이';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await SharedPreferencesHelper.getUserName();
    final age = await SharedPreferencesHelper.getUserAge();
    setState(() {
      userName = name ?? '사용자 이름';
      userAge = age != null ? '$age세' : '사용자 나이';
    });
  }

  Future<void> _logout(BuildContext context) async {
    await SharedPreferencesHelper.clearAll();
    Get.offAll(LoginOrSignup());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('설정'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle, size: 80),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userAge,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 40),
            _buildSettingCard(context, '개인정보 수정', Icons.person, () {}),
            _buildSettingCard(context, '과거 데이터 조회', Icons.history, () {
              Get.to(PastDataPage());
            }),
            _buildSettingCard(context, '라이센스', Icons.book, () {}),
            _buildSettingCard(context, '문의하기', Icons.contact_mail, () {}),
            Spacer(),
            _buildLogoutButton(context), // 로그아웃 버튼 추가
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey, // 로그아웃 버튼 배경색 설정
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      onPressed: () => _logout(context),
      child: Text(
        '로그아웃',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }
}
