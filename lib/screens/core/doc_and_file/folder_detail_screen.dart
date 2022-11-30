import 'dart:io';

import 'package:cicle_mobile_f3/controllers/folder_detail_controller.dart';

import 'package:cicle_mobile_f3/utils/constant.dart';

import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../controllers/doc_files_controller.dart';
import '../../../models/doc_file_item_model.dart';
import 'doc_files_screen.dart';
import 'doc_item.dart';
import 'file_item.dart';
import 'folder_item.dart';

class FolderDetailScreen extends StatelessWidget {
  FolderDetailScreen({Key? key}) : super(key: key);
  String folderId = Get.parameters['folderId']!;
  String companyId = Get.parameters['companyId'] ?? '';

  FolderDetailController _folderDetailController = Get.find();

  void onRefresh(RefreshController refreshController) async {
    await _folderDetailController.getBucket();
    refreshController.refreshCompleted();
  }

  onPressAdd() {
    Get.bottomSheet(BottomSheetDocAndFile(
      folderId: folderId,
      createNewFile: (File? file, String name) {
        _folderDetailController.createNewFile(file!, name);
      },
    ));
  }

  onDelete() async {
    _folderDetailController.archiveBucket();
    Get.back();
    await Future.delayed(Duration(milliseconds: 300));
  }

  onChangeName() {
    _folderDetailController.editTitle = !_folderDetailController.editTitle;
    _folderDetailController.textEditingController.text =
        _folderDetailController.title;
  }

  onArchive() {
    onDelete();
  }

  onUpdatePrivate() {
    _folderDetailController.updateIsPrivate();
  }

