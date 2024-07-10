import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bloodsugarhistory.dart';
import 'injectiondatahistory.dart';
import 'function3page.dart';

class PastDataPage extends StatefulWidget {
  @override
  _PastDataPageState createState() => _PastDataPageState();
}

class _PastDataPageState extends State<PastDataPage> {
  int _selectedIndex = 0;

  List<Widget> pages = [
    BloodSugarPage(),
    InjectionDataPage(),
    Function3Page(),
  ];

  List<String> titles = [
    '혈당',
    '인슐린',
    '기능 3',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('과거 데이터 조회'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(titles.length, (index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ChoiceChip(
                  label: Text(titles[index]),
                  selected: _selectedIndex == index,
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  selectedColor: Colors.green,
                  backgroundColor: Colors.grey,
                ),
              );
            }),
          ),
          Expanded(
            child: pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
