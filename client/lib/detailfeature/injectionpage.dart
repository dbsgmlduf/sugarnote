import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:client/shared_preferences_helper.dart';

class InjectionPage extends StatefulWidget {
  @override
  _InjectionPageState createState() => _InjectionPageState();
}

class _InjectionPageState extends State<InjectionPage> {
  Map<int, bool> injectionData = {}; // 데이터를 저장할 맵
  bool isInjectionCompletedToday = false;
  int userNo = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userNo = await SharedPreferencesHelper.getUserNo() ?? 0;
    print('User No: $userNo'); // 디버깅용 출력
    _fetchInjectionData(); // 데이터를 가져오기
  }

  Future<void> _fetchInjectionData() async {
    final measure_date = DateFormat('yyyy-MM-15').format(DateTime.now()); // 임의의 15일 날짜 사용

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/get_injection'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_no': userNo,
          'measure_date': measure_date,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response body: $data'); // 데이터를 로그에 출력
        print('data[message] type: ${data['message'].runtimeType}'); // 데이터 타입 로그
        print('data[message]: ${data['message']}');

        if (data['message'] == "1") { // 문자열 "1"과 비교
          print('Message is 1');
          final injectionValues = data['injection'].split(',');
          print('Message is 2');
          print('injectionValues: ${injectionValues}');
          setState(() {
            injectionData = {
              for (int i = 0; i < injectionValues.length; i++)
                i + 1: injectionValues[i] != '0'
            };

            _updateButtonStates();
          });

          // 디버깅용 데이터 출력
          print('Injection Data: $injectionData');
        } else {
          print('Failed to fetch injection data: ${data['message']}');
        }
      } else {
        print('Failed to fetch injection data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching injection data: $e');
    }
  }

  void _updateButtonStates() {
    final today = DateTime.now().day;
    setState(() {
      isInjectionCompletedToday = injectionData[today] ?? false;
    });

    // 디버깅용 출력
    print('Updated button states: $injectionData');
  }

  _handleInjectionComplete() {
    setState(() {
      final today = DateTime.now().day;
      injectionData[today] = true;
      isInjectionCompletedToday = true;
    });
    _submitInjectionData();
  }

  Future<void> _submitInjectionData() async {
    final measure_date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/update_injection'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_no': userNo,
          'measure_date': measure_date,
          'new_measure': injectionData.values.map((e) => e ? 1 : 0).join(','),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] != '1') {
          print('Failed to submit injection data: ${data['message']}');
        } else {
          print('Injection data submitted successfully'); // 디버깅용 출력
        }
      } else {
        print('Failed to submit injection data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting injection data: $e');
    }
  }

  bool _canCompleteInjectionToday() {
    final today = DateTime.now().day;
    return injectionData[today] == null || injectionData[today] == false;
  }

  @override
  Widget build(BuildContext context) {
    final bool canCompleteToday = _canCompleteInjectionToday();
    final String buttonText = canCompleteToday ? '오늘 주입 필요' : '오늘 주입 완료';
    final Color buttonColor = canCompleteToday ? Colors.red : Colors.green;

    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: Text('오늘의 인슐린', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  child: Image.asset('assets/image/injectionBackground.png'),
                ),
                Positioned(
                  top: 100,
                  child: Column(
                    children: List.generate(4, (rowIndex) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(8, (colIndex) {
                          int index = rowIndex * 8 + colIndex + 1;
                          if (index > 31) return Container();
                          return Container(
                            margin: EdgeInsets.all(2.0), // 간격을 조절
                            child: CircleAvatar(
                              radius: 20, // 크기를 조절
                              backgroundColor: injectionData[index] == true ? Colors.green : Colors.grey,
                              child: Text(
                                '$index',
                                style: TextStyle(fontSize: 14), // 텍스트 크기를 조절
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(height: 10), // 텍스트와 버튼 사이의 간격을 조절
            ElevatedButton(
              onPressed: canCompleteToday ? _handleInjectionComplete : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor, // 배경색 설정
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
