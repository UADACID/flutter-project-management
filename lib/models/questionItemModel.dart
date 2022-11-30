// import 'package:cicle_mobile_f3/models/card_model.dart';
// import 'package:cicle_mobile_f3/models/member_model.dart';

import 'card_model.dart';
import 'member_model.dart';

class QuestionItemModel {
  late String sId;
  late Schedule schedule;
  late Archived archived;
  late List<MemberModel> subscribers;
  late String title;
  late Creator creator;
  late String createdAt;
  late String updatedAt;
  late bool isPublic;

  QuestionItemModel(
      {required this.sId,
      required this.schedule,
      required this.archived,
      this.subscribers = const [],
      this.title = '',
      required this.creator,
      this.createdAt = '',
      this.updatedAt = '',
      this.isPublic = true});

  QuestionItemModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    isPublic = json['isPublic'] != null ? json['isPublic'] : true;
    schedule = (json['schedule'] != null
        ? new Schedule.fromJson(json['schedule'])
        : Schedule());
    archived = (json['archived'] != null
        ? new Archived.fromJson(json['archived'])
        : Archived());
    if (json['subscribers'] != null) {
      subscribers = <MemberModel>[];
      json['subscribers'].forEach((v) {
        subscribers.add(new MemberModel.fromJson(v));
      });
    }
    title = json['title'];
    if (json['creator'] != null) {
      if (json['creator'].runtimeType == String) {
        creator = Creator(sId: json['creator']);
      } else {
        creator = new Creator.fromJson(json['creator']);
      }
    }

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.schedule != null) {
      data['schedule'] = this.schedule.toJson();
    }
    if (this.archived != null) {
      data['archived'] = this.archived.toJson();
    }
    if (this.subscribers != null) {
      data['subscribers'] = this.subscribers.map((v) => v.toJson()).toList();
    }
    data['title'] = this.title;
    if (this.creator != null) {
      data['creator'] = this.creator.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Schedule {
  late List<String> days;
  late int hour;
  late int minute;

  Schedule({this.days = const [], this.hour = 0, this.minute = 0});

  Schedule.fromJson(Map<String, dynamic> json) {
    days = json['days'].cast<String>();
    hour = json['hour'];
    minute = json['minute'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['days'] = this.days;
    data['hour'] = this.hour;
    data['minute'] = this.minute;
    return data;
  }
}

class Subscribers {
  late String sId;
  late String photoUrl;

  Subscribers({required this.sId, this.photoUrl = ''});

  Subscribers.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    photoUrl = json['photoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['photoUrl'] = this.photoUrl;
    return data;
  }
}
