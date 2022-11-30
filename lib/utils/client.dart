// import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/controllers/auth_controller.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
// import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'constant.dart';

class Client {
  static Dio init() {
    Dio _dio = new Dio();
    _dio.interceptors.add(new ApiInterceptors());
    _dio.options.baseUrl = Env.BASE_URL;
    return _dio;
  }
}

class ApiInterceptors extends Interceptor {
  final box = GetStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    String? token = box.read(KeyStorage.token);

    if (token != null) {
      options.headers = {"Authorization": "JWT $token"};
    }

    if (options.method == 'GET') {
      options.connectTimeout = 180 * 1000;
    }
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    return super.onRequest(options, handler);
  }

  @override
  Future onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    return super.onResponse(response, handler);
  }

  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) async {
    int? statusCode = err.response?.statusCode;
    if (statusCode != null) {
      bool isModuleNameInvites = err.requestOptions.path.contains('invites');
      if (statusCode == 401 && isModuleNameInvites == false) {
        showAlert(
            message:
                '${err.message}, you will be redirected to the sign-in page after 3 seconds ',
            messageColor: Colors.red);

        await Future.delayed(Duration(seconds: 3));
        Get.put(AuthController()).handleSignOut();
        // return;
      }
    }
    return super.onError(err, handler);
  }
}
