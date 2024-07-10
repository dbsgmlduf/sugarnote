import 'package:flutter/material.dart';

class ExercisePage extends StatefulWidget {
  @override
  _ExercisePageState createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  List<Map<String, dynamic>> exerciseRecords = [];
  int totalCalories = 0;

  void _addExerciseRecord(String exercise, int calories) {
    setState(() {
      exerciseRecords.add({'exercise': exercise, 'calories': calories});
      totalCalories += calories;
    });
  }

  void _showAddExerciseDialog() {
    TextEditingController exerciseController = TextEditingController();
    TextEditingController caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('운동 기록 추가'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: exerciseController,
                decoration: InputDecoration(labelText: '운동 종류'),
              ),
              TextField(
                controller: caloriesController,
                decoration: InputDecoration(labelText: '소모 칼로리 (Kcal)'),
                keyboardType: TextInputType.number,
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
                String exercise = exerciseController.text;
                int calories = int.parse(caloriesController.text);
                _addExerciseRecord(exercise, calories);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                      title: Text(exerciseRecords[index]['exercise']),
                      trailing: Text('${exerciseRecords[index]['calories']} Kcal'),
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
