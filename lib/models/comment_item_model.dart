import 'card_model.dart';
import 'cheer_item_model.dart';

class CommentItemModel {
  late List<Discussions> discussions;
  late List<CheerItemModel> cheers;
  late String sId;
  late String content;
  late Creator creator;
  late String createdAt;
  late String updatedAt;

  CommentItemModel(
      {this.discussions = const [],
      this.cheers = const [],
      required this.sId,
      this.content = '',
      required this.creator,
      String? createdAt,
      String? updatedAt = ''})
      : this.createdAt = createdAt == null || createdAt == ''
            ? DateTime.now().toString()
            : createdAt,
        this.updatedAt = updatedAt == null || updatedAt == ''
            ? DateTime.now().toString()
            : updatedAt;

  CommentItemModel.fromJson(Map<String, dynamic> json) {
    if (json['discussions'] != null) {
      discussions = <Discussions>[];
      json['discussions'].forEach((v) {
        if (v.runtimeType == String) {
          discussions.add(Discussions(sId: v, creator: Creator()));
        } else {
          discussions.add(new Discussions.fromJson(v));
        }
      });
    } else {
      discussions = [];
    }
    if (json['cheers'] != null) {
      cheers = <CheerItemModel>[];
      json['cheers'].forEach((v) {
        cheers.add(new CheerItemModel.fromJson(v));
      });
    }
    sId = json['_id'];
    content = json['content'];
    creator = (json['creator'] != null
        ? new Creator.fromJson(json['creator'])
        : Creator());
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'] ?? json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.discussions != null) {
      data['discussions'] = this.discussions.map((v) => v.toJson()).toList();
    }
    if (this.cheers != null) {}
    data['_id'] = this.sId;
    data['content'] = this.content;
    if (this.creator != null) {
      data['creator'] = this.creator.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Discussions {
  late List<CheerItemModel> cheers;
  late String sId;
  late String content;
  late Creator creator;
  late String createdAt;
  late String updatedAt;

  Discussions(
      {this.cheers = const [],
      required this.sId,
      this.content = '',
      required this.creator,
      this.createdAt = '',
      this.updatedAt = ''});

  Discussions.fromJson(Map<String, dynamic> json) {
    if (json['cheers'] != null) {
      cheers = <CheerItemModel>[];
      json['cheers'].forEach((v) {
        cheers.add(CheerItemModel.fromJson(v));
      });
    }
    sId = json['_id'];
    content = json['content'];
    creator = (json['creator'] != null
        ? new Creator.fromJson(json['creator'])
        : Creator());
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cheers != null) {}
    data['_id'] = this.sId;
    data['content'] = this.content;
    if (this.creator != null) {
      data['creator'] = this.creator.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
