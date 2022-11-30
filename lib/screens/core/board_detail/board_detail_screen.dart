import 'package:cicle_mobile_f3/controllers/board_detail_controller.dart';
import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
import 'package:cicle_mobile_f3/utils/my_flutter_app_icons.dart';

import 'package:cicle_mobile_f3/widgets/comments.dart';
import 'package:cicle_mobile_f3/widgets/error_something_wrong.dart';

import 'package:cicle_mobile_f3/widgets/form_add_comment_widget.dart';
import 'package:cicle_mobile_f3/widgets/list_cheers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart';

import 'attachments_widget.dart';
import 'creator_widget.dart';
import 'due_date_widget.dart';
import 'header.dart';
import 'labels_widget.dart';
import 'notes_widget.dart';
import 'position_widget.dart';
import 'subscriber_widget.dart';
import 'title_widget.dart';

class BoardDetailScreen extends StatelessWidget {
  BoardDetailScreen({Key? key}) : super(key: key);

  final _boardDetailController = Get.find<BoardDetailController>();

  refresh() {}

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _boardDetailController.showForm = false;
      },
      child: Scaffold(
        body: Obx(() {
          if (!_boardDetailController.isLoading &&
              _boardDetailController.errorMessage != '') {
            return Scaffold(
                appBar: AppBar(),
                body: Center(
                    child: ErrorSomethingWrong(
                  refresh: () {
                    _boardDetailController.init();
                  },
                  message: _boardDetailController.errorMessage,
                )));
          }

          return _buildHasData();
        }),
      ),
    );
  }

  Column _buildHasData() {
    return Column(
      children: [
        Header(
          boardDetailController: _boardDetailController,
        ),
        Obx(() => !_boardDetailController.cardDetail.archived.status
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
                    Text('This card is archived')
                  ],
                ),
              )),
        Expanded(
          child: Comments(
            header: _buildHeader(),
            commentController: _boardDetailController.commentController,
            footer: _buildFooter(),
            onRefresh: () async {
              return _boardDetailController.init();
            },
            teamName: _boardDetailController.teamName,
            moduleName: 'Board',
            parentTitle: _boardDetailController.title,
          ),
        ),
        Obx(() {
          if (!_boardDetailController.isLoading &&
              _boardDetailController.errorMessage == '') {
            return Opacity(
              opacity: _boardDetailController.showFormCheers ? 0 : 1,
              child: FormAddCommentWidget(
                  members: _boardDetailController.teamMembers,
                  commentController: _boardDetailController.commentController),
            );
          }
          return SizedBox();
        })
      ],
    );
  }

  Column _buildHeader() {
    return Column(
      children: [
        TitleWidget(boardDetailController: _boardDetailController),
        SizedBox(height: 1, child: Divider()),
        Position_Widget(boardDetailController: _boardDetailController),
        SizedBox(height: 1, child: Divider()),
        CreatorWidget(boardDetailController: _boardDetailController),
        DueDateWidget(
          boardDetailController: _boardDetailController,
        ),
        LabelsWidget(
          boardDetailController: _boardDetailController,
        ),
        SizedBox(height: 1, child: Divider()),
        NotesWidget(
          boardDetailController: _boardDetailController,
        ),
        SizedBox(height: 1, child: Divider()),
        AttachmentWidget(boardDetailController: _boardDetailController),
        SizedBox(height: 1, child: Divider()),
        SubscriberWidget(
          boardDetailController: _boardDetailController,
        ),
        SizedBox(height: 1, child: Divider()),
        _buildListCheers(_boardDetailController),
        Container(
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 27),
          color: Colors.white,
          width: double.infinity,
          child: Text(
            'Comments & Activities',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(
          height: 24,
        ),
      ],
    );
  }

  Container _buildListCheers(BoardDetailController controller) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: 21, top: 15, right: 16, bottom: 8),
      child: Obx(() => controller.isLoading
          ? SizedBox()
          : ListCheers(
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

  Column _buildFooter() {
    return Column(
      children: [
        SizedBox(
          height: 21,
        ),
        CreatedCardWidget(),
        SizedBox(
          height: 21,
        ),
      ],
    );
  }
}

class CreatedCardWidget extends StatelessWidget {
  const CreatedCardWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

TextStyle label = TextStyle(color: Color(0xff7A7A7A), fontSize: 12);
