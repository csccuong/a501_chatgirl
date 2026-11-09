class UserModel {
  String? id;
  String? deviceId;
  String? firebaseUid;
  String? email;
  String? username;
  String? avatarUrl;
  int? gems;
  bool? isPremium;
  bool? isActive;
  String? createdAt;

  UserModel({
    this.id,
    this.deviceId,
    this.firebaseUid,
    this.email,
    this.username,
    this.avatarUrl,
    this.gems,
    this.isPremium,
    this.isActive,
    this.createdAt,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    deviceId = json['device_id'];
    firebaseUid = json['firebase_uid'];
    email = json['email'];
    username = json['username'];
    avatarUrl = json['avatar_url'];
    gems = json['gems'];
    isPremium = json['is_premium'];
    isActive = json['is_active'];
    createdAt = json['created_at'];
  }
}
