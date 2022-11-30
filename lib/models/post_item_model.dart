// import 'package:cicle_mobile_f3/models/card_model.dart';
// import 'package:cicle_mobile_f3/models/member_model.dart';

import 'card_model.dart';
import 'member_model.dart';

class PostItemModel {
  late String sId;
  late Archived archived;
  late String content;
  late String title;
  late Creator creator;
  late String createdAt;
  late String updatedAt;
  late List<String> commentsAsString;
  late List<MemberModel> subscribers;
  late bool isPublic;
  late bool complete;

  PostItemModel(
      {required this.sId,
      required this.archived,
      required this.content,
      required this.title,
      required this.creator,
      this.commentsAsString = const [],
      this.subscribers = const [],
      this.createdAt = '',
      this.updatedAt = '',
      this.isPublic = true,
      this.complete = false});

  PostItemModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    isPublic = json['isPublic'] != null ? json['isPublic'] : true;
    archived = json['archived'] != null
        ? new Archived.fromJson(json['archived'])
        : Archived(status: false);
    content = json['content'] != null ? json['content'] : '';
    title = json['title'];
    creator = (json['creator'] != null
        ? new Creator.fromJson(json['creator'])
        : Creator());
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    commentsAsString = <String>[];
    if (json['comments'] != null) {
      json['comments'].forEach((v) {
        if (v.runtimeType == String) {
          commentsAsString.add(v);
        }
      });
    }

    if (json['subscribers'] != null) {
      subscribers = <MemberModel>[];
      json['subscribers'].forEach((v) {
        if (v.runtimeType == String) {
          subscribers.add(MemberModel(sId: v));
        } else {
          subscribers.add(MemberModel.fromJson(v));
        }
      });
    }

    complete = false;
    if (json['complete'] != null && json['complete']['status'] != null) {
      complete = json['complete']['status'] ?? false;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    if (this.archived != null) {
      data['archived'] = this.archived.toJson();
    }
    data['content'] = this.content;
    data['title'] = this.title;
    if (this.creator != null) {
      data['creator'] = this.creator.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
