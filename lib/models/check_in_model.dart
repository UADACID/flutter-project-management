import 'card_model.dart';
import 'member_model.dart';

class CheckInModel {
  late Schedule schedule;
  List<MemberModel> subscribers = [];
  late String sId;
  late String title;
  late Creator creator;
  late String createdAt;
  late String updatedAt;
  late bool isPublic;

  CheckInModel(
      {required this.schedule,
      this.subscribers = const [],
      required this.sId,
      this.title = '',
      required this.creator,
      this.createdAt = '',
      this.updatedAt = '',
      required this.isPublic});

  CheckInModel.fromJson(Map<String, dynamic> json) {
    schedule = (json['schedule'] != null
        ? new Schedule.fromJson(json['schedule'])
        : Schedule());
    if (json['subscribers'] != null) {
      subscribers = <MemberModel>[];
      json['subscribers'].forEach((v) {
        subscribers.add(new MemberModel.fromJson(v));
      });
    }
    sId = json['_id'];
    title = json['title'];
    isPublic = json['isPublic'];
    if (json['creator'] != null) {
      if (json['creator'].runtimeType == String) {
        creator = Creator(sId: (json['creator']));
      } else {
        new Creator.fromJson(json['creator']);
      }
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.schedule != null) {
      data['schedule'] = this.schedule.toJson();
    }
    if (this.subscribers != null) {
      data['subscribers'] = this.subscribers.map((v) => v.toJson()).toList();
    }
    data['_id'] = this.sId;
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
