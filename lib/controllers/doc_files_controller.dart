import 'dart:io';

import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/doc_file_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/doc_file_service.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_bucket.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:dio/dio.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum SortBy { nameAsc, nameDesc, created, updated }

class DocFilesController extends GetxController {
  DocFileService _docFileService = DocFileService();

  SocketBucket _socketBucket = SocketBucket();
  final box = GetStorage();
  late String bucketId;

  bool _isSocketInit = false;

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;
  set logedInUserId(String value) {
    _logedInUserId.value = value;
  }

  var _list = <DocFileItemModel>[].obs;
  List<DocFileItemModel> get list => _list;
  set list(List<DocFileItemModel> value) {
    _list.value = value;
  }

  // SEARCH
  var _searchKey = ''.obs;
  String get searchKey => _searchKey.value;
  set searchKey(String value) {
    _searchKey.value = value;
  }
  // END OF SEARCH

  // SORT
  final _sortBy = SortBy.nameAsc.obs;
  SortBy get sortBy => _sortBy.value;
  set sortBy(SortBy value) {
    _sortBy.value = value;
  }
  // END OF SORT

  getBucket() async {
    try {
      TeamDetailController _teamDetailController = Get.find();

      if (_teamDetailController.backetId == '') {
        await _teamDetailController.getTeam();
      }
      bucketId = _teamDetailController.backetId;
      final response = await _docFileService.getBuckets(bucketId);

      List<DocFileItemModel> _tempListDocFile = [];
      // for bucket
      if (response.data['bucket']['buckets'] != null) {
        response.data['bucket']['buckets'].forEach((v) {
          _tempListDocFile.add(new DocFileItemModel.fromJson(v));
        });
      }
      // for docs
      if (response.data['bucket']['docs'] != null) {
        response.data['bucket']['docs'].forEach((v) {
          _tempListDocFile.add(new DocFileItemModel.fromJson(v));
        });
      }
      //for files
      if (response.data['bucket']['files'] != null) {
        response.data['bucket']['files'].forEach((v) {
          _tempListDocFile.add(new DocFileItemModel.fromJson(v));
        });
      }

      list = _tempListDocFile;
    } catch (e) {
      errorMessageMiddleware(e);
      print(e);
    }
  }

  var _uploadProgress = 0.0.obs;
  double get uploadProgress => _uploadProgress.value;
  set uploadProgress(double value) {
    _uploadProgress.value = value;
  }

  var _showOverlay = false.obs;
  bool get showOverlay => _showOverlay.value;
  set showOverlay(bool value) {
    _showOverlay.value = value;
  }

  var _cancelUploadFileToken = CancelToken().obs;
  CancelToken get cancelUploadFileToken => _cancelUploadFileToken.value;
  set cancelUploadFileToken(CancelToken value) {
    _cancelUploadFileToken.value = value;
  }

  setUploadProgress(double value) {
    uploadProgress = value;
  }

  getTokenCancelUpload(CancelToken token) {
    cancelUploadFileToken = token;
  }

  cancelUploadFile() {
    Get.dialog(DefaultAlert(
        onSubmit: () {
          EasyDebounce.debounce(
              'submit-add-check-in', // <-- An ID for this particular debouncer
              Duration(milliseconds: 300), // <-- The debounce duration
              () {
            Get.back();
            cancelUploadFileToken
                .cancel('file upload has been canceled by user');
          } // <-- The target method
              );
        },
        onCancel: () {
          Get.back();
        },
        title: 'are you sure you want to cancel upload ?'));
    // cancelUploadFileToken.cancel('file upload has been canceled by user');
  }

  createNewFile(File file, String name) async {
    String _bucketId = Get.put(TeamDetailController()).backetId;

    try {
      showOverlay = true;
      uploadProgress = 0.0;

      dynamic body = {"uri": file.path, "name": name};
      final response = await _docFileService.createFile(
          bucketId, body, setUploadProgress, getTokenCancelUpload);

      showOverlay = false;
      uploadProgress = 0.0;
      showAlert(message: response.data['message']);
    } catch (e) {
      print(e);
      showOverlay = false;
      uploadProgress = 0.0;
      errorMessageMiddleware(e);
    }
  }