  @override
  Widget build(BuildContext context) {
    var appBar = AppBar();
    return Material(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).padding.top,
          ),
          Container(
            height: appBar.preferredSize.height,
            width: double.infinity,
            color: Theme.of(context).appBarTheme.backgroundColor,
            child: Row(
              children: [
                Obx(() => _folderDetailController.editTitle
                    ? IconButton(
                        onPressed: () {
                          _folderDetailController.editTitle = false;
                        },
                        icon: Icon(Icons.close))
                    : IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: Icon(Icons.arrow_back))),
                Expanded(
                    child: Obx(() => !_folderDetailController.editTitle
                        ? Row(
                            children: [
                              !_folderDetailController.isPrivate
                                  ? SizedBox()
                                  : Padding(
                                      padding:
                                          const EdgeInsets.only(right: 4.0),
                                      child: Icon(
                                        Icons.lock_rounded,
                                        size: 20,
                                      ),
                                    ),
                              Expanded(child: _buildTitle()),
                              !_folderDetailController.isLoading &&
                                      _folderDetailController.errorMessage != ''
                                  ? SizedBox()
                                  : Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 30),
                                      child: PopupMenuButton(
                                        offset: Offset(14, -20),
                                        icon: Icon(
                                          Icons.more_vert_outlined,
                                          color: Color(0xffB5B5B5),
                                        ),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            height: 35,
                                            child: Text(
                                              "Change name",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xff979797)),
                                            ),
                                            value: 1,
                                          ),
                                          PopupMenuItem(
                                            height: 35,
                                            child: Text(
                                              "Archive",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xff979797)),
                                            ),
                                            value: 2,
                                          ),
                                          PopupMenuItem(
                                            height: 35,
                                            child: Text(
                                              _folderDetailController.isPrivate
                                                  ? "Set access to public"
                                                  : "Set to private",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xff979797)),
                                            ),
                                            value: 3,
                                          ),
                                        ],
                                        onSelected: (int value) {
                                          switch (value) {
                                            case 1:
                                              return onChangeName();
                                            case 2:
                                              return onArchive();
                                            case 3:
                                              return onUpdatePrivate();
                                            default:
                                              return;
                                          }
                                        },
                                      ),
                                    ),
                            ],
                          )
                        : _buildInputEditTitle())),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_folderDetailController.isLoading &&
                  _folderDetailController.list.isEmpty) {
                return _buildLoading();
              }

              if (!_folderDetailController.isLoading &&
                  _folderDetailController.errorMessage != '') {
                return Center(
                    child: ErrorSomethingWrong(
                  refresh: () =>
                      onRefresh(_folderDetailController.refreshController),
                  message: _folderDetailController.errorMessage,
                ));
              }

              if (!_folderDetailController.isLoading &&
                  _folderDetailController.list.isEmpty) {
                return Stack(
                  children: [
                    Scaffold(
                      body: _buildEmpty(),
                      floatingActionButton: FloatingActionButton(
                        onPressed: onPressAdd,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Obx(() => _folderDetailController.showOverlay
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
                                        '${_folderDetailController.uploadProgress.ceil()} %',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 11),
                                      ),
                                    ],
                                  ))),
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                    onPressed: _folderDetailController
                                        .cancelUploadFile,
                                    icon:
                                        Icon(Icons.close, color: Colors.white)),
                              )
                            ],
                          )
                        : SizedBox())
                  ],
                );
              }

              return Stack(
                children: [
                  _buildHasData(_folderDetailController, context),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: FloatingActionButton(
                      onPressed: onPressAdd,
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Obx(() => _folderDetailController.showOverlay
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
                                '${_folderDetailController.uploadProgress.ceil()} %',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 11),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 150),
                                  child: ElevatedButton(
                                      onPressed: _folderDetailController
                                          .cancelUploadFile,
                                      child: Text('Cancel Upload')))
                            ],
                          )))
                      : SizedBox())
                ],
              );

              // return Scaffold(
              //   body: _buildHasData(_folderDetailController, context),
              //   floatingActionButton: FloatingActionButton(
              //     onPressed: onPressAdd,
              //     child: Icon(
              //       Icons.add,
              //       color: Colors.white,
              //     ),
              //   ),
              // );
              // return Stack(
              //   children: [
              //     Scaffold(
              //       body: _buildHasData(_folderDetailController, context),
              //       floatingActionButton: FloatingActionButton(
              //         onPressed: onPressAdd,
              //         child: Icon(
              //           Icons.add,
              //           color: Colors.white,
              //         ),
              //       ),
              //     ),
              //     Obx(() => _folderDetailController.showOverlay
              //         ? Container(
              //             height: double.infinity,
              //             width: double.infinity,
              //             color: Colors.black.withOpacity(0.5),
              //             child: Center(
              //                 child: Stack(
              //               alignment: Alignment.center,
              //               children: [
              //                 CircularProgressIndicator(),
              //                 Text(
              //                   '${_folderDetailController.uploadProgress.ceil()} %',
              //                   style: TextStyle(
              //                       color: Colors.white, fontSize: 11),
              //                 ),
              //                 Container(
              //                     margin: EdgeInsets.only(top: 150),
              //                     child: ElevatedButton(
              //                         onPressed: _folderDetailController
              //                             .cancelUploadFile,
              //                         child: Text('Cancel Upload')))
              //               ],
              //             )))
              //         : SizedBox())
              //   ],
              // );
            }),
          ),
        ],
      ),
    );
  }

  Obx _buildTitle() {
    return Obx(() => InkWell(
          onTap: () {
            _folderDetailController.editTitle =
                !_folderDetailController.editTitle;
            if (_folderDetailController.editTitle) {
              _folderDetailController.textEditingController.text =
                  _folderDetailController.title;
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => Text(
                      _folderDetailController.title,
                      style: Theme.of(Get.context!).textTheme.headline6,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )),
                InkWell(
                  onTap: () async {
                    Get.reset();
                    await Future.delayed(Duration(milliseconds: 300));
                    Get.offAllNamed(RouteName.dashboardScreen(companyId));
                    await Future.delayed(Duration(milliseconds: 300));
                    Get.toNamed(
                        '${RouteName.teamDetailScreen(companyId)}/${_folderDetailController.currentTeam.sId}?destinationIndex=3');
                  },
                  child: Text(
                    '[Docs & Files] - ${_folderDetailController.currentTeam.name}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff708FC7)),
                  ),
                )
              ],
            ),
          ),
        ));
  }

  Widget _buildInputEditTitle() {
    return Row(
      children: [
        Expanded(
            child: TextField(
                controller: _folderDetailController.textEditingController,
                style: TextStyle(fontSize: 19),
                decoration: InputDecoration(
                    errorText: null,
                    isDense: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(10.0),
                      borderSide:
                          BorderSide(color: Colors.grey.withOpacity(0.5)),
                    ),
                    contentPadding: EdgeInsets.fromLTRB(15, 10, 10, 10),
                    border: OutlineInputBorder(
                      borderRadius: const BorderRadius.all(
                        const Radius.circular(10.0),
                      ),
                    ),
                    hintStyle: TextStyle(
                        fontSize: 19,
                        color: Color(0xffB5B5B5),
                        fontWeight: FontWeight.w600),
                    hintText: 'Type a folder name...'))),
        IconButton(
            onPressed: () {
              _folderDetailController.updateTitle();
            },
            icon: Icon(Icons.check))
      ],
    );
  }

  GestureDetector _buildHasData(FolderDetailController controller, context) {
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
                _buildButtonSort(controller, context),
              ],
            ),
          ),
          Expanded(
            child: SmartRefresher(
              header: WaterDropMaterialHeader(),
              controller: _folderDetailController.refreshController,
              onRefresh: () =>
                  onRefresh(_folderDetailController.refreshController),
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
      FolderDetailController controller, BuildContext context) {
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

  TextField _buildSearchInput(FolderDetailController controller) {
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

  // Widget _buildHasData() {
  //   return Obx(() {
  //     return SmartRefresher(
  //       header: WaterDropMaterialHeader(),
  //       controller: _folderDetailController.refreshController,
  //       onRefresh: () => onRefresh(_folderDetailController.refreshController),
  //       child: GridView.count(
  //         primary: false,
  //         padding: const EdgeInsets.all(20),
  //         crossAxisSpacing: 10,
  //         mainAxisSpacing: 10,
  //         crossAxisCount: 2,
  //         childAspectRatio: 150 / 163,
  //         children: _folderDetailController.list
  //             .asMap()
  //             .map((key, value) {
  //               Widget widget = Container();
  //               if (value.type == 'file') {
  //                 widget = FileItem(
  //                   item: value,
  //                 );
  //               }
  //               if (value.type == 'bucket') {
  //                 widget = FolderItem(item: value);
  //               }
  //               if (value.type == 'doc') {
  //                 widget = DocItem(item: value);
  //               }
  //               return MapEntry(key, widget);
  //             })
  //             .values
  //             .toList(),
  //       ),
  //     );
  //   });
  // }

  Center _buildLoading() => Center(child: CircularProgressIndicator());

  SmartRefresher _buildEmpty() {
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
      controller: _folderDetailController.refreshControllerEmpty,
      onRefresh: () =>
          onRefresh(_folderDetailController.refreshControllerEmpty),
      child: ListView.builder(
          padding: EdgeInsets.only(top: 4),
          itemCount: 1,
          itemBuilder: (ctx, index) {
            return column;
          }),
    );
  }
}
