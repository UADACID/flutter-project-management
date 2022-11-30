import 'package:cicle_mobile_f3/controllers/blast_detail_controller.dart';
import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_add_subscriber.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_more_action.dart';

import 'package:cicle_mobile_f3/widgets/comments.dart';
import 'package:cicle_mobile_f3/widgets/dialog_selectable_webview.dart';
import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';

import 'package:cicle_mobile_f3/widgets/form_add_comment_widget.dart';

import 'package:cicle_mobile_f3/widgets/horizontal_list_member.dart';
import 'package:cicle_mobile_f3/widgets/inline_widget_html.dart';
import 'package:cicle_mobile_f3/widgets/list_cheers.dart';
import 'package:cicle_mobile_f3/widgets/photo_view_section.dart';
import 'package:cicle_mobile_f3/widgets/webview_cummon.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BlastDetailScreen extends StatelessWidget {
  String? teamId = Get.parameters['teamId'];
  String? postId = Get.parameters['blastId'];
  String companyId = Get.parameters['companyId'] ?? '';

  BlastDetailController _blastDetailController = Get.find();

  onDelete() async {
    try {
      Get.back();
      await Future.delayed(Duration(milliseconds: 300));
      Get.back();
      await Future.delayed(Duration(milliseconds: 300));
      await _blastDetailController.archivePost(postId!);
      showAlert(message: 'Post has been archived');
    } catch (e) {
      if (e is DioError) {
        showAlert(message: 'Failed to archive, ${e.response!.statusCode}');
      }
    }
  }

  onEdit() async {
    Get.back();
    await Future.delayed(Duration(milliseconds: 300));
    Get.toNamed(
        '${RouteName.blastFormScreen(companyId: companyId, teamId: teamId!)}?blastId=$postId&type=edit');
  }

  onPressMore() async {
    _blastDetailController.commentController.keyEditor.currentState?.unFocus();
    await Future.delayed(Duration(milliseconds: 300));
    Get.bottomSheet(BottomSheetMoreAction(
      onDelete: onDelete,
      onEdit: onEdit,
      titleAlert: 'Delete event',
    ));
  }

  onPressAdd(BlastDetailController controller) {
    Get.bottomSheet(
        BottomSheetAddSubscriber(
          listAllProjectMembers: controller.teamMembers,
          listSelectedMembers: controller.members,
          onDone: (List<MemberModel> listSelected) {
            controller.toggleMembers(listSelected);
          },
        ),
        isDismissible: false,
        isScrollControlled: true);
  }

  _onRefresh() async {
    return _blastDetailController.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Obx(() => _blastDetailController.isLoading
            ? SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _blastDetailController.post.title,
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
                          '${RouteName.teamDetailScreen(companyId)}/${_blastDetailController.currentTeam.sId}?destinationIndex=1');
                    },
                    child: Text(
                      '[Blast] - ${_blastDetailController.currentTeam.name}',
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 11.sp,
                          color: Color(0xff708FC7),
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )),
      ),
      body: Obx(() {
        if (_blastDetailController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }

        if (!_blastDetailController.isLoading &&
            _blastDetailController.errorMessage != '') {
          return Center(
              child: ErrorSomethingWrong(
            refresh: _onRefresh,
            message: _blastDetailController.errorMessage,
          ));
        }
        return Column(
          children: [
            Obx(() => !_blastDetailController.post.archived.status
                ? SizedBox()
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                    color: Theme.of(Get.context!).primaryColor.withOpacity(0.5),
                    child: Row(
                      children: [
                        Icon(
                          MyFlutterApp.archive,
                          size: 16,
                          color: Colors.black,
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Text('This post is archived')
                      ],
                    ),
                  )),
            Expanded(
                child: Comments(
              onRefresh: _onRefresh,
              commentController: _blastDetailController.commentController,
              header: _buildBody(_blastDetailController),
              teamName: _blastDetailController.currentTeam.name,
              moduleName: 'Blast',
              parentTitle: _blastDetailController.post.title,
            )),
            Opacity(
              opacity: _blastDetailController.showFormCheers ? 0 : 1,
              child: FormAddCommentWidget(
                  members: _blastDetailController.teamMembers,
                  commentController: _blastDetailController.commentController),
            )
          ],
        );
      }),
    );
  }

  Column _buildBody(BlastDetailController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 2,
        ),
        _buildTitle(controller),
        _buildComplete(controller),
        _buildCreator(controller),
        _buildContent(controller),
        SizedBox(
          height: 2,
        ),
        _buildMembers(controller),
        SizedBox(
          height: 4,
        ),
        _buildListCheers(controller),
        SizedBox(
          height: 4,
        ),
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
    );
  }

  Container _buildListCheers(BlastDetailController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 21, top: 10, right: 16, bottom: 8),
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

  Container _buildComplete(BlastDetailController controller) {
    return Container(
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Obx(() => Checkbox(
                value: controller.isComplete,
                onChanged: (value) {
                  controller.isComplete = value!;
                  controller.updateCompleteStatus(value);
                })),
            Text(
              'Complete this post',
              style: TextStyle(fontSize: 12),
            )
          ],
        ));
  }

  Container _buildMembers(BlastDetailController controller) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.only(left: 23, top: 10, bottom: 15, right: 15),
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
                onTap: () => onPressAdd(controller),
                child: Container(
                    height: 24.w,
                    width: 24.w,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 1,
                        offset: Offset(1, 1),
                      ),
                    ], color: Color(0xff708FC7), shape: BoxShape.circle),
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
              controller.members.isEmpty
                  ? SizedBox()
                  : Expanded(
                      child: Container(
                        height: 24.w,
                        child: HorizontalListMember(
                          marginItem: EdgeInsets.only(right: 4),
                          height: 24.w,
                          fontSize: 10,
                          members: controller.members,
                        ),
                      ),
                    )
            ],
          )
        ],
      ),
    );
  }

  Container _buildContent(BlastDetailController controller) {
    _onLongPressItem() {
      Get.dialog(DialogSelectableWebView(
          content: controller.post.content
              .replaceAll(">target='_blank'", "")
              .replaceAll("id='isPasted'>", "")
          // .replaceAll(
          //     RegExp(r'(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)'), "")
          ));
      showAlert(message: 'to copy text you can select the content below');
    }

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 23, right: 23, top: 8.5, bottom: 13),
      child: GestureDetector(
        onLongPress: _onLongPressItem,
        child: HtmlWidget(controller.post.content,
            onTapUrl: parseLinkPressed,
            textStyle: TextStyle(fontSize: 11.sp),
            factoryBuilder: () => InlineWidget(),
            onTapImage: (ImageMetadata imageData) {
              String url = imageData.sources.length > 0
                  ? imageData.sources.first.url
                  : 'default uri';
              Get.dialog(PhotoViewSection(
                url: url,
              ));
            },
            customWidgetBuilder: (element) {
              if (element.localName == 'video') {
                print(element);
                String url = element.attributes['src'].toString();
                print(url);
                return GestureDetector(
                  onTap: () async {
                    print('on tap');

                    Get.to(WebViewCummon(url: url));
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ConstrainedBox(
                      constraints: new BoxConstraints(
                        minHeight: 75.0,
                        minWidth: 150.0,
                        maxHeight: 200.0,
                        maxWidth: 300.0,
                      ),
                      child: Container(
                        color: Colors.black,
                        child: Center(
                          child: Icon(
                            Icons.play_circle_fill_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return null;
            }),
      ),
    );
  }

  Container _buildCreator(BlastDetailController controller) {
    String creatorName = controller.post.creator.fullName;
    String photoUrl = controller.post.creator.photoUrl;
    String _tempDate = controller.post.createdAt;
    String date = DateFormat.Hm().format(DateTime.parse(_tempDate).toLocal());
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 23, right: 23, top: 10, bottom: 8.5),
      child: Row(
        children: [
          AvatarCustom(
              height: 24,
              child: Image.network(
                getPhotoUrl(url: photoUrl),
                height: 24,
                width: 24,
                fit: BoxFit.cover,
              )),
          SizedBox(
            width: 10,
          ),
          Text(creatorName,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: Color(0xff708FC7),
                  fontWeight: FontWeight.w600)),
          Container(
            width: 1,
            height: 12,
            color: Colors.grey,
            margin: EdgeInsets.symmetric(horizontal: 7),
          ),
          Text(date,
              style: TextStyle(
                  fontSize: 9.sp,
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.w600))
        ],
      ),
    );
  }

  Container _buildTitle(BlastDetailController controller) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 23, top: 12, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                controller.post.isPublic
                    ? SizedBox()
                    : Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 20,
                        ),
                      ),
                Flexible(
                  child: Text(
                    controller.post.title,
                    style:
                        TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          IconButton(onPressed: onPressMore, icon: Icon(Icons.more_vert))
        ],
      ),
    );
  }
}

String dummyText = '''
What is Lorem Ipsum?
Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, ting and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,  ting and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.

</br>
</br>
What is Lorem Ipsum?
Lorem Ipsum is simply dummy text of the printin
''';
