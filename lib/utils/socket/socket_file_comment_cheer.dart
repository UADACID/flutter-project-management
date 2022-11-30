import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketFileCommentCheer {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/files');
  late String _fileId;

  init(String fileId, String logedInUserId) {
    _fileId = fileId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/files/$_fileId?userId=$logedInUserId';
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
    localSocket.onConnect((data) => print('on connect socket files'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError files');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout files');
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
    localSocket.on('filesComment-new-$_fileId', callbackNewComment);
    localSocket.on('filesComment-update-$_fileId', callbackUpdateComment);
    localSocket.on('filesComment-delete-$_fileId', callbackDeleteComment);
    localSocket.on('cheerComment-new', callbackNewCheerComment);
    localSocket.on('cheerComment-delete', callbackDeleteCheerComment);
    localSocket.on('commentDiscussion-new', callbackNewDiscussion);
    localSocket.on('commentDiscussion-delete', callbackDeleteDiscussion);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      localSocket.off('filesComment-new-$_fileId');
      localSocket.off('filesComment-update-$_fileId');
      localSocket.off('filesComment-delete-$_fileId');
      localSocket.off('cheerComment-new');
      localSocket.off('cheerComment-delete');
      localSocket.off('commentDiscussion-new');
      localSocket.off('commentDiscussion-delete');
    }
  }
}
