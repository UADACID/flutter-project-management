import 'package:cicle_mobile_f3/models/notification_item_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:cicle_mobile_f3/widgets/webview_cummon.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'my_flutter_app_icons.dart';

class NotifAdapterModel {
  final String type;
  final Widget icon;
  final String photoUrl;
  final String content;
  final String projectName;
  final Function redirect;
  final String fullRoute;

  NotifAdapterModel(
      {required this.type,
      required this.icon,
      required this.photoUrl,
      required this.content,
      required this.projectName,
      required this.redirect,
      required this.fullRoute});
}

class NotificationTypeAdapter {
  static NotifAdapterModel init(NotificationItemModel notification) {
    String _fullRoute = '';
    String _type;
    String _photoUrl = notification.sender.photoUrl;
    String _projectName = notification.team!.name;
    String? _content = notification.childContent != ''
        ? notification.childContent
        : notification.content;

    Widget _icon = Container();
    String teamId = notification.team!.sId;
    String companyId = notification.company;

    if (notification.childService != null &&
        notification.childService!.serviceType == '') {
      _type = notification.service.serviceType;
    } else {
      _type = notification.childService!.serviceType;
    }

    Function _redirect = () {
      print('type $_type');
      if (_type == '') {
        showAlert(message: notification.content);
      }
    };

    switch (_type) {
      case "postSystem":
        _content = '${notification.childContent}';
        _redirect = () {
          Get.toNamed(RouteName.blastDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };
        break;
      case "post":
        _icon = _post;

        _content = 'Posted a Blast : ${notification.content}';
        _redirect = () {
          Get.toNamed(RouteName.blastDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "postMention":
        _icon = _mentioned;
        _content = notification.content;
        _redirect = () {
          Get.toNamed(RouteName.blastDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "comment":
        _icon = _comment;

        _content = 'Blast RE: ${notification.content}';
        _redirect = () {
          Get.toNamed(
              '${RouteName.blastDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "postCommentMention":
        _icon = _mentioned;

        _content = notification.content;
        _redirect = () {
          Get.toNamed(
              '${RouteName.blastDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "postSubscription":
        _icon = _other;

        _content = notification.content;
        _redirect = () {
          Get.toNamed(RouteName.blastDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;

      case "commentDiscussionPost":
        _icon = _comment;
        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'blasts', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;
      case "commentDiscussionMentionPost":
        _icon = _mentioned;

        _content = notification.content;
        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'blasts', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;
      case "card":
      case "cardComment":
        _icon = _comment;

        _content = 'Card RE: ${notification.content}';
        _redirect = () {
          Get.toNamed(
              '${RouteName.boardDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "cardCommentMention":
        _icon = _mentioned;

        _content = notification.content;
        _redirect = () {
          Get.toNamed(
              '${RouteName.boardDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "cardMember":
        _icon = _other;

        _content = notification.content;
        _redirect = () {
          Get.toNamed(RouteName.boardDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "cardMoved":
        _icon = _other;
        _redirect = () {
          Get.toNamed(RouteName.boardDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "cardArchived":
        _icon = _archived;
        _redirect = () {
          Get.toNamed(RouteName.boardDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "cardMention":
        _icon = _mentioned;

        _content = notification.content;
        _redirect = () {
          Get.toNamed(RouteName.boardDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "cardSystem":
        _icon = _dueSoon;
        _redirect = () {
          Get.toNamed(RouteName.boardDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;

      case "commentDiscussionCard":
        _icon = _comment;
        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'boards', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;
      case "commentDiscussionMentionCard":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'boards', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;
      case "chat":
        _content = notification.content;

        String _localTeamId = Get.parameters['teamId'] ?? '';
        _fullRoute =
            '${RouteName.privateChatDetailScreen(companyId, notification.service.serviceId)}?teamId=$_localTeamId';
        _redirect = () {
          Get.toNamed(
              '${RouteName.privateChatDetailScreen(companyId, notification.service.serviceId)}?teamId=$_localTeamId');
        };

        break;
      case "chatMention":
        _content = notification.content;

        String _localTeamId = Get.parameters['teamId'] ?? '';
        _fullRoute =
            '${RouteName.privateChatDetailScreen(companyId, notification.service.serviceId)}?teamId=$_localTeamId';
        _redirect = () {
          Get.toNamed(
              '${RouteName.privateChatDetailScreen(companyId, notification.service.serviceId)}?teamId=$_localTeamId');
        };
        break;
      case "groupChat":
        _icon = _groupChat;

        _content = notification.content;

        _fullRoute = RouteName.groupChatScreen(
            companyId, teamId, notification.service.serviceId);
        _redirect = () {
          Get.toNamed(RouteName.groupChatScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "groupChatMention":
        _icon = _mentioned;

        _content = notification.content;

        _fullRoute = RouteName.groupChatScreen(
            companyId, teamId, notification.service.serviceId);
        _redirect = () {
          Get.toNamed(RouteName.groupChatScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "question":
        _icon = _answering;

        _content = 'Posted a Check-in Question : ${notification.content}';

        _redirect = () {
          Get.toNamed(RouteName.checkInDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "questionSystem":
        _icon = _dueSoon;

        _redirect = () {
          Get.toNamed(RouteName.checkInDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "questionComment":
        _icon = _comment;

        _content = 'Answer To: ${notification.content}';

        _redirect = () {
          Get.toNamed(
              '${RouteName.checkInDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "questionSubscription":
        _icon = _other;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.checkInDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "questionCommentMention":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.checkInDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "commentDiscussionQuestion":
        _icon = _comment;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'check-ins', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;
      case "commentDiscussionMentionQuestion":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'check-ins', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;
      case "recurringOccurrence":
        _icon = _event;

        _content = 'Created an Event : ${notification.content}';

        _redirect = () {
          Get.toNamed(RouteName.occurenceDetailScreen(
              companyId,
              teamId,
              notification.service.serviceId,
              notification.grandChildService!.serviceId));
        };
        break;
      case "recurringOccurrenceComment":
        _icon = _comment;

        _content = 'Event RE: ${notification.content}';

        _redirect = () {
          Get.toNamed(
              '${RouteName.occurenceDetailScreen(companyId, teamId, notification.service.serviceId, notification.grandChildService!.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };
        break;
      case "recurringOccurrenceMention":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.occurenceDetailScreen(
              companyId,
              teamId,
              notification.service.serviceId,
              notification.grandChildService!.serviceId));
        };
        break;
      case "recurringOccurrenceCommentMention":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.commentDetailScreen(
              companyId,
              teamId,
              'occurrence',
              notification.service.serviceId,
              notification.childService!.serviceId));
        };
        break;
      case "recurringOccurrenceSystem":
        _icon = _dueSoon;

        _content = 'Event ${notification.childContent}';

        _redirect = () {
          Get.toNamed(RouteName.occurenceDetailScreen(
              companyId,
              teamId,
              notification.service.serviceId,
              notification.grandChildService!.serviceId));
        };

        break;
      case "recurringOccurrenceSubscription":
        _icon = _other;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.occurenceDetailScreen(
              companyId,
              teamId,
              notification.service.serviceId,
              notification.grandChildService!.serviceId));
        };
        break;
      case "commentDiscussionRecurringOccurrence":
        _icon = _comment;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'occurrence', notification.service.serviceId, notification.childService!.serviceId)}?occurrenceId=${notification.grandChildService!.serviceId}&targetCommentId=${notification.selfService!.serviceId}');
        };
        break;
      case "commentDiscussionMentionRecurringOccurrence":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'occurrence', notification.service.serviceId, notification.childService!.serviceId)}?occurrenceId=${notification.grandChildService!.serviceId}&targetCommentId=${notification.selfService!.serviceId}');
        };
        break;

      case "event":
        _icon = _event;

        _content = 'Created an Event : ${notification.content}';

        _redirect = () {
          Get.toNamed(RouteName.scheduleDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "eventComment":
        _icon = _comment;

        _content = 'Event RE: ${notification.content}';

        _redirect = () {
          Get.toNamed(
              '${RouteName.scheduleDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "eventMention":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.scheduleDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "eventCommentMention":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.scheduleDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "eventSystem":
        _icon = _dueSoon;

        _redirect = () {
          Get.toNamed(RouteName.scheduleDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "eventSubscription":
        _icon = _other;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.scheduleDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "commentDiscussionEvent":
        _icon = _comment;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'schedules', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;
      case "commentDiscussionMentionEvent":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'schedules', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;
      case "doc":
        _icon = _post;

        _content = 'Posted a Document : ${notification.content}';

        _redirect = () {
          Get.toNamed(RouteName.docDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "docMention":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.docDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "docComment":
        _icon = _comment;

        _content = 'Doc RE: ${notification.content}';

        _redirect = () {
          Get.toNamed(
              '${RouteName.docDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "docCommentMention":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.docDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "docSubscription":
        _icon = _other;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.docDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "commentDiscussionDoc":
        _icon = _comment;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'docs', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;
      case "commentDiscussionMentionDoc":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'docs', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;
      case "file":
        _icon = _upload;

        _content = 'Uploaded a File : ${notification.content}';

        _redirect = () {
          Get.toNamed(RouteName.fileDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "fileComment":
        _icon = _comment;

        _content = 'File RE: ${notification.content}';

        _redirect = () {
          Get.toNamed(
              '${RouteName.fileDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "fileCommentMention":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.fileDetailScreen(companyId, teamId, notification.service.serviceId)}?targetCommentId=${notification.childService!.serviceId}');
        };

        break;
      case "fileSubscription":
        _icon = _other;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.fileDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "commentDiscussionFile":
        _icon = _comment;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'files', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;
      case "commentDiscussionMentionFile":
        _icon = _mentioned;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'files', notification.service.serviceId, notification.childService!.serviceId)}?targetCommentId=${notification.selfService!.serviceId}');
        };

        break;

      case 'bucketSubscription':
        _icon = _other;

        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.folderDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };

        break;
      case "subscriptionSystem":
        _icon = _dueSoon;

        _content = notification.content;

        _redirect = () {
          Get.dialog(Center(
            child: Container(
              decoration: BoxDecoration(),
              margin: EdgeInsets.all(23),
              child: Material(
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    notification.content,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ));
        };
        break;

      case "cheersSystem":
        _icon = _dueSoon;

        _content = notification.content;
        _redirect = () {
          Get.toNamed('${RouteName.cheersScreen(companyId)}?teamId=$teamId');
        };
        break;
      case "taskSystem":
      case "taskReminder":
        _content = '${notification.content} - ${notification.childContent}';
        // .eg my.cicle.app/companies/:companyId/my-tasks
        String url = '${Env.WEB_URL}/companies/$companyId/my-tasks';
        _redirect = () async {
          // temporary disable
          // Get.toNamed('${RouteName.myTaskScreen}?teamId=$teamId');
          bool canLaunch = await canLaunchUrl(Uri.parse(url));
          if (canLaunch) {
            bool isLaunched = await launchUrl(Uri.parse(url),
                mode: LaunchMode.externalApplication);
            if (!isLaunched) {
              showAlert(message: "can't open $url", messageColor: Colors.red);
            }
          } else {
            Get.to(WebViewCummon(url: url));
          }
        };
        break;
      default:
        _icon = _other;

        _content = notification.content;

        break;
    }
    return NotifAdapterModel(
        type: _type,
        content: _content!,
        icon: _icon,
        photoUrl: _photoUrl,
        projectName: _projectName,
        redirect: _redirect,
        fullRoute: _fullRoute);
  }
}

Widget _dueSoon = Container(
    color: Color(0xffFDC532),
    height: 16,
    width: 16,
    child: Icon(
      Icons.notifications_active_outlined,
      color: Colors.white,
      size: 11,
    ));

Widget _mentioned = Container(
    color: Color(0xffF178B6),
    height: 16,
    width: 16,
    child: Icon(
      MyFlutterApp.mdi_at,
      color: Colors.white,
      size: 11,
    ));

Widget _comment = Container(
    color: Color(0xff42E591),
    height: 16,
    width: 16,
    child: Icon(
      Icons.chat_bubble,
      color: Colors.white,
      size: 11,
    ));

Widget _asigned = Container(
    color: Color(0xff4BEED1),
    height: 16,
    width: 16,
    child: Icon(
      Icons.attach_file_outlined,
      color: Colors.white,
      size: 11,
    ));

Widget _groupChat = Container(
    color: Color(0xff43D2FF),
    height: 16,
    width: 16,
    child: Icon(
      Icons.people_outlined,
      color: Colors.white,
      size: 11,
    ));

Widget _blast = Container(
    color: Color(0xffFF881B),
    height: 16,
    width: 16,
    child: Icon(
      Icons.campaign_outlined,
      color: Colors.white,
      size: 13,
    ));

Widget _post = Container(
    color: Color(0xffAF71FF),
    height: 16,
    width: 16,
    child: Icon(
      MyFlutterApp.mdi_square_edit_outline,
      color: Colors.white,
      size: 11,
    ));

Widget _answering = Container(
    color: Color(0xff001AFF),
    height: 16,
    width: 16,
    child: Icon(
      Icons.help_outline,
      color: Colors.white,
      size: 11,
    ));

Widget _event = Container(
  color: Color(0xff956042),
  height: 16,
  width: 16,
  child: Icon(
    Icons.event_outlined,
    color: Colors.white,
    size: 11,
  ),
);

Widget _archived = Container(
  color: Color(0xff4D4D4D),
  height: 16,
  width: 16,
  child: Icon(
    MyFlutterApp.mdi_archive_arrow_down_outline,
    size: 11,
    color: Colors.white,
  ),
);

Widget _upload = Container(
  color: Color(0xff708FC7),
  height: 16,
  width: 16,
  child: Icon(
    MyFlutterApp.notif_upload,
    size: 11,
    color: Colors.white,
  ),
);

Widget _other = Container(
  color: Color(0xffCF0F0F),
  height: 16,
  width: 16,
  child: Icon(
    Icons.error,
    color: Colors.white,
    size: 14,
  ),
);
