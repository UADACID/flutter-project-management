import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketBoard {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/socket/boards');
  late String _boardId;

  init(String boardId) {
    _boardId = boardId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/boards/$_boardId';
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
    localSocket.onConnect((data) => print('on connect socket board'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError board');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout board');
    });
  }

  listener(
      {required dynamic Function(dynamic) callbackLabelNew,
      required dynamic Function(dynamic) callbackLabelUpdate,
      required dynamic Function(dynamic) callbackLabelDelete,
      required dynamic Function(dynamic) callbacklistNew,
      required dynamic Function(dynamic) callbacklistArchive,
      required dynamic Function(dynamic) callbacklistUpdate,
      required dynamic Function(dynamic) callBackCardArchive,
      required dynamic Function(dynamic) callbackCardNew,
      required dynamic Function(dynamic) callbackCardUpdate,
      required dynamic Function(dynamic) callBackCardUnarchive,
      required dynamic Function(dynamic) callBackCardsArchive,
      required dynamic Function(dynamic) callBackListUnarchive,
      required dynamic Function(dynamic) callBackCardMove,
      required dynamic Function(dynamic) callBackListMove}) {
    localSocket.on('labelNew', callbackLabelNew); // enhance payload to object
    localSocket.on(
        'labelUpdate', callbackLabelUpdate); // enhance payload to mobject
    localSocket.on('labelDelete', callbackLabelDelete);
    localSocket.on('listNew', callbacklistNew);
    localSocket.on('listArchive', callbacklistArchive);
    localSocket.on('listUnarchive', callBackListUnarchive);
    localSocket.on('listUpdate', callbacklistUpdate);
    localSocket.on('cardArchive', callBackCardArchive);
    localSocket.on('cardsArchive', callBackCardsArchive);
    localSocket.on('cardUnarchive', callBackCardUnarchive);
    localSocket.on('cardNew', callbackCardNew);
    localSocket.on('cardUpdate', callbackCardUpdate);
    localSocket.on('listMove', callBackListMove);
    localSocket.on('cardMove', callBackCardMove);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      localSocket.off('labelNew');
      localSocket.off('labelUpdate');
      localSocket.off('labelDelete');
      localSocket.off('listNew');
      localSocket.off('listArchive');
      localSocket.off('listUnarchive');
      localSocket.off('listUpdate');

      localSocket.off('cardArchive');
      localSocket.off('cardUnarchive');
      localSocket.off('cardNew');
      localSocket.off('cardUpdate');
      localSocket.off('listMove');
      localSocket.off('cardMove');
    }
  }
}
