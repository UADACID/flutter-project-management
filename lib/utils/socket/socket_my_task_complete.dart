import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketMyTaskComplete {
  late String socketUri;

  late Socket localSocket;
  bool _isSocketInit = false;
  String _moduleName = '';
  String _userId = '';

  init(String moduleName, String userId) {
    _moduleName = moduleName;
    _userId = userId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/my-tasks/$moduleName/complete';
    print('socket $socketUri');

    localSocket = io(
        socketUri,
        OptionBuilder()
            .enableForceNew()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection/ optional
            .build());
    _isSocketInit = true;
    localSocket.connect();
    _socketStatus();
  }

  _socketStatus() {
    localSocket.onConnect((data) {
      print('on connect socket my task $_moduleName complete');
      _isSocketInit = true;
    });
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError my task $_moduleName complete');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout my task $_moduleName complete');
    });
  }

  listener(
      {required dynamic Function(dynamic) onSocketTaskComplete,
      required dynamic Function(dynamic) onSocketTaskRemoved,
      required dynamic Function(dynamic) onSocketTaskUpdateStatus}) {
    localSocket.on('taskCompleted-$_userId', onSocketTaskComplete);
    localSocket.on('taskRemoved-$_userId', onSocketTaskRemoved);
    localSocket.on('taskUpdateStatus-$_userId', onSocketTaskUpdateStatus);
  }

  removeListenFromSocket() {
    if (_isSocketInit) {
      localSocket.off('taskCompleted-$_userId');
      localSocket.off('taskRemoved-$_userId');
      localSocket.off('taskUpdateStatus-$_userId');
    }
  }
}
