import 'package:cicle_mobile_f3/controllers/comment_controller.dart';
import 'package:cicle_mobile_f3/controllers/comment_detail_controller.dart';

import 'package:cicle_mobile_f3/models/cheer_item_model.dart';

import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/avatar_custom.dart';

import 'package:cicle_mobile_f3/widgets/comments.dart';

import 'package:cicle_mobile_f3/widgets/form_add_comment_widget.dart';

import 'package:cicle_mobile_f3/widgets/inline_widget_html.dart';
import 'package:cicle_mobile_f3/widgets/list_cheers.dart';
import 'package:cicle_mobile_f3/widgets/photo_view_section.dart';
import 'package:cicle_mobile_f3/widgets/shimmer_custom.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CommentDetailScreen extends StatelessWidget {
  CommentDetailScreen({Key? key}) : super(key: key);

  CommentDetailController commentDetailController =
      Get.find<CommentDetailController>();
  String? moduleName = Get.parameters['moduleName'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        centerTitle: false,
        title: Obx(() => commentDetailController.isLoadingTitle
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerCustom(
                    width: 180,
                    height: 12,
                  ),
                  SizedBox(
                    height: 6,
                  ),
                  ShimmerCustom(
                    width: 100,
                    height: 12,
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Text('reply comment ',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                          Text('in ',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.grey,
                                  fontSize: 11)),
                          InkWell(
                            onTap: commentDetailController.handlePressTitle,
                            child: Text(commentDetailController.parentTitle,
                                style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    InkWell(
                      onTap: commentDetailController.handlePressSubtitle,
                      child: Text(
                        '[${commentDetailController.titleAdapter(moduleName)}] ${commentDetailController.teamName}',
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xff708FC7),
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
      ),
      body: Obx(() {
        if (commentDetailController.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Expanded(
              child: Comments(
                onRefresh: () async {
                  return commentDetailController.init();
                },
                header: HeaderCommentDetail(
                    commentController:
                        commentDetailController.commentController,
                    commentDetailController: commentDetailController),
                canReply: false,
                commentController: commentDetailController.commentController,
                teamName: commentDetailController.teamName,
                moduleName: 'Comment Detail',
                parentTitle: commentDetailController.titleAdapter(moduleName),
              ),
            ),
            FormAddCommentWidget(
                members: commentDetailController.teamMembers,
                commentController: commentDetailController.commentController)
          ],
        );
      }),
    );
  }
}

class HeaderCommentDetail extends StatefulWidget {
  HeaderCommentDetail({
    Key? key,
    this.hasReply = false,
    this.hasCheers = false,
    required this.commentDetailController,
    required this.commentController,
  }) : super(key: key);

  final bool hasReply;
  final bool hasCheers;
  final CommentDetailController commentDetailController;
  final CommentController commentController;

  @override
  _HeaderCommentDetailState createState() => _HeaderCommentDetailState();
}

class _HeaderCommentDetailState extends State<HeaderCommentDetail> {
  bool _showFormCheer = false;
  final faker = Faker(provider: FakerDataProvider());

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: Offset(0.0, 1.0), //(x,y)
            blurRadius: 1.0,
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() {
            String userName =
                widget.commentDetailController.comment.creator.fullName;
            String photoUrl =
                widget.commentDetailController.comment.creator.photoUrl;
            String content = widget.commentDetailController.comment.content;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 13,
                ),
                Container(
                  margin: EdgeInsets.only(top: 11),
                  height: 28,
                  child: AvatarCustom(
                      height: 28,
                      child: Image.network(
                        getPhotoUrl(url: photoUrl),
                        height: 28,
                        width: 28,
                        fit: BoxFit.cover,
                      )),
                ),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Text(userName,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff393E46))),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  HtmlWidget(
                                    content,
                                    onTapUrl: parseLinkPressed,
                                    textStyle: TextStyle(fontSize: 12),
                                    onTapImage: (ImageMetadata imageData) {
                                      String url = imageData.sources.length > 0
                                          ? imageData.sources.first.url
                                          : 'default uri';
                                      Get.dialog(PhotoViewSection(
                                        url: url,
                                      ));
                                    },
                                    factoryBuilder: () => InlineWidget(),
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
                        _buildListCheers(widget.commentDetailController),
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
                              Text(
                                  DateFormat('yyyy-MM-dd hh:mm').format(
                                      DateTime.parse(widget
                                          .commentDetailController
                                          .comment
                                          .updatedAt)),
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
                SizedBox(
                  width: 10,
                )
              ],
            );
          }),
          SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  Container _buildListCheers(CommentDetailController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 21, top: 10, right: 16, bottom: 8),
      child: Obx(() => ListCheers(
            cheers: controller.cheersRx.isEmpty ? [] : controller.cheersRx,
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

  Widget buildButtonCheer(BuildContext context) {
    return SizedBox();
  }

  Align buildListReply(BuildContext context) {
    return Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding:
              const EdgeInsets.only(right: 29.0, top: 8, bottom: 5, left: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 24,
                width: 24,
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle),
              ),
              Container(
                height: 24,
                width: 24,
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle),
              ),
              Text(' 2 Replies',
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
                child: Text('Yesterday',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.normal,
                        color: Color(0xff262727))),
              ),
            ],
          ),
        ));
  }
}
