// import 'package:cicle_mobile_f3/models/member_model.dart';

import 'card_model.dart';
import 'companies_model.dart';
import 'member_model.dart';

class NotificationItemModel {
  late Service service;
  late Service? childService;
  late Service? selfService;
  late Service? grandChildService;
  late List<Activities> activities;
  late String sId;
  late MemberModel sender;
  late String content;
  late Teams? team;
  late String company;
  late List<ReadBy> readBy;
  late String createdAt;
  late String updatedAt;
  late String? childContent;
  late String discussionId;

  NotificationItemModel(
      {required this.service,
      this.childService,
      this.selfService,
      this.grandChildService,
      this.activities = const [],
      required this.sId,
      required this.sender,
      this.content = '',
      this.team,
      this.company = '',
      this.readBy = const [],
      this.createdAt = '',
      this.updatedAt = '',
      this.childContent = '',
      this.discussionId = ''});

  NotificationItemModel.fromJson(json) {
    service = (json['service'] != null
        ? Service.fromJson(json['service'])
        : Service(serviceId: '', serviceType: ''));

    childService = (json['childService'] != null
        ? Service.fromJson(json['childService'])
        : Service(serviceId: '', serviceType: ''));

    selfService = (json['selfService'] != null
        ? Service.fromJson(json['selfService'])
        : Service(serviceId: '', serviceType: ''));

    grandChildService = (json['grandChildService'] != null
        ? Service.fromJson(json['grandChildService'])
        : Service(serviceId: '', serviceType: ''));
    activities = <Activities>[];

    if (json['activities'] != null) {
      json['activities'].forEach((v) {
        activities.add(Activities.fromJson(v));
      });
    }
    sId = json['_id'];

    sender = (json['sender'] != null
        ? MemberModel.fromJson(json['sender'])
        : MemberModel());
    if (json['content'] != null) {
      content = json['content'];
    } else {
      content = '';
    }

    team = (json['team'] != null
        ? new Teams.fromJson(json['team'])
        : Teams(archived: Archived(status: false), sId: ''));
    if (json['company'] != null && json['company'].runtimeType == String) {
      company = json['company'];
    } else if (json['company']?['_id'] != null) {
      company = json['company']['_id'];
    } else {
      company = '';
    }

    readBy = <ReadBy>[];
    if (json['readBy'] != null) {
      json['readBy'].forEach((v) {
        readBy.add(new ReadBy.fromJson(v));
      });
    }

    if (json['createdAt'] != null) {
      createdAt = json['createdAt'];
    } else {
      createdAt = '';
    }

    if (json['updatedAt'] != null) {
      updatedAt = json['updatedAt'];
    } else {
      updatedAt = '';
    }

    if (json['childContent'] != null) {
      childContent = json['childContent'];
    } else {
      childContent = '';
    }

    if (json['discussionId'] != null) {
      discussionId = json['discussionId'];
    } else {
      discussionId = '';
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.service != null) {
      data['service'] = this.service.toJson();
    }
    if (this.childService != null) {
      data['childService'] = this.childService!.toJson();
    }
    if (this.activities != null) {
      data['activities'] = this.activities.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    if (this.sender != null) {
      data['sender'] = this.sender.toJson();
    }
    data['content'] = this.content;
    if (this.team != null) {
      data['team'] = this.team!.toJson();
    }
    data['company'] = this.company;
    if (this.readBy != null) {
      data['readBy'] = this.readBy.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['childContent'] = this.childContent;
    return data;
  }
}

class Service {
  late String serviceType;
  late String serviceId;

  Service({required this.serviceType, required this.serviceId});

  Service.fromJson(json) {
    serviceType = json['serviceType'] ?? '';
    serviceId = json['serviceId'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['serviceType'] = this.serviceType;
    data['serviceId'] = this.serviceId;
    return data;
  }
}

class Activities {
  late Service service;
  late String sId;
  late String sender;
  late String content;
  late List<ReadBy> readBy;
  late String createdAt;
  late String updatedAt;

  Activities(
      {required this.service,
      required this.sId,
      this.sender = '',
      this.content = '',
      this.readBy = const [],
      this.createdAt = '',
      this.updatedAt = ''});

  Activities.fromJson(Map<String, dynamic> json) {
    service = (json['service'] != null
        ? new Service.fromJson(json['service'])
        : Service(serviceId: '', serviceType: ''));
    sId = json['_id'];
    sender = json['sender'] ?? '';
    content = json['content'];
    if (json['readBy'] != null) {
      readBy = <ReadBy>[];
      json['readBy'].forEach((v) {
        readBy.add(new ReadBy.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.service != null) {
      data['service'] = this.service.toJson();
    }
    data['_id'] = this.sId;
    data['sender'] = this.sender;
    data['content'] = this.content;
    if (this.readBy != null) {
      data['readBy'] = this.readBy.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class ReadBy {
  late String sId;
  late String reader;
  late String readAt;

  ReadBy({this.sId = '', this.reader = '', this.readAt = ''});

  ReadBy.fromJson(json) {
    sId = json?['_id'] ?? '';
    reader = json?['reader'] ?? '';
    readAt = json?['readAt'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['reader'] = this.reader;
    data['readAt'] = this.readAt;
    return data;
  }
}
