import 'dart:io';

import 'package:cicle_mobile_f3/controllers/doc_files_controller.dart';

import 'package:cicle_mobile_f3/controllers/form_new_bucket_controller.dart';
import 'package:cicle_mobile_f3/controllers/team_detail_controller.dart';
import 'package:cicle_mobile_f3/models/doc_file_item_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../team_detail.dart';
import 'doc_item.dart';
import 'file_item.dart';
import 'folder_item.dart';

class DummyObj {
  final String? url;
  final String? title;

  DummyObj({this.url, this.title});
}

class DocFilesScreen extends StatelessWidget {
  DocFilesScreen({Key? key}) : super(key: key);

  TeamDetailController _teamDetailController = Get.find();

  RefreshController refreshController =
      RefreshController(initialRefresh: false);

  RefreshController refreshControllerWithData =
      RefreshController(initialRefresh: false);

  RefreshController refreshControllerEmpty =
      RefreshController(initialRefresh: false);

  void onRefresh(DocFilesController controller) async {
    await controller.getBucket();
    refreshController.refreshCompleted();
  }

  void onRefreshEmpty(DocFilesController controller) async {
    await controller.getBucket();
    refreshControllerEmpty.refreshCompleted();
  }

  void onRefreshWithData(DocFilesController controller) async {
    await controller.getBucket();
    refreshControllerWithData.refreshCompleted();
  }

