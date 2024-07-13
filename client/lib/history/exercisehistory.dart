import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:client/shared_preferences_helper.dart'; // SharedPreferencesHelper 임포트

class ExerciseHistoryPage extends StatefulWidget {
  @override
  _ExerciseHistoryPageState createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> exerciseRecords = [];
  int totalCalories = 0;

  @override
  void initState() {
    super.initState();
    _fetchExerciseData(selectedDate);
  }

  Future<void> _fetchExerciseData(DateTime date) async {
    final user_no = await SharedPreferencesHelper.getUserNo(); // SharedPreferences에서 user_no 가져오기
    final measure_date = DateFormat('yyyy-MM-dd').format(date);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/get_exercise'),
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
        if (data[0]['message'] == '1') {
          setState(() {
            exerciseRecords = List<Map<String, dynamic>>.from(data[1]['exercise_details']);
            totalCalories = (data[1]['total_kcal'] as num).round(); // num을 int로 변환
          });
        } else {
          setState(() {
            exerciseRecords = [];
            totalCalories = 0;
          });
          print('Failed to fetch exercise data: ${data[0]['message']}');
        }
      } else {
        setState(() {
          exerciseRecords = [];
          totalCalories = 0;
        });
        print('Failed to fetch exercise data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        exerciseRecords = [];
        totalCalories = 0;
      });
      print('Error fetching exercise data: $e');
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
        _fetchExerciseData(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('운동 기록 조회'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: Text("Select date"),
              subtitle: Text(DateFormat.yMMMEd().format(selectedDate)),
              trailing: Icon(Icons.edit),
              onTap: _pickDate,
            ),
            SizedBox(height: 20),
            Expanded(
              child: Container(
                color: Colors.white,
                child: exerciseRecords.isEmpty
                    ? Center(child: Text('기록이 없습니다.'))
                    : ListView.builder(
                  itemCount: exerciseRecords.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(_getIconForExercise(exerciseRecords[index]['exercise'])),
                      title: Text(exerciseRecords[index]['exercise']),
                      trailing: Text('${exerciseRecords[index]['kcal']} Kcal'),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              '소모한 총 칼로리',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '$totalCalories Kcal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForExercise(String exercise) {
    switch (exercise) {
      case 'CYCLING':
        return Icons.directions_bike;
      case 'SWIMMING':
        return Icons.pool;
      case 'Bodyweight':
        return Icons.fitness_center;
      case 'Fitness':
        return Icons.fitness_center;
      case 'Running':
        return Icons.directions_run;
      case 'SOCCER':
        return Icons.sports_soccer;
      default:
        return Icons.fitness_center;
    }
  }
}
