import 'dart:io';

import 'package:cicle_mobile_f3/controllers/download_controller.dart';
import 'package:cicle_mobile_f3/controllers/file_detail_controller.dart';
import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_add_subscriber.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_more_action.dart';
import 'package:cicle_mobile_f3/widgets/comments.dart';
import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';

import 'package:cicle_mobile_f3/widgets/form_add_comment_widget.dart';
import 'package:cicle_mobile_f3/widgets/horizontal_list_member.dart';
import 'package:cicle_mobile_f3/widgets/list_cheers.dart';
import 'package:cicle_mobile_f3/widgets/setup_private.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';

class FileDetailScreen extends StatelessWidget {
  FileDetailScreen({Key? key}) : super(key: key);

  DownloadController _downloadController = Get.put(DownloadController());
  FileDetailController _fileDetailController = Get.find();

  String companyId = Get.parameters['companyId'] ?? '';
  onDelete() async {
    _fileDetailController.archiveFile();
    Get.back();
    await Future.delayed(Duration(milliseconds: 300));
    Get.back();
  }

  onEdit() async {
    Get.back();
  }

  onPressMore() async {
    _fileDetailController.commentController.keyEditor.currentState?.unFocus();
    await Future.delayed(Duration(milliseconds: 300));
    Get.bottomSheet(BottomSheetMoreAction(
      onDelete: onDelete,
      onEdit: onEdit,
      titleAlert: 'Archive file',
      showEdit: false,
    ));
  }

