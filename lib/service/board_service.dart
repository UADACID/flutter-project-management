import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';

class BoardService {
  final box = GetStorage();
  Dio client = Client.init();

  String dynamicCompanyId = '';

  Future<Response> _getCompanyId(String moduleName, String moduleId) async {
    try {
      Response response = await client.get('/v2/$moduleName/$moduleId/company');
      if (response.data['companyId'] != null) {
        dynamicCompanyId = response.data['companyId'];

        client.options.queryParameters
            .addAll({'companyId': response.data['companyId']});
      }
      return Future.value(response);
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getCardEachList(String listId, int startIndex) async {
    return client.get('/v2/lists/$listId/cards?lastIndex=$startIndex');
  }

  Future<Response> getBoards(String boardId, int lastIndex, String teamId,
      {limitCard: 10, limitList: 10}) async {
    try {
      if (lastIndex > 0) {
        final Response response = await client.get(
            '/v2/boards/$boardId/lists?lastIndex=$lastIndex&teamId=$teamId&limitCard=$limitCard&limitList=$limitList');
        return response;
      }
      await _getCompanyId('boards', boardId);
      final Response response = await client.get(
          '/v2/boards/$boardId?teamId=$teamId&limitCard=$limitCard&limitList=$limitList');

      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getArchivedBoards(String boardId) async {
    try {
      await _getCompanyId('boards', boardId);
      final Response response =
          await client.get('/api/v1/boards/$boardId?filter=archived');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> createBoardList(String boardId, dynamic data) async {
    return client.post('/api/v1/lists', data: data);
  }

  Future<Response> createCard(String boardId, dynamic data) async {
    return client.post('/api/v1/cards', data: data);
  }

  Future<Response> archiveList(String listId, dynamic data) async {
    return client.patch('/api/v1/lists/$listId/archived', data: data);
  }

  Future<Response> unArchiveList(String listId, dynamic data) async {
    return client.patch('/api/v1/lists/$listId/unarchived', data: data);
  }

  Future<Response> archiveAllCardOnList(dynamic data) async {
    return client.patch('/api/v1/cards/archived', data: data);
  }

  Future<Response> archiveCard(String cardId) async {
    return client.patch('/api/v1/cards/$cardId/archived');
  }

  Future<Response> unArchiveCard(String cardId, dynamic data) async {
    return client.patch('/api/v1/cards/$cardId/unarchived', data: data);
  }

  Future<Response> updateListName(String listId, dynamic data) async {
    return client.patch('/api/v1/lists/$listId', data: data);
  }

  Future<Response> moveCard(dynamic data) async {
    return client.patch('/api/v1/cards/position', data: data);
  }

  Future<Response> moveList(dynamic data) async {
    return client.patch('/api/v1/lists/position', data: data);
  }

  Future<Response> getCardDetail(String cardId) async {
    try {
      await _getCompanyId('cards', cardId);
      final Response response = await client.get('/v2/cards/$cardId');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> updateCard(String cardId, dynamic data) async {
    return client.patch('/api/v1/cards/$cardId', data: data);
  }

  Future<Response> toggleLabel(String cardId, String labelId) async {
    return client.patch('/api/v1/cards/$cardId/labels/$labelId');
  }

  Future<Response> removeLabel(String labelId, dynamic data) async {
    return client.delete('/api/v1/labels/$labelId', data: data);
  }

  Future<Response> createLabel(dynamic data) async {
    return client.post('/api/v1/labels', data: data);
  }

  Future<Response> getColors() async {
    return client.get('/api/v1/colors');
  }

  Future<Response> addAttachments(
      String cardId, List<Attachments> items) async {
    FormData formData = FormData.fromMap({});
    for (var i = 0; i < items.length; i++) {
      formData.files.addAll([
        MapEntry("file",
            await MultipartFile.fromFile(items[i].url, filename: items[i].name))
      ]);
    }

    return client.post('/api/v1/cards/$cardId/attachments', data: formData);
  }

  Future<Response> addAttachment(String cardId, dynamic body) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(body['uri'], filename: body['name']),
    });
    return client.post('/api/v1/cards/$cardId/attachments', data: formData);
  }

  Future<Response> deleteAttachment(String cardId, String attachmentId) async {
    return client.delete('/api/v1/cards/$cardId/attachments/$attachmentId');
  }

  Future<Response> updateAttachment(
      String cardId, String attachmentId, dynamic body) async {
    return client.patch('/api/v1/cards/$cardId/attachments/$attachmentId',
        data: body);
  }

  Future<Response> updateMembers(String cardId, dynamic data) async {
    return client.post('/v2/cards/$cardId/members', data: data);
  }

  Future<Response> getAllListAndCard(String boardId, String teamId) async {
    try {
      await _getCompanyId('boards', boardId);
      final Response response = await client
          .get('/v2/boards/$boardId/lists/cards?teamId=$teamId&limitCard=0');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> setListAsComplete(String listId, dynamic data) {
    return client.post('/api/v1/lists/$listId/complete', data: data);
  }

  Future<Response> unSetListAsComplete(String listId, String boardId) {
    return client.delete('/api/v1/lists/$listId/complete?boardId=$boardId');
  }

  Future<Response> updateListAsComplete(String listId, dynamic data) {
    return client.patch('/api/v1/lists/$listId/complete', data: data);
  }

  Future<Response> getListItemByCardId(String cardId) async {
    return client.get('/v2/cards/$cardId/list');
  }
}
