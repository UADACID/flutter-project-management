import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketCheckIn {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/check-ins');
  late String _checkInId;

  init(String checkInId, String logedInUserId) {
    _checkInId = checkInId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/check-ins/$checkInId?userId=$logedInUserId';
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
    localSocket.onConnect((data) => print('on connect socket checkin'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError checkin');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout checkin');
    });
  }

  listener(
      dynamic Function(dynamic) onSocketPostNew,
      dynamic Function(dynamic) onSocketPostUpdate,
      dynamic Function(dynamic) onSocketPostArchive) {
    localSocket.on('question-new-$_checkInId', onSocketPostNew);
    localSocket.on('question-update-$_checkInId', onSocketPostUpdate);
    localSocket.on('question-archive-$_checkInId', onSocketPostArchive);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      print('socket off');
      localSocket.off('question-new-$_checkInId');
      localSocket.off('question-update-$_checkInId');
      localSocket.off('question-archive-$_checkInId');
      localSocket.disconnect();
    }
  }
}
