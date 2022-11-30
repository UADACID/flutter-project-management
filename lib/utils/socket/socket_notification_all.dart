import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketNotificationAll {
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

    if (_deviceId != "" && companyId != "") {
      localSocket = io(
          socketUri,
          OptionBuilder()
              .enableForceNew()
              .setTransports(['websocket']) // for Flutter or Dart VM
              .setQuery(
                  {"userId": _userId, "companyId": _companyId, "deviceId": ""})
              .disableAutoConnect() // disable auto-connection/ optional
              .build());

      localSocket.connect();
      _socketStatus();
    }
  }

  _socketStatus() {
    localSocket.onConnect((data) {
      print('on connect socket all notification');
      _isSocketInit = true;
    });
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError all notification');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout all notification');
    });
  }

  listener(dynamic Function(dynamic) onSocketPostNew, deviceId) {
    if (_deviceId != "" && _companyId != "") {
      localSocket.on("$_companyId-$_userId", onSocketPostNew);
    }
  }

  emitEvent(emit) {
    if (_isSocketInit) {
      emit();
    }
  }

  emit(int limit) {
    print(localSocket);
    if (_isSocketInit) {
      localSocket.emit('$_companyId-$_userId', {"limit": limit});
    }
  }

  removeListenFromSocket() {
    if (_isSocketInit) {
      print('socket off');
      localSocket.off(_deviceId);
    }
  }
}
