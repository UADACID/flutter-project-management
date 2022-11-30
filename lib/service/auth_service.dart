// import 'package:cicle_mobile_f3/utils/client.dart';
// import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart';

import '../utils/client.dart';
import '../utils/constant.dart';

class AuthService {
  final box = GetStorage();
  Dio client = Client.init();

  Future<Response> googleService(String serverCode) async {
    return client.get('/api/v1/auth/google/signin?code=$serverCode&mobile=1');
  }

  Future<Response> getAppleRedirectUrl() async {
    return client.get('/api/v1/auth/apple');
  }

  Future<Response> getGoogleRedirectUrl() async {
    return client.get('/v2/auth/google');
  }

  Future<Response> appleService(dynamic body) {
    return client.post(
      '/api/v1/auth/apple/signin/mobile',
      data: body,
    );
  }

  Future<Response> renewSession(
      String token, String deviceId, String companyId) {
    return client.post('/api/v1/sessions',
        data: {'deviceId': deviceId, 'companyId': companyId},
        options: Options(headers: {'Authorization': 'JWT $token'}));
  }

  Future<Response> refreshSession(String deviceId, String companyId) {
    return client.patch('/api/v1/sessions',
        data: {'deviceId': deviceId, 'companyId': companyId});
  }
}

Socket socketClient = io(
    Env.BASE_URL_SOCKET,
    OptionBuilder()
        .setTransports(['websocket']) // for Flutter or Dart VM
        .disableAutoConnect() // disable// optional
        .build());
