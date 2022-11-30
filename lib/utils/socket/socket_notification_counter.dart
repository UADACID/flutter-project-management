import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketNotificationCounter {
  late String socketUri;

  late Socket localSocket;
  bool _isSocketInit = false;

  late String? _companyId;
  late String _logedInUserId;

  init(String deviceId, String logedInUserId, String companyId) {
    _companyId = companyId;
    _logedInUserId = logedInUserId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/notifications-counter';

    if (companyId == 'new-user' || _companyId!.length <= 20) {
      print('socket not init');
    } else {
      print('socket init to connect');
      localSocket = io(
          socketUri,
          OptionBuilder()
              .enableForceNew()
              .setQuery({
                "deviceId": deviceId,
                "userId": logedInUserId,
                "companyId": companyId
              })
              .setTransports(['websocket']) // for Flutter or Dart VM
              .disableAutoConnect() // disable auto-connection/ optional
              .build());

      localSocket.connect();

      _socketStatus();
    }
  }

  _socketStatus() {
    localSocket.onConnect((data) {
      print('companyIdss on connect socket notification counter');

      _isSocketInit = true;
    });
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError  notification counter');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout  notification counter');
    });
  }

  listener(dynamic Function(dynamic) onSocketPostNew, deviceId) {
    if (_companyId == 'new-user' || _companyId!.length <= 20) {
    } else {
      localSocket.on('$_companyId-$_logedInUserId', onSocketPostNew);
    }
  }

  removeListenFromSocket() {
    if (_isSocketInit) {
      print('socket off');
      localSocket.off('$_companyId-$_logedInUserId');
    }
  }
}
