// import 'package:cicle_mobile_f3/models/cheer_item_model.dart';
// import 'package:cicle_mobile_f3/models/notification_item_model.dart';

import 'card_model.dart';
import 'cheer_item_model.dart';
import 'companies_model.dart';
import 'notification_item_model.dart';

class NotifAsCheersModel {
  late String sId;
  late List<String> subscribers;
  late List<String> activities;
  late String sender;
  late Service service;
  late String content;
  late Service childService;
  late String childContent;
  late String grandChildContent;
  late Service? greatGrandChildService;
  late Service? grandChildService;
  late List<ReadBy> readBy;
  late Teams team;
  late String company;
  late String createdAt;
  late String updatedAt;
  late List<CheerItemModel> cheers;

  late String discussionId;
  late Service? selfService;

  NotifAsCheersModel({
    required this.sId,
    this.subscribers = const [],
    this.activities = const [],
    this.sender = '',
    required this.service,
    this.content = '',
    required this.childService,
    required this.childContent,
    this.grandChildContent = '',
    this.grandChildService,
    this.greatGrandChildService,
    this.readBy = const [],
    required this.team,
    required this.company,
    this.createdAt = '',
    this.updatedAt = '',
    this.cheers = const [],
    this.discussionId = '',
    this.selfService,
  });

  NotifAsCheersModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    subscribers = json['subscribers'].cast<String>();
    activities = json['activities'].cast<String>();
    sender = json['sender'] ?? '';
    service = (json['service'] != null
        ? Service.fromJson(json['service'])
        : Service(serviceId: '', serviceType: ''));

    childService = (json['childService'] != null
        ? Service.fromJson(json['childService'])
        : Service(serviceId: '', serviceType: ''));
    content = json['content'];
    childContent = json['childContent'];
    greatGrandChildService = (json['greatGrandChildService'] != null
        ? Service.fromJson(json['greatGrandChildService'])
        : Service(serviceId: '', serviceType: ''));
    grandChildContent =
        json['grandChildContent'] != null ? json['grandChildContent'] : '';
    grandChildService = (json['grandChildService'] != null
        ? Service.fromJson(json['grandChildService'])
        : Service(serviceId: '', serviceType: ''));
    if (json['readBy'] != null) {
      readBy = <ReadBy>[];
      json['readBy'].forEach((v) {
        readBy.add(new ReadBy.fromJson(v));
      });
    }
    team = (json['team'] != null
        ? new Teams.fromJson(json['team'])
        : Teams(archived: Archived(status: false), sId: ''));
    company = json['company'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['cheers'] != null) {
      cheers = <CheerItemModel>[];
      json['cheers'].forEach((v) {
        cheers.add(new CheerItemModel.fromJson(v));
      });
    }
    if (json['discussionId'] != null) {
      discussionId = json['discussionId'];
    } else {
      discussionId = '';
    }

    selfService = json['selfService'] != null
        ? Service.fromJson(json['selfService'])
        : Service(serviceId: '', serviceType: '');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['subscribers'] = this.subscribers;
    data['activities'] = this.activities;
    data['sender'] = this.sender;
    if (this.service != null) {
      data['service'] = this.service.toJson();
    }
    data['content'] = this.content;
    if (this.childService != null) {
      data['childService'] = this.childService.toJson();
    }
    data['childContent'] = this.childContent;
    if (this.readBy != null) {
      data['readBy'] = this.readBy.map((v) => v.toJson()).toList();
    }
    if (this.team != null) {
      data['team'] = this.team.toJson();
    }
    data['company'] = this.company;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;

    return data;
  }
}
