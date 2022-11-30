class LabelModel {
  late String sId;
  late String name;
  late ColorModel color;
  late String createdAt;
  late String updatedAt;

  LabelModel(
      {required this.sId,
      required this.name,
      required this.color,
      required this.createdAt,
      required this.updatedAt});

  LabelModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    color = (json['color'] != null
        ? new ColorModel.fromJson(json['color'])
        : ColorModel(name: 'default', sId: '99999'));
    createdAt = json['createdAt'] != null ? json['createdAt'] : '';
    updatedAt = json['updatedAt'] != null ? json['updatedAt'] : '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    if (this.color != null) {
      data['color'] = this.color.toJson();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class ColorModel {
  late String sId;
  late String name;

  ColorModel({required this.sId, required this.name});

  ColorModel.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    return data;
  }
}
