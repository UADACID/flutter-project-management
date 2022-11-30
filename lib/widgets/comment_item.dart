import 'package:cicle_mobile_f3/controllers/comment_controller.dart';
import 'package:cicle_mobile_f3/controllers/search_controller.dart';

import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';

import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';
import 'package:cicle_mobile_f3/widgets/bottom_sheet_more_action.dart';

import 'package:cicle_mobile_f3/widgets/froala_editor.dart';
import 'package:cicle_mobile_f3/widgets/photo_view_section.dart';
import 'package:cicle_mobile_f3/widgets/webview_cummon.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:darq/darq.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'cheer_item.dart';

import 'dialog_selectable_webview.dart';
import 'form_input_cheer.dart';
import 'inline_widget_html.dart';

checkIsSameFirstDay(list, index) {
  int _previousIndex = index - 1;
  bool _hasPreviousItem =
      _previousIndex >= 0 ? (list[index - 1] != null ? true : false) : false;
  bool result = _hasPreviousItem
      ? DateFormat('yyyy-MM-dd').format(
                  DateTime.parse(list[index - 1].createdAt).toLocal()) ==
              DateFormat('yyyy-MM-dd')
                  .format(DateTime.parse(list[index].createdAt).toLocal())
          ? false
          : true
      : true;
  return result;
}

class CommentItem extends StatelessWidget {
  CommentItem(
      {Key? key,
      required this.commentController,
      required this.comment,
      this.canReply = true,
      this.hide = false,
      required this.list,
      required this.index,
      required this.teamName,
      required this.moduleName,
      required this.parentTitle})
      : super(key: key);
  final faker = Faker(provider: FakerDataProvider());
  final CommentController commentController;
  final CommentItemModel comment;
  final bool canReply;
  final bool hide;
  final List<CommentItemModel> list;
  final int index;

  // FOR RECENTLY VIEWED
  final String teamName;
  final String moduleName;
  final String parentTitle;

  String? teamId = Get.parameters['teamId'];
  String companyId = Get.parameters['companyId'] ?? '';
  String? occurenceId = Get.parameters['occurenceId'];

  String userName = '';

  String content = '';

  onPressMore() {
    Get.bottomSheet(BottomSheetMoreAction(
      onDelete: () async {
        commentController.deleteComment(comment.sId);
        Get.back();
        await Future.delayed(Duration(milliseconds: 300));
        Get.back();
      },
      onEdit: () async {
        Get.back();
        await Future.delayed(Duration(milliseconds: 300));
        Get.dialog(FroalaEditor(
          initialContent: comment.content,
          commentController: commentController,
          title: 'Edit',
          onSubmit: (String value) {
            commentController.editComment(comment.sId, value);
          },
          members: commentController.listMentionmembers,
        ));
      },
      textEdit: 'Edit Comment',
      titleAlert: 'Archive comment?',
    ));
  }

  _onLongPressItem() {
    Get.dialog(DialogSelectableWebView(
        content: comment.content
            .replaceAll(">target='_blank'", "")
            .replaceAll("id='isPasted'>", "")
        // .replaceAll(
        //     RegExp(r'(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|gif|png)'), "")
        ));
    showAlert(message: 'to copy text you can select the content below');
  }

