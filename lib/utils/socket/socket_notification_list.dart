import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketNotificationList {
  late String socketUri;

  late Socket localSocket;
  bool _isSocketInit = false;

  late String _teamId;
  late String _userId;

  init(String teamId, String logedInUserId, String companyId) {
    _userId = logedInUserId;
    _teamId = teamId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/notifications/team';

    if (_teamId != "") {
      localSocket = io(
          socketUri,
          OptionBuilder()
              .enableForceNew()
              .setTransports(['websocket']) // for Flutter or Dart VM
              .setQuery({
                "userId": _userId,
                "teamId": _teamId,
                "companyId": companyId,
                "filter": "unread"
              })
              .disableAutoConnect() // disable auto-connection/ optional
              .build());

      localSocket.connect();
      _socketStatus();
    }
  }

  _socketStatus() {
    localSocket.onConnect((data) {
      print('on connect socket all notification team $_teamId');
      _isSocketInit = true;
    });
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError all notificatio team $_teamId');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout all notification team $_teamId');
    });
  }

  listener(dynamic Function(dynamic) onSocketPostNew) {
    localSocket.on('$_teamId-$_userId-unread', onSocketPostNew);
  }

  emitEvent(emit) {
    if (_isSocketInit) {
      emit();
    }
  }

  emit(int limit) {
    if (_isSocketInit) {
      localSocket
          .emit('$_teamId-$_userId', {"limit": limit, "filter": 'unread'});
    }
  }

  removeListenFromSocket() {
    if (_isSocketInit) {
      print('socket off');
      localSocket.off('$_teamId-$_userId-unread');
    }
  }
}
