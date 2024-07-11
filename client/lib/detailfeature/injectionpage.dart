import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InjectionPage extends StatefulWidget {
  @override
  _InjectionPageState createState() => _InjectionPageState();
}

class _InjectionPageState extends State<InjectionPage> {
  Map<int, bool> buttonStates = {};
  String lastInjectionDate = '';
  bool isInjectionCompletedToday = false;

  @override
  void initState() {
    super.initState();
    _loadButtonStates();
    _fetchInjectionData(); // 데이터를 불러오는 함수 호출
    _checkForMonthChange();
  }

  Future<void> _fetchInjectionData() async {
    final user_no = 4; // 가상의 사용자 번호
    final measure_date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/get_injection'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_no': user_no,
          'measure_date': measure_date,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == '1') {
          final injectionValues = data['blood_sugar'].split(',');
          setState(() {
            buttonStates = {
              for (int i = 1; i <= injectionValues.length; i++)
                i: injectionValues[i - 1] == '1'
            };
            isInjectionCompletedToday = injectionValues[DateTime.now().day - 1] == '1';
          });
          print('Injection data fetched and set: $buttonStates');
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

  _checkForMonthChange() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentMonth = DateTime.now().month;
    int savedMonth = prefs.getInt('savedMonth') ?? currentMonth;

    if (currentMonth != savedMonth) {
      setState(() {
        buttonStates.clear();
        prefs.setInt('savedMonth', currentMonth);
      });
      prefs.remove('buttonStates');
    }
  }

  _loadButtonStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      lastInjectionDate = prefs.getString('lastInjectionDate') ?? '';
      buttonStates = _stringToMap(prefs.getString('buttonStates') ?? '');
      isInjectionCompletedToday = prefs.getBool('isInjectionCompletedToday') ?? false;
    });
  }

  _saveButtonStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('lastInjectionDate', lastInjectionDate);
    prefs.setInt('savedMonth', DateTime.now().month);
    prefs.setString('buttonStates', _mapToString(buttonStates));
    prefs.setBool('isInjectionCompletedToday', isInjectionCompletedToday);
  }

  Map<int, bool> _stringToMap(String mapString) {
    if (mapString.isEmpty) {
      return {};
    }
    return Map<int, bool>.fromEntries(
      mapString.split(',').map((entry) {
        List<String> keyValue = entry.split(':');
        return MapEntry(int.parse(keyValue[0]), keyValue[1] == 'true');
      }),
    );
  }

  String _mapToString(Map<int, bool> map) {
    return map.entries.map((e) => '${e.key}:${e.value}').join(',');
  }

  Future<void> _handleInjectionComplete() async {
    final user_no = 4; // 가상의 사용자 번호
    final measure_date = DateFormat('yyyy-MM-dd').format(DateTime.now());

    setState(() {
      int today = DateTime.now().day;
      buttonStates[today] = true;
      isInjectionCompletedToday = true;
    });

    _saveButtonStates();

    // 서버로 데이터 전송
    List<String> measureList = List.generate(31, (index) {
      return buttonStates[index + 1] == true ? '1' : '0';
    });

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/update_injection'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_no': user_no,
          'measure_date': measure_date,
          'new_measure': measureList.join(','),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == '1') {
          print('Injection data updated successfully.');
        } else {
          print('Failed to update injection data: ${data['message']}');
        }
      } else {
        print('Failed to update injection data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating injection data: $e');
    }
  }

  bool _canCompleteInjectionToday() {
    int todayIndex = DateTime.now().day;
    return buttonStates[todayIndex] == false;
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
                          return Container(
                            margin: EdgeInsets.all(2.0), // 간격을 조절
                            child: CircleAvatar(
                              radius: 20, // 크기를 조절
                              backgroundColor:
                              buttonStates[index] == true ? Colors.green : Colors.grey,
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
            Text(
              lastInjectionDate.isNotEmpty
                  ? '마지막 인슐린 주사 날짜: $lastInjectionDate'
                  : '아직 주사 기록이 없습니다.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
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
