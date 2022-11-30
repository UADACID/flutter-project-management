import 'package:cicle_mobile_f3/models/notif_as_cheers_model.dart';
import 'package:cicle_mobile_f3/utils/constant.dart';
import 'package:cicle_mobile_f3/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'my_flutter_app_icons.dart';

class NotifCheersAdapterModel {
  final String type;
  final Widget icon;
  final String photoUrl;
  final String content;
  final String title;
  final String projectName;
  final Function redirect;
  final String fullRoute;

  NotifCheersAdapterModel(
      {required this.type,
      required this.icon,
      required this.title,
      required this.photoUrl,
      required this.content,
      required this.projectName,
      required this.redirect,
      required this.fullRoute});
}

class NotificationAsCheersTypeAdapter {
  static NotifCheersAdapterModel init(NotifAsCheersModel notification) {
    String _fullRoute = '';
    String _type;
    String _title = '';

    String _projectName = notification.team.name;
    String? _content = notification.childContent != ''
        ? notification.childContent
        : notification.content;
    Widget _icon = Container();
    String teamId = notification.team.sId;
    String companyId = notification.company;

    _type = notification.service.serviceType;

    Function _redirect = () {
      print('type $_type');
      print(notification);
      if (_type == '') {
        showAlert(message: notification.content);
      }
    };

    switch (_type) {
      case 'postCheers':
        _icon = _post;
        _title = notification.childContent;

        _content = '${notification.content}';

        _redirect = () {
          Get.toNamed(RouteName.blastDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };
        break;
      case 'eventCheers':
        _icon = _event;

        _title = notification.childContent;
        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.scheduleDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };
        break;
      case 'recurringOccurrenceCheers':
        _icon = _event;

        _title = notification.childContent;
        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.occurenceDetailScreen(
              companyId,
              teamId,
              notification.service.serviceId,
              notification.greatGrandChildService!.serviceId));
        };
        break;
      case 'docCheers':
        _icon = _post;