  callbackNewBucket(data) {
    DocFileItemModel item = DocFileItemModel.fromJson(data);
    if (item.mainParentBucketId == null ||
        item.mainParentBucketId == item.localParentBucketId) {
      int checkIsItemExist =
          _list.indexWhere((element) => element.sId == item.sId);
      if (checkIsItemExist < 0) {
        _list.add(item);
      }
    } else {
      // for child folder update
      String localParentBucketId = item.localParentBucketId ?? '';
      _list.value = list.map((e) {
        if (e.sId == localParentBucketId) {
          List<DocFileItemModel> _tempsBuckets = e.buckets;
          int index =
              _tempsBuckets.indexWhere((element) => element.sId == item.sId);
          if (index < 0) {
            e.buckets.add(item);
          }

          print(e);
          return e;
        }

        return e;
      }).toList();
    }
  }

  callbackBucket(data) {
    DocFileItemModel item = DocFileItemModel.fromJson(data);

    if (item.localParentBucketId == bucketId) {
      _list.value = list.map((e) {
        if (e.sId == item.sId) {
          e.title = item.title;
          e.isPublic = item.isPublic;
          return e;
        }

        return e;
      }).toList();
    } else {
      // update overview
      String localParentBucketId = item.localParentBucketId ?? '';
      _list.value = list.map((e) {
        if (e.sId == localParentBucketId) {
          e.buckets = e.buckets.map((o) {
            if (o.sId == item.sId) {
              return item;
            }
            return o;
          }).toList();
          return e;
        }

        return e;
      }).toList();
    }
  }

  callbackBucketArchive(data) {
    DocFileItemModel item = DocFileItemModel.fromJson(data);
    if (item.mainParentBucketId == null ||
        item.mainParentBucketId == item.localParentBucketId) {
      _list.removeWhere((element) => element.sId == item.sId);
    } else {
      String localParentBucketId = item.localParentBucketId ?? '';
      _list.value = list.map((e) {
        if (e.sId == localParentBucketId) {
          e.buckets.removeWhere((element) => element.sId == item.sId);
          return e;
        }

        return e;
      }).toList();
    }
  }

  callbackNewDoc(data) {
    DocFileItemModel item = DocFileItemModel.fromJson(data);
    if (item.mainParentBucketId == null ||
        item.mainParentBucketId == item.localParentBucketId) {
      int checkIsItemExist =
          _list.indexWhere((element) => element.sId == item.sId);
      if (checkIsItemExist < 0) {
        _list.add(item);
      }
    } else {
      // for child folder update
      String localParentBucketId = item.localParentBucketId ?? '';
      _list.value = list.map((e) {
        if (e.sId == localParentBucketId) {
          List<DocFileItemModel> _tempDocs = e.docs;
          int index =
              _tempDocs.indexWhere((element) => element.sId == item.sId);
          if (index < 0) {
            e.docs.add(item);
          }
          return e;
        }

        return e;
      }).toList();
    }
  }

  callbackUpdateDoc(data) {
    DocFileItemModel item = DocFileItemModel.fromJson(data);

    if (item.localParentBucketId == bucketId) {
      // check isPublic status
      // check logedin id is members of this file
      var getIndexLogedInUserOnMembers = item.subscribers
          .indexWhere((element) => element.sId == logedInUserId);
      if (item.isPublic == false && getIndexLogedInUserOnMembers < 0) {
        _list.removeWhere((element) => element.sId == item.sId);
      } else if (item.isPublic == true) {
        var getIndexOfItem =
            _list.indexWhere((element) => element.sId == item.sId);
        if (getIndexOfItem < 0) {
          _list.add(item);
        }
      } else {
        int index = _list.indexWhere((element) => element.sId == item.sId);
        if (index >= 0) {
          _list[index] = item;
        }
      }
    } else {
      // update overview
      String localParentBucketId = item.localParentBucketId ?? '';
      _list.value = list.map((e) {
        if (e.sId == localParentBucketId) {
          e.docs = e.docs.map((o) {
            if (o.sId == item.sId) {
              return item;
            }
            return o;
          }).toList();
          return e;
        }

        return e;
      }).toList();
    }
  }

