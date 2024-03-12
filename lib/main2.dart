import 'dart:convert';
import 'package:flutter/material.dart';
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

  // 创建一个AIProvider工厂实例
  final AIProvider _aiProvider = AIProvider();

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
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: EdgeInsets.all(16.0),
        padding: EdgeInsets.all(16.0),
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
              color: isUserMessage ? Colors.blue : Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(message.text),
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _messages.insert(0, Message(text, isBot: false));
    });
    _fetchReplyFromAI(text);
  }

  Future<void> _fetchReplyFromAI(String message) async {
    try {
      final reply = await _aiProvider.getAI('ChatGPT').fetchReply(message);
      setState(() {
        _messages.insert(0, Message(reply, isBot: true));
      });
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

// AIProvider工厂类
class AIProvider {
  AIProvider();

  // 根据类型返回相应的AI服务实例
  AI getAI(String type) {
    if (type == 'ChatGPT') {
      return ChatGPTService('YOUR_CHATGPT_API_URL', 'YOUR_API_KEY');
    } else {
      throw Exception('Unsupported AI type');
    }
  }
}

// 抽象AI接口
abstract class AI {
  Future<String> fetchReply(String message);
}

// ChatGPT服务类
class ChatGPTService implements AI {
  final String apiUrl;
  final String apiKey;

  ChatGPTService(this.apiUrl, this.apiKey);

  @override
  Future<String> fetchReply(String message) async {
    final headers = {
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $apiKey',
    };
    final body = jsonEncode({'message': message});

    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply']; // 假设服务器返回的数据中有一个名为'reply'的字段，表示回复消息
      } else {
        throw Exception('Failed to fetch reply from ChatGPT API');
      }
    } catch (e) {
      print('Error: $e');
      // 处理错误情况
      return 'Error';
    }
  }
}
