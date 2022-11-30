import 'dart:io';

import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/companies_model.dart';
import 'package:cicle_mobile_f3/models/doc_file_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/service/doc_file_service.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/socket/socket_bucket.dart';
import 'package:cicle_mobile_f3/widgets/default_alert.dart';
import 'package:dio/dio.dart';
import 'package:easy_debounce/easy_debounce.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'doc_files_controller.dart';

class FolderDetailController extends GetxController {
  DocFileService _docFileService = DocFileService();

  String folderId = Get.parameters['folderId'] ?? '';
  SocketBucket _socketBucket = SocketBucket();

  TextEditingController textEditingController = TextEditingController();

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  RefreshController refreshControllerEmpty =
      RefreshController(initialRefresh: false);

  bool _isSocketInit = false;

  var _bucketId = ''.obs;
  String get bucketId => _bucketId.value;
  set bucketId(String value) {
    _bucketId.value = value;
  }

  var _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;
  set errorMessage(String value) {
    _errorMessage.value = value;
  }

  final box = GetStorage();
  var _logedInUserId = ''.obs;
  String get logedInUserId => _logedInUserId.value;
  set logedInUserId(String value) {
    _logedInUserId.value = value;
  }

  var _isLoading = false.obs;
  bool get isLoading => _isLoading.value;
  set isLoading(bool value) {
    _isLoading.value = value;
  }

  var _isPrivate = false.obs;
  bool get isPrivate => _isPrivate.value;
  set isPrivate(bool value) {
    _isPrivate.value = value;
  }

  var _editTitle = false.obs;
  bool get editTitle => _editTitle.value;
  set editTitle(bool value) {
    _editTitle.value = value;
  }

  var _list = <DocFileItemModel>[].obs;
  List<DocFileItemModel> get list {
    return _list;
  }

  set list(List<DocFileItemModel> value) {
    _list.sort((a, b) => a.type.compareTo(b.type));
    _list.value = value;
  }

  var _title = ''.obs;
  String get title => _title.value;
  set title(String value) {
    _title.value = value;
  }

  var _members = <MemberModel>[].obs;
  List<MemberModel> get members => _members;
  set members(List<MemberModel> value) {
    _members.value = [...value];
  }

  var _currentTeam = Teams(sId: '', archived: Archived()).obs;
  Teams get currentTeam => _currentTeam.value;
  set currentTeam(Teams value) {
    _currentTeam.value = value;
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

  Future<void> getBucket() async {
    try {
      errorMessage = '';
      final response = await _docFileService.getBuckets(folderId);

      List<DocFileItemModel> _tempListDocFile = [];
      // for bucket
      if (response.data['bucket'] != null &&
          response.data['bucket']['_id'] != null) {
        bucketId = response.data['bucket']['_id'];
      }
      title = response.data['bucket']['title'];
      isPrivate = response.data['bucket']['isPublic'] != null
          ? !response.data['bucket']['isPublic']
          : false;

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

      // for members
      if (response.data['bucket']['subscribers'] != null) {
        members = [];
        response.data['bucket']['subscribers'].forEach((v) {
          _members.add(new MemberModel.fromJson(v));
        });
      }

      if (response.data['currentTeam'] != null) {
        currentTeam = Teams.fromJson(response.data['currentTeam']);
      }

      _tempListDocFile.sort((a, b) => a.type.compareTo(b.type));
      list = _tempListDocFile;
      return Future.value(true);
    } catch (e) {
      print(e);

      errorMessage = errorMessageMiddleware(e);
      return Future.value(false);
    }
  }

  Future<void> archiveBucket() async {
    try {
      await _docFileService.archiveBucket(folderId);

      showAlert(message: 'Succesfuly archive this folder');
      return Future.value();
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
      return Future.value();
    }
  }

  updateTitle() async {
    if (title == textEditingController.text) {
      editTitle = false;
      return;
    }
    title = textEditingController.text;
    editTitle = false;
    try {
      dynamic body = {
        "isPublic": true,
        "subscribers": subcriberAdapter(members),
        "title": textEditingController.text
      };
      final response = await _docFileService.updateFolderTitle(folderId, body);

      showAlert(
          message:
              response.data['message'] ?? 'Update title bucket successful');
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
    }
  }

  Future<void> updateIsPrivate() async {
    try {
      dynamic body = {
        "isPublic": isPrivate,
        "subscribers": subcriberAdapter(members),
        "title": title
      };

      final response = await _docFileService.updateFolder(folderId, body);

      isPrivate = !isPrivate;
      showAlert(
          message: response.data['message'] ?? 'Update folder successful');
      return Future.value(true);
    } catch (e) {
      print(e);
      errorMessageMiddleware(e);
      return Future.value(false);
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
    // cancelUploadFileToken.cancel('file upload has been canceled by user');
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
        onCancel: () {},
        title: 'are you sure you want to cancel upload ?'));
  }

  createNewFile(File file, String name) async {
    String? _bucketId = Get.parameters['folderId'] ?? '';
    try {
      showOverlay = true;
      uploadProgress = 0.0;
      dynamic body = {"uri": file.path, "name": name};
      final response = await _docFileService.createFile(
          _bucketId, body, setUploadProgress, getTokenCancelUpload);

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
        item.mainParentBucketId == item.localParentBucketId ||
        item.localParentBucketId == folderId) {
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
            e.buckets.insert(0, item);
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

    _list.value = list.map((e) {
      if (e.sId == item.sId) {
        e.title = item.title;
        e.isPublic = item.isPublic;
        return e;
      }

      return e;
    }).toList();

    if (folderId == item.sId) {
      if (item.isPublic == false) {
        getBucket();
      }
      title = item.title ?? title;
    }
  }

  callbackBucketArchive(data) {
    DocFileItemModel item = DocFileItemModel.fromJson(data);
    if (item.mainParentBucketId == null ||
        item.mainParentBucketId == item.localParentBucketId ||
        item.localParentBucketId == folderId) {
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
        item.mainParentBucketId == item.localParentBucketId ||
        item.localParentBucketId == folderId) {
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
    if (item.localParentBucketId == folderId) {
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
        item.mainParentBucketId == item.localParentBucketId ||
        item.localParentBucketId == folderId) {
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
        item.mainParentBucketId == item.localParentBucketId ||
        item.localParentBucketId == folderId) {
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

    if (item.localParentBucketId == folderId) {
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

    if (item.localParentBucketId == folderId) {
      int index = _list.indexWhere((element) => element.sId == item.sId);
      _list[index] = item;
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

    init();
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
