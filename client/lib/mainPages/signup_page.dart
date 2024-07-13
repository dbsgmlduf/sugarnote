import 'package:client/mainPages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  Future<void> _registerUser() async {
    final String name = _nameController.text;
    final int age = int.parse(_ageController.text);
    final double height = double.parse(_heightController.text);
    final double weight = double.parse(_weightController.text);
    final String id = _idController.text;
    final String pw = _pwController.text;

    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/insert_user'), // Replace with your Flask API URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'name': name,
        'age': age,
        'height': height,
        'weight': weight,
        'ID': id,
        'PW': pw,
      }),
    );

    final data = jsonDecode(response.body);

    if (data['message'] == '1') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입 성공')));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else if (data['message'] == '2') {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('이미 존재하는 ID입니다')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('회원가입 실패')));
    }
  }

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
            ListTile(
              title: Text("나이"),
              subtitle: Text(_ageController.text.isEmpty ? "선택되지 않음" : "${_ageController.text} 세"),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: () => _selectValue(context, "나이", _ageController, 0, 150, " 세"),
            ),
            ListTile(
              title: Text("키"),
              subtitle: Text(_heightController.text.isEmpty ? "선택되지 않음" : "${_heightController.text} cm"),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: () => _selectValue(context, "키", _heightController, 0, 300, " cm"),
            ),
            ListTile(
              title: Text("몸무게"),
              subtitle: Text(_weightController.text.isEmpty ? "선택되지 않음" : "${_weightController.text} kg"),
              trailing: Icon(Icons.arrow_drop_down),
              onTap: () => _selectValue(context, "몸무게", _weightController, 0, 300, " kg"),
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
              onPressed: _registerUser,
              child: Text('회원가입'),
            ),
          ],
        ),
      ),
    );
  }

  void _selectValue(BuildContext context, String title, TextEditingController controller, int min, int max, String unit) {
    showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Container(
            width: double.minPositive,
            height: 300.0, // Increase height to make the list scrollable
            child: ListView.builder(
              itemCount: max - min + 1,
              itemBuilder: (BuildContext context, int index) {
                int value = min + index;
                return ListTile(
                  title: Text('$value $unit'),
                  onTap: () {
                    setState(() {
                      controller.text = value.toString();
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
