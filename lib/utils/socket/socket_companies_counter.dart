import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketCompaniesCounter {
  late String socketUri;

  late Socket localSocket;
  late String _userId;
  late bool _isConneted;

  init(String userId) {
    _userId = userId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/notifications-counter/companies';

    localSocket = io(
        socketUri,
        OptionBuilder()
            .enableForceNew()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .setQuery({"userId": userId})
            .disableAutoConnect() // disable auto-connection/ optional
            .build());
    print(localSocket);
    localSocket.connect();
    _socketStatus();
  }

  _socketStatus() {
    localSocket.onConnect((data) {
      _isConneted = true;
      print('on connect socket companies counter');
    });
    localSocket.onDisconnect((data) {
      _isConneted = false;
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError socket companies counter');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout socket companies counter');
    });
    localSocket.onError((data) {
      print(data);
      print('error socket kwwkwkkwkw');
    });
  }

  listener({
    required dynamic Function(dynamic) onCounterUpdate,
  }) {
    localSocket.on(_userId, onCounterUpdate);
  }

  removeListenFromSocket() {
    if (_isConneted) {
      localSocket.off(_userId);
    }
  }
}
