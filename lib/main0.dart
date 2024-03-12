import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChatGPT Demo',
      theme: ThemeData(
        primaryColor: Colors.blue,
      ),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<Message> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ChatGPT Demo'),
        actions: [IconButton(icon: Icon(Icons.settings), onPressed: () {})],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16.0), // 添加圆角背景
        ),
        margin: EdgeInsets.all(16.0), // 添加外边距
        padding: EdgeInsets.all(16.0), // 添加内边距
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: _messages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            SizedBox(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  IconButton(icon: Icon(Icons.settings), onPressed: () {}),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Send a message',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_textController.text),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Message message) {
    final isUserMessage = !message.isBot;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              CircleAvatar(
                child: isUserMessage ? Icon(Icons.person) : Icon(Icons.android),
              ),
              SizedBox(width: 8.0),
              Text('Name'),
            ],
          ),
          SizedBox(height: 4.0),
          Container(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            decoration: BoxDecoration(
              // color: isUserMessage ? Colors.blue : Colors.white, // 修改聊天内容背景颜色
              borderRadius: BorderRadius.circular(8.0),
              // boxShadow: [
              //   BoxShadow(
              //     color: Colors.grey.withOpacity(0.5),
              //     spreadRadius: 1,
              //     blurRadius: 3,
              //     offset: Offset(0, 2),
              //   ),
              // ],
            ),
            child: Text(message.text),
          ),
        ],
      ),
    );
  }

  // void _handleSubmitted(String text) {
  //   _textController.clear();
  //   setState(() {
  //     _messages.insert(0, Message(text, isBot: false));
  //     // 模拟AI自动回复
  //     _messages.insert(0, Message('AI Reply', isBot: true));
  //   });
  // }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _messages.insert(0, Message(text, isBot: false));
    });
    _fetchReplyFromChatGPT(text);
  }

  Future<void> _fetchReplyFromChatGPT(String message) async {
    final url = 'YOUR_CHATGPT_API_URL'; // 请替换为你的ChatGPT API URL
    final apiKey = 'YOUR_API_KEY'; // 请替换为你的API密钥
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $apiKey',
    };
    // final body = jsonEncode({'message': message});
    final body = jsonEncode (
        {'model': 'gpt-3.5-turbo',
      "messages": [
        {
          "role": "user",
          "content": message
        }
        ]});

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);
      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        final data = jsonDecode(utf8.decode(response.body.codeUnits));
        final replyMessage = data['choices'][0]['message']['content'];
        setState(() {
          _messages.insert(0, Message(replyMessage, isBot: true));
        });
      } else {
        throw Exception('Failed to fetch reply from ChatGPT API');
      }
    } catch (e) {
      print('Error: $e');
      // 处理错误情况
    }
  }
}

class Message {
  final String text;
  final bool isBot;

  Message(this.text, {this.isBot = false});
}
