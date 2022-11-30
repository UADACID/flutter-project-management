import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';

class GroupChatService {
  Dio client = Client.init();

  String dynamicCompanyId = '';

  Future<Response> _getCompanyId(String moduleName, String moduleId) async {
    try {
      Response response = await client.get('/v2/$moduleName/$moduleId/company');
      if (response.data['companyId'] != null) {
        client.options.queryParameters
            .addAll({'companyId': response.data['companyId']});
      }
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getMessages(
      String groupChatId, Map<String, dynamic> queryParams) async {
    try {
      await _getCompanyId('group-chats', groupChatId);

      Response response = await client.get('/v2/group-chats/$groupChatId',
          queryParameters: queryParams);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> createMessage(String groupChatId, dynamic body) async {
    return client.post('/api/v1/group-chats/$groupChatId/messages', data: body);
  }

  Future<Response> addAttachment(String groupChatId, dynamic body,
      [Function(double prosen)? onSendProgress,
      Function(CancelToken cancelToken)? getToken]) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(body['uri'],
          filename: body['name'], contentType: body['ext']),
    });
    CancelToken token = CancelToken();
    if (getToken != null) {
      getToken(token);
    }
    return client.post('/api/v1/group-chats/$groupChatId/attachments',
        data: formData,
        cancelToken: token, onSendProgress: (int sent, int total) {
      double prosen = (sent * 100) / total;
      print('send $prosen progress $sent $total');
      if (onSendProgress != null) {
        onSendProgress(prosen);
      }
    });
  }

  Future<Response> deleteMessage(String groupChatId, String messageId) async {
    return client
        .delete('/api/v1/group-chats/$groupChatId/messages/$messageId');
  }

  Future<Response> deleteAttachment(
      String groupChatId, String messageId) async {
    return client
        .delete('/api/v1/group-chats/$groupChatId/attachments/$messageId');
  }
  //
}
