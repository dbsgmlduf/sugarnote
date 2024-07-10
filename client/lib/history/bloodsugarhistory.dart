import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BloodSugarPage extends StatefulWidget {
  @override
  _BloodSugarPageState createState() => _BloodSugarPageState();
}

class _BloodSugarPageState extends State<BloodSugarPage> {
  DateTime selectedDate = DateTime.now();
  Map<String, int> bloodSugarData = {
    '아침 공복': -1,
    '아침 식후': -1,
    '점심 공복': -1,
    '점심 식후': -1,
    '저녁 공복': -1,
    '저녁 식후': -1,
  };

  final Map<String, int> normalRanges = {
    '아침 공복': 110,
    '아침 식후': 140,
    '점심 공복': 110,
    '점심 식후': 140,
    '저녁 공복': 110,
    '저녁 식후': 140,
  };

  @override
  void initState() {
    super.initState();
    _fetchBloodSugarData();
  }

  Future<void> _fetchBloodSugarData() async {
    final user_no = 1; // 임시로 저장된 사용자 번호
    final measure_date = DateFormat('yyyy-MM-dd').format(selectedDate);

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
          final bloodSugarValues = data['blood_sugar'].split(',').map(int.parse).toList();
          setState(() {
            bloodSugarData = {
              '아침 공복': bloodSugarValues[0],
              '아침 식후': bloodSugarValues[1],
              '점심 공복': bloodSugarValues[2],
              '점심 식후': bloodSugarValues[3],
              '저녁 공복': bloodSugarValues[4],
              '저녁 식후': bloodSugarValues[5],
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

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _fetchBloodSugarData();
      });
    }
  }

  bool _isBloodSugarHigh(String time, int value) {
    if (value == -1) {
      return false;
    }
    return value > (normalRanges[time] ?? 140);
  }

  Color _determineCardColor(String time, int value) {
    if (value == -1) {
      return Colors.grey;
    }
    if (_isBloodSugarHigh(time, value)) {
      return Colors.red;
    }
    return Colors.lightBlue;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          ListTile(
            title: Text("Select date"),
            subtitle: Text(DateFormat.yMMMEd().format(selectedDate)),
            trailing: Icon(Icons.edit),
            onTap: _pickDate,
          ),
          SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: bloodSugarData.entries.map((entry) {
                Color cardColor = _determineCardColor(entry.key, entry.value);
                return Card(
                  color: cardColor,
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text(entry.key),
                    trailing: Text(
                      entry.value == -1
                          ? '측정하지 않았습니다'
                          : '${entry.value} mg/dL',
                      style: TextStyle(color: cardColor == Colors.red ? Colors.white : Colors.black),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "공복 혈당은 8시간 이상의 금식 후 아침 공복 상태에서 측정해요. "
                      "정상인은 결과가 110mg/dL 이하로 측정되요. "
                      "식후 2시간 혈당은 식사 시작 시점부터 2시간 후 측정한 혈당을 말해요. "
                      "140mg/dL 이하가 정상이에요.",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
