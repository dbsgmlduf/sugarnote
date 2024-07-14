import 'package:flutter/material.dart';

class CounselingPage extends StatefulWidget {
  @override
  _CounselingPageState createState() => _CounselingPageState();
}

class _CounselingPageState extends State<CounselingPage> {
  final TextEditingController _questionController = TextEditingController();
  final List<Map<String, String>> _conversation = [];

  void _sendQuestion() {
    String question = _questionController.text;
    if (question.isEmpty) {
      return;
    }
    setState(() {
      _conversation.add({'role': 'user', 'content': question});
      _questionController.clear();
    });

    // 여기에 GPT API를 호출하는 로직을 추가할 수 있습니다.
    // 현재는 임시 응답을 추가해두었습니다.
    setState(() {
      _conversation.add({'role': 'bot', 'content': '이것은 GPT의 응답입니다.'});
    });
  }

  Widget _buildMessage(Map<String, String> message) {
    bool isUser = message['role'] == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message['content']!,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person),
            SizedBox(width: 8),
            Text('상담 서비스'),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: _conversation.length,
              itemBuilder: (context, index) {
                return _buildMessage(_conversation[index]);
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: '질문을 입력하세요...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendQuestion,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