  onPressAdd(DocFilesController controller) {
    Get.bottomSheet(BottomSheetDocAndFile(
      folderId: _teamDetailController.backetId,
      createNewFile: (File? file, String name) {
        controller.createNewFile(file!, name);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Obx(() => Text(
              _teamDetailController.teamName,
              style: TextStyle(fontSize: 16),
            )),
        elevation: 0.0,
        actions: [
          SizedBox(
            width: 10,
          ),
          ActionsAppBarTeamDetail(
            showSetting: false,
          )
        ],
      ),
      body: GetX<DocFilesController>(
          init: DocFilesController(),
          initState: (state) {
            state.controller?.init();
          },
          builder: (controller) {
            if (controller.isLoading && controller.list.isEmpty) {
              return _buildLoading();
            }

            if (!controller.isLoading && controller.list.isEmpty) {
              return Stack(
                children: [
                  Scaffold(
                    body: _buildEmpty(controller),
                    floatingActionButton: FloatingActionButton(
                      heroTag: 'doc-and-file',
                      onPressed: () => onPressAdd(controller),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Obx(() => controller.showOverlay
                      ? Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                              child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularProgressIndicator(),
                              Text(
                                '${controller.uploadProgress.ceil()} %',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 150),
                                  child: ElevatedButton(
                                      onPressed: controller.cancelUploadFile,
                                      child: Text('Cancel Upload')))
                            ],
                          )))
                      : SizedBox())
                ],
              );
            }
            return Stack(
              children: [
                Scaffold(
                  body: _buildHasData(controller, context),
                  floatingActionButton: FloatingActionButton(
                    heroTag: 'doc-and-file',
                    onPressed: () => onPressAdd(controller),
                    child: Icon(
                      Icons.add,
                      color: Colors.white,
                    ),
                  ),
                ),
                Obx(() => controller.showOverlay
                    ? Stack(
                        children: [
                          Container(
                              height: double.infinity,
                              width: double.infinity,
                              color: Colors.black.withOpacity(0.5),
                              child: Center(
                                  child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  Text(
                                    '${controller.uploadProgress.ceil()} %',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11),
                                  ),
                                ],
                              ))),
                          Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                                onPressed: controller.cancelUploadFile,
                                icon: Icon(Icons.close, color: Colors.white)),
                          )
                        ],
                      )
                    : SizedBox())
              ],
            );
          }),
    );
  }

  GestureDetector _buildHasData(DocFilesController controller, context) {
    List<DocFileItemModel> list = controller.list;
    // list.sort((a, b) => a.type.compareTo(b.type));

    List<DocFileItemModel> listOfFolder = list
        .where((o) =>
            o.type == 'bucket' &&
            o.title!.toLowerCase().contains(controller.searchKey.toLowerCase()))
        .toList();

    List<DocFileItemModel> listOfDoc = list
        .where((o) =>
            o.type == 'doc' &&
            o.title!.toLowerCase().contains(controller.searchKey.toLowerCase()))
        .toList();

    List<DocFileItemModel> listOfFile = list
        .where((o) =>
            o.type == 'file' &&
            o.title!.toLowerCase().contains(controller.searchKey.toLowerCase()))
        .toList();

    if (controller.sortBy == SortBy.nameAsc) {
      listOfFolder.sort(
          (a, b) => a.title!.toLowerCase().compareTo(b.title!.toLowerCase()));
      listOfDoc.sort(
          (a, b) => a.title!.toLowerCase().compareTo(b.title!.toLowerCase()));
      listOfFile.sort(
          (a, b) => a.title!.toLowerCase().compareTo(b.title!.toLowerCase()));
    } else if (controller.sortBy == SortBy.nameDesc) {
      listOfFolder.sort(
          (a, b) => b.title!.toLowerCase().compareTo(a.title!.toLowerCase()));
      listOfDoc.sort(
          (a, b) => b.title!.toLowerCase().compareTo(a.title!.toLowerCase()));
      listOfFile.sort(
          (a, b) => b.title!.toLowerCase().compareTo(a.title!.toLowerCase()));
    } else if (controller.sortBy == SortBy.created) {
      listOfFolder.sort((a, b) =>
          DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!)));
      listOfDoc.sort((a, b) =>
          DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!)));
      listOfFile.sort((a, b) =>
          DateTime.parse(b.createdAt!).compareTo(DateTime.parse(a.createdAt!)));
    } else if (controller.sortBy == SortBy.updated) {
      listOfFolder.sort((a, b) =>
          DateTime.parse(b.updatedAt!).compareTo(DateTime.parse(a.updatedAt!)));
      listOfDoc.sort((a, b) =>
          DateTime.parse(b.updatedAt!).compareTo(DateTime.parse(a.updatedAt!)));
      listOfFile.sort((a, b) =>
          DateTime.parse(b.updatedAt!).compareTo(DateTime.parse(a.updatedAt!)));
    }

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildSearchInput(controller),
                ),
                // IconButton(
                //     onPressed: () {},
                //     icon: Icon(Icons.sort, color: Colors.grey))
                _buildButtonSort(controller, context),
              ],
            ),
          ),
          Expanded(
            child: SmartRefresher(
              header: WaterDropMaterialHeader(),
              controller: refreshControllerWithData,
              onRefresh: () => onRefreshWithData(controller),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  listOfFolder.isEmpty
                      ? SizedBox()
                      : Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 26, top: 15, bottom: 8),
                                child: Text(
                                  'Folders',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                            GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              crossAxisCount: 2,
                              childAspectRatio: 150 / 163,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              children: listOfFolder
                                  .asMap()
                                  .map((key, value) =>
                                      MapEntry(key, FolderItem(item: value)))
                                  .values
                                  .toList(),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(),
                            )
                          ],
                        ),
                  listOfDoc.isEmpty
                      ? SizedBox()
                      : Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 26, top: 15, bottom: 8),
                                child: Text(
                                  'Docs',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                            GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              crossAxisCount: 2,
                              childAspectRatio: 150 / 163,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              children: listOfDoc
                                  .asMap()
                                  .map((key, value) =>
                                      MapEntry(key, DocItem(item: value)))
                                  .values
                                  .toList(),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(),
                            )
                          ],
                        ),
                  listOfFile.isEmpty
                      ? SizedBox()
                      : Column(
                          children: [
                            Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 26, top: 15, bottom: 8),
                                child: Text(
                                  'Files',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                ),
                              ),
                            ),
                            GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              crossAxisCount: 2,
                              childAspectRatio: 150 / 163,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              children: listOfFile
                                  .asMap()
                                  .map((key, value) =>
                                      MapEntry(key, FileItem(item: value)))
                                  .values
                                  .toList(),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Divider(),
                            )
                          ],
                        )
                ],
              )),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuButton<int> _buildButtonSort(
      DocFilesController controller, BuildContext context) {
    return PopupMenuButton(
      // offset: Offset(14, -20),
      icon: Icon(Icons.sort, color: Colors.grey),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          height: 35,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Sort By",
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xff979797),
                    fontWeight: FontWeight.bold),
              ),
              Divider()
            ],
          ),
          value: 99,
        ),
        PopupMenuItem(
          height: 35,
          child: Text(
            "Name A-Z",
            style: TextStyle(
                fontSize: 14,
                color: controller.sortBy == SortBy.nameAsc
                    ? Colors.amber
                    : Color(0xff979797)),
          ),
          value: 1,
        ),
        PopupMenuItem(
          height: 35,
          child: Text(
            "Name Z-A",
            style: TextStyle(
                fontSize: 14,
                color: controller.sortBy == SortBy.nameDesc
                    ? Colors.amber
                    : Color(0xff979797)),
          ),
          value: 2,
        ),
        PopupMenuItem(
          height: 35,
          child: Text(
            "Date Created",
            style: TextStyle(
                fontSize: 14,
                color: controller.sortBy == SortBy.created
                    ? Colors.amber
                    : Color(0xff979797)),
          ),
          value: 3,
        ),
        PopupMenuItem(
          height: 35,
          child: Text(
            "Date Updated",
            style: TextStyle(
                fontSize: 14,
                color: controller.sortBy == SortBy.updated
                    ? Colors.amber
                    : Color(0xff979797)),
          ),
          value: 4,
        ),
      ],
      onSelected: (int value) {
        Future.delayed(const Duration(milliseconds: 600), () {
          FocusScope.of(context).unfocus();
        });

        switch (value) {
          case 1:
            Future.delayed(const Duration(milliseconds: 300), () {
              controller.sortBy = SortBy.nameAsc;
            });

            return;
          case 2:
            Future.delayed(const Duration(milliseconds: 300), () {
              controller.sortBy = SortBy.nameDesc;
            });

            return;
          case 3:
            Future.delayed(const Duration(milliseconds: 300), () {
              controller.sortBy = SortBy.created;
            });

            return;
          case 4:
            Future.delayed(const Duration(milliseconds: 300), () {
              controller.sortBy = SortBy.updated;
            });

            return;
          default:
            return;
        }
      },
    );
  }

  TextField _buildSearchInput(DocFilesController controller) {
    return TextField(
      // controller: _textEditingControllerInputCardName,
      // focusNode: _focusNodeInputCardName,
      onChanged: (value) {
        // setState(() {
        //   _keywordInputCardName = value;
        // });
        controller.searchKey = value;
      },
      style: TextStyle(fontSize: 11),
      decoration: InputDecoration(
        isDense: true,
        contentPadding:
            EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
        hintText: "Search docs or files...",
        hintStyle: TextStyle(color: Color(0xffB5B5B5), fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: new BorderRadius.circular(15.0),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.5)),
        ),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(15.0),
          ),
        ),
      ),
    );
  }

  Center _buildLoading() => Center(child: CircularProgressIndicator());

  SmartRefresher _buildEmpty(DocFilesController _docFileController) {
    var column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 89.w,
        ),
        Image.asset(
          'assets/images/doc_and_file.png',
          height: 145.w,
          width: 247.w,
          fit: BoxFit.contain,
        ),
        Container(
            margin: EdgeInsets.symmetric(horizontal: 34, vertical: 20),
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            width: 306.w,
            child: Column(
              children: [
                Text(
                  'No data here yet...',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.sp, color: Color(0xffB5B5B5)),
                ),
              ],
            ))
      ],
    );
    return SmartRefresher(
      header: WaterDropMaterialHeader(),
      controller: refreshControllerEmpty,
      onRefresh: () => onRefreshEmpty(_docFileController),
      child: ListView.builder(
          padding: EdgeInsets.only(top: 4),
          itemCount: 1,
          itemBuilder: (ctx, index) {
            return column;
          }),
    );
  }
}

