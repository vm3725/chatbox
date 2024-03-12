// 抽象AI接口
abstract class AI {
  Future<String> fetchReply(String message);
  List<String> getMessageModels();
  setMessageModel([model]);
}