        _title = notification.childContent;
        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.docDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };
        break;
      case 'fileCheers':
        _icon = _upload;

        _title = notification.childContent;
        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.fileDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };
        break;
      case 'cardCheers':
        _icon = _other;

        _title = notification.childContent;
        _content = notification.content;

        _redirect = () {
          Get.toNamed(RouteName.boardDetailScreen(
              companyId, teamId, notification.service.serviceId));
        };
        break;
      case 'postCommentCheers':
        _icon = _comment;
        _title = 'Post Re: ${notification.childContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.blastDetailScreen(companyId, teamId, notification.childService.serviceId)}?targetCommentId=${notification.service.serviceId}');
        };
        break;
      case 'eventCommentCheers':
        _icon = _comment;

        _title = 'Event Re: ${notification.childContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.scheduleDetailScreen(companyId, teamId, notification.childService.serviceId)}?targetCommentId=${notification.service.serviceId}');
        };
        break;
      case 'recurringOccurrenceCommentCheers':
        _icon = _comment;

        _title = 'Event Re: ${notification.childContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.occurenceDetailScreen(companyId, teamId, notification.childService.serviceId, notification.greatGrandChildService!.serviceId)}?targetCommentId=${notification.service.serviceId}');
        };
        break;
      case 'questionCommentCheers':
        _icon = _comment;

        _title = 'Answer To: ${notification.childContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.checkInDetailScreen(companyId, teamId, notification.childService.serviceId)}?targetCommentId=${notification.service.serviceId}');
        };
        break;
      case 'docCommentCheers':
        _icon = _comment;

        _title = 'Doc Re: ${notification.childContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.docDetailScreen(companyId, teamId, notification.childService.serviceId)}?targetCommentId=${notification.service.serviceId}');
        };
        break;
      case 'fileCommentCheers':
        _icon = _comment;

        _title = 'File Re: ${notification.childContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.fileDetailScreen(companyId, teamId, notification.childService.serviceId)}?targetCommentId=${notification.service.serviceId}');
        };
        break;
      case 'cardCommentCheers':
        _icon = _comment;

        _title = 'Card Re: ${notification.childContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.boardDetailScreen(companyId, teamId, notification.childService.serviceId)}?targetCommentId=${notification.service.serviceId}');
        };
        break;
      case 'postCommentDiscussionCheers':
        _icon = _comment;
        _title =
            'Your reply to a comment in Post: ${notification.grandChildContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'blasts', notification.grandChildService!.serviceId, notification.childService.serviceId)}?targetCommentId=${notification.discussionId}');
        };
        break;
      case 'eventCommentDiscussionCheers':
        _icon = _comment;

        _title =
            'Your reply to a comment in Event: ${notification.grandChildContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'schedules', notification.grandChildService!.serviceId, notification.childService.serviceId)}?targetCommentId=${notification.discussionId}');
        };
        break;
      case 'recurringOccurrenceCommentDiscussionCheers':
        _icon = _comment;

        _title =
            'Your reply to a comment in Event: ${notification.grandChildContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'occurrence', notification.grandChildService!.serviceId, notification.childService.serviceId)}?occurrenceId=${notification.greatGrandChildService!.serviceId}&targetCommentId=${notification.discussionId}');
        };
        break;
      case 'questionCommentDiscussionCheers':
        _icon = _comment;

        _title =
            'Your reply to an answer in Question: ${notification.grandChildContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'check-ins', notification.grandChildService!.serviceId, notification.childService.serviceId)}?targetCommentId=${notification.discussionId}');
        };
        break;
      case 'docCommentDiscussionCheers':
        _icon = _comment;

        _title =
            'Your reply to a comment in Doc: ${notification.grandChildContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'docs', notification.grandChildService!.serviceId, notification.childService.serviceId)}?targetCommentId=${notification.discussionId}');
        };
        break;
      case 'fileCommentDiscussionCheers':
        _icon = _comment;

        _title =
            'Your reply to a comment in File: ${notification.grandChildContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'files', notification.grandChildService!.serviceId, notification.childService.serviceId)}?targetCommentId=${notification.discussionId}');
        };
        break;
      case 'cardCommentDiscussionCheers':
        _icon = _comment;

        _title =
            'Your reply to a comment in Card: ${notification.grandChildContent}';
        _content = notification.content;

        _redirect = () {
          Get.toNamed(
              '${RouteName.commentDetailScreen(companyId, teamId, 'boards', notification.grandChildService!.serviceId, notification.childService.serviceId)}?targetCommentId=${notification.discussionId}');
        };
        break;

      default:
        break;
    }
    return NotifCheersAdapterModel(
        type: _type,
        content: _content,
        title: _title,
        icon: _icon,
        photoUrl: '',
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
// due soon reminder

Widget _mentioned = Container(
    color: Color(0xffF178B6),
    height: 16,
    width: 16,
    child: Icon(
      MyFlutterApp.mdi_at,
      color: Colors.white,
      size: 11,
    ));
// mentioned

Widget _comment = Container(
    color: Color(0xff42E591),
    height: 16,
    width: 16,
    child: Icon(
      Icons.chat_bubble,
      color: Colors.white,
      size: 11,
    ));
// comment /reply

Widget _asigned = Container(
    color: Color(0xff4BEED1),
    height: 16,
    width: 16,
    child: Icon(
      Icons.attach_file_outlined,
      color: Colors.white,
      size: 11,
    ));
// assigned to me card only

Widget _groupChat = Container(
    color: Color(0xff43D2FF),
    height: 16,
    width: 16,
    child: Icon(
      Icons.people_outlined,
      color: Colors.white,
      size: 11,
    ));
// group chat

Widget _blast = Container(
    color: Color(0xffFF881B),
    height: 16,
    width: 16,
    child: Icon(
      Icons.campaign_outlined,
      color: Colors.white,
      size: 13,
    ));
// blast

Widget _post = Container(
    color: Color(0xffAF71FF),
    height: 16,
    width: 16,
    child: Icon(
      MyFlutterApp.mdi_square_edit_outline,
      color: Colors.white,
      size: 11,
    ));
// post

Widget _answering = Container(
    color: Color(0xff001AFF),
    height: 16,
    width: 16,
    child: Icon(
      Icons.help_outline,
      color: Colors.white,
      size: 11,
    ));
// answering question

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
// event

Widget _archived = Container(
  color: Color(0xff4D4D4D),
  height: 16,
  width: 16,
  child: Icon(
    MyFlutterApp.mdi_archive_arrow_down_outline,
    size: 11,
    color: Colors.white,
  ),
); // archived

Widget _upload = Container(
  color: Color(0xff708FC7),
  height: 16,
  width: 16,
  child: Icon(
    MyFlutterApp.notif_upload,
    size: 11,
    color: Colors.white,
  ),
); // archived

Widget _other = Container(
  color: Color(0xffCF0F0F),
  height: 16,
  width: 16,
  child: Icon(
    Icons.error,
    color: Colors.white,
    size: 14,
  ),
); // other action
