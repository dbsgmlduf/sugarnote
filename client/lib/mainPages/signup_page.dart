import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: '이름'),
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: '나이'),
            ),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(labelText: '키'),
            ),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: '몸무게'),
            ),
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
              onPressed: () {
                // 회원가입 처리
              },
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }
}
