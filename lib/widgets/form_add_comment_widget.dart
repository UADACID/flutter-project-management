import 'package:cicle_mobile_f3/controllers/comment_controller.dart';
import 'package:cicle_mobile_f3/models/card_model.dart';
import 'package:cicle_mobile_f3/models/comment_item_model.dart';
import 'package:cicle_mobile_f3/models/member_model.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/froala_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';

class FormAddCommentWidget extends StatelessWidget {
  const FormAddCommentWidget({
    Key? key,
    required this.commentController,
    required this.members,
  }) : super(key: key);

  final CommentController commentController;
  final List<MemberModel> members;

  onPress() {
    Get.dialog(
        FroalaEditor(
          initialContent: commentController.tempContentAddComment,
          commentController: commentController,
          title: 'Add',
          onSubmit: (String value) {
            print(value);
            CommentItemModel commentItem = CommentItemModel(
                sId: getRandomString(20),
                content: value,
                creator: Creator(fullName: ''));
            commentController.addComment(commentItem);
          },
          members: members,
        ),
        useSafeArea: false,
        barrierDismissible: false);
  }

  CustomRenderMatcher img1Matcher() => (ctx) {
        // print(ctx);
        if (ctx.tree.element != null) {
          if (ctx.tree.element!.attributes['style'] != null) {
            if (ctx.tree.element!.attributes['style']!
                    .contains('width: 20px') ||
                ctx.tree.element!.attributes['style']!.contains('width:20px') ||
                ctx.tree.element!.attributes['style']!
                    .contains('width: 10px') ||
                ctx.tree.element!.attributes['style']!.contains('width:10px') ||
                ctx.tree.element!.attributes['style']!
                    .contains('width: 12px') ||
                ctx.tree.element!.attributes['style']!.contains('width:12px') ||
                ctx.tree.element!.attributes['style']!
                    .contains('width: 15px') ||
                ctx.tree.element!.attributes['style']!.contains('width:15px')) {
              return true;
            }
          }

          return false;
        }

        return false;
        // // return ctx.tree.element!.attributes['style']!.contains('width: 20px') ||
        // //     ctx.tree.element!.attributes['style']!.contains('width:20px');
      };

  _contentPreview(String content) {
    return IgnorePointer(
      child: SingleChildScrollView(
        controller: commentController.tempContentAddCommentScrollController,
        child: Html(
          data: content,
          customRenders: {
            img1Matcher():
                CustomRender.widget(widget: (context, buildChildren) {
              print(context);
              String imageAvatarUrl = '';
              if (context.tree.element!.attributes['src'] != null) {
                imageAvatarUrl = context.tree.element!.attributes['src']!;
              }
              return Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: CircleAvatar(
                  radius: 20, // Image radius
                  backgroundImage:
                      NetworkImage(getPhotoUrl(url: imageAvatarUrl)),
                ),
              );
            }),
          },
          // customRender: {
          //   "img": (ctx, child) {
          //     if (ctx.tree.element!.attributes['style']!
          //             .contains('width: 20px') ||
          //         ctx.tree.element!.attributes['style']!
          //             .contains('width:20px')) {
          //       return ClipRRect(
          //         borderRadius: BorderRadius.circular(20),
          //         child: Image.network(
          //           ctx.tree.element!.attributes["src"].toString(),
          //           width: 20,
          //           height: 20,
          //           fit: BoxFit.cover,
          //         ),
          //       );
          //     } else if (ctx.tree.element!.attributes['style']!
          //             .contains('width: 10px') ||
          //         ctx.tree.element!.attributes['style']!
          //             .contains('width:10px')) {
          //       return ClipRRect(
          //         borderRadius: BorderRadius.circular(20),
          //         child: Image.network(
          //           ctx.tree.element!.attributes["src"].toString(),
          //           width: 20,
          //           height: 20,
          //           fit: BoxFit.cover,
          //         ),
          //       );
          //     } else if (ctx.tree.element!.attributes['style']!
          //             .contains('width: 12px') ||
          //         ctx.tree.element!.attributes['style']!
          //             .contains('width:12px')) {
          //       return ClipRRect(
          //         borderRadius: BorderRadius.circular(20),
          //         child: Image.network(
          //           ctx.tree.element!.attributes["src"].toString(),
          //           width: 20,
          //           height: 20,
          //           fit: BoxFit.cover,
          //         ),
          //       );
          //     } else if (ctx.tree.element!.attributes['style']!
          //             .contains('width: 15px') ||
          //         ctx.tree.element!.attributes['style']!
          //             .contains('width:15px')) {
          //       return ClipRRect(
          //         borderRadius: BorderRadius.circular(20),
          //         child: Image.network(
          //           ctx.tree.element!.attributes["src"].toString(),
          //           width: 20,
          //           height: 20,
          //           fit: BoxFit.cover,
          //         ),
          //       );
          //     } else if (ctx.tree.element!.attributes["src"] != null) {
          //       return Image.network(
          //         ctx.tree.element!.attributes["src"].toString(),
          //         width: 50,
          //         height: 50,
          //         fit: BoxFit.cover,
          //       );
          //     }
          //     return child;
          //     // return Image.network(
          //     //     ctx.tree.element!.attributes["src"].toString(),
          //     //     height: 100,);
          //   }
          // },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (commentController.loadingCreate) {
        return SizedBox();
      }
      return Container(
        padding: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: Offset(0, 0), // Shadow position
            ),
          ],
        ),
        child: Obx(() {
          Widget widget = Container();

          if (commentController.tempContentAddComment.trim() == '' ||
              removeHtmlTag(commentController.tempContentAddComment).trim() ==
                  '') {
            widget = Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Add new comment...',
                style: TextStyle(color: Colors.grey.withOpacity(0.5)),
              ),
            );
          } else {
            widget = Container(
              height: 30,
              // color: Colors.red.withOpacity(0.5),
              child: _contentPreview(commentController.tempContentAddComment),
            );
          }
          return InkWell(
            onTap: onPress,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.25)),
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.only(),
              // child: Text(
              //   'Add new comment...',
              //   style: TextStyle(color: Colors.grey.withOpacity(0.5)),
              // ),
              child: widget,
            ),
          );
        }),
      );
    });
  }
}
