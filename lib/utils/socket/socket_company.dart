import 'package:socket_io_client/socket_io_client.dart';

import '../constant.dart';

class SocketCompany {
  late String socketUri;

  Socket localSocket = io('${Env.BASE_URL_SOCKET}/socket/companies');
  late String _companyId;
  late bool _isConneted;

  init(String companyId) {
    _companyId = companyId;
    socketUri = '${Env.BASE_URL_SOCKET}/socket/companies/$_companyId';
    print('socketUri $socketUri');
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
      print('on connect socket company');
    });
    localSocket.onDisconnect((data) {
      _isConneted = false;
      localSocket.connect();
    });
    localSocket.onConnectError((data) {
      print('onConnectError socket company');
    });

    localSocket.onConnectTimeout((data) {
      print('onConnectTimeout socket company');
    });
  }

  listener({
    required dynamic Function(dynamic) onCompanyAdd,
    required dynamic Function(dynamic) onCompanyUpdate,
    required dynamic Function(dynamic) onMemberAdd,
    required dynamic Function(dynamic) onMemberRemove,
    required dynamic Function(dynamic) onMemberUpdate,
    required dynamic Function(dynamic) onTeamAdd,
    required dynamic Function(dynamic) onTeamUpdate,
    required dynamic Function(dynamic) onTeamArchive,
  }) {
    localSocket.on('company-new', onCompanyAdd);
    localSocket.on('company-update', onCompanyUpdate);
    localSocket.on('company-member-add', onMemberAdd);
    localSocket.on('company-member-remove', onMemberRemove);
    localSocket.on('company-member-update', onMemberUpdate);
    localSocket.on('team-new', onTeamAdd);
    localSocket.on('team-update', onTeamUpdate);
    localSocket.on('team-archive', onTeamArchive);
  }

  removeListenFromSocket() {
    if (_isConneted) {
      localSocket.off('company-new');
      localSocket.off('company-update');
      localSocket.off('company-member-remove');
      localSocket.off('company-member-update');
      localSocket.off('team-new');
      localSocket.off('team-update');
      localSocket.off('team-archive');
    }
  }
}
