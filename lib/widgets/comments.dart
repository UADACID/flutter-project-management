import 'package:cicle_mobile_f3/controllers/comment_controller.dart';

import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/widgets/comment_item.dart';
import 'package:cicle_mobile_f3/widgets/shimmer_custom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Comments extends StatelessWidget {
  Comments({
    Key? key,
    this.canReply = true,
    required this.commentController,
    required this.header,
    this.footer,
    this.onRefresh,
    required this.teamName,
    required this.moduleName,
    required this.parentTitle,
  }) : super(key: key);
  final bool canReply;
  final CommentController commentController;
  final Widget header;
  final Widget? footer;
  final Function? onRefresh;

  // FOR RECENTLY VIEWED
  final String teamName;
  final String moduleName;
  final String parentTitle;

  void _onRefresh() async {
    if (onRefresh != null) {
      await onRefresh!();
    }
    commentController.refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Widget mandatoryWidget = Column(
        children: [
          header,
          CommentItem(
            index: 0,
            list: commentController.comments,
            hide: true,
            commentController: commentController,
            comment: CommentItemModel(creator: Creator(), sId: ''),
            teamName: teamName,
            moduleName: moduleName,
            parentTitle: parentTitle,
          )
        ],
      );

      List<Widget> listData = [mandatoryWidget];

      if (commentController.loading && commentController.comments.length == 0) {
        listData.add(Container(
          height: 200,
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 13,
              ),
              Container(
                  margin: EdgeInsets.only(top: 6),
                  height: 48,
                  child: ShimmerCustom(
                    height: 48,
                    width: 48,
                    borderRadius: 48,
                  )),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: 6, left: 10, right: 12),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15)),
                    padding: EdgeInsets.all(13),
                    width: double.infinity,
                    height: 75.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerCustom(
                          height: 12.w,
                          width: 100.w,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        ShimmerCustom(
                          height: 12.w,
                          width: 200.w,
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        ShimmerCustom(
                          height: 12.w,
                          width: 150.w,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
      }

      if (!commentController.loading && commentController.comments.length > 0) {
        for (var i = 0; i < commentController.comments.length; i++) {
          if (i == (commentController.comments.length - 1)) {
            listData.add(Column(
              children: [
                CommentItem(
                  canReply: canReply,
                  index: i,
                  list: commentController.comments,
                  comment: commentController.comments[i],
                  commentController: commentController,
                  teamName: teamName,
                  moduleName: moduleName,
                  parentTitle: parentTitle,
                ),
                footer ?? Container()
              ],
            ));
          } else {
            listData.add(CommentItem(
              canReply: canReply,
              index: i,
              list: commentController.comments,
              comment: commentController.comments[i],
              commentController: commentController,
              teamName: teamName,
              moduleName: moduleName,
              parentTitle: parentTitle,
            ));
          }
        }
      }

      return Stack(
        children: [
          SmartRefresher(
            physics: BouncingScrollPhysics(),
            header: WaterDropMaterialHeader(),
            controller: commentController.refreshController,
            onRefresh: _onRefresh,
            enablePullUp: true,
            onLoading: () => commentController.getMoreData(),
            footer: CustomFooter(
              builder: (BuildContext context, LoadStatus? mode) {
                Widget body;
                if (mode == LoadStatus.idle) {
                  body = SizedBox();
                } else if (mode == LoadStatus.loading) {
                  body = CircularProgressIndicator();
                } else if (mode == LoadStatus.failed) {
                  body = Text("Load Failed!Click retry!");
                } else if (mode == LoadStatus.canLoading) {
                  body = Text("release to load more");
                } else {
                  body = Text("No more Data");
                }
                return Container(
                  height: 55.0,
                  child: Center(child: body),
                );
              },
            ),
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: listData.length,
                itemBuilder: (ctx, index) {
                  return listData[index];
                }),
          ),
          commentController.loadingCreate
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withOpacity(0.5),
                  child: Center(child: CircularProgressIndicator()))
              : SizedBox()
        ],
      );
    });
  }
}
