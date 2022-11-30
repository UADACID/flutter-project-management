import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketEventCommentCheer {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/events');
  late String _eventId;

  init(String eventId, String logedInUserId) {
    _eventId = eventId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/events/$_eventId?userId=$logedInUserId';
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
    localSocket.onConnect((data) => print('on connect socket event'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError event');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout event');
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
    localSocket.on('eventsComment-new-$_eventId', callbackNewComment);
    localSocket.on('eventsComment-update-$_eventId', callbackUpdateComment);
    localSocket.on('eventsComment-delete-$_eventId', callbackDeleteComment);
    localSocket.on('cheerComment-new', callbackNewCheerComment);
    localSocket.on('cheerComment-delete', callbackDeleteCheerComment);
    localSocket.on('commentDiscussion-new', callbackNewDiscussion);
    localSocket.on('commentDiscussion-delete', callbackDeleteDiscussion);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      localSocket.off('eventsComment-new-$_eventId');
      localSocket.off('eventsComment-update-$_eventId');
      localSocket.off('eventsComment-delete-$_eventId');
      localSocket.off('cheerComment-new');
      localSocket.off('cheerComment-delete');
      localSocket.off('commentDiscussion-new');
      localSocket.off('commentDiscussion-delete');
    }
  }
}
