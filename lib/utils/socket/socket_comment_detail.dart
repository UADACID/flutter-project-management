import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketCommentDetail {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/discussion');
  late String _commentId;

  init(String commentId, String logedInUserId) {
    _commentId = commentId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/comments/$commentId?userId=$logedInUserId';
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
    localSocket.onConnect((data) => print('on connect socket comment detail'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError comment detail');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout comment detail');
    });
  }

  listener(
      dynamic Function(dynamic) callbackNewCheer,
      dynamic Function(dynamic) callbackDeleteCheer,
      dynamic Function(dynamic) callbackNewComment,
      dynamic Function(dynamic) callbackUpdateComment,
      dynamic Function(dynamic) callbackDeleteComment,
      dynamic Function(dynamic) callbackNewCheerComment,
      dynamic Function(dynamic) callbackDeleteCheerComment) {
    localSocket.on('cheer-new', callbackNewCheer);
    localSocket.on('cheer-delete', callbackDeleteCheer);
    localSocket.on('commentDiscussion-new-$_commentId', callbackNewComment);
    localSocket.on(
        'commentDiscussion-update-$_commentId', callbackUpdateComment);
    localSocket.on(
        'commentDiscussion-delete-$_commentId', callbackDeleteComment);
    localSocket.on('cheerDiscussion-new', callbackNewCheerComment);
    localSocket.on('cheerDiscussion-delete', callbackDeleteCheerComment);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      localSocket.off('cheer-new');
      localSocket.off('cheer-delete');
      localSocket.off('commentDiscussion-new-$_commentId');
      localSocket.off('commentDiscussion-update-$_commentId');
      localSocket.off('commentDiscussion-delete-$_commentId');
      localSocket.off('cheerDiscussion-new');
      localSocket.off('cheerDiscussion-delete');
    }
  }
}
