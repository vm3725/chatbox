// ChatGPT服务类
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'AI.dart';
class ChatGPTService implements AI {
  String apiUrl = 'https://chat.openai.com/v1/chat/completions';
  String apiKey = 'YOUR_API_KEY'; // 请替换为你的API密钥
  String model = 'gpt-3.5-turbo';
  ChatGPTService([apiUrl,apiKey]){
    if(apiUrl != null){
      this.apiUrl = apiUrl;
    }
    if(apiKey != null){
      this.apiKey = apiKey;
    }
  }


  @override
  Future<String> fetchReply(String message) async {
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $apiKey',
    };
    // final body = jsonEncode({'message': message});
    final body = getBody(message);

    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers, body: body);
      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        final data = jsonDecode(utf8.decode(response.body.codeUnits));
        final replyMessage = getDataContent(data);
        return replyMessage;
      } else {
        throw Exception('Failed to fetch reply from ChatGPT API');
      }
    } catch (e) {
      print('Error: $e');
      // 处理错误情况
      return 'Error';
    }
  }
  String getDataContent(data){
    return data['choices'][0]['message']['content'];
  }
  String getBody(message){
    final body = jsonEncode (
        {'model': model,
          "messages": [
            {
              "role": "user",
              "content": message
            }
          ]});
    return body;
  }
  @override
  List<String> getMessageModels(){
    return 'gpt-3.5-turbo'.split('、');
  }

  @override
  setMessageModel([model]) {
    if(model != null){
      this.model = model;
    }else{
      this.model = 'gpt-3.5-turbo';
    }
  }
}