import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketEventOccurenceComment {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/occurences');
  late String _occurrenceId;

  init(String occurrenceId, String logedInUserId, String eventId) {
    _occurrenceId = occurrenceId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/events/$eventId/occurrences/$_occurrenceId?userId=$logedInUserId';
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
    localSocket.onConnect((data) => print('on connect socket _occurrence'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError _occurrence');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout _occurrence');
    });
  }

  listener(
    dynamic Function(dynamic) callbackNewComment,
    dynamic Function(dynamic) callbackUpdateComment,
    dynamic Function(dynamic) callbackDeleteComment,
  ) {
    localSocket.on('occurrencesComment-new-$_occurrenceId', callbackNewComment);
    localSocket.on(
        'occurrencesComment-update-$_occurrenceId', callbackUpdateComment);
    localSocket.on(
        'occurrencesComment-delete-$_occurrenceId', callbackDeleteComment);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      localSocket.off('occurrencesComment-new-$_occurrenceId');
      localSocket.off('occurrencesComment-update-$_occurrenceId');
      localSocket.off('occurrencesComment-delete-$_occurrenceId');
    }
  }
}
