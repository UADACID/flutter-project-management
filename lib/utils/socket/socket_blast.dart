import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketBlast {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/blast');
  late String _blastId;

  init(String blastId, String logedInUserId) {
    _blastId = blastId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/blasts/$_blastId?userId=$logedInUserId';
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
    localSocket.onConnect((data) => print('on connect socket blast'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError blast');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout blast');
    });
  }

  listener(dynamic Function(dynamic) onSocketPostUpdate,
      dynamic Function(dynamic) onSocketPostArchive) {
    localSocket.on('post-update-$_blastId', onSocketPostUpdate);
    localSocket.on('post-archive-$_blastId', onSocketPostArchive);
  }

  removeListenFromSocket(String currentBlastId) {
    if (localSocket.connected) {
      if (currentBlastId != _blastId) {
        print('socket off');
        localSocket.off('post-update-$_blastId');
        localSocket.off('post-archive-$_blastId');
      }
    }
  }
}
