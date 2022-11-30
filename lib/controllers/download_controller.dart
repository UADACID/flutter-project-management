import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:get_storage/get_storage.dart';

const debug = false;

class DownloadController extends GetxController {
  late String _localPath;
  ReceivePort _port = ReceivePort();
  // List<TaskInfo>? _tasks;

  var _tasks = <TaskInfo>[].obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);
    _prepareSaveDir();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    _unbindBackgroundIsolate();
    super.onClose();
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) {
      print('listen');
      if (debug) {
        print('UI Isolate Callback: $data');
      }
      String? id = data[0];
      DownloadTaskStatus? status = data[1];
      int? progress = data[2];
      print('listen progress $progress');

      if (_tasks.isNotEmpty) {
        final task = _tasks.firstWhere((task) => task.taskId == id);
        print('status ZZZZZ $status');
        if (progress != null && progress >= 100) {
          // final task = _tasks!.firstWhere((task) => task.taskId == id);
          EasyDebounce.debounce(
              'submit-add-check-in', // <-- An ID for this particular debouncer
              Duration(milliseconds: 300), // <-- The debounce duration
              () => showAlert(
                  message: Platform.isIOS
                      ? '${task.name} downloaded to File -> on my iphone -> Cicle'
                      : '${task.name} downloaded',
                  flashDuration: 10,
                  customActionWidget: GestureDetector(
                    onTap: () {
                      openDownloadedFile(task);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'OPEN',
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.w500),
                      ),
                    ),
                  )) // <-- The target method
              );
        }
      }
    });
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    print('id $id status $status progress $progress');
    if (debug) {
      print(
          'Background Isolate Callback: task ($id) is in status ($status) and process ($progress)');
    }

    if (progress >= 100) {
      print('status alertttttt');

      // showAl();
    }
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void showAl() {
    showAlert(message: 'wkwk start to download');
  }

  void requestDownload(TaskInfo task) async {
    try {
      showAlert(message: '${task.name} start to download');
      task.taskId = await FlutterDownloader.enqueue(
          url: task.link!,
          savedDir: _localPath,
          showNotification: true,
          saveInPublicStorage: true,
          openFileFromNotification: true);
      _tasks.add(task);
    } catch (e) {
      print(e);
      showAlert(message: '${task.name} failed to download');
    }
  }

  void _cancelDownload(TaskInfo task) async {
    await FlutterDownloader.cancel(taskId: task.taskId!);
  }

  void _pauseDownload(TaskInfo task) async {
    await FlutterDownloader.pause(taskId: task.taskId!);
  }

  void _resumeDownload(TaskInfo task) async {
    String? newTaskId = await FlutterDownloader.resume(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  void _retryDownload(TaskInfo task) async {
    String? newTaskId = await FlutterDownloader.retry(taskId: task.taskId!);
    task.taskId = newTaskId;
  }

  Future<bool> openDownloadedFile(TaskInfo? task) {
    if (task != null) {
      return FlutterDownloader.open(taskId: task.taskId!);
    } else {
      return Future.value(false);
    }
  }

  Future<void> _prepareSaveDir() async {
    // _localPath = (await _findLocalPath())! +
    //     Platform.pathSeparator +
    //     'Cicle Download Files';

    // final savedDir = Directory(_localPath);
    // bool hasExisted = await savedDir.exists();
    // print('hasExisted $hasExisted _localPath $_localPath savedDir $savedDir');
    // if (!hasExisted) {
    //   savedDir.create();
    // }
    _localPath = (await _findLocalPath())!;
    print('local path: $_localPath');
    final savedDir = Directory(_localPath);
    print('local path save dir: $savedDir');
    final hasExisted = savedDir.existsSync();
    if (!hasExisted) {
      await savedDir.create();
    }
  }

  // Future<String?> _findLocalPath() async {
  //   if (Platform.isAndroid) {
  //     final directoryAndroid = await getExternalStorageDirectory();
  //     return directoryAndroid!.path;
  //   }

  //   final directory = await getApplicationDocumentsDirectory();
  //   String? result = directory.path;

  //   return result;
  // }

  Future<String?> _findLocalPath() async {
    String? externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return externalStorageDirPath;
  }

  var _teamMembers = <MemberModel>[].obs;
  List<MemberModel> get teamMembers => _teamMembers;
}

class TaskInfo {
  String? name;
  final String? link;

  String? taskId;
  int? progress = 0;
  DownloadTaskStatus? status = DownloadTaskStatus.undefined;

  TaskInfo({this.name, this.link, this.taskId});
}
