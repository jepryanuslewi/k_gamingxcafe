class UserModel {
  final int? id;
  final String username;
  final String role;
  final String? createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.role,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'],
    username: map['username'],
    role: map['role'],
    createdAt: map['created_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'role': role,
    'created_at': createdAt,
  };
}
