import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketQuestionCommentCheer {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/question');
  late String _questionId;

  init(String questionId, String logedInUserId) {
    _questionId = questionId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/questions/$_questionId?userId=$logedInUserId';
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
    localSocket.onConnect((data) => print('on connect socket question'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError question');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout question');
    });
  }

  listener(
      dynamic Function(dynamic) callbackNewComment,
      dynamic Function(dynamic) callbackUpdateComment,
      dynamic Function(dynamic) callbackDeleteComment,
      dynamic Function(dynamic) callbackNewCheerComment,
      dynamic Function(dynamic) callbackDeleteCheerComment,
      dynamic Function(dynamic) callbackNewDiscussion,
      dynamic Function(dynamic) callbackDeleteDiscussion) {
    localSocket.on('questionComment-new-$_questionId', callbackNewComment);
    localSocket.on(
        'questionComment-update-$_questionId', callbackUpdateComment);
    localSocket.on(
        'questionComment-delete-$_questionId', callbackDeleteComment);
    localSocket.on('cheerComment-new', callbackNewCheerComment);
    localSocket.on('cheerComment-delete', callbackDeleteCheerComment);
    localSocket.on('commentDiscussion-new', callbackNewDiscussion);
    localSocket.on('commentDiscussion-delete', callbackDeleteDiscussion);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      localSocket.off('questionComment-new-$_questionId');
      localSocket.off('questionComment-update-$_questionId');
      localSocket.off('questionComment-delete-$_questionId');
      localSocket.off('cheerComment-new');
      localSocket.off('cheerComment-delete');
      localSocket.off('commentDiscussion-new');
      localSocket.off('commentDiscussion-delete');
    }
  }
}
