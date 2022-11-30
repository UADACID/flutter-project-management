import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketCardCommentCheer {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/boards');
  late String _cardId;

  init(String cardId, String logedInUserId) {
    _cardId = cardId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/cards/$_cardId?userId=$logedInUserId';
    localSocket = io(
        socketUri,
        OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection/ optional
            .build());
    localSocket.connect();
    _socketStatus();
  }

  _socketStatus() {
    localSocket.onConnect((data) => print('on connect socket card'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError card');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout card');
    });
  }

  listener(
      dynamic Function(dynamic) callbackUpdateCard,
      dynamic Function(dynamic) callbackArchiveCard,
      dynamic Function(dynamic) callbackNewCheer,
      dynamic Function(dynamic) callbackDeleteCheer,
      dynamic Function(dynamic) callbackNewComment,
      dynamic Function(dynamic) callbackUpdateComment,
      dynamic Function(dynamic) callbackDeleteComment,
      dynamic Function(dynamic) callbackNewCheerComment,
      dynamic Function(dynamic) callbackDeleteCheerComment,
      dynamic Function(dynamic) callbackNewDiscussion,
      dynamic Function(dynamic) callbackDeleteDiscussion) {
    localSocket.on('update', callbackUpdateCard);
    localSocket.on('archive', callbackArchiveCard);
    localSocket.on('cheer-new', callbackNewCheer);
    localSocket.on('cheer-delete', callbackDeleteCheer);
    localSocket.on('cardsComment-new-$_cardId', callbackNewComment);
    localSocket.on('cardsComment-update-$_cardId', callbackUpdateComment);
    localSocket.on('cardsComment-delete-$_cardId', callbackDeleteComment);
    localSocket.on('cheerComment-new', callbackNewCheerComment);
    localSocket.on('cheerComment-delete', callbackDeleteCheerComment);
    localSocket.on('commentDiscussion-new', callbackNewDiscussion);
    localSocket.on('commentDiscussion-delete', callbackDeleteDiscussion);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      localSocket.off('cheer-new');
      localSocket.off('cheer-delete');
      localSocket.off('cardsComment-new-$_cardId');
      localSocket.off('cardsComment-update-$_cardId');
      localSocket.off('cardsComment-delete-$_cardId');
      localSocket.off('cheerComment-new');
      localSocket.off('cheerComment-delete');
      localSocket.off('commentDiscussion-new');
      localSocket.off('commentDiscussion-delete');
    }
  }
}
