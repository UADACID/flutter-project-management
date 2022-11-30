import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';

class DocFileService {
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
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> getBuckets(String bucketId) async {
    try {
      await _getCompanyId('buckets', bucketId);
      Response response = await client.get('/api/v1/buckets/$bucketId');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> uploadImageEditor(dynamic body) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(body['uri'], filename: body['name']),
    });
    return client.post('/api/v1/editor-uploads/image', data: formData);
  }

  defaultFunc() {}

  Future<Response> uploadFileEditor(dynamic body,
      [Function(double prosen)? onSendProgress]) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(body['uri'], filename: body['name']),
    });
    return client.post('/api/v1/editor-uploads/file', data: formData,
        onSendProgress: (int sent, int total) {
      double prosen = (sent * 100) / total;
      print('send $prosen progress $sent $total');
      if (onSendProgress != null) {
        onSendProgress(prosen);
      }
    }, onReceiveProgress: (int sent, int total) {
      print('receive progress $sent $total');
    });
  }

  Future<Response> uploadVideoEditor(dynamic body) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(body['uri'], filename: body['name']),
    });
    return client.post('/api/v1/editor-uploads/video', data: formData);
  }

  Future<Response> getDoc(String docId) async {
    try {
      await _getCompanyId('docs', docId);
      Response response = await client.get('/api/v1/docs/$docId');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> archiveDoc(String docId) async {
    return client.patch('/api/v1/docs/$docId/archived');
  }

  Future<Response> archiveFile(String fileId) async {
    return client.patch('/api/v1/files/$fileId/archived');
  }

  Future<Response> archiveBucket(String bucketId) async {
    return client.patch('/api/v1/buckets/$bucketId/archived');
  }

  Future<Response> getFile(String fileId) async {
    try {
      await _getCompanyId('files', fileId);
      Response response = await client.get('/api/v1/files/$fileId');
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> updateFile(String fileId, dynamic body) async {
    return client.patch('/api/v1/files/$fileId', data: body);
  }

  Future<Response> fileToggleMembers(String fileId, dynamic body) async {
    return client.post('/v2/files/$fileId/members', data: body);
  }

  Future<Response> docToggleMembers(String docId, dynamic body) async {
    return client.post('/v2/docs/$docId/members', data: body);
  }

  Future<Response> createDoc(String bucketId, dynamic body) async {
    try {
      await _getCompanyId('buckets', bucketId);
      Response response =
          await client.post('/api/v1/buckets/$bucketId/docs', data: body);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> updateDoc(String docId, dynamic body) async {
    return client.patch('/api/v1/docs/$docId', data: body);
  }

  Future<Response> createBucket(dynamic body, String bucketId) async {
    try {
      await _getCompanyId('buckets', bucketId);
      Response response = await client.post('/api/v1/buckets/', data: body);
      return response;
    } catch (e) {
      return Future.error(e);
    }
  }

  Future<Response> createFile(String bucketId, dynamic body,
      [Function(double prosen)? onSendProgress,
      Function(CancelToken cancelToken)? getToken]) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(body['uri'], filename: body['name']),
    });
    CancelToken token = CancelToken();
    if (getToken != null) {
      getToken(token);
    }

    await _getCompanyId('buckets', bucketId);

    return client.post('/api/v1/buckets/$bucketId/files',
        cancelToken: token,
        data: formData, onSendProgress: (int sent, int total) {
      double prosen = (sent * 100) / total;
      print('send $prosen progress $sent $total');
      if (onSendProgress != null) {
        onSendProgress(prosen);
      }
    });
  }

  Future<Response> updateFolderTitle(String bucketId, dynamic body) async {
    return client.patch('/api/v1/buckets/$bucketId', data: body);
  }

  Future<Response> updateFolder(String bucketId, dynamic body) async {
    return client.patch('/api/v1/buckets/$bucketId', data: body);
  }
}
