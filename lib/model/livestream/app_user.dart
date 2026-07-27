class AppUser {
  int? userId;
  String? username;
  String? fullname;
  String? profile;
  int? isVerify;
  String? firebaseUid;

  AppUser(
      {this.userId, this.username, this.fullname, this.profile, this.isVerify, this.firebaseUid});

  AppUser.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    username = json['username'];
    fullname = json['fullname'];
    profile = json['profile'];
    isVerify = json['is_verify'];
    firebaseUid = json['firebase_uid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['user_id'] = userId;
    data['username'] = username;
    data['fullname'] = fullname;
    data['profile'] = profile;
    data['is_verify'] = isVerify;
    data['firebase_uid'] = firebaseUid;
    return data;
  }
}