class BottomSheetDocAndFile extends StatelessWidget {
  BottomSheetDocAndFile({
    Key? key,
    required this.folderId,
    required this.createNewFile,
  }) : super(key: key);

  final String folderId;
  final Function(File file, String name) createNewFile;

  String? teamId = Get.parameters['teamId'];
  String companyId = Get.parameters['companyId'] ?? '';

  onAddDoc() async {
    Get.back();
    await Future.delayed(Duration(milliseconds: 200));
    Get.toNamed(
        '${RouteName.docFormScreen(teamId: teamId!, companyId: companyId)}?folderId=$folderId');
  }

  onAddFolder() async {
    Get.back();
    await Future.delayed(Duration(milliseconds: 300));
    Get.dialog(FormNewFolder(folderId: folderId));
  }

  onUploadFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files[0].name;

      createNewFile(file, fileName);
    } else {
      // User canceled the picker
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 195,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15))),
      child: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          ListTile(
            minLeadingWidth: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Icon(
                Icons.insert_drive_file_outlined,
                color: Color(0xff708FC7),
              ),
            ),
            onTap: onAddDoc,
            title: Text(
              'Add a new doc',
              style: TextStyle(
                  color: Color(0xff708FC7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: SizedBox(height: 0, child: Divider()),
          ),
          ListTile(
            minLeadingWidth: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Icon(
                Icons.folder_outlined,
                color: Color(0xff708FC7),
              ),
            ),
            onTap: onAddFolder,
            title: Text(
              'Create a new folder',
              style: TextStyle(
                  color: Color(0xff708FC7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 23),
            child: SizedBox(height: 0, child: Divider()),
          ),
          ListTile(
            minLeadingWidth: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Icon(
                Icons.publish_outlined,
                color: Color(0xff708FC7),
              ),
            ),
            onTap: onUploadFile,
            title: Text(
              'Upload File',
              style: TextStyle(
                  color: Color(0xff708FC7),
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class FormNewFolder extends StatelessWidget {
  const FormNewFolder({
    Key? key,
    required this.folderId,
  }) : super(key: key);

  final String folderId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 13),
          margin:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), color: Colors.white),
          width: 310,
          child: GetX<FormNewBucketController>(
              init: FormNewBucketController(),
              builder: (controller) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 5,
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text('Create new folder'),
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: controller.textEditingController,
                      minLines: 1,
                      maxLines: 5,
                      onChanged: (value) {
                        controller.text = value;
                      },
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.fromLTRB(15, 10, 10, 10),
                        hintText: "folder name...",
                        hintStyle:
                            TextStyle(color: Color(0xffB5B5B5), fontSize: 11),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.5)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(20.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: controller.loading
                          ? SizedBox(
                              height: 25,
                              width: 25,
                              child: Center(
                                  child: CircularProgressIndicator(
                                strokeWidth: 2,
                              )))
                          : ElevatedButton(
                              onPressed: () async {
                                await controller.create(folderId);
                                FocusScope.of(context).unfocus();
                                await Future.delayed(
                                    Duration(milliseconds: 300));
                                Get.back();
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ))),
                              child: Container(
                                  width: 68,
                                  child: Center(
                                      child: Text(
                                    'Create',
                                    style: TextStyle(color: Colors.white),
                                  )))),
                    )
                  ],
                );
              }),
        ),
      ),
    );
    ;
  }
}
