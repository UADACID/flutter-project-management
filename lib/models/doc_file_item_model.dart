// import 'package:cicle_mobile_f3/models/card_model.dart';
// import 'package:cicle_mobile_f3/models/member_model.dart';

import 'card_model.dart';
import 'member_model.dart';

class DocFileItemModel {
  late String? content;
  late String? createdAt;
  late Creator? creator;
  late bool? isPublic;
  late String? title;
  late String? sId;
  late String? updatedAt;
  late List<DocFileItemModel> buckets;
  late List<DocFileItemModel> docs;
  late List<DocFileItemModel> files;
  late List<MemberModel> subscribers;
  late String? mimeType;
  late String? url;
  late String type;
  late String? mainParentBucketId;
  late String? localParentBucketId;

  DocFileItemModel(
      {this.content,
      this.createdAt,
      this.creator,
      this.isPublic,
      this.title,
      this.sId,
      this.updatedAt,
      this.buckets = const [],
      this.docs = const [],
      this.files = const [],
      this.subscribers = const [],
      this.mimeType,
      this.url,
      this.mainParentBucketId,
      this.localParentBucketId});

  DocFileItemModel.fromJson(Map<String, dynamic> json) {
    content = json['content'];
    createdAt = json['createdAt'];
    if (json['creator'] != null) {
      if (json['creator'].runtimeType == String) {
        creator = Creator(sId: json['creator']);
      } else {
        creator = Creator.fromJson(json['creator']);
      }
    }

    isPublic = json['isPublic'];
    title = json['title'];
    sId = json['_id'];
    updatedAt = json['updatedAt'];
    if (json['buckets'] != null) {
      buckets = <DocFileItemModel>[];
      json['buckets'].forEach((v) {
        if (v.runtimeType == String) {
          buckets.add(DocFileItemModel(sId: v));
        } else {
          buckets.add(new DocFileItemModel.fromJson(v));
        }
      });
    }

    if (json['docs'] != null) {
      docs = <DocFileItemModel>[];
      json['docs'].forEach((v) {
        if (v.runtimeType == String) {
          docs.add(DocFileItemModel(sId: v));
        } else {
          docs.add(new DocFileItemModel.fromJson(v));
        }
      });
    }
    if (json['files'] != null) {
      files = <DocFileItemModel>[];
      json['files'].forEach((v) {
        if (v.runtimeType == String) {
          files.add(DocFileItemModel(sId: v));
        } else {
          files.add(new DocFileItemModel.fromJson(v));
        }
      });
    }
    if (json['subscribers'] != null) {
      subscribers = <MemberModel>[];
      json['subscribers'].forEach((v) {
        if (v.runtimeType == String) {
          subscribers.add(MemberModel(sId: v));
        } else {
          subscribers.add(new MemberModel.fromJson(v));
        }
      });
    }
    mimeType = json['mimeType'];
    url = json['url'];
    type = '';
    if (json['mimeType'] != null) {
      type = 'file';
    } else if (json['buckets'] != null) {
      type = 'bucket';
    } else {
      type = 'doc';
    }

    mainParentBucketId =
        json['mainParentBucketId'] != null ? json['mainParentBucketId'] : null;
    localParentBucketId = json['localParentBucketId'] != null
        ? json['localParentBucketId']
        : null;
  }
}
