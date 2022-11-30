// import 'package:cicle_mobile_f3/models/member_model.dart';

import 'comment_item_model.dart';
import 'label_model.dart';
import 'member_model.dart';

class CardModel {
  late Complete complete;
  late IsNotified isNotified;
  late Archived archived;
  late List<MemberModel> members;
  late List<LabelModel> labels;
  late List<CommentItemModel> comments;
  late List<Attachments> attachments;
  late bool isPublic;
  late String sId;
  late String name;
  late Creator creator;
  late String createdAt;
  late String updatedAt;
  late String desc;
  late String dueDate;
  late bool isLocal;
  late bool isProgressToArchived;

  CardModel(
      {required this.complete,
      required this.isNotified,
      required this.archived,
      this.members = const [],
      this.comments = const [],
      this.labels = const [],
      this.attachments = const [],
      this.isPublic = true,
      this.sId = '',
      this.name = '',
      required this.creator,
      this.createdAt = '',
      this.updatedAt = '',
      this.desc = '',
      this.dueDate = '',
      this.isLocal = true,
      this.isProgressToArchived = false});

  CardModel.fromJson(Map<String, dynamic> json) {
    complete = (json['complete'] != null
        ? new Complete.fromJson(json['complete'])
        : Complete());

    isNotified = (json['isNotified'] != null
        ? new IsNotified.fromJson(json['isNotified'])
        : IsNotified());

    archived = (json['archived'] != null
        ? new Archived.fromJson(json['archived'])
        : Archived());

    if (json['members'] != null) {
      members = <MemberModel>[];
      json['members'].forEach((v) {
        if (v.runtimeType == String) {
          members.add(new MemberModel(sId: v));
        } else {
          members.add(new MemberModel.fromJson(v));
        }
      });
    }

    comments = <CommentItemModel>[];
    if (json['comments'] != null) {
      json['comments'].forEach((v) {
        if (v.runtimeType == String) {
          comments.add(CommentItemModel(sId: v, creator: Creator()));
        } else {
          comments.add(new CommentItemModel.fromJson(v));
        }
      });
    }

    if (json['labels'] != null) {
      labels = <LabelModel>[];
      json['labels'].forEach((v) {
        if (v.runtimeType == String) {
          labels.add(new LabelModel(
              color: ColorModel(sId: '', name: 'grey'),
              createdAt: '',
              name: 'no label name',
              sId: v,
              updatedAt: ''));
        } else {
          labels.add(new LabelModel.fromJson(v));
        }
      });
    }

    if (json['attachments'] != null) {
      attachments = <Attachments>[];
      json['attachments'].forEach((v) {
        if (v.runtimeType == String) {
          attachments.add(new Attachments(sId: v, creator: MemberModel()));
        } else {
          attachments.add(new Attachments.fromJson(v));
        }
      });
    }

    isPublic = json['isPublic'] != null ? json['isPublic'] : true;

    sId = json['_id'];

    name = json['name'] != null ? json['name'] : '';

    if (json['creator'] != null) {
      if (json['creator'].runtimeType == String) {
        creator = Creator(sId: json['creator']);
      } else {
        creator = Creator.fromJson(json['creator']);
      }
    }

    createdAt = json['createdAt'] != null ? json['createdAt'] : '';

    updatedAt = json['updatedAt'] != null ? json['updatedAt'] : '';

    desc = json['desc'] == null ? '' : json['desc'].toString();

    dueDate = json['dueDate'] == null ? '' : json['dueDate'].toString();

    isLocal = false;

    isProgressToArchived = false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.complete != null) {
      data['complete'] = this.complete.toJson();
    }
    if (this.isNotified != null) {
      data['isNotified'] = this.isNotified.toJson();
    }
    if (this.archived != null) {
      data['archived'] = this.archived.toJson();
    }
    if (this.members != null) {
      data['members'] = this.members.map((v) => v.toJson()).toList();
    }
    data['comments'] = this.comments;
    if (this.labels != null) {
      data['labels'] = this.labels.map((v) => v.toJson()).toList();
    }
    data['attachments'] = this.attachments;
    data['_id'] = this.sId;
    data['name'] = this.name;
    if (this.creator != null) {
      data['creator'] = this.creator.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['desc'] = this.desc;
    return data;
  }
}

class Complete {
  late bool status;
  late String type;

  Complete({this.status = false, this.type = ''});

  Complete.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    type = json['type'] == null ? '' : json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['type'] = this.type;
    return data;
  }
}

class IsNotified {
  late bool dueOneHour;
  late bool dueOneDay;

  IsNotified({this.dueOneHour = false, this.dueOneDay = false});

  IsNotified.fromJson(Map<String, dynamic> json) {
    dueOneHour = json['dueOneHour'];
    dueOneDay = json['dueOneDay'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dueOneHour'] = this.dueOneHour;
    data['dueOneDay'] = this.dueOneDay;
    return data;
  }
}

class Archived {
  late bool status;

  Archived({this.status = false});

  Archived.fromJson(Map<String, dynamic> json) {
    status = json['status'] == null ? false : json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    return data;
  }
}

class Creator {
  late String sId;
  late String fullName;
  late String photoUrl;

  Creator({this.sId = '', this.fullName = '', this.photoUrl = ''});

  Creator.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    fullName = json['fullName'] == null ? '' : json['fullName'];
    photoUrl = json['photoUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['fullName'] = this.fullName;
    data['photoUrl'] = this.photoUrl;
    return data;
  }
}

class Attachments {
  late bool isDeleted;
  late String sId;
  late String name;
  late String url;
  late MemberModel creator;
  late String type;
  late String mimeType;
  late String createdAt;
  late String updatedAt;

  Attachments(
      {this.isDeleted = false,
      required this.sId,
      this.name = '',
      this.url = '',
      required this.creator,
      this.type = '',
      this.mimeType = '',
      this.createdAt = '',
      this.updatedAt = ''});

  Attachments.fromJson(Map<String, dynamic> json) {
    isDeleted = json['isDeleted'];
    sId = json['_id'];
    name = json['name'];
    url = json['url'];
    creator = (json['creator'] != null
        ? new MemberModel.fromJson(json['creator'])
        : MemberModel());
    type = json['type'];
    mimeType = json['mimeType'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isDeleted'] = this.isDeleted;
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['url'] = this.url;
    if (this.creator != null) {
      data['creator'] = this.creator.toJson();
    }
    data['type'] = this.type;
    data['mimeType'] = this.mimeType;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
