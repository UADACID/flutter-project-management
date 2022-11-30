import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketTeamDetail {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/teams');
  late String _teamId;
  late bool _isConneted;

  init(String teamId, String logedInUserId) {
    _teamId = teamId;
    socketUri =
        '${Env.BASE_URL_SOCKET}/socket/teams/$_teamId?userId=$logedInUserId';
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
    localSocket.onConnect((data) {
      _isConneted = true;
      print('on connect socket team');
    });
    localSocket.onDisconnect((data) {
      _isConneted = false;
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError socket team');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout socket team');
    });
  }

  listener(
      {
      // group chat
      required dynamic Function(dynamic) onGroupChatNew,
      required dynamic Function(dynamic) onGroupChatDelete,
      required dynamic Function(dynamic) onMemberNew,
      required dynamic Function(dynamic) onMemberRemove,
      required dynamic Function(dynamic) onMemberUpdate,
      required dynamic Function(dynamic) onSetBlastOverview,
      required dynamic Function(dynamic) onSetScheduleOverview,
      required dynamic Function(dynamic) onSetBoardOverview,
      required dynamic Function(dynamic) onSetCheckinOverview,
      required dynamic Function(dynamic) onSetDocsFilesOverview}) {
    // group chat
    localSocket.on('groupChat-new', onGroupChatNew);
    localSocket.on('groupChat-delete', onGroupChatDelete);
    localSocket.on('member-new', onMemberNew);
    localSocket.on('member-remove', onMemberRemove);
    localSocket.on('member-update', onMemberUpdate);

    localSocket.on('blast-overview', onSetBlastOverview);
    localSocket.on('schedule-overview', onSetScheduleOverview);
    localSocket.on('board-overview', onSetBoardOverview);
    localSocket.on('checkIn-overview', onSetCheckinOverview);
    localSocket.on('docsFiles-overview', onSetDocsFilesOverview);
  }

  removeListenFromSocket() {
    if (_isConneted) {
      localSocket.off('groupChat-new');
      localSocket.off('groupChat-delete');
      localSocket.off('member-new');
      localSocket.off('member-remove');
      localSocket.off('member-update');
    }
  }
}
