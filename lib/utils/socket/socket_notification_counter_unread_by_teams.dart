import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketNotificationCounterUnreadByTeams {
  late String socketUri;

  late Socket localSocket;
  bool _isSocketInit = false;

  late String? _companyId;
  late String _logedInUserId;

  init(String logedInUserId, String companyId) {
    _companyId = companyId;
    _logedInUserId = logedInUserId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/notifications-counter/teams';

    if (_companyId != "") {
      localSocket = io(
          socketUri,
          OptionBuilder()
              .enableForceNew()
              .setTransports(['websocket']) // for Flutter or Dart VM
              .setQuery({"userId": _logedInUserId, "companyId": _companyId})
              .disableAutoConnect() // disable auto-connection/ optional
              .build());

      localSocket.connect();
      _socketStatus();
    }
  }

  _socketStatus() {
    localSocket.onConnect((data) {
      print('on connect socket notification counter by teams');
      _isSocketInit = true;
    });
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError  notification counter by teams');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout  notification counter by teams');
    });
  }

  listener(
      {required dynamic Function(dynamic) onFirstGetData,
      required dynamic Function(dynamic) onUpdateCounterTeams}) {
    if (_companyId != "") {
      localSocket.on(_logedInUserId, onFirstGetData);
      localSocket.on("$_logedInUserId-updateCounter", onUpdateCounterTeams);
    }
  }

  removeListenFromSocket() {
    if (_isSocketInit) {
      print('socket off');
      localSocket.off(_logedInUserId);
      localSocket.off("$_logedInUserId-updateCounter");
    }
  }
}
