import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketNotificationChat {
  late String socketUri;

  late Socket localSocket;
  bool _isSocketInit = false;
  late String _deviceId;
  late String _companyId;
  late String _logedInUserId;

  init(String deviceId, String logedInUserId, String companyId) {
    _deviceId = deviceId;
    _companyId = companyId;
    _logedInUserId = logedInUserId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/notifications-chat?deviceId=$_deviceId&userId=$logedInUserId&companyId=$companyId';

    if (_deviceId != "" && companyId != "") {
      localSocket = io(
          socketUri,
          OptionBuilder()
              .enableForceNew()
              .setTransports(['websocket']) // for Flutter or Dart VM
              .disableAutoConnect() // disable auto-connection/ optional
              .build());
      localSocket.connect();
      _isSocketInit = true;
      _socketStatus();
    }
  }

  _socketStatus() {
    localSocket
        .onConnect((data) => print('on connect socket notification chat'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError  notification chat');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout  notification chat');
    });
  }

  listener(dynamic Function(dynamic) onSocketPostNew, deviceId) {
    localSocket.on('$_companyId-$_logedInUserId', onSocketPostNew);
  }

  removeListenFromSocket() {
    if (_isSocketInit) {
      print('socket off');
      localSocket.off('$_companyId-$_logedInUserId');
    }
  }
}
