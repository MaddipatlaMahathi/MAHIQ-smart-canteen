class UserModel {
  final String userId;
  final String name;
  final String email;
  final bool isAdmin;
  final String? canteenId;

  UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.canteenId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      userId: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      isAdmin: map['isAdmin'] ?? false,
      canteenId: map['canteenId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'isAdmin': isAdmin,
      'canteenId': canteenId,
    };
  }
}
