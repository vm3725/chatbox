import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'AI.dart';
import 'ChatGPTService.dart';
import 'ErnieBotService.dart';
import 'QwenBotService.dart';
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
  AI _aiProvider = AIProvider("ChatGPT").getAI();

  String _appBarTitle = 'ChatGPT'; // 初始标题

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        // actions: [IconButton(icon: Icon(Icons.settings), onPressed: () {})],
        actions: [IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            _showPopupMenu(context);
          },
        ),
        ],
        leading: PopupMenuButton<String>(
          onSelected: (String setting) {
            setState(() {
              // _appBarTitle = setting;
              // _appBarTitle = setting == 'QwenBot' ? '通义千问' : setting; // 更新标题
              _aiProvider.setMessageModel(setting);
            });

          },
          itemBuilder: (BuildContext context) {
            var aiModels = _aiProvider.getMessageModels();
            return List.generate(aiModels.length, (index) {
              return PopupMenuItem<String>(
                value: aiModels[index],
                child: Text(aiModels[index]),
              );
            });
          },
      ),
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
                  IconButton(icon: Icon(Icons.settings), onPressed: () => _showAISelectionMenu(context)),
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
  void _showAISelectionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: aiTypes.length,
          itemBuilder: (BuildContext context, int index) {
            String aiType = aiTypes[index];
            String aiTitle = aiTitles[index];
            return ListTile(
              leading: _buildIcon(aiType),
              title: Text(aiTitle),
              onTap: () {
                setState(() {
                  _appBarTitle = aiTitle; // 更新标题
                  _aiProvider = AIProvider(aiType).getAI(); // 更新 AIProvider
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
  void _showPopupMenu(BuildContext context) {
    var aiModels = _aiProvider.getMessageModels();
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(100, AppBar().preferredSize.height, 0, 100),
      items: List.generate(aiModels.length, (index) {
        return PopupMenuItem<String>(
          value: aiModels[index],
          child: Text(aiModels[index]),
        );
      }),
      elevation: 8.0,
    ).then((value) {
      if (value != null) {
        setState(() {
          _aiProvider.setMessageModel(value);
        });
      }
    });
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
                child: isUserMessage ? const Icon(Icons.person) : const Icon(Icons.android),
              ),
              const SizedBox(width: 8.0),
              Text(isUserMessage ? 'user': _appBarTitle),
            ],
          ),
          const SizedBox(height: 4.0),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
      final reply = await _aiProvider.fetchReply(message);
      setState(() {
        _messages.insert(0, Message(reply, isBot: true));
      });
    } catch (e) {
      print('Error: $e');
      // 处理错误情况
    }
  }


  Widget _buildIcon(String aiType) {
    switch (aiType) {
      case 'ChatGPT':
        return const Icon(Icons.chat);
      case 'ErnieBot':
        return const Icon(Icons.android);
      case 'QwenBot':
        return const Icon(Icons.question_answer);
      default:
        return const Icon(Icons.help);
    }
  }

  final List<String> aiTypes = ['ChatGPT', 'ErnieBot', 'QwenBot'];
  final List<String> aiTitles = ['ChatGPT', '文心一言', '通义千问'];
}

class Message {
  final String text;
  final bool isBot;

  Message(this.text, {this.isBot = false});
}

// AIProvider工厂类
class AIProvider {
  String type;
  AIProvider(this.type){}
  // 根据类型返回相应的AI服务实例
  AI getAI() {
    if (type == 'ChatGPT') {
      return ChatGPTService();
    } else if (type == 'ErnieBot') {
      return ErnieBotService();
    } else if (type == 'QwenBot') {
      return QwenBotService();
    }else{
      throw Exception('Unsupported AI type');
    }
  }
}




