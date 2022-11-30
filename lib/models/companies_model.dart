// import 'package:cicle_mobile_f3/models/member_model.dart';

import 'card_model.dart';
import 'member_model.dart';

class CompaniesModel {
  late List<Companies> companies;

  CompaniesModel({this.companies = const []});

  CompaniesModel.fromJson(Map<String, dynamic> json) {
    if (json['companies'] != null) {
      companies = <Companies>[];
      json['companies'].forEach((v) {
        companies.add(new Companies.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.companies != null) {
      data['companies'] = this.companies.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Companies {
  String? logo;
  List<MemberModel>? admins;
  late List<MemberModel> members;
  late List<Teams> teams;
  late String sId;
  late String name;
  late String desc;
  late List<MembersJoined>? membersJoined;
  late String createdAt;
  late String updatedAt;

  Companies({
    this.logo,
    this.admins = const [],
    this.members = const [],
    this.teams = const [],
    required this.sId,
    this.name = '',
    this.desc = '',
    this.membersJoined = const [],
    this.createdAt = '',
    this.updatedAt = '',
  });

  Companies.fromJson(Map<String, dynamic> json) {
    logo = json['logo'];
    if (json['admins'] != null) {
      admins = <MemberModel>[];
      json['admins'].forEach((v) {
        if (v.runtimeType == String) {
          admins = [];
        } else {
          admins!.add(new MemberModel.fromJson(v));
        }
      });
    }
    if (json['members'] != null) {
      members = <MemberModel>[];
      json['members'].forEach((v) {
        if (v.runtimeType == String) {
          admins = [];
        } else {
          members.add(new MemberModel.fromJson(v));
        }
      });
    }
    if (json['teams'] != null) {
      teams = <Teams>[];
      json['teams'].forEach((v) {
        if (v.runtimeType == String) {
          admins = [];
        } else {
          teams.add(new Teams.fromJson(v));
        }
      });
    }
    sId = json['_id'];
    name = json['name'];
    desc = json['desc'];
    if (json['membersJoined'] != null) {
      membersJoined = <MembersJoined>[];
      json['membersJoined'].forEach((v) {
        membersJoined!.add(new MembersJoined.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['logo'] = this.logo;
    if (this.admins != null) {
      data['admins'] = this.admins!.map((v) => v.toJson()).toList();
    }
    if (this.members != null) {
      data['members'] = this.members.map((v) => v.toJson()).toList();
    }
    if (this.teams != null) {
      data['teams'] = this.teams.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['desc'] = this.desc;
    if (this.membersJoined != null) {
      data['membersJoined'] =
          this.membersJoined!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Teams {
  late Archived archived;
  late List<MemberModel> members;
  late List<String> boards;
  late String sId;
  late String name;
  late String desc;
  late String type;
  late String createdAt;
  late String updatedAt;

  late String blast;
  late String bucket;
  late String checkIn;
  late String groupChat;
  late String schedule;

  Teams(
      {required this.archived,
      this.members = const [],
      this.boards = const [],
      required this.sId,
      this.name = '',
      this.desc = '',
      this.type = '',
      this.createdAt = '',
      this.updatedAt = '',
      this.blast = '',
      this.bucket = '',
      this.checkIn = '',
      this.groupChat = '',
      this.schedule = ''});

  Teams.fromJson(json) {
    archived = (json['archived'] != null
        ? new Archived.fromJson(json['archived'])
        : Archived(status: false));
    if (json['members'] != null) {
      members = <MemberModel>[];
      json['members'].forEach((v) {
        if (v is String) {
        } else {
          members.add(new MemberModel.fromJson(v));
        }
      });
    }

    boards = json['boards'] != null ? json['boards'].cast<String>() : [''];
    sId = json['_id'];
    name = json['name'] ?? '';
    desc = json['desc'] ?? '';
    type = json['type'] ?? '';
    createdAt = json['createdAt'] ?? '';
    updatedAt = json['updatedAt'] ?? '';
    // BLAST
    if (json['blast'].runtimeType == String) {
      blast = json['blast'];
    } else {
      blast = json['blast']['_id'];
    }

    // BUCKET
    if (json['bucket'].runtimeType == String) {
      bucket = json['bucket'];
    } else {
      bucket = json['bucket']['_id'];
    }

    // CHEKC_IN
    if (json['checkIn'].runtimeType == String) {
      checkIn = json['checkIn'];
    } else {
      checkIn = json['checkIn']['_id'];
    }

    // GROUP CHAT
    if (json['groupChat'].runtimeType == String) {
      groupChat = json['groupChat'];
    } else {
      groupChat = json['groupChat']['_id'];
    }

    // SCHEDULE
    if (json['schedule'].runtimeType == String) {
      schedule = json['schedule'];
    } else {
      schedule = json['schedule']['_id'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.archived != null) {
      data['archived'] = this.archived.toJson();
    }
    if (this.members != null) {
      data['members'] = this.members.map((v) => v.toJson()).toList();
    }
    data['boards'] = this.boards;
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['desc'] = this.desc;
    data['type'] = this.type;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;

    data['blast'] = this.blast;
    data['bucket'] = this.bucket;
    data['checkIn'] = this.checkIn;
    data['groupChat'] = this.groupChat;
    data['schedule'] = this.schedule;
    return data;
  }
}

class MembersJoined {
  late String sId;
  late String member;
  late String joinedAt;

  MembersJoined(
      {required this.sId, required this.member, required this.joinedAt});

  MembersJoined.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    member = json['member'];
    joinedAt = json['joinedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['member'] = this.member;
    data['joinedAt'] = this.joinedAt;
    return data;
  }
}
