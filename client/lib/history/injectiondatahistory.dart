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
            subtitle: Text(DateFormat.yMMMM().format(selectedDate)),
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
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return child ?? Text('No date selected');
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _fetchInjectionData(); // 데이터 가져오기
      });
    }
  }

  Future<void> _fetchInjectionData() async {
    final user_no = 3; // 임시로 저장된 사용자 번호
    final measure_date = DateFormat('yyyy-MM-01').format(selectedDate); // 월의 첫날을 사용

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
