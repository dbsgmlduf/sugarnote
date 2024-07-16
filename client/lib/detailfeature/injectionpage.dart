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
  Map<int, bool> buttonStates = {};
  String lastInjectionDate = '';
  bool isInjectionCompletedToday = false;
  int userNo = 0;
  List<int> injectionData = List.filled(31, 0); // 데이터를 저장할 리스트

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userNo = await SharedPreferencesHelper.getUserNo() ?? 0;
    _loadButtonStates();
    _checkForMonthChange();
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
    _fetchInjectionData();
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
        if (data['message'] == '1') {
          final injectionValues = data['measure'].split(',').map((e) => int.parse(e)).toList();
          setState(() {
            injectionData = injectionValues;
            _updateButtonStates();
          });
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
      for (int i = 1; i <= 31; i++) {
        if (i <= injectionData.length && injectionData[i - 1] == 1) {
          buttonStates[i] = true;
        } else if (i == today) {
          buttonStates[i] = false;
        }
      }
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

  _handleInjectionComplete() {
    setState(() {
      final today = DateTime.now().day;
      injectionData[today - 1] = 1;
      buttonStates[today] = true;
      lastInjectionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      isInjectionCompletedToday = true;
    });
    _saveButtonStates();
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
          'new_measure': injectionData.join(','),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] != '1') {
          print('Failed to submit injection data: ${data['message']}');
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
    return buttonStates[today] == false || buttonStates[today] == null;
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
                              backgroundColor: buttonStates[index] == true ? Colors.green : Colors.grey,
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