  @override
  Widget build(BuildContext context) {
    String date =
        DateFormat.jm().format(DateTime.parse(comment.createdAt).toLocal());

    String dateCummon =
        DateFormat.yMEd().format(DateTime.parse(comment.createdAt).toLocal());

    bool isSameFirstDay = checkIsSameFirstDay(list, index);

    String dateTimeAgo =
        timeago.format(DateTime.parse(comment.createdAt).toLocal());

    bool isCreatedAtMoreThan3dayAgo =
        calculateDifference(DateTime.parse(comment.createdAt).toLocal()) <= -3
            ? true
            : false;

    bool showMoreButton =
        comment.creator.sId == commentController.logedInUserId;

    if (hide) {
      return SizedBox();
    }

    String targetCommentId = Get.parameters['targetCommentId'] ?? '';

    Color getContainerColor() {
      if (comment.sId == targetCommentId) {
        return Theme.of(context).primaryColor.withOpacity(0.3);
      }

      return Colors.transparent;
    }

    EdgeInsets getPadding() {
      if (comment.sId == targetCommentId) {
        return EdgeInsets.symmetric(vertical: 10);
      }

      return EdgeInsets.zero;
    }

    return Container(
      color: getContainerColor(),
      padding: getPadding(),
      margin: EdgeInsets.only(bottom: 6, top: 6),
      child: Column(
        children: [
          isSameFirstDay
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    isCreatedAtMoreThan3dayAgo ? dateCummon : dateTimeAgo,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                )
              : Container(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 13,
              ),
              Container(
                  margin: EdgeInsets.only(top: 6),
                  height: 48,
                  child: AvatarCustom(
                    height: 48,
                    child: Image.network(
                      getPhotoUrl(url: comment.creator.photoUrl),
                      height: 48,
                      width: 48,
                      fit: BoxFit.cover,
                    ),
                  )),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10, right: 12),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 13,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 18.0),
                                        child: Text(comment.creator.fullName,
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff393E46))),
                                      ),
                                    ),
                                    showMoreButton
                                        ? GestureDetector(
                                            onTap: () {
                                              onPressMore();
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Icon(
                                                Icons.more_horiz_outlined,
                                                color: Color(0xff979797),
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onLongPress: _onLongPressItem,
                                        child: Container(
                                          // decoration: BoxDecoration(
                                          //     border: Border.all()),
                                          child: HtmlWidget(
                                              comment.content
                                                  .replaceAll(
                                                      ">target='_blank'", "")
                                                  .replaceAll(
                                                      "id='isPasted'>", "")
                                                  .replaceAll(
                                                      ' style=\"box-sizing: border-box; padding: 0px; margin: 0px; font-size: 1rem; overflow-wrap: break-word; white-space: normal;\"', '')
                                                  .replaceAll(
                                                      " style='box-sizing: border-box; padding: 0px; margin: 0px 0px 1rem; list-style-position: inside; color: rgb(33, 37, 41); font-family: Nunito, \"Open Sans\"; font-size: 16px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; background-color: rgb(255, 255, 255);'",
                                                      '')
                                                  .replaceAll(
                                                      ' style=\"box-sizing: border-box; padding: 0px; margin: 0px; font-size: 1rem; overflow-wrap: break-word; white-space: normal;\"',
                                                      "")
                                                  .replaceAll(
                                                      ' style=\"font-size: 16px; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-indent: 0px; text-transform: none; white-space: normal; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; box-sizing: border-box; padding: 0px; margin: 0px 0px 1rem; list-style-position: inside; color: rgb(33, 37, 41); font-family: Nunito, &quot;Open Sans&quot;; text-align: left; background-color: rgb(255, 255, 255);\"',
                                                      "")
                                                  .replaceAll(
                                                      "<blockquote><p style='box-sizing: border-box; padding: 0px; margin: 0px 0px 5px; font-size: 16px; overflow-wrap: break-word; white-space: normal; color: rgb(33, 37, 41); font-family: Nunito, \"Open Sans\"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; background-color: rgb(255, 255, 255);'>",
                                                      "<blockquote><p style='box-sizing: border-box; padding: 0px; margin: 0px 0px 5px; font-size: 16px; overflow-wrap: break-word; white-space: normal; color: rgb(33, 37, 41); font-family: Nunito, \"Open Sans\"; font-style: normal; font-variant-ligatures: normal; font-variant-caps: normal; font-weight: 400; letter-spacing: normal; orphans: 2; text-align: left; text-indent: 0px; text-transform: none; widows: 2; word-spacing: 0px; -webkit-text-stroke-width: 0px; text-decoration-thickness: initial; text-decoration-style: initial; text-decoration-color: initial; background-color: rgb(220, 220, 220);'>")
                                                  .replaceAll(
                                                      "font-size: 16px;",
                                                      "font-size: 12px;"),
                                              onTapUrl: parseLinkPressed,
                                              textStyle:
                                                  TextStyle(fontSize: 12),
                                              onTapImage:
                                                  (ImageMetadata imageData) {
                                                String url =
                                                    imageData.sources.length > 0
                                                        ? imageData
                                                            .sources.first.url
                                                        : 'default uri';
                                                Get.dialog(PhotoViewSection(
                                                  url: url,
                                                ));
                                              },
                                              factoryBuilder: () =>
                                                  InlineWidget(),
                                              customWidgetBuilder: (element) {
                                                if (element.localName ==
                                                    'video') {
                                                  print(element);
                                                  String url = element
                                                      .attributes['src']
                                                      .toString();

                                                  return GestureDetector(
                                                    onTap: () async {
                                                      Get.to(WebViewCummon(
                                                        url: url,
                                                        isVideo: true,
                                                      ));
                                                    },
                                                    onLongPress: () {},
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              20.0),
                                                      child: ConstrainedBox(
                                                        constraints:
                                                            new BoxConstraints(
                                                          minHeight: 75.0,
                                                          minWidth: 150.0,
                                                          maxHeight: 200.0,
                                                          maxWidth: 300.0,
                                                        ),
                                                        child: Container(
                                                          color: Colors.black,
                                                          child: Center(
                                                            child: Icon(
                                                              Icons
                                                                  .play_circle_fill_rounded,
                                                              color:
                                                                  Colors.white,
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
                                      ),
                                    ),
                                    comment.cheers.length > 0
                                        ? SizedBox(
                                            width: 20,
                                          )
                                        : buildButtonCheer(context)
                                  ],
                                ),
                                SizedBox(
                                  height: 14,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          )
                        ],
                      ),
                      comment.cheers.length > 0
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: buildListCheers(context)))
                          : SizedBox(),
                      Obx(() => commentController.selectedCommentIdFormCheers ==
                                  comment.sId &&
                              comment.discussions.length == 0
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 8, left: 10),
                                child: FormInputCheers(
                                  onClose: () async {
                                    FocusScope.of(context).unfocus();
                                    await Future.delayed(
                                        Duration(milliseconds: 300));
                                    commentController
                                        .selectedCommentIdFormCheers = '';
                                  },
                                  onSubmit: (String? text) {
                                    commentController
                                        .selectedCommentIdFormCheers = '';
                                    commentController.addCheersToComment(
                                        comment.sId,
                                        text!,
                                        comment.creator.sId);
                                  },
                                ),
                              ))
                          : SizedBox()),
                      Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: Color(0xffB5B5B5),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(date,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff979797))),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 18.5,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          Obx(() =>
              commentController.selectedCommentIdFormCheers == comment.sId &&
                      comment.discussions.length > 0
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 30.0),
                        child: FormInputCheers(
                          onClose: () async {
                            FocusScope.of(context).unfocus();
                            await Future.delayed(Duration(milliseconds: 300));
                            commentController.selectedCommentIdFormCheers = '';
                          },
                          onSubmit: (String? text) {
                            commentController.selectedCommentIdFormCheers = '';
                            commentController.addCheersToComment(
                                comment.sId, text!, comment.creator.sId);
                          },
                        ),
                      ))
                  : SizedBox()),
          comment.discussions.length > 0
              ? GestureDetector(
                  onTap: () {
                    String _moduleName = commentController.typeModule;
                    String _moduleId = commentController.moduleId;

                    if (occurenceId != null) {
                      String path =
                          '${RouteName.commentDetailScreen(companyId, teamId!, 'occurrence', _moduleId, comment.sId)}?occurrenceId=$occurenceId';

                      Get.put(SearchController()).insertListRecenlyViewed(
                          RecentlyViewed(
                              moduleName: 'comment-detail',
                              companyId: companyId,
                              path: path,
                              teamName: teamName,
                              title: '[COMMENT] $parentTitle',
                              subtitle:
                                  'Home  >  $teamName  >  $moduleName  >  $parentTitle',
                              uniqId: comment.sId));
                      Get.toNamed(
                          '${RouteName.commentDetailScreen(companyId, teamId!, 'occurrence', _moduleId, comment.sId)}?occurrenceId=$occurenceId');
                    } else {
                      String path = RouteName.commentDetailScreen(companyId,
                          teamId!, _moduleName, _moduleId, comment.sId);
                      Get.put(SearchController()).insertListRecenlyViewed(
                          RecentlyViewed(
                              moduleName: 'comment-detail',
                              companyId: companyId,
                              path: path,
                              teamName: teamName,
                              title: '[COMMENT] $parentTitle',
                              subtitle:
                                  'Home  >  $teamName  >  $moduleName  >  $parentTitle',
                              uniqId: comment.sId));
                      Get.toNamed(path);
                    }
                  },
                  child: buildListReply(context))
              : GestureDetector(
                  onTap: () {
                    String _moduleName = commentController.typeModule;
                    String _moduleId = commentController.moduleId;

                    if (occurenceId != null) {
                      String path =
                          '${RouteName.commentDetailScreen(companyId, teamId!, 'occurrence', _moduleId, comment.sId)}?occurrenceId=$occurenceId';
                      Get.put(SearchController()).insertListRecenlyViewed(
                          RecentlyViewed(
                              moduleName: 'comment-detail',
                              companyId: companyId,
                              path: path,
                              teamName: teamName,
                              title: '[COMMENT] $parentTitle',
                              subtitle:
                                  'Home  >  $teamName  >  $moduleName  >  $parentTitle',
                              uniqId: comment.sId));
                      Get.toNamed(path);
                    } else {
                      String path = RouteName.commentDetailScreen(companyId,
                          teamId!, _moduleName, _moduleId, comment.sId);
                      Get.put(SearchController()).insertListRecenlyViewed(
                          RecentlyViewed(
                              moduleName: 'comment-detail',
                              companyId: companyId,
                              path: path,
                              teamName: teamName,
                              title: '[COMMENT] $parentTitle',
                              subtitle:
                                  'Home  >  $teamName  >  $moduleName  >  $parentTitle',
                              uniqId: comment.sId));
                      Get.toNamed(path);
                    }
                  },
                  child: canReply ? buildReplyButton() : SizedBox()),
        ],
      ),
    );
  }

  showOptionCheers(CheerItemModel item) {
    if (commentController.logedInUserId != item.creator.sId) {
      return;
    }
    Get.bottomSheet(BottomSheetOptionCheers(
      item: item,
      onPressDelete: () {
        Get.back();
        commentController.deleteCheersFromComment(comment.sId, item.sId);
      },
    ));
  }

  Padding buildListCheers(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        children: [
          ...comment.cheers
              .asMap()
              .map((key, value) => MapEntry(
                  key,
                  InkWell(
                    onTap: () {
                      showOptionCheers(value);
                    },
                    child: CheerItem(
                      item: value,
                    ),
                  )))
              .values
              .toList(),
          buildButtonCheer(context)
        ],
      ),
    );
  }

  Widget buildButtonCheer(BuildContext context) {
    return GestureDetector(
      onTap: () {
        commentController.selectedCommentIdFormCheers = comment.sId;
      },
      child: Container(
          padding: EdgeInsets.all(2),
          height: 30,
          width: 30,
          decoration: BoxDecoration(
              border:
                  Border.all(width: 1, color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(30)),
          child: Image.asset(
            'assets/images/cheers.png',
            fit: BoxFit.contain,
          )),
    );
  }

  Align buildListReply(BuildContext context) {
    List<Discussions> listReplies = comment.discussions;
    int repliesCounter = listReplies.length;
    var distinctListByCreatorId =
        listReplies.distinct((d) => d.creator.sId).toList();
    int _realLengthList = distinctListByCreatorId.length;

    if (distinctListByCreatorId.length > 3) {
      distinctListByCreatorId.length = 3;
    }

    int plusCounter = _realLengthList - distinctListByCreatorId.length;
    String dateTimeAgo = timeago.format(
        DateTime.parse(distinctListByCreatorId.last.createdAt).toLocal());
    return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding:
              const EdgeInsets.only(right: 29.0, top: 8, bottom: 5, left: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                margin: EdgeInsets.only(left: 71),
                height: 24,
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: distinctListByCreatorId.length,
                    shrinkWrap: true,
                    itemBuilder: (ctx, index) {
                      Discussions replyItem = distinctListByCreatorId[index];
                      return AvatarCustom(
                        height: 24,
                        child: Image.network(
                          getPhotoUrl(url: replyItem.creator.photoUrl),
                          height: 24,
                          width: 24,
                          fit: BoxFit.cover,
                        ),
                      );
                    }),
              ),
              plusCounter > 0
                  ? Container(
                      height: 24,
                      width: 24,
                      margin: EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                          color: Color(0xff708FC7), shape: BoxShape.circle),
                      child: Center(
                          child: Text('$plusCounter+',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.white))),
                    )
                  : Container(),
              Text(' $repliesCounter Replies',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff708FC7))),
              Text(' Last reply:',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.normal,
                      color: Color(0xff262727))),
              SizedBox(
                width: 4,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                    color: Color(0xffDEEAFF),
                    borderRadius: BorderRadius.circular(5)),
                child: Text(dateTimeAgo,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                        color: Color(0xff262727))),
              ),
            ],
          ),
        ));
  }

  Widget buildReplyButton() {
    return Container(
        child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 29.0, top: 5, bottom: 5, left: 5),
              child: Text('Reply',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff7A7A7A))),
            )));
  }
}

class BottomSheetOptionCheers extends StatelessWidget {
  const BottomSheetOptionCheers({
    Key? key,
    required this.item,
    required this.onPressDelete,
  }) : super(key: key);

  final CheerItemModel item;
  final Function onPressDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(19), topRight: Radius.circular(19))),
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CheerItem(item: item),
          InkWell(
            onTap: () => onPressDelete(),
            child: Icon(
              Icons.delete_outline_outlined,
              color: Colors.red,
            ),
          )
        ],
      ),
    );
  }
}
