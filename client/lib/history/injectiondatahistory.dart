import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InjectionDataPage extends StatefulWidget {
  @override
  _InjectionDataPageState createState() => _InjectionDataPageState();
}

class _InjectionDataPageState extends State<InjectionDataPage> {
  DateTime selectedDate = DateTime.now();
  Map<int, bool> injectionData = {};
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  @override
  void initState() {
    super.initState();
    _fetchInjectionData(); // 앱이 시작될 때 데이터 가져오기
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          SizedBox(height: 20),
          ListTile(
            title: Text("Select year and month"),
            subtitle: Text(DateFormat.yMMMM().format(DateTime(selectedYear, selectedMonth))),
            trailing: Icon(Icons.edit),
            onTap: _pickDate,
          ),
          SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              itemCount: 31,
              itemBuilder: (context, index) {
                return CircleAvatar(
                  radius: 14,
                  backgroundColor: injectionData[index + 1] == true ? Colors.green : Colors.grey,
                  child: Text('${index + 1}', style: TextStyle(fontSize: 12)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDialog<List<int>>(
      context: context,
      builder: (BuildContext context) {
        int tempYear = selectedYear;
        int tempMonth = selectedMonth;
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text("Select year and month"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<int>(
                    value: tempYear,
                    items: List.generate(101, (index) => 2020 + index).map((year) {
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        tempYear = value!;
                      });
                    },
                  ),
                  DropdownButton<int>(
                    value: tempMonth,
                    items: List.generate(12, (index) => index + 1).map((month) {
                      return DropdownMenuItem(
                        value: month,
                        child: Text(month.toString()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        tempMonth = value!;
                      });
                    },
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop([tempYear, tempMonth]);
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null && picked is List<int> && picked.length == 2) {
      setState(() {
        selectedYear = picked[0];
        selectedMonth = picked[1];
        selectedDate = DateTime(selectedYear, selectedMonth);
        _fetchInjectionData(); // 데이터 가져오기
      });
    }
  }

  Future<void> _fetchInjectionData() async {
    final user_no = 3; // 임시로 저장된 사용자 번호
    final measure_date = DateFormat('yyyy-MM-15').format(DateTime(selectedYear, selectedMonth)); // YYYY-MM-15 형식

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
          final injectionValues = data['injection'].split(',');
          setState(() {
            injectionData = {
              for (int i = 0; i < injectionValues.length; i++)
                i + 1: injectionValues[i] != '0'
            };
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
}
