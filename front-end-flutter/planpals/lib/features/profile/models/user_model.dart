class PPUser {
  final String id;
  final String userName;
  final String preferredName;
  final String? email;
  final String? password;

  PPUser({
    required this.id,
    required this.userName,
    required this.preferredName,
    this.email,
    this.password,
  });

  factory PPUser.fromJson(Map<String, dynamic> json) {
    PPUser user = PPUser(
      id: json['_id'],
      userName: json['userName'],
      preferredName: json['preferredName'],
    );
    print(user);
    return user;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userName': userName,
      'preferredName': preferredName,
    };
  }

  @override
  String toString() {
    return 'User{id: $id, userName: $userName, preferredName: $preferredName}';
  }
}
