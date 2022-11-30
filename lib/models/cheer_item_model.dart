// import 'package:cicle_mobile_f3/models/card_model.dart';

import 'card_model.dart';

class CheerItemModel {
  late PrimaryParent primaryParent;
  late String content;

  late String sId;
  late Creator creator;

  CheerItemModel({
    required this.primaryParent,
    this.content = '',
    required this.sId,
    required this.creator,
  });

  CheerItemModel.fromJson(json) {
    if (json is String) {
      content = '';

      sId = '';
    } else {
      primaryParent = (json['primaryParent'] != null
          ? new PrimaryParent.fromJson(json['primaryParent'])
          : PrimaryParent());
      content = json['content'];

      sId = json['_id'];
      creator = (json['creator'] != null
          ? new Creator.fromJson(json['creator'])
          : Creator());
    }
  }
}

class PrimaryParent {
  late String id;
  late String type;

  PrimaryParent({this.id = '', this.type = ''});

  PrimaryParent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    return data;
  }
}
