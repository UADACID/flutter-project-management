import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketBoardCardsCounter {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/boards');
  late String _boardId;
  bool _isInit = false;

  init(String boardId) {
    _boardId = boardId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/boards?boardId=$_boardId';
    localSocket = io(
        socketUri,
        OptionBuilder()
            .enableForceNew()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection/ optional
            .build());
    localSocket.connect();
    _isInit = true;
    _socketStatus();
  }

  _socketStatus() {
    localSocket
        .onConnect((data) => print('on connect socket board cards counter'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError board cards counter');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout board cards counter');
    });
  }

  listener(
    dynamic Function(dynamic) callback,
  ) {
    localSocket.on('card-counter', callback);
  }

  removeListenFromSocket() {
    if (_isInit) {
      localSocket.off('card-counter');
    }
  }
}
