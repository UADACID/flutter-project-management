import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketPostCommentCheer {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/posts');
  late String _postId;

  init(String postId, String logedInUserId) {
    _postId = postId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/posts/$_postId?userId=$logedInUserId';
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
    localSocket.onConnect((data) => print('on connect socket post'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError post');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout post');
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
    dynamic Function(dynamic) callbackDeleteDiscussion,
  ) {
    localSocket.on('cheer-new', callbackNewCheer);
    localSocket.on('cheer-delete', callbackDeleteCheer);
    localSocket.on('postsComment-new-$_postId', callbackNewComment);
    localSocket.on('postsComment-update-$_postId', callbackUpdateComment);
    localSocket.on('postsComment-delete-$_postId', callbackDeleteComment);
    localSocket.on('cheerComment-new', callbackNewCheerComment);
    localSocket.on('cheerComment-delete', callbackDeleteCheerComment);
    localSocket.on('commentDiscussion-new', callbackNewDiscussion);
    localSocket.on('commentDiscussion-delete', callbackDeleteDiscussion);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      localSocket.off('cheer-new');
      localSocket.off('cheer-delete');
      localSocket.off('postsComment-new-$_postId');
      localSocket.off('postsComment-update-$_postId');
      localSocket.off('postsComment-delete-$_postId');
      localSocket.off('cheerComment-new');
      localSocket.off('cheerComment-delete');
      localSocket.off('commentDiscussion-new');
      localSocket.off('commentDiscussion-delete');
    }
  }
}
