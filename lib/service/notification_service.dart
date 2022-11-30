import 'package:cicle_mobile_f3/utils/client.dart';
import 'package:dio/dio.dart';

class NotificationService {
  Dio client = Client.init();

  Future<Response> updateNotifItemAsRead(String notificationId) async {
    return client.patch('/api/v1/notifications/$notificationId');
  }

  Future<Response> markAllAsRead(dynamic body) async {
    return client.patch('/api/v1/notifications?selectBy=selected', data: body);
  }

  Future<Response> getNotifAsCheer(String url) async {
    return client.get(url);
  }
}