  callbackArchiveDoc(data) {
    DocFileItemModel item = DocFileItemModel.fromJson(data);
    if (item.mainParentBucketId == null ||
        item.mainParentBucketId == item.localParentBucketId) {
      _list.removeWhere((element) => element.sId == item.sId);
    } else {
      String localParentBucketId = item.localParentBucketId ?? '';
      _list.value = list.map((e) {
        if (e.sId == localParentBucketId) {
          e.docs.removeWhere((element) => element.sId == item.sId);
          return e;
        }

        return e;
      }).toList();
    }
  }

  callbackNewFile(data) {
    DocFileItemModel item = DocFileItemModel.fromJson(data);
    if (item.mainParentBucketId == null ||
        item.mainParentBucketId == item.localParentBucketId) {
      int checkIsItemExist =
          _list.indexWhere((element) => element.sId == item.sId);
      if (checkIsItemExist < 0) {
        _list.add(item);
      }
    } else {
      // for child folder update
      String localParentBucketId = item.localParentBucketId ?? '';
      _list.value = list.map((e) {
        if (e.sId == localParentBucketId) {
          List<DocFileItemModel> _tempFiles = e.files;
          int index =
              _tempFiles.indexWhere((element) => element.sId == item.sId);
          if (index < 0) {
            e.files.add(item);
          }
          return e;
        }

        return e;
      }).toList();
    }
  }

  callbackUpdateFile(data) {
    DocFileItemModel item = DocFileItemModel.fromJson(data);

    if (item.localParentBucketId == bucketId) {
      // check isPublic status
      // check logedin id is members of this file
      var getIndexLogedInUserOnMembers = item.subscribers
          .indexWhere((element) => element.sId == logedInUserId);
      if (item.isPublic == false && getIndexLogedInUserOnMembers < 0) {
        _list.removeWhere((element) => element.sId == item.sId);
      } else if (item.isPublic == true) {
        var getIndexOfItem =
            _list.indexWhere((element) => element.sId == item.sId);
        if (getIndexOfItem < 0) {
          _list.add(item);
        }
      } else {
        int index = _list.indexWhere((element) => element.sId == item.sId);
        _list[index] = item;
      }
    } else {
      // update overview
      String localParentBucketId = item.localParentBucketId ?? '';
      _list.value = list.map((e) {
        if (e.sId == localParentBucketId) {
          e.files = e.files.map((o) {
            if (o.sId == item.sId) {
              return item;
            }
            return o;
          }).toList();
          return e;
        }

        return e;
      }).toList();
    }
  }

  callbackArchiveFile(data) {
    DocFileItemModel item = DocFileItemModel.fromJson(data);
    if (item.mainParentBucketId == null ||
        item.mainParentBucketId == item.localParentBucketId) {
      _list.removeWhere((element) => element.sId == item.sId);
    } else {
      String localParentBucketId = item.localParentBucketId ?? '';
      _list.value = list.map((e) {
        if (e.sId == localParentBucketId) {
          e.files.removeWhere((element) => element.sId == item.sId);
          return e;
        }

        return e;
      }).toList();
    }
  }

  init() async {
    if (list.isEmpty) {
      isLoading = true;
      await getBucket();
      isLoading = false;

      _isSocketInit = true;
      _socketBucket.init(bucketId, logedInUserId);
      _socketBucket.listener(
          callbackNewBucket,
          callbackBucket,
          callbackBucketArchive,
          callbackNewDoc,
          callbackUpdateDoc,
          callbackArchiveDoc,
          callbackNewFile,
          callbackUpdateFile,
          callbackArchiveFile);
    }
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    TeamDetailController _teamDetailController = Get.find();
    bucketId = _teamDetailController.backetId;
    final userString = box.read(KeyStorage.logedInUser);
    MemberModel _templogedInUser = MemberModel.fromJson(userString);
    logedInUserId = _templogedInUser.sId;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
    if (_isSocketInit) {
      _socketBucket.removeListenFromSocket();
    }
  }
}
