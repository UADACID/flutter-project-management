import 'card_model.dart';

class BoardListItemModel {
  late Archived archived;
  late Complete complete;
  late String sId;
  late String name;
  late String createdAt;
  late String updatedAt;
  late List<CardModel> cards;
  late int totalCard;

  BoardListItemModel(
      {required this.archived,
      required this.complete,
      this.sId = '',
      this.name = '',
      this.createdAt = '',
      this.updatedAt = '',
      this.cards = const [],
      this.totalCard = 0});

  BoardListItemModel.fromJson(Map<String, dynamic> json) {
    archived = (json['archived'] != null
        ? new Archived.fromJson(json['archived'])
        : Archived());
    complete = (json['complete'] != null
        ? new Complete.fromJson(json['complete'])
        : Complete(status: false));
    sId = json['_id'];
    name = json['name'] != null ? json['name'] : '';
    createdAt = json['createdAt'] != null ? json['createdAt'] : '';
    updatedAt = json['updatedAt'] != null ? json['updatedAt'] : '';
    if (json['cards'] != null) {
      cards = <CardModel>[];
      json['cards'].forEach((v) {
        if (v.runtimeType == String) {
          cards.add(new CardModel(
              sId: v,
              archived: Archived(),
              complete: Complete(),
              creator: Creator(),
              isNotified: IsNotified()));
        } else {
          cards.add(new CardModel.fromJson(v));
        }
      });
    }
    totalCard = json['totalCard'] != null ? json['totalCard'] : 0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.archived != null) {
      data['archived'] = this.archived.toJson();
    }
    if (this.complete != null) {
      data['complete'] = this.complete.toJson();
    }
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
