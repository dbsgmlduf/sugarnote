import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExerciseHistoryPage extends StatefulWidget {
  @override
  _ExerciseHistoryPageState createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  DateTime selectedDate = DateTime.now();
  List<Map<String, dynamic>> exerciseRecords = [];
  int totalCalories = 0;

  void _fetchExerciseData(DateTime date) {
    // 여기에 실제 데이터를 가져오는 로직을 추가해야 합니다.
    // 지금은 예시로 더미 데이터를 사용합니다.
    if (date.day % 2 == 0) {
      setState(() {
        exerciseRecords = [
          {'exercise': '걷기', 'calories': 100},
          {'exercise': '달리기', 'calories': 200},
        ];
        totalCalories = 300;
      });
    } else {
      setState(() {
        exerciseRecords = [];
        totalCalories = 0;
      });
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
  void initState() {
    super.initState();
    _fetchExerciseData(selectedDate);
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
                      title: Text(exerciseRecords[index]['exercise']),
                      trailing: Text('${exerciseRecords[index]['calories']} Kcal'),
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
}
