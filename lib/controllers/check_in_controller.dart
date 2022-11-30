import 'package:cicle_mobile_f3/controllers/company_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/check_in_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/check_in_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/scoket_check_in.dart';
import 'package:dio/dio.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CheckInController extends GetxController {
  final box = GetStorage();
  TeamDetailController _teamDetailController = Get.find();
  CheckInService _checkInService = CheckInService();

  SocketCheckIn _socketCheckIn = SocketCheckIn();

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _questions = <CheckInModel>[].obs;
  List<CheckInModel> get questions => _questions;

  set questions(List<CheckInModel> values) {
    _questions.value = [...values];
  }

  removeCheckInItem(String id) {
    int index = _questions.indexWhere((element) => element.sId == id);
    if (index >= 0) {
      _questions.removeAt(index);
    }
  }

  addCheckInItem(CheckInModel item) {
    _questions.insert(0, item);
  }

  Future<List<CheckInModel>> getQuestions() async {
    try {
      if (_teamDetailController.checkInId == '') {
        await _teamDetailController.getTeam();
      }
      final response =
          await _checkInService.getQuestions(_teamDetailController.checkInId);

      if (response.data['checkIns'] != null) {
        questions = [];

        response.data['checkIns'].forEach((v) {
          _questions.add(CheckInModel.fromJson(v));
        });
      }
      return Future.value(_questions);
    } catch (e) {
      print(e);
      if (e is DioError) {
        showAlert(message: e.response!.statusCode.toString());
      }
      return Future.value([]);
    }
  }

  Future<List<CheckInModel>> getMoreQuestions() async {
    if (questions.length == 0) {
      return Future.value([]);
    }
    String checkInId = _teamDetailController.checkInId;
    try {
      String lastCreatedAt = questions.last.createdAt;
      dynamic queryParams = {"limit": 10, "createdAt": lastCreatedAt};
      final response =
          await _checkInService.getMoreQuestions(checkInId, queryParams);

      if (response.data['checkIns'] != null) {
        response.data['checkIns'].forEach((v) {
          _questions.add(CheckInModel.fromJson(v));
        });
      }

      return Future.value(_questions);
    } catch (e) {
      print(e);
      return Future.value([]);
    }
  }

  onSocketPostNew(data) {
    CheckInModel _question = CheckInModel.fromJson(data);
    _questions.insert(0, _question);
  }

  onSocketPostUpdate(data) {
    CheckInModel _question = CheckInModel.fromJson(data);
    int index =
        _questions.indexWhere((element) => element.sId == _question.sId);
    CompanyController _companyController = Get.find();
    List<MemberModel> admins = _companyController.currentCompany.admins ?? [];
    var isLogedInUserIdAdmin =
        admins.where((element) => element.sId == logedInUserId).length;
    if (index >= 0) {
      // check apakah current userid adalah admin
      // check apakah current userid adalah members
      // check apakah current userid adalah creator
      // check apakah post itu public

      if (isLogedInUserIdAdmin == 0) {
        // bukan admin
        if (_question.isPublic) {
          _questions[index] = _question;
        } else {
          var isLogedInUserMember = _question.subscribers
              .where((element) => element.sId == logedInUserId)
              .length;
          var isLogedInUserCreator = _question.creator.sId == logedInUserId;
          if (isLogedInUserCreator == true || isLogedInUserMember > 0) {
            _questions[index] = _question;
          } else {
            _questions.removeWhere((element) => element.sId == _question.sId);
          }
        }
      } else {
        _questions[index] = _question;
      }
    } else {
      if (isLogedInUserIdAdmin == 0) {
        // bukan admin
        if (_question.isPublic) {
          _questions.insert(0, _question);
        } else {
          var isLogedInUserMember = _question.subscribers
              .where((element) => element.sId == logedInUserId)
              .length;
          var isLogedInUserCreator = _question.creator.sId == logedInUserId;
          if (isLogedInUserCreator == true || isLogedInUserMember > 0) {
            _questions.insert(0, _question);
          }
        }
      } else {
        _questions.insert(0, _question);
      }
    }
  }

  onSocketPostArchive(data) {
    CheckInModel _question = CheckInModel.fromJson(data);
    int index =
        _questions.indexWhere((element) => element.sId == _question.sId);
    if (index >= 0) {
      _questions.removeAt(index);
    }
  }

  init() async {
    String checkInId = _teamDetailController.checkInId;

    if (questions.isEmpty) {
      isLoading = true;
      await getQuestions();
      isLoading = false;
      _socketCheckIn.init(checkInId, logedInUserId);
      _socketCheckIn.listener(
          onSocketPostNew, onSocketPostUpdate, onSocketPostArchive);
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel logedInUser = MemberModel.fromJson(userString);
    _logedInUserId.value = logedInUser.sId;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    _socketCheckIn.removeListenFromSocket();
  }
}
