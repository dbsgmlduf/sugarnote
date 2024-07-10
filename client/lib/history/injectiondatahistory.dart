import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InjectionDataPage extends StatefulWidget {
  @override
  _InjectionDataPageState createState() => _InjectionDataPageState();
}

class _InjectionDataPageState extends State<InjectionDataPage> {
  DateTime selectedDate = DateTime.now();
  Map<int, bool> injectionData = {};

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
              itemCount: 32,
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
        // 여기에 실제 데이터 로직을 추가하십시오.
        injectionData = {};
      });
    }
  }
}
