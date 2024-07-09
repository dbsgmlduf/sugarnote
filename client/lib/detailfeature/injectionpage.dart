import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      bool allCompleted = true;
      for (int i = 1; i <= 32; i++) {
        if (buttonStates[i] != true) {
          buttonStates[i] = true;
          allCompleted = false;
          break;
        }
      }
      if (allCompleted) {
        buttonStates.clear();
      }
      lastInjectionDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      isInjectionCompletedToday = true;
    });
    _saveButtonStates();
  }

  bool _canCompleteInjectionToday() {
    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return lastInjectionDate != todayDate && !isInjectionCompletedToday;
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
