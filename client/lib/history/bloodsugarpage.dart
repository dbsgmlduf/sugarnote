import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BloodSugarPage extends StatefulWidget {
  @override
  _BloodSugarPageState createState() => _BloodSugarPageState();
}

class _BloodSugarPageState extends State<BloodSugarPage> {
  DateTime selectedDate = DateTime.now();
  Map<String, int> bloodSugarData = {
    '아침 공복': 0,
    '아침 식후': 0,
    '점심 공복': 0,
    '점심 식후': 0,
    '저녁 공복': 0,
    '저녁 식후': 0,
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
                bool isHigh = _isBloodSugarHigh(entry.key, entry.value);
                return Card(
                  color: isHigh ? Colors.red : Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    title: Text(entry.key),
                    trailing: Text(
                      entry.value == 0 ? '측정된 데이터가 없습니다.' : '${entry.value} mg/dL',
                      style: TextStyle(color: isHigh ? Colors.white : Colors.black),
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
        // 여기에 더미 데이터를 사용한 로직을 추가합니다.
        bloodSugarData = _getDummyDataForDate(picked);
      });
    }
  }

  Map<String, int> _getDummyDataForDate(DateTime date) {
    if (date.day % 2 == 0) {
      return {
        '아침 공복': 110,
        '아침 식후': 190,
        '점심 공복': 100,
        '점심 식후': 120,
        '저녁 공복': 105,
        '저녁 식후': 115,
      };
    } else {
      return {
        '아침 공복': 0,
        '아침 식후': 0,
        '점심 공복': 0,
        '점심 식후': 0,
        '저녁 공복': 0,
        '저녁 식후': 0,
      };
    }
  }

  bool _isBloodSugarHigh(String time, int value) {
    if (value == 0) {
      return false;
    }
    return value > (normalRanges[time] ?? 140);
  }
}
