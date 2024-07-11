import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExercisePage extends StatefulWidget {
  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  List<Map<String, dynamic>> exerciseRecords = [];
  int totalCalories = 0;

  @override
  void initState() {
    super.initState();
    _fetchExerciseData(); // 앱이 시작될 때 데이터 가져오기
  }

  Future<void> _fetchExerciseData() async {
    final user_no = 4; // 임시로 저장된 사용자 번호
    final measure_date = DateTime.now().toIso8601String().split('T')[0]; // 오늘 날짜

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
          print('Failed to fetch exercise data: ${data[0]['message']}');
        }
      } else {
        print('Failed to fetch exercise data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching exercise data: $e');
    }
  }

  Future<void> _addExerciseRecord(String exercise, int exerciseTime) async {
    final user_no = 4; // 임시로 저장된 사용자 번호
    final measure_date = DateTime.now().toIso8601String().split('T')[0]; // 오늘 날짜

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:5000/add_exercise'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'user_no': user_no,
          'exercise': exercise,
          'exercise_time': exerciseTime,
          'measure_date': measure_date,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        setState(() {
          exerciseRecords.add({
            'exercise': exercise,
            'exercise_time': exerciseTime,
            'kcal': (data['kcal'] as num).round() // num을 int로 변환
          });
          totalCalories += (data['kcal'] as num).round(); // num을 int로 변환
        });
      } else {
        print('Failed to add exercise data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error adding exercise data: $e');
    }
  }

  void _showAddExerciseDialog() {
    String selectedExercise = '사이클';
    int exerciseTime = 0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('운동 기록 추가'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedExercise,
                    items: [
                      DropdownMenuItem(value: '사이클', child: Text('사이클')),
                      DropdownMenuItem(value: '수영', child: Text('수영')),
                      DropdownMenuItem(value: '맨몸운동', child: Text('맨몸운동')),
                      DropdownMenuItem(value: '웨이트', child: Text('웨이트')),
                      DropdownMenuItem(value: '달리기', child: Text('달리기')),
                      DropdownMenuItem(value: '축구', child: Text('축구')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedExercise = value!;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            if (exerciseTime > 0) exerciseTime--;
                          });
                        },
                      ),
                      Text('$exerciseTime 분'),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            exerciseTime++;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('취소'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('저장'),
                  onPressed: () {
                    String exercise;
                    switch (selectedExercise) {
                      case '사이클':
                        exercise = 'CYCLING';
                        break;
                      case '수영':
                        exercise = 'SWIMMING';
                        break;
                      case '맨몸운동':
                        exercise = 'Bodyweight';
                        break;
                      case '웨이트':
                        exercise = 'Fitness';
                        break;
                      case '달리기':
                        exercise = 'Running';
                        break;
                      case '축구':
                        exercise = 'SOCCER';
                        break;
                      default:
                        exercise = 'CYCLING';
                    }
                    _addExerciseRecord(exercise, exerciseTime);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '기록',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: exerciseRecords.isEmpty
                    ? Center(child: Text('현재 기록 없음'))
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
              '오늘 소모한 칼로리',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '$totalCalories Kcal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddExerciseDialog,
              icon: Icon(Icons.add),
              label: Text('기록 입력하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple, // 배경색 설정
                foregroundColor: Colors.white, // 글자 색상 설정
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
