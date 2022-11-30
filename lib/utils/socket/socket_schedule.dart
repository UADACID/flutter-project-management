import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketSchedule {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/schedules');
  late String _scheduleId;

  init(String scheduleId, String logedInUserId) {
    _scheduleId = scheduleId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/schedules/$_scheduleId?userId=$logedInUserId';
    localSocket = io(
        socketUri,
        OptionBuilder()
            .enableForceNew()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection/ optional
            .build());
    localSocket.connect();
    _socketStatus();
  }

  _socketStatus() {
    localSocket.onConnect((data) => print('on connect socket schedule'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError schedule');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout schedule');
    });
  }

  listener(
    dynamic Function(dynamic) onSocketPostNew,
    dynamic Function(dynamic) onSocketPostUpdate,
    dynamic Function(dynamic) onSocketPostArchive,
    dynamic Function(dynamic) onSocketOccurrenceNew,
    dynamic Function(dynamic) onSocketOccurrenceUpdate,
    dynamic Function(dynamic) onSocketOccurrenceArchive,
  ) {
    localSocket.on('event-new', onSocketPostUpdate);
    localSocket.on('event-update-$_scheduleId', onSocketPostUpdate);
    localSocket.on('event-archive-$_scheduleId', onSocketPostArchive);
    localSocket.on('occurrence-new', onSocketOccurrenceNew);
    localSocket.on('occurrence-update-$_scheduleId', onSocketOccurrenceUpdate);
    localSocket.on(
        'occurrence-archive-$_scheduleId', onSocketOccurrenceArchive);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      print('socket off');
      localSocket.off('event-new');
      localSocket.off('event-update-$_scheduleId');
      localSocket.off('event-archive-$_scheduleId');
      localSocket.off('occurrence-new');
      localSocket.off('occurrence-update-$_scheduleId');
      localSocket.off('occurrence-archive-$_scheduleId');
    }
  }
}
