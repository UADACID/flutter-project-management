class MemberModel {
  late String defaultCompany;
  late String sId;
  late String googleId;
  late String email;
  late String fullName;
  late String photoUrl;
  late String bio;
  late String status;
  late String createdAt;
  late String updatedAt;
  late String appleId;

  MemberModel(
      {this.defaultCompany = '',
      this.sId = '',
      this.googleId = '',
      this.email = '',
      this.fullName = '',
      this.photoUrl = '',
      this.bio = '',
      this.status = '',
      this.createdAt = '',
      this.updatedAt = '',
      this.appleId = ''});

  MemberModel.fromJson(json) {
    if (json != null) {
      if (json['defaultCompany'] == null) {
        defaultCompany = '';
      } else {
        if (json['defaultCompany'].runtimeType == String) {
          defaultCompany = json['defaultCompany'];
        } else {
          defaultCompany = json['defaultCompany']['_id'];
        }
      }

      sId = json['_id'];
      googleId = json['appleId'] == null ? '' : json['appleId'];
      email = json['email'] == null ? '' : json['email'];
      fullName = json['fullName'] == null ? '' : json['fullName'];
      photoUrl = json['photoUrl'] == null ? '' : json['photoUrl'];
      bio = json['bio'] == null ? '' : json['bio'];
      status = json['status'] == null ? '' : json['status'];
      createdAt = json['createdAt'] == null ? '' : json['createdAt'];
      updatedAt = json['updatedAt'] == null ? '' : json['updatedAt'];
      appleId = json['appleId'] == null ? '' : json['appleId'];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['defaultCompany'] = this.defaultCompany;
    data['_id'] = this.sId;
    data['googleId'] = this.googleId;
    data['email'] = this.email;
    data['fullName'] = this.fullName;
    data['photoUrl'] = this.photoUrl;
    data['bio'] = this.bio;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['appleId'] = this.appleId;
    return data;
  }
}
