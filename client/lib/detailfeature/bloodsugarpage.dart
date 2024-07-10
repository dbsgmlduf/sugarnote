import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BloodSugarPage extends StatefulWidget {
  @override
  _BloodSugarPageState createState() => _BloodSugarPageState();
}

class _BloodSugarPageState extends State<BloodSugarPage> {
  DateTime today = DateTime.now();

  // 더미 데이터
  Map<String, String?> bloodSugarData = {
    '아침공복': null,
    '아침식후': null,
    '점심식전': null,
    '점심식후': null,
    '저녁식전': null,
    '취침전': null,
  };

  @override
  void initState() {
    super.initState();
    _fetchBloodSugarData();
  }

  Future<void> _fetchBloodSugarData() async {
    final user_no = 1; // 임시로 저장된 사용자 번호
    final measure_date = DateFormat('yyyy-MM-dd').format(today);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/get_bloodsugar'),
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
          final bloodSugarValues = data['blood_sugar'].split(',');
          setState(() {
            bloodSugarData = {
              '아침공복': bloodSugarValues[0] == '-1' ? null : bloodSugarValues[0],
              '아침식후': bloodSugarValues[1] == '-1' ? null : bloodSugarValues[1],
              '점심식전': bloodSugarValues[2] == '-1' ? null : bloodSugarValues[2],
              '점심식후': bloodSugarValues[3] == '-1' ? null : bloodSugarValues[3],
              '저녁식전': bloodSugarValues[4] == '-1' ? null : bloodSugarValues[4],
              '취침전': bloodSugarValues[5] == '-1' ? null : bloodSugarValues[5],
            };
          });
        } else {
          print('Failed to fetch blood sugar data: ${data['message']}');
        }
      } else {
        print('Failed to fetch blood sugar data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching blood sugar data: $e');
    }
  }

  Future<void> _submitBloodSugarData(String time, int value) async {
    final user_no = 1; // 임시로 저장된 사용자 번호
    final measure_date = DateFormat('yyyy-MM-dd').format(today);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/update_bloodsugar'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_no': user_no,
          'new_measure': value,
          'measure_date': measure_date,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['message'] == '1') {
          setState(() {
            bloodSugarData[time] = value.toString();
          });
        } else {
          print('Failed to submit blood sugar data: ${data['message']}');
        }
      } else {
        print('Failed to submit blood sugar data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error submitting blood sugar data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: <Widget>[
                Text(
                  '오늘 날짜',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                Spacer(),
                Text(
                  DateFormat('yyyy년 MM월 dd일 EEE').format(today),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.0),
          ...bloodSugarData.keys.map((time) {
            final value = bloodSugarData[time];
            return BloodSugarCard(
              time: time,
              value: value ?? '측정 필요',
              isMeasured: value != null,
              onAddPressed: () => _showInputDialog(context, time),
            );
          }).toList(),
          Spacer(),
          Row(
            children: [
              Icon(Icons.info, color: Colors.black, size: 16.0),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  "공복 혈당은 8시간 이상의 금식 후 아침 공복 상태에서 측정해요. 정상인은 결과가 110mg/dL 이하로 측정되요. 식후 2시간 혈당은 식사 시작 시점부터 2시간 후 측정한 혈당을 말해요. 140mg/dL 이하가 정상이에요.",
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showInputDialog(BuildContext context, String time) {
    TextEditingController _textFieldController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("오늘의 혈당 입력"),
          content: TextField(
            controller: _textFieldController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "혈당기에 적힌 숫자를 적어주세요",
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('저장'),
              onPressed: () {
                setState(() {
                  bloodSugarData[time] = _textFieldController.text;
                });
                _submitBloodSugarData(time, int.parse(_textFieldController.text));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class BloodSugarCard extends StatelessWidget {
  final String time;
  final String value;
  final bool isMeasured;
  final VoidCallback? onAddPressed;

  BloodSugarCard({required this.time, required this.value, required this.isMeasured, this.onAddPressed});

  Color _determineColor() {
    if (isMeasured) {
      int bloodSugarValue = int.tryParse(value) ?? 0;
      if ((time == '아침공복' && bloodSugarValue > 110) ||
          (time != '아침공복' && bloodSugarValue > 140)) {
        return Colors.red;
      } else {
        return Colors.lightBlue;
      }
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      color: _determineColor(),
      child: ListTile(
        title: Text(
          time,
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        trailing: isMeasured
            ? Text(
          value,
          style: TextStyle(color: Colors.black, fontSize: 32),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            SizedBox(width: 8.0),
            IconButton(
              icon: Icon(Icons.add, size: 25, color: Colors.black),
              onPressed: onAddPressed,
            ),
          ],
        ),
      ),
    );
  }
}