  onPressAdd() {
    Get.bottomSheet(
        BottomSheetAddSubscriber(
          listAllProjectMembers: _fileDetailController.teamMembers,
          listSelectedMembers: _fileDetailController.members,
          onDone: (List<MemberModel> listSelected) {
            _fileDetailController.toggleMembers(listSelected);
          },
        ),
        isDismissible: false,
        isScrollControlled: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Obx(() => _fileDetailController.isLoading
            ? SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fileDetailController.fileDetail.title != null
                        ? _fileDetailController.fileDetail.title!
                        : '',
                    maxLines: 1,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  InkWell(
                    onTap: () async {
                      Get.reset();
                      await Future.delayed(Duration(milliseconds: 300));

                      Get.offAllNamed(RouteName.dashboardScreen(companyId));
                      await Future.delayed(Duration(milliseconds: 300));
                      Get.toNamed(
                          '${RouteName.teamDetailScreen(companyId)}/${_fileDetailController.currentTeam.sId}?destinationIndex=3');
                    },
                    child: Text(
                      '[Docs & Files] - ${_fileDetailController.currentTeam.name}',
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 11,
                          color: Color(0xff708FC7),
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )),
        actions: [
          IconButton(
              onPressed: onPressMore, icon: Icon(Icons.more_vert_outlined))
        ],
      ),
      body: Obx(() {
        if (_fileDetailController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (!_fileDetailController.isLoading &&
            _fileDetailController.errorMessage != '') {
          return Center(
              child: ErrorSomethingWrong(
            refresh: () async {
              return _fileDetailController.init();
            },
            message: _fileDetailController.errorMessage,
          ));
        }
        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Comments(
                    onRefresh: () async {
                      return _fileDetailController.init();
                    },
                    header: _buildBody(),
                    commentController: _fileDetailController.commentController,
                    teamName: _fileDetailController.currentTeam.name,
                    moduleName: 'Docs & Files',
                    parentTitle: _fileDetailController.fileDetail.title ?? '',
                  ),
                ),
                Opacity(
                  opacity: _fileDetailController.showFormCheers ? 0 : 1,
                  child: FormAddCommentWidget(
                      members: _fileDetailController.teamMembers,
                      commentController:
                          _fileDetailController.commentController),
                )
              ],
            ),
            _fileDetailController.isOverflowLoading
                ? Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black.withOpacity(0.5),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SizedBox()
          ],
        );
      }),
    );
  }

  Container _buildBody() => Container(
        child: Column(
          children: [
            _buildHeaderPreview(),
            SizedBox(
              height: 2,
            ),
            Obx(() => Container(
                color: Colors.white,
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                child: Text(
                  _fileDetailController.fileDetail.title ?? 'no name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ))),
            SizedBox(
              height: 2,
            ),
            _buildMembers(),
            SizedBox(
              height: 2,
            ),
            _buildSetupPrivate(),
            SizedBox(
              height: 2,
            ),
            _buildListCheers(_fileDetailController),
            Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 23),
                color: Colors.white,
                child: Text(
                  'Comments & Activities',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                )),
            SizedBox(
              height: 18,
            ),
          ],
        ),
      );

  Container _buildListCheers(FileDetailController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 16, top: 10, right: 16, bottom: 8),
      child: Obx(() => ListCheers(
            cheers: controller.cheers.isEmpty ? [] : controller.cheers,
            logedInUserId: controller.logedInUserId,
            setShowFormCheers: (value) {
              controller.showFormCheers = value;
            },
            showFormCheers: controller.showFormCheers,
            submitAdd: (String value) {
              controller.addCheer(value);
            },
            submitDelete: (CheerItemModel item) {
              Get.back();
              controller.deleteCheer(item);
            },
          )),
    );
  }

  Widget _buildSetupPrivate() {
    return Container(
      margin: EdgeInsets.only(left: 12),
      child: Obx(() => SetupPrivate(
            title: 'Is the file for private only?',
            isPrivate: _fileDetailController.isPrivate,
            onChange: (bool value) {
              _fileDetailController.isPrivate = value;
              _fileDetailController.updatePrivateStatus();
            },
          )),
    );
  }

  Widget _buildHeaderPreview() {
    String? mimeType = lookupMimeType(_fileDetailController.fileDetail.url!);
    if (mimeType != null) {
      if (mimeType.contains('image')) {
        return Container(
          constraints:
              BoxConstraints(minHeight: 300, minWidth: double.infinity),
          child: Stack(
            children: [
              _previewAsImage(),
              Positioned(right: 10, bottom: 10, child: _buildDownloadButton())
            ],
          ),
        );
      }
      return Container(
        constraints: BoxConstraints(minHeight: 300, minWidth: double.infinity),
        child: Stack(
          children: [
            _previewAsWebView(),
            Positioned(right: 10, bottom: 10, child: _buildDownloadButton())
          ],
        ),
      );
    }
    return Container(
      constraints: BoxConstraints(minHeight: 300, minWidth: double.infinity),
      child: Stack(
        children: [
          _previewAsWebView(),
          Positioned(right: 10, bottom: 10, child: _buildDownloadButton())
        ],
      ),
    );
  }

  Obx _previewAsImage() {
    return Obx(() => Container(
          constraints: BoxConstraints(minHeight: 300),
          color: Colors.white,
          child: Image.network(
            getPhotoUrl(url: _fileDetailController.fileDetail.url!),
            fit: BoxFit.cover,
          ),
        ));
  }

  Container _previewAsWebView() {
    String? mimeType = lookupMimeType(_fileDetailController.fileDetail.url!);
    if (mimeType != null) {
      if (Platform.isAndroid) {
        String ext = extensionFromMime(mimeType);
        if (mimeType.contains('video')) {
          return Container(
            constraints: BoxConstraints(minHeight: 300),
            height: 300,
            color: Colors.white,
            child: InAppWebView(
                initialUrlRequest: URLRequest(
                    url: Uri.parse(_fileDetailController.fileDetail.url!)),
                androidOnPermissionRequest:
                    (controller, origin, resources) async {
                  return PermissionRequestResponse(
                      resources: resources,
                      action: PermissionRequestResponseAction.GRANT);
                },
                onLoadError: (ctrl, url, code, message) {
                  print('messageerror $message');
                }),
          );
        }
        return Container(
          constraints: BoxConstraints(minHeight: 300),
          height: 300,
          color: Colors.white,
          child: Center(
            child: Text(
              ext,
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.withOpacity(0.5)),
            ),
          ),
        );
      }
    }

    return Container(
      constraints: BoxConstraints(minHeight: 300),
      height: 300,
      color: Colors.white,
      child: IgnorePointer(
        child: InAppWebView(
            initialUrlRequest: URLRequest(
                url: Uri.parse(_fileDetailController.fileDetail.url!)),
            androidOnPermissionRequest: (controller, origin, resources) async {
              return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT);
            },
            onLoadError: (ctrl, url, code, message) {
              print('messageerror $message');
            }),
      ),
    );
  }

  Widget _buildDownloadButton() {
    String? mimeType = lookupMimeType(_fileDetailController.fileDetail.url!);
    if (mimeType != null) {
      String ext = extensionFromMime(mimeType);
      return ElevatedButton(
        onPressed: () async {
          var grant = await checkPermission();
          if (grant == true) {
            _downloadController.requestDownload(TaskInfo(
                name: _fileDetailController.fileDetail.title ?? 'file',
                link: getPhotoUrl(url: _fileDetailController.fileDetail.url!)));
          }
        },
        style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                EdgeInsets.symmetric(horizontal: 10)),
            overlayColor:
                MaterialStateProperty.all(Colors.grey.withOpacity(0.25)),
            backgroundColor: MaterialStateProperty.all(Colors.white),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ))),
        child: Container(
            child: Row(
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                    color: Theme.of(Get.context!).primaryColor,
                    borderRadius: BorderRadius.circular(5)),
                child: Text(
                  ext.toUpperCase(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                )),
            Container(
              width: 1,
              height: 30,
              margin: EdgeInsets.symmetric(horizontal: 10),
              color: Colors.grey.withOpacity(0.2),
            ),
            Text('Download'),
            SizedBox(
              width: 10,
            ),
            Icon(Icons.file_download_outlined)
          ],
        )),
      );
    }

    return ElevatedButton(
      onPressed: () async {
        print(
            '_fileDetailController.fileDetail.url! ${_fileDetailController.fileDetail.url!}');
      },
      style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(horizontal: 10)),
          overlayColor:
              MaterialStateProperty.all(Colors.grey.withOpacity(0.25)),
          backgroundColor: MaterialStateProperty.all(Colors.white),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ))),
      child: Container(
          child: Row(
        children: [
          Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  color: Theme.of(Get.context!).primaryColor,
                  borderRadius: BorderRadius.circular(5)),
              child: Text(
                '',
                style: TextStyle(color: Colors.white, fontSize: 12),
              )),
          Container(
            width: 1,
            height: 30,
            margin: EdgeInsets.symmetric(horizontal: 10),
            color: Colors.grey.withOpacity(0.2),
          ),
          Text('Download'),
          SizedBox(
            width: 10,
          ),
          Icon(Icons.file_download_outlined)
        ],
      )),
    );
  }

  Container _buildMembers() {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.only(left: 15, top: 10, bottom: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                MyFlutterApp.mdi_account_plus_outline,
                size: 20,
                color: Color(0xffB5B5B5),
              ),
              SizedBox(
                width: 9,
              ),
              Text(
                'Who do you wanna be notified?',
                style: TextStyle(fontSize: 12.sp, color: Color(0xff979797)),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              GestureDetector(
                onTap: onPressAdd,
                child: Container(
                    height: 24.w,
                    width: 24.w,
                    decoration: BoxDecoration(
                        color: Color(0xff708FC7), shape: BoxShape.circle),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    )),
              ),
              SizedBox(
                width: 4,
              ),
              Expanded(
                child: Obx(() => Container(
                      height: 24.w,
                      child: HorizontalListMember(
                        marginItem: EdgeInsets.only(right: 4),
                        height: 24.w,
                        fontSize: 10,
                        members: _fileDetailController.members.isEmpty
                            ? []
                            : _fileDetailController.members,
                      ),
                    )),
              )
            ],
          )
        ],
      ),
    );
  }
}
