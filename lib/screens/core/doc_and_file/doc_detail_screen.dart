import 'package:cicle_mobile_f3/controllers/doc_detail_controller.dart';
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
import 'package:cicle_mobile_f3/widgets/list_cheers.dart';
import 'package:cicle_mobile_f3/widgets/webview_cummon.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class DocDetailScreen extends StatelessWidget {
  DocDetailController _docDetailController = Get.find();
  String? teamId = Get.parameters['teamId'];
  String? docId = Get.parameters['docId'];
  String companyId = Get.parameters['companyId'] ?? '';

  onDelete() async {
    _docDetailController.archiveDoc();
    Get.back();
    await Future.delayed(Duration(milliseconds: 300));
    Get.back();
  }

  onEdit() async {
    Get.back();
    await Future.delayed(Duration(milliseconds: 300));
    var result = await Get.toNamed(
        '${RouteName.docFormScreen(teamId: teamId!, companyId: companyId)}?docId=$docId&type=edit');
    if (result == true) {
      _docDetailController.init();
    }
  }

  onPressMore() async {
    _docDetailController.commentController.keyEditor.currentState?.unFocus();
    await Future.delayed(Duration(milliseconds: 300));
    Get.bottomSheet(BottomSheetMoreAction(
      onDelete: onDelete,
      onEdit: onEdit,
      titleAlert: 'Archive doc',
    ));
  }

  onPressAdd() {
    Get.bottomSheet(
        BottomSheetAddSubscriber(
          listAllProjectMembers: _docDetailController.teamMembers,
          listSelectedMembers: _docDetailController.members,
          onDone: (List<MemberModel> listSelected) {
            _docDetailController.toggleMembers(listSelected);
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
        title: Obx(() => _docDetailController.isLoading
            ? SizedBox()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _docDetailController.docDetail.title!,
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
                          '${RouteName.teamDetailScreen(companyId)}/${_docDetailController.currentTeam.sId}?destinationIndex=3');
                    },
                    child: Text(
                      '[Docs & Files] - ${_docDetailController.currentTeam.name}',
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
      ),
      body: Obx(() {
        if (_docDetailController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        if (!_docDetailController.isLoading &&
            _docDetailController.errorMessage != '') {
          return Center(
              child: ErrorSomethingWrong(
            refresh: () async {
              return _docDetailController.init();
            },
            message: _docDetailController.errorMessage,
          ));
        }
        return Column(
          children: [
            Expanded(
                child: Comments(
              onRefresh: () async {
                return _docDetailController.init();
              },
              commentController: _docDetailController.commentController,
              header: _buildBody(),
              teamName: _docDetailController.currentTeam.name,
              moduleName: 'Docs & Files',
              parentTitle: _docDetailController.docDetail.title ?? '',
            )),
            Opacity(
              opacity: _docDetailController.showFormCheers ? 0 : 1,
              child: FormAddCommentWidget(
                  members: _docDetailController.teamMembers,
                  commentController: _docDetailController.commentController),
            )
          ],
        );
      }),
    );
  }

  Column _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 2,
        ),
        _buildTitle(),
        _buildCreator(),
        _buildContent(),
        SizedBox(
          height: 2,
        ),
        _buildMembers(),
        SizedBox(
          height: 4,
        ),
        _buildListCheers(_docDetailController),
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

  Container _buildListCheers(DocDetailController controller) {
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

  Container _buildMembers() {
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
                        members: _docDetailController.members.isEmpty
                            ? []
                            : _docDetailController.members,
                      ),
                    )),
              )
            ],
          )
        ],
      ),
    );
  }

  _onLongPressItem(String content) {
    Get.dialog(DialogSelectableWebView(
        content: content
            .replaceAll(">target='_blank'", "")
            .replaceAll("id='isPasted'>", "")
        // .replaceAll(
        //     RegExp(r'(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)'), "")
        ));
    showAlert(message: 'to copy text you can select the content below');
  }

  Container _buildContent() {
    String content = _docDetailController.docDetail.content!;
    return Container(
      color: Colors.white,
      width: double.infinity,
      padding: EdgeInsets.only(left: 23, right: 23, top: 8.5, bottom: 13),
      child: GestureDetector(
        onLongPress: () {
          _onLongPressItem(content);
        },
        child: HtmlWidget(content,
            onTapUrl: parseLinkPressed, textStyle: TextStyle(fontSize: 11.sp),
            customWidgetBuilder: (element) {
          if (element.localName == 'video') {
            print(element);
            String url = element.attributes['src'].toString();
            print(url);
            return GestureDetector(
              onTap: () async {
                print('on tap');

                Navigator.push(Get.context!,
                    MaterialPageRoute(builder: (_) => WebViewCummon(url: url)));
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

  Container _buildCreator() {
    String creatorName = _docDetailController.docDetail.creator!.fullName;
    String photoUrl = _docDetailController.docDetail.creator!.photoUrl;
    String time = DateFormat.Hm().format(
        DateTime.parse(_docDetailController.docDetail.createdAt!).toLocal());
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 23, right: 23, top: 10, bottom: 8.5),
      child: Row(
        children: [
          AvatarCustom(
              height: 24, child: Image.network(getPhotoUrl(url: photoUrl))),
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
          Text(time,
              style: TextStyle(
                  fontSize: 9.sp,
                  color: Colors.black.withOpacity(0.5),
                  fontWeight: FontWeight.w600))
        ],
      ),
    );
  }

  Container _buildTitle() {
    String title = _docDetailController.docDetail.title ?? '';
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(left: 23, top: 12, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                _docDetailController.docDetail.isPublic!
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
                    title,
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
