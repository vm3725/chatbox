// ChatGPT服务类
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'AI.dart';
import 'AI_secrets.dart';
class ErnieBotService implements AI {
  String apiUrl = ernie_apiUrl;
  String apiUrlAll = ernie_apiUrlAll;
  String apiTokenUrl = ernie_apiTokenUrl;
  String apiTokenUrlAll = ernie_apiTokenUrl;

  String grant_type = '';
  String client_id = '';
  String client_secret = '';
  String access_token = '';

  @override
  Future<String> fetchReply(String message) async {
    // Uri uri = Uri.parse(apiTokenUrl);
    var headers = {
      'Content-Type': 'application/json; charset=UTF-8'
    };
    // var params = {
    //   "grant_type": "client_credentials",
    //   "client_id": client_id,
    //   "client_secret": client_secret
    // };
    // uri.replace(queryParameters: params);
    // print('url: $uri');
    try {
      final response = await http.get(Uri.parse(apiTokenUrl),headers: headers);
      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        final data = jsonDecode(response.body);
        access_token = data['access_token'];
      } else {
        throw Exception('Failed to fetch reply from ChatGPT API');
      }
    } catch (e) {
      print('Error1: $e');
      return 'token 获取失败';
    }
    headers = {
      'Content-Type': 'application/json; charset=UTF-8'
    };
    // final body = jsonEncode({'message': message});
    final body = jsonEncode ({
      "messages": [
        {
          "role": "user",
          "content": message
        }
      ]
    });
    var uri = Uri.parse(apiUrlAll);
    var params = {
      "access_token": 'YOUR_API_token'
    };
    // uri.replace(queryParameters: params);
    // uri = Uri.http(apiUrl, '/path', params);
    try {
      final response = await http.post(uri,headers: headers, body: body);
      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        final data = jsonDecode(response.body);
        print(data);
        return  data['result'];
      } else {
        throw Exception('Failed to fetch reply from ChatGPT API');
      }
    } catch (e) {
      print('Error: $e');
      return 'Error';
    }
  }
  @override
  List<String> getMessageModels() {
    // TODO: implement getMessageModels
    return 'qwen-turbo、qwen-plus、qwen-max、qwen-max-1201、qwen-max-longcontext'.split('、');
  }

  @override
  setMessageModel([model]) {

  }
}