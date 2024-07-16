import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:client/shared_preferences_helper.dart';

class CounselingPage extends StatefulWidget {
  @override
  _CounselingPageState createState() => _CounselingPageState();
}

class _CounselingPageState extends State<CounselingPage> {
  int userNo = 0;
  String advice = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userNo = await SharedPreferencesHelper.getUserNo() ?? 0;
    _sendDailyAdvice(); // 하루에 한 번 전날 데이터를 활용하여 상담을 받습니다.
  }

  Future<void> _sendDailyAdvice() async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:5000/counseling'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'user_no': userNo,
        'measure_date': DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(Duration(days: 1))), // 전날 데이터 사용
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        advice = data['response'];
      });
    } else if (response.statusCode == 808) {
      setState(() {
        advice = '전날 측정한 기록이 없습니다.';
      });
    } else {
      setState(() {
        advice = '알 수 없는 오류가 발생했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person),
            SizedBox(width: 8),
            Text('상담 서비스'),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            advice.isNotEmpty ? advice : '상담 내용을 불러오는 중입니다...',
            style: TextStyle(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
