import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';
import 'package:cicle_mobile_f3/models/board_list_item_model.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/models/doc_file_item_model.dart';
import 'package:cicle_mobile_f3/models/event_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/models/message_item_model.dart';
import 'package:cicle_mobile_f3/models/post_item_model.dart';
import 'package:cicle_mobile_f3/models/questionItemModel.dart';
import 'package:cicle_mobile_f3/service/team_detail_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_team_detail.dart';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:supercharged/supercharged.dart';

class TeamDetailController extends GetxController {
  CompanyController _companyController = Get.find();
  TeamDetailService _teamDetailService = TeamDetailService();
  String teamId = Get.parameters['teamId']!;
  String companyId = Get.parameters['companyId'] ?? '';

  SocketTeamDetail _socketTeamDetail = SocketTeamDetail();

  final box = GetStorage();

  var _logedInUser = MemberModel().obs;
  MemberModel get logedInUser => _logedInUser.value;
  set logedInUser(MemberModel value) {
    _logedInUser.value = value;
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;

  var _isLoading = true.obs;
  bool get isLoading => _isLoading.value;

  var _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  // TEAM DETAIL DATA

  var _teamName = ''.obs;
  String get teamName => _teamName.value;
  set teamName(String value) {
    _teamName.value = value;
  }

  var _teamDesc = ''.obs;
  String get teamDesc => _teamDesc.value;
  set teamDesc(String value) {
    _teamDesc.value = value;
  }

  var _groupChatId = ''.obs;
  String get groupChatId => _groupChatId.value;
  set groupChatId(String value) {
    _groupChatId.value = value;
  }

  var _boardId = ''.obs;
  String get boardId => _boardId.value;
  set boardId(String value) {
    _boardId.value = value;
  }

  var _blastId = ''.obs;
  String get blastId => _blastId.value;
  set blastId(String value) {
    _blastId.value = value;
  }

  var _checkInId = ''.obs;
  String get checkInId => _checkInId.value;
  set checkInId(String value) {
    _checkInId.value = value;
  }

  var _scheduleId = ''.obs;
  String get scheduleId => _scheduleId.value;
  set scheduleId(String value) {
    _scheduleId.value = value;
  }

  var _backetId = ''.obs;
  String get backetId => _backetId.value;
  set backetId(String value) {
    _backetId.value = value;
  }

  // cancel token request get team
  late CancelToken cancelTokenGetTeam;

  // MENU OVERVIEW

  var _listOverviewGroupChat = <MessageItemModel>[].obs;
  List<MessageItemModel> get listOverviewGroupChat => _listOverviewGroupChat;

  var _listOverviewBlast = <PostItemModel>[].obs;
  List<PostItemModel> get listOverviewBlast => _listOverviewBlast;

  var _listMapEvents = <String, List<EventItemModel>>{}.obs;
  Map<String, List<EventItemModel>> get listMapEvents => _listMapEvents;

  var _listEvents = <EventItemModel>[].obs;
  List<EventItemModel> get listEvents => _listEvents;
  set listEvents(List<EventItemModel> value) {
    _listEvents.value = value;
  }

  var _boardList = <BoardListItemModel>[].obs;
  List<BoardListItemModel> get boardList => _boardList;
  set boardList(List<BoardListItemModel> value) {
    _boardList.value = value;
  }

  var _listOverviewBoards = <CardModel>[].obs;
  List<CardModel> get listOverviewBoards => _listOverviewBoards;

  var _listOverviewCheckIns = <QuestionItemModel>[].obs;
  List<QuestionItemModel> get listOverviewCheckIns => _listOverviewCheckIns;

  var _listOverviewDocFile = <DocFileItemModel>[].obs;
  List<DocFileItemModel> get listOverviewDocFile => _listOverviewDocFile;

  //DUMMY FOR LAYOUTING
  var _fullFillOverview = false.obs;
  var _selectedMenuIndex = 0.obs;

  var _scaffoldKey = GlobalKey<ScaffoldState>();

  GlobalKey<ScaffoldState> get scaffoldKey => _scaffoldKey;

  int get selectedMenuIndex => _selectedMenuIndex.value;

  bool get fullFillOverview => _fullFillOverview.value;
  set fullFillOverview(bool value) {
    _fullFillOverview.value = value;
  }

  set selectedMenuIndex(int index) {
    _selectedMenuIndex.value = index;
    if (Get.currentRoute.contains('group-chats')) {
      return Get.back();
    }
    if (index == 4) {
      Get.toNamed(RouteName.groupChatScreen(companyId, teamId, groupChatId));
    }
  }

  //MEMBERS
  var _teamMembers = <MemberModel>[].obs;

  List<MemberModel> get teamMembers => _teamMembers;

  set teamMembers(List<MemberModel> list) {
    _teamMembers.value = [...list];
  }

  Future<void> updateTeam(String name, String desc) async {
    String previousName = _teamName.value;
    String previousDesc = _teamDesc.value;
    try {
      String teamId = Get.parameters['teamId']!;

      _teamName.value = name;
      _teamDesc.value = desc;
      dynamic data = {
        "name": name,
        "desc": desc,
      };
      await _teamDetailService.updateTeam(teamId, data);
    } catch (e) {
      errorMessageMiddleware(e, false, 'Failed to update team,');
      _teamName.value = previousName;
      _teamDesc.value = previousDesc;
    }
  }

  Future<bool> getTeam() async {
    try {
      cancelTokenGetTeam = CancelToken();
      final response =
          await _teamDetailService.getTeam(teamId, cancelTokenGetTeam);

      final userString = box.read(KeyStorage.logedInUser);
      MemberModel logedInUser = MemberModel.fromJson(userString);

      box.write(
          'team-$teamId-user-${logedInUser.sId}', response.data['currentTeam']);

      _teamName.value = response.data['currentTeam']['name'];
      _teamDesc.value = response.data['currentTeam']['desc'];

      // members
      if (response.data['currentTeam']['members'] != null) {
        var _tempMembers = [];
        response.data['currentTeam']['members'].forEach((v) {
          _tempMembers.add(new MemberModel.fromJson(v));
        });
        _teamMembers.value = [..._tempMembers];
      }

      // groupchat
      var _tempListGroupChat = [];
      if (response.data['currentTeam']['groupChat']['attachments'] != null) {
        response.data['currentTeam']['groupChat']['attachments'].forEach((v) {
          _tempListGroupChat.add(new MessageItemModel.fromJson(v));
        });
      }
      if (response.data['currentTeam']['groupChat']['messages'] != null) {
        response.data['currentTeam']['groupChat']['messages'].forEach((v) {
          _tempListGroupChat.add(new MessageItemModel.fromJson(v));
        });
      }

      groupChatId = response.data['currentTeam']['groupChat']['_id'];

      // blast
      List<PostItemModel> _tempListPost = [];
      if (response.data['currentTeam']['blast']['posts'] != null) {
        response.data['currentTeam']['blast']['posts'].forEach((v) {
          PostItemModel object = PostItemModel.fromJson(v);

          _tempListPost.add(object);
        });

        _blastId.value = response.data['currentTeam']['blast']['_id'];
      }

      // schedule
      List<EventItemModel> _tempListEvents = [];
      if (response.data['currentTeam']['schedule']['events'] != null) {
        response.data['currentTeam']['schedule']['events'].forEach((v) {
          _tempListEvents.add(new EventItemModel.fromJson(v));
        });
        listEvents = _tempListEvents;

        var groupingByDate = _tempListEvents.groupBy<String, EventItemModel>(
          (item) {
            DateTime date = DateTime.parse(item.startDate!).toLocal();
            String dateFormat = DateFormat('yyyy-MM-dd').format(date);
            return dateFormat;
          },
          valueTransform: (item) => item,
        );

        _listMapEvents.value = groupingByDate;
        _scheduleId.value = response.data['currentTeam']['schedule']['_id'];
      }

      // checkins
      var _tempListQuestion = [];
      if (response.data['currentTeam']['checkIn']['questions'] != null) {
        response.data['currentTeam']['checkIn']['questions'].forEach((v) {
          _tempListQuestion.add(new QuestionItemModel.fromJson(v));
        });
        _checkInId.value = response.data['currentTeam']['checkIn']['_id'];
      }

      // board
      var _tempListCards = <CardModel>[];
      if (response.data['currentTeam']['boards'] != null &&
          response.data['currentTeam']['boards'][0] != null) {
        List<BoardListItemModel> _list = [];
        response.data['currentTeam']['boards'][0]['lists'].forEach((v) {
          _list.add(BoardListItemModel.fromJson(v));
        });

        boardList = _list;
        _list.forEach((element) {
          element.cards.forEach((card) {
            _tempListCards.add(card);
          });
        });
        _tempListCards.sort((a, b) =>
            DateTime.parse(b.updatedAt).compareTo(DateTime.parse(a.updatedAt)));

        _boardId.value = response.data['currentTeam']['boards'][0]['_id'];
      }

      //doc & file
      var _tempListDocFile = [];
      // for bucket
      if (response.data['currentTeam']['bucket']['buckets'] != null) {
        response.data['currentTeam']['bucket']['buckets'].forEach((v) {
          _tempListDocFile.add(new DocFileItemModel.fromJson(v));
        });
      }
      // for docs
      if (response.data['currentTeam']['bucket']['docs'] != null) {
        response.data['currentTeam']['bucket']['docs'].forEach((v) {
          _tempListDocFile.add(new DocFileItemModel.fromJson(v));
        });
      }
      //for files
      if (response.data['currentTeam']['bucket']['files'] != null) {
        response.data['currentTeam']['bucket']['files'].forEach((v) {
          _tempListDocFile.add(new DocFileItemModel.fromJson(v));
        });
      }
      backetId = response.data['currentTeam']['bucket']['_id'];

      _listOverviewGroupChat.value = [..._tempListGroupChat];
      _listOverviewBlast.value = [..._tempListPost];

      _listOverviewBoards.value = [..._tempListCards];
      _listOverviewCheckIns.value = [..._tempListQuestion];
      _listOverviewDocFile.value = [..._tempListDocFile];

      _errorMessage.value = '';
      return Future.value(true);
    } catch (e) {
      _errorMessage.value =
          errorMessageMiddleware(e, false, 'Failed to Get Team Detail,');
      return Future.error(e);
    }
  }

  List<String> toggleMembersAdapter(List<MemberModel> membersFromListDialog) {
    List<MemberModel> _currentTeamMembers = [...teamMembers];
    List<String> listIdMembersFromListDialog =
        membersFromListDialog.map((e) => e.sId).toList();
    List<String> listIdCurrentTeamMembers =
        _currentTeamMembers.map((e) => e.sId).toList();
    List<String> result = [];
    listIdMembersFromListDialog.map((e) {
      if (listIdCurrentTeamMembers.contains(e)) {
      } else {
        result.add(e);
      }
    }).toList();
    listIdCurrentTeamMembers.map((e) {
      if (listIdMembersFromListDialog.contains(e)) {
      } else {
        result.add(e);
      }
    }).toList();
    result.remove(logedInUserId); // remove current user from toggle
    return result;
  }

  Future<void> addMembers(List<MemberModel> selectedMembersList) async {
    List<MemberModel> _oldListMember = [...teamMembers];
    List<String> _listIdMembers = toggleMembersAdapter(selectedMembersList);
    List<MemberModel> filterCurrentUserLogedIn = selectedMembersList
        .where((element) => element.sId != logedInUserId)
        .toList();
    filterCurrentUserLogedIn.add(logedInUser);
    teamMembers = filterCurrentUserLogedIn;
    selectedMembersList.removeWhere((o) => o.sId == logedInUserId);
    if (_listIdMembers.isEmpty) {
      return;
    }
    try {
      String teamId = Get.parameters['teamId']!;
      dynamic data = {"members": _listIdMembers};
      await _teamDetailService.addMembers(teamId, data);
    } catch (e) {
      teamMembers = _oldListMember;
      errorMessageMiddleware(e, false, 'Failed to Add Team Members,');
    }
  }

  onGroupChatNew(dynamic messageItemJson) {
    MessageItemModel message = MessageItemModel.fromJson(messageItemJson);
    _listOverviewGroupChat.add(message);
  }

  onGroupChatDelete(dynamic messageItemJson) {
    MessageItemModel message = MessageItemModel.fromJson(messageItemJson);
    List<MessageItemModel> _tempList = List.from(_listOverviewGroupChat);
    _listOverviewGroupChat.value = _tempList.map((e) {
      if (e.sId == message.sId) {
        return message;
      } else {
        return e;
      }
    }).toList();
  }

  onMemberNew(dynamic json) {
    MemberModel item = MemberModel.fromJson(json);
    int index = teamMembers.indexWhere((element) => element.sId == item.sId);
    if (index < 0) {
      _teamMembers.insert(0, item);
    }
  }

  onMemberRemove(dynamic json) {
    MemberModel item = MemberModel.fromJson(json);
    _teamMembers.removeWhere((element) => element.sId == item.sId);
  }

  onMemberUpdate(dynamic json) {
    MemberModel item = MemberModel.fromJson(json);
    List<MemberModel> _tempTeams = teamMembers.map((e) {
      if (e.sId == item.sId) {
        return item;
      }

      return e;
    }).toList();
    _teamMembers.value = _tempTeams;

    if (item.sId == logedInUserId) {
      getTeam();
    }
  }

  _onSetBlastOverview(dynamic json) {
    if (json['posts'] != null) {
      _listOverviewBlast.value = [];
      json['posts'].forEach((item) {
        PostItemModel postItem = PostItemModel.fromJson(item);
        _listOverviewBlast.add(postItem);
      });
    }
  }

  _onSetScheduleOverview(dynamic json) {
    List<EventItemModel> _tempList = [];
    if (json['events'] != null) {
      json['events'].forEach((eventJson) {
        EventItemModel item = EventItemModel.fromJson(eventJson);
        _tempList.add(item);
      });
      _tempList.sort((a, b) =>
          DateTime.parse(a.startDate!).compareTo(DateTime.parse(b.startDate!)));
      _listEvents.value = _tempList;
      _listMapEvents.value = _eventAdapter(_tempList);
    }
  }

  _onSetBoardOverview(dynamic json) {
    List<CardModel> tempListCard = [];
    if (json['lists'] != null) {
      List<BoardListItemModel> _list = [];
      json['lists'].forEach((boardList) {
        if (json['lists'] is Map<String, dynamic>) {
          _list.add(BoardListItemModel.fromJson(json['lists']));
          if (boardList['cards'] != null) {
            boardList['cards'].forEach((cardJson) {
              CardModel item = CardModel.fromJson(cardJson);

              tempListCard.add(item);
            });
          }
        }
      });
      boardList = _list;
      tempListCard.sort((a, b) =>
          DateTime.parse(b.updatedAt).compareTo(DateTime.parse(a.updatedAt)));
      _listOverviewBoards.value = tempListCard;
    }
  }

  _onSetCheckinOverview(dynamic json) {
    if (json['questions'] != null) {
      _listOverviewCheckIns.value = [];
      json['questions'].forEach((item) {
        QuestionItemModel checkInItem = QuestionItemModel.fromJson(item);
        _listOverviewCheckIns.add(checkInItem);
      });
    }
  }

  _onSetDocsFilesOverview(dynamic json) {
    List<DocFileItemModel> _tempList = [];
    if (json['files'] != null) {
      json['files'].forEach((fileJson) {
        DocFileItemModel fileItem = DocFileItemModel.fromJson(fileJson);
        _tempList.add(fileItem);
      });
    }

    if (json['docs'] != null) {
      json['docs'].forEach((docJson) {
        DocFileItemModel docItem = DocFileItemModel.fromJson(docJson);
        _tempList.add(docItem);
      });
    }

    if (json['buckets'] != null) {
      json['buckets'].forEach((bucketJson) {
        DocFileItemModel bucketItem = DocFileItemModel.fromJson(bucketJson);
        _tempList.add(bucketItem);
      });
    }

    _tempList.sort((a, b) =>
        DateTime.parse(b.updatedAt!).compareTo(DateTime.parse(a.updatedAt!)));
    _listOverviewDocFile.value = _tempList;
  }

  Map<String, List<EventItemModel>> _eventAdapter(List<EventItemModel> list) {
    var groupingByDate = list.groupBy<String, EventItemModel>(
      (item) {
        DateTime date = DateTime.parse(item.startDate!).toLocal();
        String dateFormat = DateFormat('yyyy-MM-dd').format(date);
        return dateFormat;
      },
      valueTransform: (item) => item,
    );

    return groupingByDate;
  }

  bool _getTeamFromLocalStorage(String paramsTeamId) {
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel logedInUser = MemberModel.fromJson(userString);

    var localCurrentTeam =
        box.read('team-$paramsTeamId-user-${logedInUser.sId}');
    if (localCurrentTeam == null) {
      return false;
    }

    _teamName.value = localCurrentTeam['name'];
    _teamDesc.value = localCurrentTeam['desc'];

    // members
    if (localCurrentTeam['members'] != null) {
      var _tempMembers = [];
      localCurrentTeam['members'].forEach((v) {
        _tempMembers.add(new MemberModel.fromJson(v));
      });
      _teamMembers.value = [..._tempMembers];
    }

    // groupchat
    var _tempListGroupChat = [];
    if (localCurrentTeam['groupChat']['attachments'] != null) {
      localCurrentTeam['groupChat']['attachments'].forEach((v) {
        _tempListGroupChat.add(new MessageItemModel.fromJson(v));
      });
    }
    if (localCurrentTeam['groupChat']['messages'] != null) {
      localCurrentTeam['groupChat']['messages'].forEach((v) {
        _tempListGroupChat.add(new MessageItemModel.fromJson(v));
      });
    }

    groupChatId = localCurrentTeam['groupChat']['_id'];

    // blast
    List<PostItemModel> _tempListPost = [];
    if (localCurrentTeam['blast']['posts'] != null) {
      localCurrentTeam['blast']['posts'].forEach((v) {
        PostItemModel object = PostItemModel.fromJson(v);

        _tempListPost.add(object);
      });

      _blastId.value = localCurrentTeam['blast']['_id'];
    }

    // schedule
    List<EventItemModel> _tempListEvents = [];
    if (localCurrentTeam['schedule']['events'] != null) {
      localCurrentTeam['schedule']['events'].forEach((v) {
        _tempListEvents.add(new EventItemModel.fromJson(v));
      });
      listEvents = _tempListEvents;

      var groupingByDate = _tempListEvents.groupBy<String, EventItemModel>(
        (item) {
          DateTime date = DateTime.parse(item.startDate!).toLocal();
          String dateFormat = DateFormat('yyyy-MM-dd').format(date);
          return dateFormat;
        },
        valueTransform: (item) => item,
      );

      _listMapEvents.value = groupingByDate;
      _scheduleId.value = localCurrentTeam['schedule']['_id'];
    }

    // checkins
    var _tempListQuestion = [];
    if (localCurrentTeam['checkIn']['questions'] != null) {
      localCurrentTeam['checkIn']['questions'].forEach((v) {
        _tempListQuestion.add(new QuestionItemModel.fromJson(v));
      });
      _checkInId.value = localCurrentTeam['checkIn']['_id'];
    }

    // board
    var _tempListCards = <CardModel>[];
    if (localCurrentTeam['boards'] != null &&
        localCurrentTeam['boards'][0] != null) {
      List<BoardListItemModel> _list = [];
      localCurrentTeam['boards'][0]['lists'].forEach((v) {
        _list.add(BoardListItemModel.fromJson(v));
      });

      boardList = _list;
      _list.forEach((element) {
        element.cards.forEach((card) {
          _tempListCards.add(card);
        });
      });
      _tempListCards.sort((a, b) =>
          DateTime.parse(b.updatedAt).compareTo(DateTime.parse(a.updatedAt)));

      _boardId.value = localCurrentTeam['boards'][0]['_id'];
    }

    //doc & file
    var _tempListDocFile = [];
    // for bucket
    if (localCurrentTeam['bucket']['buckets'] != null) {
      localCurrentTeam['bucket']['buckets'].forEach((v) {
        _tempListDocFile.add(new DocFileItemModel.fromJson(v));
      });
    }
    // for docs
    if (localCurrentTeam['bucket']['docs'] != null) {
      localCurrentTeam['bucket']['docs'].forEach((v) {
        _tempListDocFile.add(new DocFileItemModel.fromJson(v));
      });
    }
    //for files
    if (localCurrentTeam['bucket']['files'] != null) {
      localCurrentTeam['bucket']['files'].forEach((v) {
        _tempListDocFile.add(new DocFileItemModel.fromJson(v));
      });
    }
    backetId = localCurrentTeam['bucket']['_id'];

    _listOverviewGroupChat.value = [..._tempListGroupChat];
    _listOverviewBlast.value = [..._tempListPost];

    _listOverviewBoards.value = [..._tempListCards];
    _listOverviewCheckIns.value = [..._tempListQuestion];
    _listOverviewDocFile.value = [..._tempListDocFile];

    return true;
  }

  Future<bool> init() async {
    try {
      String teamId = Get.parameters['teamId']!;

      Companies _currentCompany = _companyController.currentCompany;

      List<Teams> teamsByTeamId =
          _currentCompany.teams.where((e) => e.sId == teamId).toList();

      if (teamsByTeamId.isNotEmpty) {
        // set team name
        _teamName.value = teamsByTeamId[0].name;
        _teamMembers.value = [...teamsByTeamId[0].members];
      }

      bool hasDataOnLocal = _getTeamFromLocalStorage(teamId);

      if (hasDataOnLocal) {
        _isLoading.value = false;
      } else {
        _isLoading.value = true;
      }

      bool getTeamSuccess = await getTeam();

      if (getTeamSuccess) {
        _isLoading.value = false;
        _socketTeamDetail.init(teamId, logedInUserId);
        _socketTeamDetail.listener(
          onGroupChatNew: onGroupChatNew,
          onGroupChatDelete: onGroupChatDelete,
          onMemberNew: onMemberNew,
          onMemberRemove: onMemberRemove,
          onMemberUpdate: onMemberUpdate,
          onSetBlastOverview: _onSetBlastOverview,
          onSetScheduleOverview: _onSetScheduleOverview,
          onSetBoardOverview: _onSetBoardOverview,
          onSetCheckinOverview: _onSetCheckinOverview,
          onSetDocsFilesOverview: _onSetDocsFilesOverview,
        );

        return Future.value(true);
      } else {
        return Future.value(false);
      }
    } catch (e) {
      _isLoading.value = false;
      // print(e);
      return Future.error(e);
      // throw Exception(e);
    }
  }

  onChangeSelectedMenuIndex(int value) {
    String teamId = Get.parameters['teamId']!;
    String path = '';
    if (value == 4) {
      // GROUP CHAT

      path =
          '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=4';
      Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
          moduleName: 'group-chat',
          companyId: companyId,
          path: path,
          teamName: teamName == '' ? ' ' : teamName,
          title: 'Group Chat',
          subtitle:
              'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Group Chat',
          uniqId: teamId + groupChatId));
    } else if (value == 1) {
      // BLAST
      path =
          '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=1';
      Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
          moduleName: 'blast',
          companyId: companyId,
          path: path,
          teamName: teamName == '' ? ' ' : teamName,
          title: 'Blast',
          subtitle:
              'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Blast',
          uniqId: teamId + blastId));
    } else if (value == 5) {
      // SCHEDULE
      path =
          '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=5';
      Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
          moduleName: 'schedule',
          companyId: companyId,
          path: path,
          teamName: teamName == '' ? ' ' : teamName,
          title: 'Schedule',
          subtitle:
              'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Schedule',
          uniqId: teamId + scheduleId));
    } else if (value == 2) {
      // BOARD
      path =
          '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=2';
      Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
          moduleName: 'board',
          companyId: companyId,
          path: path,
          teamName: teamName == '' ? ' ' : teamName,
          title: 'Board',
          subtitle:
              'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Board',
          uniqId: teamId + boardId));
    } else if (value == 6) {
      // CHECK-IN
      path =
          '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=6';
      Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
          moduleName: 'check-ins',
          companyId: companyId,
          path: path,
          teamName: teamName == '' ? ' ' : teamName,
          title: 'Check-Ins',
          subtitle:
              'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Check-Ins',
          uniqId: teamId + checkInId));
    } else if (value == 3) {
      // DOC & FILE
      path =
          '${RouteName.teamDetailScreen(companyId)}/$teamId?destinationIndex=3';
      Get.put(SearchController()).insertListRecenlyViewed(RecentlyViewed(
          moduleName: 'docsAndFile',
          companyId: companyId,
          path: path,
          teamName: teamName == '' ? ' ' : teamName,
          title: 'Docs & Files',
          subtitle:
              'Home  >  ${Get.put(TeamDetailController()).teamName}  >  Docs & Files',
          uniqId: teamId + backetId));
    }
  }

  @override
  void onInit() async {
    // TODO: implement onInit
    super.onInit();
    await Future.delayed(Duration(milliseconds: 300));
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    _logedInUserId.value = _templogedInUser.sId;
    logedInUser = _templogedInUser;

    var resultInit = await init();

    if (resultInit) {
      ever(_selectedMenuIndex, onChangeSelectedMenuIndex);
      String? destinationMenuIndex = Get.parameters['destinationIndex'];
      if (destinationMenuIndex != null) {
        selectedMenuIndex = destinationMenuIndex.toInt()!;
      }
    }
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    cancelTokenGetTeam.cancel('request get team cancelled');
  }
}
