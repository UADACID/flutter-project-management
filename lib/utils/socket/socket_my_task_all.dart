import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketMyTaskAll {
  late String socketUri;

  late Socket localSocket;
  bool _isSocketInit = false;
  String _moduleName = '';
  String _userId = '';

  init(String moduleName, String userId) {
    _moduleName = moduleName;
    _userId = userId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/my-tasks/$moduleName';
    print('socket $socketUri');

    localSocket = io(
        socketUri,
        OptionBuilder()
            .enableForceNew()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection/ optional
            .build());

    localSocket.connect();
    _socketStatus();
  }

  _socketStatus() {
    localSocket.onConnect((data) {
      print('on connect socket my task $_moduleName all');
      _isSocketInit = true;
    });
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError my task $_moduleName all');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout my task $_moduleName all');
    });
  }

  listener(
      {required dynamic Function(dynamic) onSocketTaskAssigned,
      required dynamic Function(dynamic) onSocketTaskRemoved,
      required dynamic Function(dynamic) onSocketTaskUpdateStatus}) {
    localSocket.on('taskAssigned-$_userId', onSocketTaskAssigned);
    localSocket.on('taskRemoved-$_userId', onSocketTaskRemoved);
    localSocket.on('taskUpdateStatus-$_userId', onSocketTaskUpdateStatus);
  }

  removeListenFromSocket() {
    if (_isSocketInit) {
      localSocket.off('taskAssigned-$_userId');
      localSocket.off('taskRemoved-$_userId');
      localSocket.off('taskUpdateStatus-$_userId');
    }
  }
}
