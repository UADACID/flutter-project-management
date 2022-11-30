import 'card_model.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class MessageItemModel {
  late bool? isDeleted;
  late String sId;
  late String content;
  late Creator creator;
  late String createdAt;
  late String updatedAt;
  late String type;

  late String? name;
  late String? mimeType;
  late String? url;
  late types.CustomMessage customMessage;

  MessageItemModel(
      {this.isDeleted,
      required this.sId,
      required this.content,
      required this.creator,
      required this.createdAt,
      required this.updatedAt,
      required this.type,
      this.name,
      this.mimeType,
      this.url});

  MessageItemModel.fromJson(Map<String, dynamic> json) {
    isDeleted = json['isDeleted'] == null ? false : json['isDeleted'];
    sId = json['_id'];
    content = json['content'] ?? '';
    creator = (json['creator'] != null
        ? new Creator.fromJson(json['creator'])
        : Creator());

    if (json['createdAt'].runtimeType == String) {
      createdAt = json['createdAt'];
    } else {
      createdAt = '';
    }
    if (json['updatedAt'].runtimeType == String) {
      createdAt = json['updatedAt'];
    } else {
      createdAt = '';
    }
    type = json['type'] ?? '';
    name = json['name'] ?? '';
    mimeType = json['mimeType'] ?? '';
    url = json['url'] ?? '';
    // for type image
    if (json['mimeType'] != null) {
      String _tempMime = json['mimeType'];
      if (_tempMime.contains('image')) {
        customMessage = types.CustomMessage(
            author: types.User(
                id: json['creator']['_id'],
                firstName: json['creator']['fullName'],
                imageUrl: json['creator']['photoUrl']),
            createdAt: DateTime.parse(json['createdAt']).millisecondsSinceEpoch,
            id: json['_id'],
            metadata: {
              'text': json['name'] ?? '',
              'size': 0,
              'path': json['url'] ?? '',
              'type': 'image'
            });
      } else {
        // print('type file');
        customMessage = types.CustomMessage(
            author: types.User(
                id: json['creator']['_id'],
                firstName: json['creator']['fullName'],
                imageUrl: json['creator']['photoUrl']),
            createdAt: DateTime.parse(json['createdAt']).millisecondsSinceEpoch,
            id: json['_id'],
            metadata: {
              'text': json['name'] ?? '',
              'extension': json['mimeType'] ?? '',
              'size': 0,
              'path': json['url'] ?? '',
              'type': 'file'
            });
      }
    } else {
      // print('type text');
      customMessage = types.CustomMessage(
          author: types.User(
              id: json['creator']['_id'],
              firstName: json['creator']['fullName'],
              imageUrl: json['creator']['photoUrl']),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          id: json['_id'],
          metadata: {'text': json['content'] ?? ''});
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['isDeleted'] = this.isDeleted;
    data['_id'] = this.sId;
    data['content'] = this.content;
    if (this.creator != null) {
      data['creator'] = this.creator.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['type'] = this.type;
    return data;
  }
}
