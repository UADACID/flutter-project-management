// import 'package:cicle_mobile_f3/models/card_model.dart';
// import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
// import 'package:cicle_mobile_f3/models/comment_item_model.dart';
// import 'package:cicle_mobile_f3/models/member_model.dart';

import 'card_model.dart';
import 'cheer_item_model.dart';
import 'comment_item_model.dart';
import 'member_model.dart';

class EventItemModel {
  String? createdAt;
  String? updatedAt;
  String? sId;
  Archived? archived;
  List<CheerItemModel>? cheers;
  List<CommentItemModel>? comments;
  String? content;
  Creator? creator;
  int? duration;
  String? endDate;
  GoogleCalendar? googleCalendar;
  bool? isAllday;
  IsNotified? isNotified;
  bool? isPublic;
  bool? isRecurring;
  Recurrence? recurrence;
  String? startDate;
  List<MemberModel>? subscribers;
  String? title;
  String? event;
  OriginalStartPattern? originalStartPattern;
  late String status;
  late String teamName;
  late String teamId;
  late CommentItemModel? lastComment;

  EventItemModel(
      {this.createdAt,
      this.updatedAt,
      this.sId,
      this.archived,
      this.cheers = const [],
      this.comments = const [],
      this.content,
      this.creator,
      this.duration,
      this.endDate,
      this.googleCalendar,
      this.isAllday,
      this.isNotified,
      this.isPublic,
      this.isRecurring,
      this.recurrence,
      this.startDate,
      this.subscribers,
      this.title,
      this.event,
      this.originalStartPattern,
      this.status = '',
      this.teamName = '',
      this.teamId = '',
      this.lastComment});

  EventItemModel.fromJson(Map<String, dynamic> json) {
    teamName = json['teamName'] ?? '';
    createdAt = json['createdAt'] ?? '';
    updatedAt = json['updatedAt'] ?? '';
    sId = json['_id'];
    archived = json['archived'] != null
        ? Archived.fromJson(json['archived'])
        : Archived();
    if (json['cheers'] != null) {
      cheers = <CheerItemModel>[];
      json['cheers'].forEach((v) {
        cheers!.add(new CheerItemModel.fromJson(v));
      });
    }
    if (json['comments'] != null) {
      comments = <CommentItemModel>[];
      json['comments'].forEach((v) {
        comments!.add(new CommentItemModel.fromJson(v));
      });
    }
    content = json['content'] ?? '';
    creator = json['creator'] != null && json['creator'].runtimeType != String
        ? Creator.fromJson(json['creator'])
        : Creator();
    duration = json['duration'] ?? 0;
    endDate = json['endDate'] ?? '';
    googleCalendar = json['googleCalendar'] != null
        ? new GoogleCalendar.fromJson(json['googleCalendar'])
        : GoogleCalendar();
    isAllday = json['isAllday'] ?? false;
    isNotified = json['isNotified'] != null
        ? IsNotified.fromJson(json['isNotified'])
        : IsNotified();
    isPublic = json['isPublic'] ?? true;
    isRecurring = json['isRecurring'] ?? false;
    recurrence = json['recurrence'] != null
        ? new Recurrence.fromJson(json['recurrence'])
        : Recurrence();
    startDate = json['startDate'] ?? '';
    if (json['subscribers'] != null) {
      subscribers = <MemberModel>[];
      json['subscribers'].forEach((v) {
        subscribers!.add(new MemberModel.fromJson(v));
      });
    }
    title = json['title'] ?? '';
    if (json['isOccurrence'] != null) {
      isRecurring = json['isOccurrence'];
    }
    if (json['event'] != null) {
      if (json['event'].runtimeType == String) {
        event = json['event'];
      }
    }

    if (json['originalStartPattern'] != null) {
      originalStartPattern =
          OriginalStartPattern.fromJson(json['originalStartPattern']);
    }

    if (json['status'] != null) {
      status = json['status'] ?? '';
    } else {
      status = '';
    }
  }
}

class OriginalStartPattern {
  String? code;
  String? endDate;
  String? readableText;
  String? startDate;

  OriginalStartPattern(
      {this.code, this.endDate, this.startDate, this.readableText});

  OriginalStartPattern.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? '';
    endDate = json['endDate'] ?? '';
    startDate = json['startDate'] ?? '';
    readableText = json['readableText'] ?? '';
  }
}

class GoogleCalendar {
  String? calendarId;
  String? eventGCalTemplateLink;
  String? eventHtmlLink;
  String? eventIcsLink;
  String? eventId;

  GoogleCalendar(
      {this.calendarId,
      this.eventGCalTemplateLink,
      this.eventHtmlLink,
      this.eventIcsLink,
      this.eventId});

  GoogleCalendar.fromJson(Map<String, dynamic> json) {
    calendarId = json['calendarId'] ?? '';
    eventGCalTemplateLink = json['eventGCalTemplateLink'] ?? '';
    eventHtmlLink = json['eventHtmlLink'] ?? '';
    eventIcsLink = json['eventIcsLink'] ?? '';
    eventId = json['eventId'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['calendarId'] = this.calendarId;
    data['eventGCalTemplateLink'] = this.eventGCalTemplateLink;
    data['eventHtmlLink'] = this.eventHtmlLink;
    data['eventIcsLink'] = this.eventIcsLink;
    data['eventId'] = this.eventId;
    return data;
  }
}

class ScheduleGoogleCalendar {
  String? aclRuleId;
  String? calendarHtmlLink;
  String? calendarIcsLink;
  String? calendarId;

  ScheduleGoogleCalendar(
      {this.aclRuleId,
      this.calendarHtmlLink,
      this.calendarIcsLink,
      this.calendarId});

  ScheduleGoogleCalendar.fromJson(Map<String, dynamic> json) {
    aclRuleId = json['aclRuleId'] ?? '';
    calendarHtmlLink = json['calendarHtmlLink'] ?? '';
    calendarIcsLink = json['calendarIcsLink'] ?? '';
    calendarId = json['calendarId'] ?? '';
  }
}

class Recurrence {
  String? code;
  String? endDate;
  String? gCalPattern;
  String? pattern;
  String? readableText;
  String? startDate;

  Recurrence(
      {this.code,
      this.endDate,
      this.gCalPattern,
      this.pattern,
      this.readableText,
      this.startDate});

  Recurrence.fromJson(Map<String, dynamic> json) {
    code = json['code'] ?? '';
    endDate = json['endDate'] ?? '';
    gCalPattern = json['gCalPattern'] ?? '';
    pattern = json['pattern'] ?? '';
    readableText = json['readableText'] ?? '';
    startDate = json['startDate'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['endDate'] = this.endDate;
    data['gCalPattern'] = this.gCalPattern;
    data['pattern'] = this.pattern;
    data['readableText'] = this.readableText;
    data['startDate'] = this.startDate;
    return data;
  }
}
