import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';
import 'package:get/route_manager.dart';

class PrivateChatService {
  Dio client = Client.init();

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

  Future<Response> getMessage(String chatId, dynamic queryParams) async {
    try {
      await _getCompanyId('chats', chatId);
      Response response =
          await client.get('/v2/chats/$chatId', queryParameters: queryParams);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> createMessage(String chatId, dynamic body) async {
    return client.post('/api/v1/chats/$chatId/messages', data: body);
  }

  Future<Response> addAttachment(String chatId, dynamic body,
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
    return client.post('/api/v1/chats/$chatId/attachments',
        data: formData,
        cancelToken: token, onSendProgress: (int sent, int total) {
      double prosen = (sent * 100) / total;
      print('send $prosen progress $sent $total');
      if (onSendProgress != null) {
        onSendProgress(prosen);
      }
    });
  }

  Future<Response> createNewChat(dynamic body) async {
    String _commpanyId = Get.parameters['companyId'] ?? '';

    client.options.queryParameters.addAll({'companyId': _commpanyId});

    return client.post('/api/v1/chats/', data: body);
  }

  Future<Response> deleteMessage(String chatId, String messageId) async {
    return client.delete('/api/v1/chats/$chatId/messages/$messageId');
  }

  Future<Response> deleteAttachment(String chatId, String messageId) async {
    return client.delete('/api/v1/chats/$chatId/attachments/$messageId');
  }
}
