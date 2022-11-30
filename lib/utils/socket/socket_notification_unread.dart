import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketNotificationUnread {
  late String socketUri;

  late Socket localSocket;
  bool _isSocketInit = false;

  late String _deviceId;
  late String _companyId;
  late String _userId;

  init(String deviceId, String logedInUserId, String companyId) {
    _deviceId = deviceId;
    _companyId = companyId;
    _userId = logedInUserId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/notifications';

    if (companyId != "") {
      localSocket = io(
          socketUri,
          OptionBuilder()
              .setQuery({
                "deviceId": deviceId,
                "userId": logedInUserId,
                "companyId": companyId,
                "filter": 'unread'
              })
              .enableForceNew()
              .setTransports(['websocket']) // for Flutter or Dart VM
              .disableAutoConnect() // disable auto-connection/ optional
              .build());
      _isSocketInit = true;
      localSocket.connect();
      _socketStatus();
    }
  }

  _socketStatus() {
    localSocket
        .onConnect((data) => print('on connect socket unread notification'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError unread notification');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout unread notification');
    });
  }

  listener(dynamic Function(dynamic) onSocketPostNew, deviceId) {
    try {
      if (_companyId != "") {
        localSocket.on("$_companyId-$_userId-unread", onSocketPostNew);
      }
    } catch (e) {
      print(e);
    }
  }

  emit(int limit) {
    if (_isSocketInit) {
      localSocket.emit(
          '$_companyId-$_userId-unread', {"limit": limit, "filter": 'unread'});
    }
  }

  removeListenFromSocket() {
    if (_isSocketInit) {
      print('socket off');
      localSocket.off("$_companyId-$_userId-unread");
    }
  }
}
