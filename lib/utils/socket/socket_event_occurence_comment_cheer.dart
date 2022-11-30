import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketEventOccurenceCommentCheer {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/occurences');
  late String _occurrenceId;

  init(String occurrenceId, String logedInUserId) {
    _occurrenceId = occurrenceId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/occurrences/$_occurrenceId?userId=$logedInUserId';
    print(socketUri);
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
    localSocket
        .onConnect((data) => print('on connect socket _occurrence cheer'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError _occurrence cheer');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout _occurrence cheer');
    });
  }

  listener(
    dynamic Function(dynamic) callbackNewCheer,
    dynamic Function(dynamic) callbackDeleteCheer,
    dynamic Function(dynamic) callbackNewCheerComment,
    dynamic Function(dynamic) callbackDeleteCheerComment,
    dynamic Function(dynamic) callbackNewDiscussion,
    dynamic Function(dynamic) callbackDeleteDiscussion,
  ) {
    localSocket.on('cheer-new', callbackNewCheer);
    localSocket.on('cheer-delete', callbackDeleteCheer);
    localSocket.on('cheerComment-new', callbackNewCheerComment);
    localSocket.on('cheerComment-delete', callbackDeleteCheerComment);
    localSocket.on('commentDiscussion-new', callbackNewDiscussion);
    localSocket.on('commentDiscussion-delete', callbackDeleteDiscussion);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      localSocket.off('cheerComment-new');
      localSocket.off('cheerComment-delete');
      localSocket.off('commentDiscussion-new');
      localSocket.off('commentDiscussion-delete');
    }
  }
}
