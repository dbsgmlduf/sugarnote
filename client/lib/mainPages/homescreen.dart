import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 포맷을 위해 필요합니다.
import '../detailfeature/bloodsugarpage.dart';
import '../detailfeature/injectionpage.dart';
import '../detailfeature/exercisepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Homescreen(),
    );
  }
}

class Homescreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Homescreen> {
  int _currentIndex = 0;
  PageController _pageController = PageController();

  List<String> pageTitles = ['오늘의 혈당', '인슐린 기록','운동량 기록'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitles[_currentIndex], style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.lightGreenAccent,
        elevation: 0,
        centerTitle: true, // 제목을 가운데로 오게 설정
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            children: [
              BloodSugarPage(),
              InjectionPage(),
              ExercisePage()
            ],
          ),
          Positioned(
            bottom: 5.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPageIndicator(0),
                SizedBox(width: 8.0),
                _buildPageIndicator(1),
                SizedBox(width: 8.0),
                _buildPageIndicator(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return Container(
      width: 10.0,
      height: 10.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentIndex == index ? Colors.black : Colors.grey,
      ),
    );
  }
}
