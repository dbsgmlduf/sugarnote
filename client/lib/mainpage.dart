import 'package:client/mainPages/counselingpage.dart';
import 'package:client/mainPages/homescreen.dart';
import 'package:client/mainPages/settingscreen.dart';

import 'package:flutter/material.dart';
class Mainpage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<Mainpage>{
  int _selectedIndex=0;
  List<BottomNavigationBarItem> bottomItems=[
    BottomNavigationBarItem(
        label: '홈',
        icon: Icon(Icons.home)
    ),
    BottomNavigationBarItem(
        label: '상담',
        icon: Icon(Icons.people)
    ),
    BottomNavigationBarItem(
        label: '마이페이지',
        icon: Icon(Icons.settings)
    )
  ];
  List pages =[
    Homescreen(),
    CounselingPage(),
    SettingScreen(),
  ];
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text('오늘의 당'),),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey.withOpacity(.60),
        selectedFontSize: 14,
        unselectedFontSize: 10,
        currentIndex: _selectedIndex,
        onTap: (int index){
          setState(() {
            _selectedIndex = index;
          });
        },
          items: bottomItems
      ),

      body: pages[_selectedIndex],
    );
  }
}