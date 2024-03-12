import 'AI_secrets.dart';
import 'ChatGPTService.dart';
import 'dart:convert';
/**/
class QwenBotService extends ChatGPTService{

  String apiUrl = qwen_apiUrl;
  String apiKey = qwen_apiKey;
  String model = 'qwen-turbo';
  @override
  String getDataContent(data) {
    return data['output']['text'];
  }
  @override
  String getBody(message){
    var body = jsonEncode (
        {
          "model": model,
          "input":{
            "messages":[
              {
                "role": "system",
                "content": "You are a helpful assistant."
              },
              {
                "role": "user",
                "content": message
              }
            ]
          },
          "parameters": {
          }
        });
    return body;
  }
  List<String> getMessageModels(){
    return 'qwen-turbo、qwen-plus、qwen-max、qwen-max-1201、qwen-max-longcontext'.split('、');
  }
  void setMessageModel([model]){
    if(model != null){
      this.model = model;
    }else{
      this.model = 'qwen-max-1201';
    }
  }
}