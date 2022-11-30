import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketMyTaskDuesoon {
  late String socketUri;

  late Socket localSocket;
  bool _isSocketInit = false;
  String _moduleName = '';
  String _userId = '';
  String _companyId = '';

  init(String moduleName, String userId, String companyId) {
    _moduleName = moduleName;
    _userId = userId;
    _companyId = companyId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/my-tasks/$moduleName/duesoon';
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
      print('on connect socket my task $_moduleName duesoon');
      _isSocketInit = true;
    });
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError my task $_moduleName duesoon');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout my task $_moduleName duesoon');
    });
  }

  listener(
      {required dynamic Function(dynamic) onSocketTaskAssigned,
      required dynamic Function(dynamic) onSocketTaskRemoved,
      required dynamic Function(dynamic) onSocketTaskUpdateStatus}) {
    localSocket.on(
        'taskAssigned-dueSoon-$_userId-$_companyId', onSocketTaskAssigned);
    localSocket.on(
        'taskRemoved-dueSoon-$_userId-$_companyId', onSocketTaskRemoved);
    localSocket.on('taskUpdateStatus-dueSoon-$_userId-$_companyId',
        onSocketTaskUpdateStatus);
  }

  removeListenFromSocket() {
    if (_isSocketInit) {
      localSocket.off('taskAssigned-dueSoon-$_userId-$_companyId');
      localSocket.off('taskRemoved-dueSoon-$_userId-$_companyId');
      localSocket.off('taskUpdateStatus-dueSoon-$_userId-$_companyId');
    }
  }
}
