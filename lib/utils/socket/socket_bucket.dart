import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketBucket {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/blast');
  late String _bucketId;

  init(String bucketId, String logedInUserId) {
    _bucketId = bucketId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/buckets/$_bucketId?userId=$logedInUserId';
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
    localSocket.onConnect((data) => print('on connect socket bucket'));
    localSocket.onDisconnect((data) {
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError bucket');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout bucket');
    });
  }

  listener(
    dynamic Function(dynamic) callbackNewBucket,
    dynamic Function(dynamic) callbackBucket,
    dynamic Function(dynamic) callbackBucketArchive,
    dynamic Function(dynamic) callbackNewDoc,
    dynamic Function(dynamic) callbackUpdateDoc,
    dynamic Function(dynamic) callbackArchiveDoc,
    dynamic Function(dynamic) callbackNewFile,
    dynamic Function(dynamic) callbackUpdateFile,
    dynamic Function(dynamic) callbackArchiveFile,
  ) {
    localSocket.on('bucket-new-$_bucketId', callbackNewBucket);
    localSocket.on('bucket-update-$_bucketId', callbackBucket);
    localSocket.on('bucket-archive-$_bucketId', callbackBucketArchive);
    localSocket.on('doc-new-$_bucketId', callbackNewDoc);
    localSocket.on('doc-update-$_bucketId', callbackUpdateDoc);
    localSocket.on('doc-archive-$_bucketId', callbackArchiveDoc);
    localSocket.on('file-new-$_bucketId', callbackNewFile);
    localSocket.on('file-update-$_bucketId', callbackUpdateFile);
    localSocket.on('file-archive-$_bucketId', callbackArchiveFile);
  }

  removeListenFromSocket() {
    if (localSocket.connected) {
      localSocket.off('bucket-new-$_bucketId');
      localSocket.off('bucket-update-$_bucketId');
      localSocket.off('bucket-archive-$_bucketId');
      localSocket.off('doc-new-$_bucketId');
      localSocket.off('doc-update-$_bucketId');
      localSocket.off('doc-archive-$_bucketId');
      localSocket.off('file-new-$_bucketId');
      localSocket.off('file-update-$_bucketId');
      localSocket.off('file-archive-$_bucketId');
    }
  }
}
