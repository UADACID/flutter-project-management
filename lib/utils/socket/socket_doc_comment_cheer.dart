import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketDocCommentCheer {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/docs');
  late String _docId;

  init(String docId, String logedInUserId) {
    _docId = docId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/docs/$_docId?userId=$logedInUserId';
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
    localSocket.onConnect((data) => print('on connect socket doc'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError doc');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout doc');
    });
  }

  listener(
      dynamic Function(dynamic) callbackNewCheer,
      dynamic Function(dynamic) callbackDeleteCheer,
      dynamic Function(dynamic) callbackNewComment,
      dynamic Function(dynamic) callbackUpdateComment,
      dynamic Function(dynamic) callbackDeleteComment,
      dynamic Function(dynamic) callbackNewCheerComment,
      dynamic Function(dynamic) callbackDeleteCheerComment,
      dynamic Function(dynamic) callbackNewDiscussion,
      dynamic Function(dynamic) callbackDeleteDiscussion) {
    localSocket.on('cheer-new', callbackNewCheer);
    localSocket.on('cheer-delete', callbackDeleteCheer);
    localSocket.on('docsComment-new-$_docId', callbackNewComment);
    localSocket.on('docsComment-update-$_docId', callbackUpdateComment);
    localSocket.on('docsComment-delete-$_docId', callbackDeleteComment);
    localSocket.on('cheerComment-new', callbackNewCheerComment);
    localSocket.on('cheerComment-delete', callbackDeleteCheerComment);
    localSocket.on('commentDiscussion-new', callbackNewDiscussion);
    localSocket.on('commentDiscussion-delete', callbackDeleteDiscussion);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      localSocket.off('docsComment-new-$_docId');
      localSocket.off('docsComment-update-$_docId');
      localSocket.off('docsComment-delete-$_docId');
      localSocket.off('cheerComment-new');
      localSocket.off('cheerComment-delete');
      localSocket.off('commentDiscussion-new');
      localSocket.off('commentDiscussion-delete');
    }
  }
}
